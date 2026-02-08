<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\Post;
use App\Service\Database;
use App\Entity\Topic;

final readonly class TopicRepository
{
    public function __construct(private Database $db) {}

    public function streamList(): \Generator
    {
        $stmt = $this->db->pdo->query(
            'SELECT t.id, t.title,
            GROUP_CONCAT(DISTINCT p.author) AS authors,
            MAX(p.created_at) AS lastPostDate
            FROM topics t
            INNER JOIN posts p ON t.id = p.topic_id
            GROUP BY t.id
            ORDER BY lastPostDate DESC',
        );

        $stmt->setFetchMode(\PDO::FETCH_CLASS, Topic::class);

        yield from $stmt;
    }

    public function fetchOne(string $id): ?Topic
    {
        $stmt = $this->db->pdo->prepare(
            'SELECT id, title FROM topics WHERE id = ?',
        );
        $stmt->execute([$id]);
        $stmt->setFetchMode(\PDO::FETCH_CLASS, Topic::class);
        $topic = $stmt->fetch();

        return $topic ?: null;
    }

    public function streamPosts(string $topicId): \Generator
    {
        $stmt = $this->db->pdo->prepare(
            'SELECT id, topic_id AS topicId, position, author, content, created_at AS createdAt
            FROM posts
            WHERE topicId = ?
            ORDER BY createdAt ASC'
        );

        $stmt->setFetchMode(\PDO::FETCH_CLASS, Post::class);
        $stmt->execute([$topicId]);

        yield from $stmt;
    }
}
