defmodule Platform.Game.UnitArchetype do
  defstruct [
    :label,
    :power,
    :defense,
    :speed,
    :kill_rate,
    :distance?,
    :fame_cost
  ]

  @type t :: %__MODULE__{
    label: atom(),
    power: float(),
    defense: float(),
    speed: float(),
    kill_rate: float(),
    distance?: boolean(),
    fame_cost: float()
  }

  def get(1), do: b1()
  def get(:b1), do: b1()

  def get(2), do: b2()
  def get(:b2), do: b2()

  def get(3), do: b3()
  def get(:b3), do: b3()

  def get(4), do: b4()
  def get(:b4), do: b4()

  def get(5), do: b5()
  def get(:b5), do: b5()

  def get(6), do: b6()
  def get(:b6), do: b6()

  def get(7), do: b7()
  def get(:b7), do: b7()

  def get(8), do: b8()
  def get(:b8), do: b8()

  def all do
    [get(1), get(2), get(3), get(4), get(5), get(6), get(7), get(8)]
  end

  defp b1 do
    %__MODULE__{label: :b1, power: 4.0, defense: 7.0, speed: 85.0, kill_rate: 4.0 / 7.0, distance?: false, fame_cost: 2.86}
  end
end
