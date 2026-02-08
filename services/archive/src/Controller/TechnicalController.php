<?php

declare(strict_types=1);

namespace App\Controller;

use App\Service\Database;
use Psr\Log\LoggerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class TechnicalController extends AbstractController
{
    #[Route('/ping', name: 'ping', methods: ['GET'])]
    public function ping(): Response
    {
        return new Response('', 204);
    }

    #[Route('/health', name: 'health', methods: ['GET'])]
    public function health(LoggerInterface $logger, Database $db): JsonResponse
    {
        try {
            $db->pdo->exec('SELECT 1');
            return new JsonResponse([
                'status' => 'ok',
                'database' => 'connected',
            ], 200);
        } catch (\Exception $e) {
            $logger->error($e->getMessage());
            return new JsonResponse([
                'status' => 'error',
                'database' => 'unreachable',
            ], 503);
        }
    }
}
