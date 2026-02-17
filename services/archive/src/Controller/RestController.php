<?php

namespace App\Controller;

use App\Repository\PostRepository;
use App\Service\Database;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\Exception\BadRequestException;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\ResponseHeaderBag;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Routing\Attribute\Route;
use Twig\Environment;
use App\Repository\TopicRepository;

final class RestController
{
    /**
     * Todo: change before prod deploy
     * 6 months
     * Archive data is static and eternal anyway
     */
    // private const int RESPONSES_MAX_AGE = 60 * 60 * 24 * 30 * 6;
    private const int RESPONSES_MAX_AGE = 1;


    #[Route("/topics", name: "topics.list", methods: ["GET"])]
    public function topics(Environment $twig, TopicRepository $topicRepo): StreamedResponse
    {
        return new StreamedResponse()
            ->setPublic()
            ->setMaxAge(self::RESPONSES_MAX_AGE)
            ->setSharedMaxAge(self::RESPONSES_MAX_AGE)
            ->setCallback(function () use ($twig, $topicRepo) {
                $twig->display('rest/topics.html.twig', [
                    'topics' => $topicRepo->streamList()
                ]);
            })
        ;
    }

    #[Route("/topics/{id}", name: "topics.view", methods: ["GET"])]
    public function topic(Environment $twig, TopicRepository $topicRepo, string $id): StreamedResponse
    {
        $topic = $topicRepo->fetchOne($id);
        if (!$topic) {
            throw new NotFoundHttpException();
        }

        return new StreamedResponse()
            ->setPublic()
            ->setMaxAge(self::RESPONSES_MAX_AGE)
            ->setSharedMaxAge(self::RESPONSES_MAX_AGE)
            ->setCallback(function () use ($twig, $topicRepo, $topic) {
                $twig->display('rest/topic.html.twig', [
                    'topic' => $topic,
                    'posts' => $topicRepo->streamPosts($topic->id)
                ]);
            })
        ;
    }

    #[Route("/posts", name: "posts.list", methods: ["GET"])]
    public function posts(
        Request $request,
        Environment $twig,
        PostRepository $postRepo
    ): StreamedResponse {
        $onlyOrphansParam = $request->query->get("without_topic");
        $onlyOrphans = filter_var(
            $onlyOrphansParam,
            \FILTER_VALIDATE_BOOLEAN,
            \FILTER_NULL_ON_FAILURE,
        );

        if ($onlyOrphansParam !== null && $onlyOrphans === null) {
            throw new BadRequestException(
                "The “only_orphans” query parameter must be a valid boolean. \
                Possible values: “1”, “true”, “on”, “yes”, “0”, “false”, “off”, “no”. \
                “{$onlyOrphansParam}” given."
            );
        }

        return new StreamedResponse()
            ->setPublic()
            ->setMaxAge(self::RESPONSES_MAX_AGE)
            ->setSharedMaxAge(self::RESPONSES_MAX_AGE)
            ->setCallback(function () use ($twig, $postRepo, $onlyOrphans) {
                $twig->display('rest/posts.html.twig', [
                    'posts' => $postRepo->streamList($onlyOrphans)
                ]);
            })
        ;
    }

    #[Route(
        "posts/search/{s}",
        name: "posts.search",
        methods: ["GET"]
    )]
    public function posts_search(
        string $s,
        Environment $twig,
        PostRepository $postRepo
    ): StreamedResponse
    {
        return new StreamedResponse()
            ->setPublic()
            ->setMaxAge(self::RESPONSES_MAX_AGE)
            ->setSharedMaxAge(self::RESPONSES_MAX_AGE)
            ->setCallback(function () use ($s, $twig, $postRepo) {
                $twig->display('rest/posts-search-results.html.twig', [
                    'posts' => $postRepo->streamSearch($s)
                ]);
            })
        ;
    }

    #[Route("/authors", name: "authors.list", methods: ["GET"])]
    public function authors(Environment $twig, PostRepository $postRepo): StreamedResponse
    {
        return new StreamedResponse()
            ->setPublic()
            ->setMaxAge(self::RESPONSES_MAX_AGE)
            ->setSharedMaxAge(self::RESPONSES_MAX_AGE)
            ->setCallback(function () use ($twig, $postRepo) {
                $twig->display('rest/authors.html.twig', [
                    'authors' => $postRepo->streamAuthors()
                ]);
            })
        ;
    }

    #[Route("/places", name: "places.list", methods: ["GET"])]
    public function places(Environment $twig, PostRepository $postRepo): StreamedResponse
    {
        return new StreamedResponse()
            ->setPublic()
            ->setMaxAge(self::RESPONSES_MAX_AGE)
            ->setSharedMaxAge(self::RESPONSES_MAX_AGE)
            ->setCallback(function () use ($twig, $postRepo) {
                $twig->display('rest/places.html.twig', [
                    'places' => $postRepo->streamPlaces()
                ]);
            })
        ;
    }

    #[Route("/races", name: "races.list", methods: ["GET"])]
    public function races(Environment $twig): Response
    {
        $html = $twig->render('rest/races.html.twig', [
            'races' => [
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
            ]
        ]);

        return new Response($html)
            ->setPublic()
            ->setMaxAge(self::RESPONSES_MAX_AGE)
            ->setSharedMaxAge(self::RESPONSES_MAX_AGE)
        ;
    }

    #[Route("/downloads/database", name: "downloads.database", methods: ["GET"])]
    public function downloadDatabase(
        #[Autowire('%app.db_path%')] string $dbPath,
        Database $db
    ): BinaryFileResponse {
        $db->pdo->exec('PRAGMA wal_checkpoint(FULL);');

        return new BinaryFileResponse(
            file: $dbPath,
            headers: ['Content-Type' => 'application/vnd.sqlite3'],
            contentDisposition: ResponseHeaderBag::DISPOSITION_ATTACHMENT
        );
    }
}
