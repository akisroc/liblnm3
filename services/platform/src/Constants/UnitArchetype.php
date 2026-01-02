<?php

declare(strict_types=1);

namespace App\Constants;

final readonly class UnitArchetype
{
    private function __construct(
        public int $id,
        public float $power,
        public float $defense,
        public float $speed,
        public float $killRate,
        public float $fameStealRate,
        public bool $isDistance,
        public float $fameCost
    ) {}

    public static function B1(): self
    {
        return new self(
            id: 1,
            power: 4.0,
            defense: 7.0,
            speed: 85.0,
            killRate: 4.0 / 7.0,
            fameStealRate: 6.0,
            isDistance: false,
            fameCost: 2.86
        );
    }

    public static function B2(): self
    {
        return new self(
            id: 2,
            power: 3.0,
            defense: 5.0,
            speed: 86.0,
            killRate: 3.0 / 5.0,
            fameStealRate: 2.0,
            isDistance: true,
            fameCost: 3.14
        );
    }

    public static function B3(): self
    {
        return new self(
            id: 3,
            power: 5.0,
            defense: 9.0,
            speed: 95.0,
            killRate: 5.0 / 9.0,
            fameStealRate: 3.0,
            isDistance: false,
            fameCost: 4.5
        );
    }

    public static function B4(): self
    {
        return new self(
            id: 4,
            power: 5.0,
            defense: 7.0,
            speed: 84.0,
            killRate: 5.0 / 7.0,
            fameStealRate: 2.0,
            isDistance: true,
            fameCost: 5.33
        );
    }

    public static function B5(): self
    {
        return new self(
            id: 5,
            power: 18.0,
            defense: 8.0,
            speed: 80.0,
            killRate: 18.0 / 8.0,
            fameStealRate: 3.0,
            isDistance: false,
            fameCost: 7.2
        );
    }

    public static function B6(): self
    {
        return new self(
            id: 6,
            power: 10.0,
            defense: 7.0,
            speed: 98.0,
            killRate: 10.0 / 7.0,
            fameStealRate: 3.0,
            isDistance: true,
            fameCost: 8.0
        );
    }

    public static function B7(): self
    {
        return new self(
            id: 7,
            power: 24.0,
            defense: 16.0,
            speed: 88.0,
            killRate: 24.0 / 16.0,
            fameStealRate: 4.0,
            isDistance: false,
            fameCost: 12.0
        );
    }

    public static function B8(): self
    {
        return new self(
            id: 8,
            power: 19.0,
            defense: 13.0,
            speed: 90.0,
            killRate: 19.0 / 13.0,
            fameStealRate: 3.0,
            isDistance: true,
            fameCost: 13.25
        );
    }

    /**
     * @return array<self>
     */
    public static function ALL(): array
    {
        return [
            self::B1(), self::B2(), self::B3(), self::B4(),
            self::B5(), self::B6(), self::B7(), self::B8()
        ];
    }
}
