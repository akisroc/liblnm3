defmodule Platform.Sovereignty.War.Types.BattleState do
  alias Platform.Sovereignty.War.Types.{Unit, Battle, BattleLogEntry}

  defstruct [
    :units,
    log_queue: :queue.new()
  ]

  @type t :: %__MODULE__{
    units: [Unit.t()],
    log_queue: :queue.queue()
  }

  @doc false
  @spec update_log(__MODULE__.t(), Unit.t(), Unit.t(), [non_neg_integer()]) :: __MODULE__.t()
  def update_log(battle_state, attacking_unit, defending_unit, kill_steps) do
    log_entry = %BattleLogEntry{
      attacking_unit: attacking_unit,
      defending_unit: defending_unit,
      kill_steps: kill_steps
    }

    %__MODULE__{
      battle_state |
      log_queue: :queue.in(log_entry, battle_state.log_queue)
    }
  end
end
