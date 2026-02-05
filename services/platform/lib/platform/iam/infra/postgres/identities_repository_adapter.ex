defmodule Platform.IAM.Infra.Postgres.IdentitiesRepositoryAdapter do
  @behaviour Platform.IAM.Ports.SPI.IdentitiesRepository

  @repo Application.compile_env(:platform, :iam_repo_adapter)

  alias Ecto.Changeset

  alias Platform.IAM.Infra.Postgres.Schemas.{User, Session}
  alias Platform.IAM.Entities.User, as: IAMUser

  @impl true
  def get_user(token) when is_binary(token) do
    with {:ok, session} <- get_session(%{token: token}) do
      @repo.get_by(User, id: session.user_id)
    end
  end

  @impl true
  def get_user(%{id: id}), do: @repo.get_by(User, id: id)
  @impl true
  def get_user(%{slug: slug}), do: @repo.get_by(User, slug: slug)
  @impl true
  def get_user(%{email: email}), do: @repo.get_by(User, email: email)
  @impl true
  def get_user(%{nickname: nickname}), do: @repo.get_by(User, nickname: nickname)

  @impl true
  def register_user(nickname, email, password) do
    result = @repo.insert(User.create(%User{}, %{
      nickname: nickname,
      email: email,
      password: password
    }))

    case result do
      {:ok, user} -> {:ok, IAMUser.new(user)}
      {:error, changeset} -> {:error, errors_on(changeset)}
    end
  end

  @impl true
  def get_session(%{token: token}), do: @repo.get_by(Session, token: hash_token(token))
  @impl true
  def get_session(%{user_id: user_id}), do: @repo.get_by(Session, user_id: user_id)

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
    @repo.insert(session)
  end

  defp hash_token(token) do
    :crypto.hash(:sha256, token)
  end

  defp errors_on(changeset) do
    Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
