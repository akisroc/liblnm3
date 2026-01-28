defmodule Platform.Roleplay.Core.LoreName.Archetype do
  defstruct [
    :identifier,
    :length_peak,
    :length_spread,
    :length_min,
    :length_max,
    :start_with_consonant_prob,
    :vowels,
    :consonants
  ]

  @type t :: %__MODULE__{
    identifier: atom(),
    length_peak: float(),
    length_spread: float(),
    length_min: non_neg_integer(),
    length_max: non_neg_integer(),
    start_with_consonant_prob: float(),
    vowels: [{[String.t()], non_neg_integer()}],
    consonants: [{[String.t()], non_neg_integer()}]
  }

  @sea %{
    identifier: :sea,
    length_peak: 5.0, length_spread: 2.0, length_min: 3, length_max: 8,
    start_with_consonant_prob: 0.5,
    vowels: [
      { ~w(a ë i y), 10 },
      { ~w(aa ei), 7 },
      { ~w(æ), 3 }
    ],
    consonants: [
      { ~w(z j l), 10 },
      { ~w(s), 7 },
      { ~w(ts ss zz sh), 3 },
      { ~w(z’ sh’j), 3 }
    ]
  }

  @swamp %{
    identifier: :swamp,
    length_peak: 9.0, length_spread: 3.5, length_min: 5, length_max: 12,
    start_with_consonant_prob: 0.9,
    vowels: [
      { ~w(a o é), 10 },
      { ~w(ou), 3 }
    ],
    consonants: [
      { ~w(b d g k p q r t h), 40 },
      { ~w(gn sh br kr st sk tr zg gr), 10 }
    ]
  }

  @zelda %{
    identifier: :zelda,
    length_peak: 6.0, length_spread: 2, length_min: 5, length_max: 12,
    start_with_consonant_prob: 0.9,
    vowels: [
      { ~w(a e i o u), 1 }
    ],
    consonants: [
      { ~w(b c d f g j k l m n p r s t v x z), 1 }
    ]
  }

  def get(:sea), do: struct!(__MODULE__, @sea)
  def get(:swamp), do: struct!(__MODULE__, @swamp)
  def get(:zelda), do: struct!(__MODULE__, @zelda)

  def all, do: [get(:sea), get(:swamp), get(:zelda)]
end
