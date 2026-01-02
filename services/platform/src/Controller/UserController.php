<?php

declare(strict_types=1);

namespace App\Controller;

use App\Repository\UserRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;

class UserController extends AbstractController
{
    #[Route('/users', name: 'users.index', methods: ['GET'])]
    public function index(UserRepository $userRepository, Request $req): JsonResponse
    {
        $selects = ['id', 'username', 'slug', 'profile_picture', 'is_enabled', 'created_at'];
        if ($this->isGranted('ROLE_ADMIN')) {
            $selects = array_merge($selects, ['email', 'roles', 'updated_at']);
        }

        $limit = 10;
        if ($req->query->getInt('limit')) {
            $queryLimit = $req->query->getInt('limit');
            if ($queryLimit < 100 && $queryLimit > 0) {
                $limit = $queryLimit;
            }
        }

        $users = $userRepository->getList(
            $selects,
            $req->query->getInt('offset'),
            $limit
        );

        return new JsonResponse($users);
    }
}
