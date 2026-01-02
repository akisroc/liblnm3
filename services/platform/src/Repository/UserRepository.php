<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\User;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

class UserRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, User::class);
    }

    public function getList(
        array $selects,
        ?int $offset = null,
        ?int $limit = null,
        string $order = 'DESC'
    ): array
    {
        $qb = $this->getEntityManager()->getConnection()->createQueryBuilder();
        $qb->from('users');
        foreach ($selects as $select) {
            $qb->addSelect($select);
        }

        if ($offset !== null) {
            $qb->setFirstResult($offset);
        }
        if ($limit !== null) {
            $qb->setMaxResults($limit);
        }
        $qb->orderBy('created_at', $order);

        return $qb->fetchAllAssociative();
    }
}
