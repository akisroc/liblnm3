# defmodule Platform.Shared.Outbox do
#   alias Platform.Shared.Infrastructure.Persistence.Schemas.OutboxMessage

#   def build_message(message_type, payload, metadata \\ %{}) do
#     OutboxMessage.create(%OutboxMessage{}, %{
#       message_type: message_type,
#       payload: payload,
#       metadata: metadata
#     })
#   end
# end
