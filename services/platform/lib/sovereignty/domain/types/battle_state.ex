defmodule Platform.Sovereignty.War.Types.BattleState do
  alias Platform.Sovereignty.War.Types.{Unit, BattleLogEntry}

  defstruct [
    :units,
    log_queue: :queue.new()
  ]

  @type t :: %__MODULE__{
    units: [Unit.t()],
    log_queue: :queue.queue()
  }

  @doc false
  @spec update_salvo_units(__MODULE__.t(), Unit.t(), Unit.t(), non_neg_integer()) :: __MODULE__.t()
  def update_salvo_units(%__MODULE__{units: units} = state, %Unit{} = atk_unit, %Unit{} = def_unit, kill_count) do
    updated_units = Enum.map(units, fn u ->
      cond do
        Unit.same_unit?(atk_unit, u) ->
          %{u | stroke?: true}
        Unit.same_unit?(def_unit, u) ->
          %{u | stricken?: true, count: max(0, u.count - kill_count)}
        true -> u
      end
    end)

    %__MODULE__{
      state |
      units: updated_units
    }
  end

  @doc false
  @spec add_salvo_log_entry(__MODULE__.t(), Unit.t(), Unit.t(), [non_neg_integer()]) :: __MODULE__.t()
  def add_salvo_log_entry(%__MODULE__{} = state, %Unit{} = atk_unit, %Unit{} = def_unit, kill_steps) do
    log_entry = %BattleLogEntry{
      attacking_unit: atk_unit,
      defending_unit: def_unit,
      kill_steps: kill_steps
    }

    %__MODULE__{
      state |
      log_queue: :queue.in(log_entry, state.log_queue)
    }
  end
end
