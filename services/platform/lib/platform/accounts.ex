defmodule Platform.Accounts do
  def authenticate_user(email, password) do
    user = Platform.Repo.get_by(
      Platform.Accounts.User,
      email: email
    )

    cond do
      user && Argon2.verify_pass(password, user.password) && user.is_enabled && !user.is_removed ->
        {:ok, user}

      user && user.is_removed -> [:error, :removed]

      user && !user.is_enabled -> {:error, :disabled}

      true ->
        Argon2.no_user_verify()
        {:error, :unauthorized}
    end
  end

  def register_user(attrs \\ %{}) do
    %Platform.Accounts.User{}
    |> Platform.Accounts.User.changeset(attrs)
    |> Platform.Repo.insert()
  end

  defdelegate generate_session_token(user), to: Platform.Accounts.Session
end
