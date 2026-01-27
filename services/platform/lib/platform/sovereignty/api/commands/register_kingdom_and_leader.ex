# defmodule Platform.Sovereignty.API.Commands.RegisterKingdomAndLeader do
#   @kingships_adapter Application.compile_env(:platform, :kingships_adapter)

#   alias Platform.Sovereignty.Core.Entities.{Kingdom, Notable}
#   alias Platform.Shared.Core.Types

#   defstruct [
#     :kingdom_name,
#     :leader_name,
#     :player_id
#   ]

#   @type t :: %__MODULE__{
#           kingdom_name: Types.lore_name(),
#           leader_name: Types.leader_name(),
#           player_id: Types.id()
#         }

#   @spec execute(__MODULE__.t()) :: {:ok, %{kingdom: Kingdom.t(), leader: Notable.t()}} | {:error, any()}
#   defimpl Platform.Shared.Protocols.Command do
#     def execute(%{kingdom_name: kname, leader_name: lname, player_id: pid}) do
#       @kingships_adapter.register_kingdom_and_leader(kname, lname, pid)
#     end
#   end
# end
