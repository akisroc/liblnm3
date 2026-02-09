defmodule Platform.Sovereignty.Types.BattleOutcome do
  @moduledoc false
  alias Platform.Sovereignty.Types.BattleLogEntry
  alias Platform.Sovereignty.Types.Troop

  defstruct [
    :atk_initial_troop,
    :def_initial_troop,
    :atk_final_troop,
    :def_final_troop,
    log: [],
    atk_wins?: false,
    atk_initial_fame: 0.0,
    def_initial_fame: 0.0,
    atk_fame_modifier: 0.0,
    def_fame_modifier: 0.0
  ]

  @type t :: %__MODULE__{
          atk_initial_troop: Troop.t(),
          def_initial_troop: Troop.t(),
          atk_final_troop: Troop.t(),
          def_final_troop: Troop.t(),
          log: [BattleLogEntry.t()],
          atk_wins?: boolean(),
          atk_initial_fame: float(),
          def_initial_fame: float(),
          atk_fame_modifier: float(),
          def_fame_modifier: float()
        }
end
