<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;
use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity]
#[ORM\Table(name: 'kingdoms')]
#[UniqueEntity('name', message: 'violation.name.not_unique')]
class Kingdom extends AbstractEntity
{
    #[ORM\Column(type: 'string', length: 31, unique: true, nullable: false)]
    #[Assert\NotBlank(message: 'violation.name.blank')]
    #[Assert\Regex(
        pattern: '/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ\'’\-]+$/',
        message: 'violation.name.invalid_characters',
    )]
    #[Assert\Length(
        min: 1,
        max: 30,
        minMessage: 'violation.name.too_short',
        maxMessage: 'violation.name.too_long'
    )]
    public ?string $name = null;

    #[ORM\Column(type: 'float', nullable: false)]
    #[Assert\NotBlank(message: 'violation.fame.blank')]
    #[Assert\PositiveOrZero(message: 'violation.fame.negative')]
    public float $fame = 30000.0;

    #[ORM\OneToOne(targetEntity: 'User', inversedBy: 'kingdom')]
    #[ORM\JoinColumn(nullable: false)]
    #[Gedmo\Blameable(on: 'create')]
    public ?User $user = null;

    public function __toString(): string
    {
        return $this->name;
    }
}
