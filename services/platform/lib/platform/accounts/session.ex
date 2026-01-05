defmodule Platform.Accounts.Session do
  use Ecto.Schema
  import Ecto.Query

  @session_validity_in_days 120

  @primary_key {:id, Platform.EctoTypes.UUIDv7, autogenerate: true}
  @foreign_key_type Platform.EctoTypes.UUIDv7

  schema "sessions" do
    field :token, :binary
    field :context, :string, default: "session"
    field :ip_address, EctoNetwork.INET
    field :user_agent, :string

    belongs_to :user, Platform.Accounts.User

    timestamps(updated_at: false, type: :utc_datetime)
  end

  def generate_session_token(user) do
    token = :crypto.strong_rand_bytes(32)
    Platform.Repo.insert!(%Platform.Accounts.Session{
      user_id: user.id,
      token: token,
      context: "session"
    })

    token
  end

  def get_user_by_session_token(token) do
    query = from u in Platform.Accounts.User,
      join: s in assoc(u, :user_sessions),
      where: s.token == ^token and s.insert_at > ago(@session_validity_in_days, "day"),
      select: u

    Platform.Repo.one(query)
  end

  def delete_session_token(token) do
    Platform.Repo.delete_all(from s in Platform.Accounts.Session, where: s.token == ^token)

    :ok
  end
end
