defmodule Platform.Sovereignty.War.Types.BattleLogEntry do
  alias Platform.Sovereignty.War.Types.Unit

  defstruct [
    :attacking_unit,
    :defending_unit,
    :kill_steps
  ]

  @type t :: %__MODULE__{
    attacking_unit: Unit.t(),
    defending_unit: Unit.t(),
    kill_steps: [non_neg_integer()]
  }
end
