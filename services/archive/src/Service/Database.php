<?php

declare(strict_types=1);

namespace App\Service;

use Symfony\Component\HttpKernel\KernelInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;

final readonly class Database
{
	public \PDO $pdo;

	public function __construct(
		#[Autowire('%app.db_path%')] string $dbPath
	) {
		$this->pdo = new \PDO('sqlite:' . $dbPath);
		$this->pdo->setAttribute(\PDO::ATTR_ERRMODE, \PDO::ERRMODE_EXCEPTION);
		$this->pdo->setAttribute(\PDO::ATTR_DEFAULT_FETCH_MODE, \PDO::FETCH_ASSOC);
	}
}
