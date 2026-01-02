<?php

declare(strict_types=1);

namespace App\DataFixtures\Dev;

use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;
use Symfony\Component\PasswordHasher\Hasher\SodiumPasswordHasher;

class UserFixtures extends Fixture
{
    public const int COUNT = 30;

    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create();

        $hasher = new SodiumPasswordHasher();

        $user = new User();
        $user->username = 'adrien';
        $user->email = $faker->unique()->safeEmail();
        $user->password = $hasher->hash('adrien');
        $user->roles = ['ROLE_USER', 'ROLE_GM', 'ROLE_ADMIN'];
        $this->setReference('user_admin', $user);
        $manager->persist($user);

        for ($i = 0; $i < self::COUNT; ++$i) {
            $user = new User();

            $user->username = $faker->unique()->firstName;
            $user->email = $faker->unique()->safeEmail;
            $user->password = $hasher->hash(
                $faker->password(8, 100)
            );
            $user->addRoles(['ROLE_USER']);
            $user->isEnabled = $faker->boolean(92);
            $user->profilePicture = $faker->imageUrl();

            $this->setReference("user_$i", $user);
            $manager->persist($user);
        }

        $manager->flush();
    }
}
