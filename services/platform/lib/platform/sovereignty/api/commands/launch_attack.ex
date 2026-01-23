defmodule Platform.Sovereignty.API.Commands.LaunchAttack do

  alias Platform.Sovereignty.Core.War
  # alias Platform.Sovereignty.Core.Types.BattleOutcome
  alias Platform.Shared.Core.Types

  alias Platform.Sovereignty.Infra.Persistence.Postgres.Repo

  defstruct [
    :atk_player_id,
    :def_player_id
  ]

  @type t :: %__MODULE__{
    atk_player_id: Types.id(),
    def_player_id: Types.id()
  }


  # @spec execute(__MODULE__.t()) :: {:ok, BattleOutcome.t()} | {:error, any()}
  defimpl Platform.Shared.Protocols.Command do
    def execute(%{atk_player_id: atk_pid, def_player_id: def_pid}) do
      with {:ok, atk_kingdom, def_kingdom} <- Repo.fetch_fighting_kingdoms(atk_pid, def_pid) do
        with {:ok, battle} <- War.attack(atk_kingdom, def_kingdom) do
          Repo.apply_battle_outcome(battle)
        end
      end
    end
  end

end
