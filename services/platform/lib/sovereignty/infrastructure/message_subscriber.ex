defmodule Platform.Sovereignty.Infrastructure.MessageSubscriber do

  require Logger

  alias Platform.Sovereignty.Application.Command
  alias Platform.Shared.Application.Commands.RegisterKingdomAndLeader

  def handle_info({:domain_message, %{message_type: "UserRegistered"} = message}, state) do
    cmd = %RegisterKingdomAndLeader{
      kingdom_name: message.payload["kingdom_name"],
      leader_name: message.payload["leader_name"],
      player_id: message.payload["user_id"]
    }

    # Idempotent call
    case Command.execute(cmd) do
      {:ok, %{kingdom: kingdom, leader: leader}} ->
        Logger.info("\
          [#{__MODULE__}] Successfully created kingdom “#{kingdom.name}” (id: “#{kingdom.id}”)\
          and its leader “#{leader.name}” (id: “#{leader.id}”) for player “#{kingdom.player_id}”\
        ")
      {:error, :already_exists} ->
        Logger.warning("\
          [#{__MODULE__}] Idempotence warning: kingdom “#{kingdom_name}” already exists\
        ")
      error ->
        Logger.error("\
          [#{__MODULE__}] Error while creating kingdom “#{kingdom_name}”: “#{inspect(error)}”
        ")
    end

    {:noreply, state}
  end

  def handle_info({:message_event, _ignored_message}) do
    {:noreply, state}
  end
end
