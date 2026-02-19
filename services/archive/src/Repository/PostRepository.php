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
        // $term = trim($s);
        // Normalize term before comparison (trimming and handling accents + case)
        $transliterator = \Transliterator::create('Any-Lower; Any-Latin; Latin-ASCII;');
        // print_r(\Transliterator::listIDs());
        // die;
        // $term = $transliterator->transliterate(trim($s));
        // $term = strtolower(trim($s));
        $term = $this->normalizeSearchTerm($s);
        $len = mb_strlen($term);

        // IF term is less than 3 characters long, we do
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
                    t.title LIKE :term
                    OR p.content LIKE :term
                    OR p.author LIKE :term
                    OR p.place LIKE :term
                LIMIT 50
            ');

            $stmt->execute(['term' => "%$term%"]);

            return $stmt->fetchAll(\PDO::FETCH_ASSOC);

        // ELSE, if term is 3 characters long or more,
        // we go brr brr Levenshtein on the FTS trigrams.
        } else {
            $trigrams = [];
            for ($i = 0; $i < $len - 2; ++$i) {
                $trigrams[] = '"' . mb_substr($term, $i, 3) . '"';
            }

            $searchQuery = implode(' OR ', $trigrams);

            $stmt = $this->db->pdo->prepare("
                SELECT
                    topic_title, post_content, author, place,
                    snippet(search_index, -1, '', '', '...', 15) as matching_context
                FROM search_index
                WHERE search_index MATCH ?
                ORDER BY rank
                LIMIT 50
            ");

            $stmt->execute([$searchQuery]);
            $results = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            usort($results, function($a, $b) use ($term, $transliterator) {
                // Function to find best word in snippet
                // $getBestDist = function($snippet) use ($term, $transliterator): int {
                //     if (!$snippet) {
                //         return 255;
                //     }

                //     // Cut into words, ignoring punctuation
                //     $words = preg_split('/[\s\p{P}]+/u', $snippet);
                //     $bestDist = 255;

                //     foreach ($words as $word) {
                //         if ($word === '') {
                //             continue;
                //         }
                //         $dist = levenshtein($term, $transliterator->transliterate($word));
                //         if ($dist < $bestDist) {
                //             $bestDist = $dist;
                //         }
                //     }

                //     return $bestDist;
                // };

                // $distA = $getBestDist($a['matching_context']);
                // $distB = $getBestDist($b['matching_context']);

                $distA = levenshtein($term, $this->normalizeSearchTerm($a['matching_context']));
                $distB = levenshtein($term, $this->normalizeSearchTerm($b['matching_context']));

                return $distA <=> $distB;
            });

           return $results;
        }
    }

    private function normalizeSearchTerm(string $term): string
    {
        $s = trim($term);
        $s = mb_strtolower($s);
        // $s = \Normalizer::normalize($s, \Normalizer::FORM_D);
        // $s = preg_replace('/\pM/u', '', $s);

        return $s;
    }
}
