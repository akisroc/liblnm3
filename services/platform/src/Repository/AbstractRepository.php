<?php

declare(strict_types=1);

namespace App\Repository;


use Doctrine\DBAL\Connection;
use Doctrine\ORM\EntityRepository;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;

abstract class AbstractRepository extends EntityRepository
{
    public function __construct(
        protected Connection $connection,
        protected TokenInterface $accessTokenHandler
    ) { }

    public function getList(
        string $from,
        array $selects,
        array $criterias = [],
        ?int $offset = null,
        ?int $limit = null,
        string $order = 'DESC'
    ): array
    {
        $qb = $this->connection->createQueryBuilder();
        $qb->from($from);
        foreach ($selects as $select) {
            $qb->addSelect($select);
        }

        if ($offset !== null) {
            $qb->setFirstResult($offset);
        }
        if ($limit !== null) {
            $qb->setMaxResults($limit);
        }
        $qb->orderBy($order);
    }
}
