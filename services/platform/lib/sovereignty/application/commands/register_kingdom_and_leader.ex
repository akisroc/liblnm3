defmodule Platform.Sovereignty.Application.Commands.RegisterKingdomAndLeader do
  @repository_adapter Application.compile_env(:platform, :kingdom_repository_adapter)

  alias Platform.Sovereignty.Domain.Entities.{Kingdom, Notable}
  alias Platform.Shared.Domain.Types

  defstruct [
    :kingdom_name,
    :leader_name,
    :player_id
  ]

  @type t :: %__MODULE__{
    kingdom_name: Types.lore_name(),
    leader_name: Types.leader_name(),
    player_id: Types.id()
  }


  # @spec execute(__MODULE__.t()) :: {:ok, %{kingdom: Kingdom.t(), leader: Notable.t()}} | {:error, any()}
  defimpl Platform.Shared.Application.Command do
    def execute(%{kingdom_name: kname, leader_name: lname, player_id: pid}) do
      @repository_adapter.register_with_leader(kname, lname, pid)
    end
  end
end
