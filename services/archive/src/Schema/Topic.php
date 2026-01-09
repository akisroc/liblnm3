<?php

declare(strict_types=1);

namespace App\Schema;

final readonly class Topic implements \JsonSerializable
{
	public ?string $id;
	public ?string $title;
	public ?string $authors;
	public ?string $lastPostDate;

	/**
	 * This query has been checked:
	 * 
	 * ```sql
	 * SELECT COUNT(*) FROM posts WHERE author LIKE '%,%';
	 * ```
	 * 
	 * It returns 0, so we can safely explode on the `,` separator
	 * from `GROUP_CONCAT` as no author in the database has a comma
	 * in its name. 
	 */ 
	public function jsonSerialize(): array {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'authors' => $this->authors ? explode(',', $this->authors) : [],
            'lastPostDate' => $this->lastPostDate,
        ];
    }
}
