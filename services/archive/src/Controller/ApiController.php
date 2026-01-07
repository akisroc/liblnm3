<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\StreamedJsonResponse;
use Symfony\Component\HttpKernel\Attribute\MapQueryParameter;
use Symfony\Component\Routing\Attribute\Route;
use App\Service\Database;

class ApiController extends AbstractController
{
    public function __construct(private Database $db) {}

    #[Route('/topics', name: 'topics.list', methods: ['GET'])]
    public function topics(): StreamedJsonResponse
    {
        $generator = function () {
            $stmt = $this->db->pdo->query(
                "SELECT
                t.id,
                t.title,
                REPLACE(GROUP_CONCAT(DISTINCT p.author), ',', ', ') AS authors,
                MAX(p.created_at) AS last_post_date
                FROM topics t
                INNER JOIN posts p ON t.id = p.topic_id
                GROUP BY t.id
                ORDER BY last_post_date DESC"
            );

            while ($topic = $stmt->fetch()) {
                yield $topic;
            }
        };

        return new StreamedJsonResponse($generator());
    }

    #[Route('/topics/{id}', name: 'topics.view', methods: ['GET'])]
    public function topic(string $id): JsonResponse
    {
        $stmt = $this->db->pdo->prepare(
            'SELECT id, title FROM topics WHERE id = ?'
        );
        $stmt->execute([$id]);
        $topic = $stmt->fetch();

        $stmt = $this->db->pdo->prepare(
            'SELECT id, topic_id, position, author, content, created_at
            FROM posts
            WHERE topic_id = ?
            ORDER BY created_at ASC'
        );
        $stmt->execute([$id]);
        $posts = $stmt->fetchAll();

        if ($topic === false) {
            return new JsonResponse([
                'message' => "No topic found for id “{$id}”"
            ], 404);
        }

        if (empty($posts)) {
            return new JsonResponse([
                'message' => "No post found for topic with id “{$id}”"
            ], 404);
        }

        return new JsonResponse([
            'id' => $topic['id'],
            'title' => $topic['title'],
            'posts' => $posts
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
            return new JsonResponse([
                'message' => "The “without_topic” query parameter must be a valid boolean. Possible values: “1”, “true”, “on”, “yes”, “0”, “false”, “off”, “no”. “{$withoutTopicParam}” given."
            ], 400);
        }

        $generator = function () use (&$withoutTopic): iterable {
            $sql = '
                SELECT id, topic_id, place, author, content, created_at
                FROM posts
            ';

            if ($withoutTopic === true) {
                $sql .= ' WHERE topic_id IS NULL';
            }

            $stmt = $this->db->pdo->query($sql);

            while ($post = $stmt->fetch()) {
                yield $post;
            }
        };

        return new StreamedJsonResponse($generator());
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

            while ($author = $stmt->fetch(\PDO::FETCH_COLUMN)) {
                yield $author;
            }
        };

        return new StreamedJsonResponse($generator());
    }

    #[Route('/downloads/database', name: 'downloads.database', methods: ['GET'])]
    public function downloadDatabase(
        #[Autowire('%app.db_path%')] string $dbPath
    ): BinaryFileResponse {
        return new BinaryFileResponse($dbPath);
    }
}
