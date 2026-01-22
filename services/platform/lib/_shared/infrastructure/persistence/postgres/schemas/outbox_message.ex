defmodule Platform.Shared.Infrastructure.Persistence.Postgres.Schemas.OutboxMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    message_type: String.t() | nil,
    payload: map() | nil,
    metadata: map() | nil,
    consumed_by: [String.t()] | nil,
    failed_attempts: non_neg_integer() | nil,
    last_error: String.t() | nil,
    status: String.t() | nil,
    closed_at: DateTime.t()
  }

  @status_pending :pending
  @status_success :success
  @status_failed :failed
  @statuses [@status_pending, @status_success, @status_failed]

  @last_error_max_length 1027

  @primary_key {:id, :id, autogenerate: true}

  schema "outbox" do
    field :message_type, :string
    field :payload, :map
    field :metadata, :map, default: %{}
    field :consumed_by, {:array, :string}, default: []
    field :failed_attempts, :integer, default: 0
    field :last_error, :string
    field :status, Ecto.Enum, values: @statuses, default: @status_pending

    field :closed_at, :utc_datetime_usec

    timestamps(
      inserted_at_source: :scheduled_at,
      updated_at: false,
      type: :utc_datetime_usec
    )
  end

  def create(outbox_message, attrs) do
    outbox_message
    |> cast(attrs, [:message_type, :payload, :metadata])
    |> validate_required([:message_type, :payload])
  end

  def add_consumers(outbox_message, consumers) when is_list(consumers) do
    outbox_message |> change(
      consumed_by: Enum.uniq(outbox_message.consumed_by ++ consumers)
    )
  end

  def failed_attempt(outbox_message, error_reason) when is_binary(error_reason) do
    outbox_message |> change(
      failed_attempts: outbox_message.failed_attempts + 1,
      last_error: String.slice(error_reason, 0, @last_error_max_length),
      status: @status_failed
    )
  end

  def mark_as_failure(outbox_message) do
    outbox_message |> change(status: @status_failed)
  end

  def mark_as_success(outbox_message) do
    outbox_message |> change(status: @status_success)
  end

  def close(outbox_message) do
    outbox_message |> change(closed_at: DateTime.utc_now())
  end
end
