<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\StreamedJsonResponse;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\ResponseHeaderBag;
use Symfony\Component\HttpKernel\Attribute\MapQueryParameter;
use Symfony\Component\Routing\Attribute\Route;
use Psr\Log\LoggerInterface;
use App\Service\Database;
use App\Schema\Topic;
use App\Schema\Post;

/**
 * Todo: Might consider using a query builder when
 * more precise filters will be required by frontend.
 * Maybe https://github.com/usmanhalalit/pixie .
 */ 
class ApiController extends AbstractController
{
    /**
     *  6 months
     * Archive data is static and eternal anyway
     */
    private const int RESPONSES_MAX_AGE = 60 * 60 * 24 * 30 * 6;

    public function __construct(
        private readonly Database $db
    ) {}

    #[Route('/ping', name: 'ping', methods: ['GET'])]
    public function ping(): Response
    {
        return new Response('', 204);
    }

    #[Route('/health', name: 'health', methods: ['GET'])]
    public function health(LoggerInterface $logger): JsonResponse
    {
        try {
            $this->db->pdo->exec('SELECT 1');
            return new JsonResponse([
                'status' => 'ok',
                'database' => 'connected'
            ], 200);
        } catch(\Exception $e) {
            $logger->error($e->getMessage());
            return new JsonResponse([
                'status' => 'error',
                'database' => 'unreachable'
            ], 503);
        }
    }

    #[Route('/topics', name: 'topics.list', methods: ['GET'])]
    public function topics(): StreamedJsonResponse
    {
        $generator = function () {
            $stmt = $this->db->pdo->query(
                "SELECT
                t.id,
                t.title,
                GROUP_CONCAT(DISTINCT p.author) AS authors,
                MAX(p.created_at) AS lastPostDate
                FROM topics t
                INNER JOIN posts p ON t.id = p.topic_id
                GROUP BY t.id
                ORDER BY lastPostDate DESC"
            );
            $stmt->setFetchMode(\PDO::FETCH_CLASS, Topic::class);

            yield from $stmt;
        };

        return $this->createStreamedResponse($generator());
    }

    #[Route('/topics/{id}', name: 'topics.view', methods: ['GET'])]
    public function topic(string $id): JsonResponse | StreamedJsonResponse
    {
        $stmt = $this->db->pdo->prepare(
            'SELECT id, title FROM topics WHERE id = ?'
        );
        $stmt->execute([$id]);
        $stmt->setFetchMode(\PDO::FETCH_CLASS, Topic::class);
        $topic = $stmt->fetch();

        if ($topic === false) {
            return new JsonResponse([
                'message' => "No topic found for id “{$id}”"
            ], 404);
        }

        $generator = function () use ($id) {
            $stmt = $this->db->pdo->prepare(
                'SELECT id, topic_id AS topicId, position, author, content, created_at AS createdAt
                FROM posts
                WHERE topicId = ?
                ORDER BY createdAt ASC'
            );
            $stmt->setFetchMode(\PDO::FETCH_CLASS, Post::class);
            $stmt->execute([$id]);

            yield from $stmt;
        };

        return $this->createStreamedResponse([
            'id' => $topic->id,
            'title' => $topic->title,
            'posts' => $generator()
        ]);
    }

    #[Route('/posts', name: 'posts.list', methods: ['GET'])]
    public function posts(Request $request): StreamedJsonResponse | JsonResponse {
        $withoutTopicParam = $request->query->get('without_topic');
        $withoutTopic = filter_var(
            $withoutTopicParam,
            \FILTER_VALIDATE_BOOLEAN,
            \FILTER_NULL_ON_FAILURE
        );

        if ($withoutTopicParam !== null && $withoutTopic === null) {
            return $this->createErrorResponse(
                message: "The “without_topic” query parameter must be a valid boolean. Possible values: “1”, “true”, “on”, “yes”, “0”, “false”, “off”, “no”. “{$withoutTopicParam}” given.",
                httpCode: 400
            );
        }

        $generator = function () use ($withoutTopic): iterable {
            $sql = '
                SELECT id, topic_id AS topicId, place, author, content, created_at AS createdAt
                FROM posts
            ';

            if ($withoutTopic === true) {
                $sql .= ' WHERE topicId IS NULL';
            }

            $stmt = $this->db->pdo->query($sql);
            $stmt->setFetchMode(\PDO::FETCH_CLASS, Post::class);

            yield from $stmt;
        };

        return $this->createStreamedResponse($generator());
    }

    #[Route('/authors', name: 'authors.list', methods: ['GET'])]
    public function authors(): StreamedJsonResponse
    {
        $generator = function (): iterable {
            $stmt = $this->db->pdo->query(
                'SELECT DISTINCT author
                FROM posts
                WHERE author IS NOT NULL
                ORDER BY author ASC'
            );
            $stmt->setFetchMode(\PDO::FETCH_COLUMN, 0);

            yield from $stmt;
        };

        return $this->createStreamedResponse($generator());
    }

    #[Route('/places', name: 'places.list', methods: ['GET'])]
    public function places(): StreamedJsonResponse
    {
        $generator = function (): iterable {
            $stmt = $this->db->pdo->query(
                'SELECT DISTINCT place
                FROM posts
                WHERE place IS NOT NULL
                ORDER BY place ASC'
            );
            $stmt->setFetchMode(\PDO::FETCH_COLUMN, 0);

            yield from $stmt;
        };

        return $this->createStreamedResponse($generator());
    }

    #[Route('/races', name: 'races.list', methods: ['GET'])]
    public function races(): JsonResponse
    {
        return $this->createStaticResponse([
            'Arakkoas',
            'Damnés',
            'Dragoons',
            'Elfes sylvains',
            'Golems',
            'Humains',
            'Morts-vivants',
            'Naggas',
            'Nains',
            'Nordiques',
            'Orcs',
            'Skavens'
        ]);
    }

    #[Route('/downloads/database', name: 'downloads.database', methods: ['GET'])]
    public function downloadDatabase(
        #[Autowire('%app.db_path%')] string $dbPath
    ): BinaryFileResponse {
        $this->db->pdo->exec('PRAGMA wal_checkpoint(FULL);');

        return new BinaryFileResponse($dbPath, ResponseHeaderBag::DISPOSITION_ATTACHMENT);
    }

    private function createStreamedResponse(iterable $data): StreamedJsonResponse
    {
        $response = new StreamedJsonResponse($data);
        $response->setPublic();
        $response->setMaxAge(self::RESPONSES_MAX_AGE);
        $response->setSharedMaxAge(self::RESPONSES_MAX_AGE);

        return $response;
    }

    private function createStaticResponse(iterable $data): JsonResponse
    {
        $response = new JsonResponse($data);
        $response->setPublic();
        $response->setMaxAge(self::RESPONSES_MAX_AGE);
        $response->setSharedMaxAge(self::RESPONSES_MAX_AGE);

        return $response;
    }

    private function createErrorResponse(string $message, int $httpCode): JsonResponse
    {
        return new JsonResponse(['message' => $message], $httpCode);
    }
}
