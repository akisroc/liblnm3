defmodule Platform.Shared.Infrastructure.Persistence.OutboxDispatcher do
  require Logger
  alias Phoenix.PubSub

  alias Platform.Shared.Infrastructure.Persistence.Schemas.OutboxMessage

  # Todo: configure that
  @pubsub_name Platform.PubSub
  @topic "domain_messages"

  def dispatch(%OutboxMessage{} = msg) do
    Logger.debug("[#{__MODULE__}] Broadcasting message “#{msg.message_type}” (\##{msg.id}) to topic “#{@topic}”")

    PubSub.broadcast(@pubsub_name, @topic, {:domain_message, msg})

    {:ok, ["Phoenix.PubSub"]}
  end
end
