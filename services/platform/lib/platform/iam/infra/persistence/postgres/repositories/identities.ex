defmodule Platform.IAM.Infra.Persistence.Postgres.Repositories.Identities do
  @behaviour Platform.IAM.SPI.Identities

  alias Platform.IAM.Infra.Persistence.Postgres.Schemas.{User, Session}
  alias Platform.IAM.Infra.Persistence.Postgres.Repo

  @impl true
  def get_user(token) when is_binary(token) do
    with {:ok, session} <- get_session(%{token: token}) do
      Repo.get_by(User, id: session.user_id)
    end
  end

  @impl true
  def get_user(%{id: id}), do: Repo.get_by(User, id: id)
  @impl true
  def get_user(%{slug: slug}), do: Repo.get_by(User, slug: slug)
  @impl true
  def get_user(%{email: email}), do: Repo.get_by(User, email: email)
  @impl true
  def get_user(%{nickname: nickname}), do: Repo.get_by(User, nickname: nickname)

  @impl true
  def register_user(%{nickname: nickname, email: email, password: password}) do
    user = User.create(%User{}, %{
      nickname: nickname,
      email: email,
      password: password
    })
    Repo.insert(user)
  end

  @impl true
  def get_session(%{token: token}), do: Repo.get_by(Session, token: hash_token(token))
  @impl true
  def get_session(%{user_id: user_id}), do: Repo.get_by(Session, user_id: user_id)

  @impl true
  def create_session(user_id, token, inet_addr, expires_at, user_agent \\ nil) do
    session = Session.create(%Session{}, %{
      user_id: user_id,
      token: hash_token(token),
      context: "session",
      ip_address: %Postgrex.INET{address: inet_addr},
      user_agent: user_agent,
      expires_at: expires_at
    })
    Repo.insert(session)
  end

  defp hash_token(token) do
    :crypto.hash(:sha256, token)
  end
end
