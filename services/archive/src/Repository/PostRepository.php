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

    public function search(string $s): array
    {
        $term = trim($s);
        $len = mb_strlen($term);

        // IF term is less than 3 characters, we do
        // a simple LIKE fulltext search.
        if ($len < 3) {
            $stmt = $this->db->pdo->prepare('
                SELECT
                    t.title as topic_title,
                    p.content as post_content,
                    p.author,
                    p.place
                FROM posts p
                LEFT JOIN topics t ON p.topic_id = t.id
                WHERE
                    OR t.title LIKE :term
                    p.content LIKE :term
                    OR p.author LIKE :term
                    OR p.place LIKE :term
                LIMIT 50
            ');

            $stmt->execute(['term' => "%$term%"]);

            return $stmt->fetchAll(\PDO::FETCH_ASSOC);

        // ELSE, if term is more than 3 characters,
        // we go brr brr Levenshtein on the FTS trigrams.
        } else {
            $trigrams = [];
            for ($i = 0; $i < $len; ++$i) {
                $trigrams[] = '"' . substr($term, $i, 3) . '"';
            }

            $searchQuery = implode(' OR ', $trigrams);

            $stmt = $this->db->pdo->prepare(
                'SELECT
                    topic_title,
                    post_content,
                    author,
                    place
                FROM search_index
                WHERE search_index MATCH ?
                ORDER BY rank
                LIMIT 50'
            );

            $stmt->execute([$searchQuery]);
            $results = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            usort($results, function($a, $b) use ($term) {
                $textA = implode(' ', [
                    $a['topic_title'],
                    $a['post_content'],
                    $a['author'],
                    $a['place']
                ]);
                $textB = implode(' ', [
                    $b['topic_title'],
                    $b['post_content'],
                    $b['author'],
                    $b['place']
                ]);

                $distA = levenshtein($term, substr($textA, 0, 255));
                $distB = levenshtein($term, substr($textB, 0, 255));

                return $distA <=> $distB;
            });

            return $results;
        }
    }
}
