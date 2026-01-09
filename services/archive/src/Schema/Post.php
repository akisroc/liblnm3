<?php

declare(strict_types=1);

namespace App\Schema;

final readonly class Post
{
	public ?string $id;
	public ?string $topicId;
	public ?string $place;
	public ?int $position;
	public ?string $author;
	public ?string $content;
	public ?string $createdAt;
}
