<?php

declare(strict_types=1);

namespace App\DataFixtures\Dev;

use App\Entity\Kingdom;
use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Common\DataFixtures\DependentFixtureInterface;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;

class KingdomFixtures extends Fixture implements DependentFixtureInterface
{
    public const int COUNT = UserFixtures::COUNT;

    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create();

        for ($i = 0; $i < self::COUNT; ++$i) {
            $kingdom = new Kingdom();
            $kingdom->name = $faker->unique()->city();
            $kingdom->fame = 30000.0;
            $kingdom->user = $this->getReference("user_$i", User::class);

            $this->setReference("kingdom_$i", $kingdom);
            $manager->persist($kingdom);
        }

        $manager->flush();
    }

    public function getDependencies(): array
    {
        return [
            UserFixtures::class
        ];
    }
}
