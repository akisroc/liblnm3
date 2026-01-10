defmodule Platform.Sovereignty.War.Types.Troop do
  alias Platform.Sovereignty.War.Types.Unit

  defstruct [
    :attacker?,
    :units
  ]

  @type t :: %__MODULE__{
    attacker?: boolean(),
    units: [Unit.t()]
  }

  @doc """
  `units` parameter must be a list a 8 positive integers.
  See: Platform.Sovereignty.Ecto.Types.Troop
  """
  @spec from_raw_list([non_neg_integer()], boolean()) :: __MODULE__.t()
  def from_raw_list(units, attacker?) do
    %__MODULE__{
      attacker?: attacker?,
      units: units
      |> Stream.with_index(1)
      |> Enum.map(fn {unit_count, identifier} ->
        %Unit{
          archetype: UnitArchetype.get!(identifier),
          count: unit_count,
          attacker?: attacker?,
          stroke?: false,
          stricken?: false
        }
    end)
    }
  end

  @spec military_strength(__MODULE.t()) :: non_neg_integer()
  def military_strength(troop) do
    troop |> Enum.reduce(0.0, fn unit, acc ->
      acc + Unit.military_strength(unit)
    end)
  end

  @spec count(__MODULE__.t()) :: non_neg_integer()
  def count(troop) do
    troop |> Enum.reduce(0, fn unit, acc -> acc + unit.count end)
  end
end
