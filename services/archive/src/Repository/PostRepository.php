<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\Post;
use App\Service\Database;

final readonly class PostRepository
{
    public function __construct(private Database $db) {}

    public function streamList(bool $onlyOrphans): \Generator
    {
        $sql = '
            SELECT id, topic_id AS topicId, place, author, content, created_at AS createdAt
            FROM posts
        ';

        if ($onlyOrphans === true) {
            $sql .= ' WHERE topicId IS NULL';
        }

        $stmt = $this->db->pdo->query($sql);
        $stmt->setFetchMode(\PDO::FETCH_CLASS, Post::class);

        yield from $stmt;
    }

    public function streamAuthors(): \Generator
    {
        $stmt = $this->db->pdo->query(
            'SELECT DISTINCT author
            FROM posts
            WHERE author IS NOT NULL
            ORDER BY author ASC'
        );

        $stmt->setFetchMode(\PDO::FETCH_COLUMN, 0);

        yield from $stmt;
    }

    public function streamPlaces(): \Generator
    {
        $stmt = $this->db->pdo->query(
            'SELECT DISTINCT place
            FROM posts
            WHERE place IS NOT NULL
            ORDER BY place ASC',
        );
        $stmt->setFetchMode(\PDO::FETCH_COLUMN, 0);

        yield from $stmt;
    }

    public function streamSearch(string $s): \Generator
    {
        $stmt = $this->db->pdo->prepare(
            'SELECT * FROM search_index
            WHERE search_index MATCH ?
            ORDER BY rank'
        );

        $stmt->setFetchMode(\PDO::FETCH_ASSOC);
        $stmt->execute([$s]);

        yield from $stmt;
    }
}
