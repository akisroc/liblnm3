defmodule Platform.Sovereignty.War.Types.Unit do
  alias Platform.Sovereignty.War.Types.UnitArchetype

  defstruct [
    :archetype,
    :count,
    :attacker?,
    stroke?: false,
    stricken?: false
  ]

  @type t :: %__MODULE__{
    archetype: UnitArchetype.t(),
    count: non_neg_integer(),
    attacker?: boolean(),
    stroke?: boolean(),
    stricken?: boolean()
  }

  @spec military_strength(__MODULE.t()) :: non_neg_integer()
  def military_strength(unit) do
    unit.count * (unit.archetype.power + unit.archetype.defense)
  end
end
