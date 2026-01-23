# defmodule Platform.Sovereignty.Infrastructure.Workers.UserRegisteredSubscriber do
#   use GenServer
#   require Logger

#   alias Phoenix.PubSub
#   alias Ecto.Changeset

#   alias Platform.Shared.Domain.Events.UserRegistered
#   alias Platform.Shared.Application.Command
#   alias Platform.Sovereignty.Application.Commands.RegisterKingdomAndLeader

#   @pubsub_name Platform.PubSub
#   @topic "domain_messages"

#   def start_link(opts) do
#     GenServer.start_link(__MODULE__, opts, name: __MODULE__)
#   end

#   @impl true
#   def init(state) do
#     Logger.info("[#{__MODULE__}] Listening to topic “#{@topic}”")
#     PubSub.subscribe(@pubsub_name, @topic)

#     {:ok, state}
#   end

#   @impl true
#   def handle_info({:domain_message, message}, state) do
#     process_message(message)
#     {:noreply, state}
#   end

#   @impl true
#   def handle_info(_, state), do: {:noreply, state}

#   defp process_message(%{type: UserRegistered.message_type() = message_type} = message) do
#     Logger.info("[#{__MODULE__} Processing “#{message_type}”] message")

#     payload = message.payload
#     user_id = payload["user_id"]
#     with %{kingdom_name: k_name, leader_name: l_name} <- payload["provisioning_data"] do
#       cmd = %RegisterKingdomAndLeader{
#         kingdom_name: k_name,
#         leader_name: l_name,
#         player_id: user_id
#       }
#       case Command.execute(cmd) do
#         {:ok, leader, kingdom} -> Logger.info("\
#             [#{__MODULE__}] Kingdom “#{kingdom.name}” (id: “#{kingdom.id}”) created \
#             with its leading Notable “#{leader.name}” (id: “#{leader.id}”) for player \
#             “#{kingdom.player_id}”\
#         ")

#         {:error, :already_exists} -> Logger.warning("\
#           [#{__MODULE__}] Idempotence warning: kingdom “#{kingdom_name}” already exists \
#           for player “#{user_id}” – skipping creation task\
#         ")

#         {:error, changeset} when is_struct(changeset, Changeset) -> Logger.warning("\
#           [#{__MODULE__}] Failed to create kingdom “#{kingdom_name}” and \
#           leader “#{leader_name}”: #{inspect(errors_on(changeset))}\
#         ")

#         {:error, reason} -> Logger.error("\
#           [#{__MODULE__}] Unexpected error while creating kingdom “#{kingdom_name}”: \
#           #{inspect(reason)}\
#         ")
#       end
#     else
#       Logger.error("[#{__MODULE__}] Missing data in payload")
#       {:error, "Missing data in payload: need “kingdom_name” and “leader_name”"}
#     end
#   end
#   defp process_message(_message), do: :ok

#   defp errors_on(changeset) do
#     Changeset.traverse_errors(changeset, fn {msg, opts} ->
#       Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
#         opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
#       end)
#     end)
#   end
# end
