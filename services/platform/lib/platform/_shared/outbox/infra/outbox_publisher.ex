defmodule Platform.Shared.Outbox.Infra.OutboxPublisher do
  @moduledoc false
  alias Phoenix.PubSub
  alias Platform.Shared.Outbox.Infra.Persistence.Postgres.Schemas.OutboxMessage

  require Logger

  # Todo: configure that
  @pubsub_name Platform.PubSub
  @topic "domain_messages"

  def publish(%OutboxMessage{} = msg) do
    Logger.debug("[#{__MODULE__}] Broadcasting message “#{msg.message_type}” (\##{msg.id}) to topic “#{@topic}”")

    PubSub.broadcast(@pubsub_name, @topic, {:domain_message, msg})

    {:ok, ["Phoenix.PubSub"]}
  end
end
