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

  @spec military_strength(__MODULE__.t()) :: non_neg_integer()
  def military_strength(%__MODULE__{} = unit) do
    unit.count * (unit.archetype.power + unit.archetype.defense)
  end

  # Distance units can reach all units.
  # Melee units cannot reach distance units.
  @spec can_reach?(__MODULE__.t(), __MODULE__.t()) :: boolean()
  def can_reach?(%__MODULE__{archetype: %{distance?: true}}, _), do: true
  def can_reach?(_, %__MODULE__{archetype: %{distance?: false}}), do: true
  def can_reach?(_, _), do: false

  @spec same_unit?(__MODULE__.t(), __MODULE__.t()) :: boolean()
  def same_unit?(%__MODULE__{} = u1, %__MODULE__{} = u2) do
    same_archetype?(u1, u2) && same_side?(u1, u2)
  end

  @spec same_archetype?(__MODULE__.t(), __MODULE__.t()) :: boolean()
  def same_archetype?(%__MODULE__{archetype: a1}, %__MODULE__{archetype: a2}) do
    a1.key === a2.key
  end

  @spec same_side?(__MODULE__.t(), __MODULE__.t()) :: boolean()
  def same_side?(%__MODULE__{attacker?: _} = u1, %__MODULE__{attacker?: _} = u2) do
    u1.attacker? === u2.attacker?
  end
end
