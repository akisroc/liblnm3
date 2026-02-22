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

    public function search(string $term): array
    {
        // 1. On interroge Spellfix1 pour corriger le mot ou trouver des variations
        $stmtSpell = $this->db->pdo->prepare("
            SELECT word
            FROM vocab
            WHERE word MATCH ? AND distance <= 2
            ORDER BY distance, score DESC
            LIMIT 5
        ");
        $stmtSpell->execute([$term]);
        $validWords = $stmtSpell->fetchAll(\PDO::FETCH_COLUMN);

        if (empty($validWords)) {
            return []; // Mot introuvable, même avec fautes
        }

        // 2. On reconstruit une requête pour FTS5 avec les mots corrigés
        // Ex: "harkka" OR "harkas"
        $ftsQuery = implode(' OR ', $validWords);

        // 3. On exécute la recherche texte standard
        $stmtFts = $this->db->pdo->prepare("
            SELECT topic_title, post_content, author, place
            FROM search_index
            WHERE search_index MATCH ?
            ORDER BY rank
            LIMIT 50
        ");

        $stmtFts->execute([$ftsQuery]);
        return $stmtFts->fetchAll(\PDO::FETCH_ASSOC);
    }

    // public function search(string $s): array
    // {
    //     // Normalize term before comparison (trimming and handling accents + case)
    //     $transliterator = \Transliterator::createFromRules(':: Any-Latin; :: Latin-ASCII; :: NFD; :: [:Nonspacing Mark:] Remove; :: Lower(); :: NFC;', \Transliterator::FORWARD);
    //     $term = $transliterator->transliterate($s);
    //     $len = mb_strlen($term);

    //     // IF term is less than 3 characters long, we do
    //     // a simple LIKE fulltext search.
    //     if ($len < 3) {
    //         $stmt = $this->db->pdo->prepare('
    //             SELECT
    //                 t.title as topic_title,
    //                 p.content as post_content,
    //                 p.author,
    //                 p.place
    //             FROM posts p
    //             LEFT JOIN topics t ON p.topic_id = t.id
    //             WHERE
    //                 t.title LIKE :term
    //                 OR p.content LIKE :term
    //                 OR p.author LIKE :term
    //                 OR p.place LIKE :term
    //             LIMIT 50
    //         ');

    //         $stmt->execute(['term' => "%$term%"]);

    //         return $stmt->fetchAll(\PDO::FETCH_ASSOC);

    //     // ELSE, if term is 3 characters long or more,
    //     // we go brr brr Levenshtein on the FTS trigrams.
    //     } else {
    //         $trigrams = [];
    //         for ($i = 0; $i < $len - 2; ++$i) {
    //             $trigrams[] = '"' . mb_substr($term, $i, 3) . '"';
    //         }

    //         $searchQuery = implode(' OR ', $trigrams);

    //         $stmt = $this->db->pdo->prepare("
    //             SELECT
    //                 topic_title, post_content, author, place,
    //                 snippet(search_index, -1, '', '', '...', 15) as matching_context
    //             FROM search_index
    //             WHERE search_index MATCH ?
    //             ORDER BY rank
    //             LIMIT 50
    //         ");

    //         $stmt->execute([$searchQuery]);
    //         $results = $stmt->fetchAll(\PDO::FETCH_ASSOC);

    //         usort($results, function($a, $b) use ($term, $transliterator) {
    //             // Function to find best word in snippet
    //             // $distA = levenshtein($term, $transliterator->transliterate($a['matching_context']));
    //             // $distB = levenshtein($term, $transliterator->transliterate($b['matching_context']));

    //             $getBestDist = function($row) use ($term, $transliterator) {
    //                 $fullText = $row['topic_title'] . ' ' . $row['post_content'] . ' ' . $row['author'] . ' ' . $row['place'] . ' ' . $row['matching_context'];
    //                 $words = preg_split('/[\s\p{P}]+/u', $fullText);
    //                 $bestDist = 255;

    //                 foreach ($words as $word) {
    //                     if ($word === '') continue;

    //                     $dist = levenshtein($term, $transliterator->transliterate($word));

    //                     if ($dist === 0) return 0; // Perfect match
    //                     if ($dist < $bestDist) $bestDist = $dist;
    //                 }
    //                 return $bestDist;
    //             };

    //             return $getBestDist($a) <=> $getBestDist($b);
    //         });

    //        return $results;
    //     }
    // }
}
