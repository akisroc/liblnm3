defmodule Platform.IAM.Infrastructure.Persistence.Postgres.Schemas.Session do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.IAM.Infrastructure.Persistence.Schemas.User
  alias Platform.Shared.Infrastructure.Persistence.Types.UUID7

  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "sessions" do
    field :token, :binary
    field :context, :string, default: "session"
    field :ip_address, EctoNetwork.INET
    field :user_agent, :string
    field :expires_at, :utc_datetime

    belongs_to :user, User

    timestamps(updated_at: false)
  end

  def create(session, attrs) do
    session
    |> cast(attrs, [:token, :context, :ip_address, :user_id, :user_agent, :expires_at])
    |> validate_required([:token, :context, :ip_address, :user_id, :expires_at])
    |> unique_constraint(:token, name: "sessions_token_key")
  end
end
