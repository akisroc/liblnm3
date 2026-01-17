defmodule Platform.Sovereignty.War.Types.Troop do
  alias Platform.Sovereignty.War.Types.{Unit, UnitArchetype}

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
  @spec from_raw([non_neg_integer()], boolean()) :: __MODULE__.t()
  def from_raw(units, attacker?) when is_list(units) do
    if length(units) === 8 and Enum.all?(units, &is_integer/1) do
      {
        :ok,
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
      }
    else
      {:error, :invalid_troop_format}
    end
  end
  def from_raw(_, _), do: {:error, :invalid_troop_format}

  @spec to_raw(__MODULE__.t()) :: [non_neg_integer()]
  def to_raw(%__MODULE__{units: units}) do
    units |> Enum.map(fn %{count: count} -> count end)
  end

  # Merge two raw lists of units into one flat list, having them shuffled
  # then sorted by speed.
  #
  # Shuffling before sorting allows to naturally randomize striking order
  # for opposite units with same speed. Otherwise, attacking b2, for example,
  # would always strike before defending b2.
  @spec format_for_fight(__MODULE__.t() | [Unit.t()], __MODULE__.t() | [Unit.t()]) :: [Unit.t()]
  def format_for_fight(%__MODULE__{units: atk_units}, %__MODULE__{units: def_units}) do
    format_for_fight(atk_units, def_units)
  end
  def format_for_fight(atk_units, def_units) do
    (atk_units ++ def_units)
    # Naturally randomize striking order if speed equality
    |> Enum.shuffle()
    |> Enum.sort_by(& &1.archetype.speed, :desc)
  end

  @spec military_strength(__MODULE__.t() | [Unit.t()]) :: non_neg_integer()
  def military_strength(%__MODULE__{units: units}), do: military_strength(units)
  def military_strength(units) when is_list(units) do
    units |> Enum.reduce(0.0, fn unit, acc ->
      acc + Unit.military_strength(unit)
    end)
  end

  @spec count(__MODULE__.t()) :: non_neg_integer()
  def count(%__MODULE__{units: units}) do
    units |> Enum.reduce(0, fn unit, acc -> acc + unit.count end)
  end
end
