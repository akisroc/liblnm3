<?php

declare(strict_types=1);

namespace App\Iam\Entity;

final class User
{
    public function __construct(
        public readonly string $id,
        public private(set) string $nickname,
        public private(set) string $email,
        public private(set) string $password,
        public private(set) ?string $profilePicture = null,
        public private(set) string $slug,
        /** @var [string] */
        public private(set) array $roles,
        public private(set) string $platformTheme,
        public private(set) bool $isEnabled,
        public private(set) bool $isRemoved,
        public readonly \DateTimeImmutable $createdAt,
        public private(set) \DateTime $updatedAt,
    ) { }
}
