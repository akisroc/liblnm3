defmodule Platform.Sovereignty.Application.Commands.LaunchAttack do

  alias Platform.Sovereignty.Domain.War
  alias Platform.Sovereignty.Domain.Types.BattleOutcome

  alias Platform.Sovereignty.Infrastructure.Persistence.Repo

  defstruct [
    :atk_player_id,
    :def_player_id
  ]

  @type t :: %__MODULE__{
    atk_player_id: any(),
    def_player_id: any()
  }


  # @spec execute(__MODULE__.t()) :: {:ok, BattleOutcome.t()} | {:error, any()}
  defimpl Platform.Shared.Application.Command do
    def execute(%{atk_player_id: atk_pid, def_player_id: def_pid}) do
      with {:ok, atk_kingdom, def_kingdom} <- Repo.fetch_fighting_kingdoms(atk_pid, def_pid) do
        with {:ok, battle} <- War.attack(atk_kingdom, def_kingdom) do
          Repo.apply_battle_outcome(battle)
        end
      end
    end
  end

end
