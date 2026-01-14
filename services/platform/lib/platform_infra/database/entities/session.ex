defmodule PlatformInfra.Database.Entities.Session do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias PlatformInfra.Database.Entities.User
  alias PlatformInfra.Database.Types.PrimaryKey

  @session_validity_in_days 120
  @session_validity_in_seconds 60 * 60 * 24 * @session_validity_in_days

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  schema "sessions" do
    field :token, :binary
    field :context, :string, default: "session"
    field :ip_address, EctoNetwork.INET
    field :user_agent, :string
    field :expires_at, :utc_datetime

    belongs_to :user, User

    timestamps(updated_at: false, type: :utc_datetime)
  end

  @doc false
  def create_changeset(session, attrs) do
    session
    |> cast(attrs, [:token, :context, :ip_address, :user_id, :user_agent, :expires_at])
    |> validate_required([:token, :context, :ip_address, :user_id, :expires_at])
    |> unique_constraint(:token)
  end
end
