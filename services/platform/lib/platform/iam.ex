defmodule Platform.IAM do
  @moduledoc """
  Handle accounts / identities.
  """

  @identities_repository_adapter Application.compile_env(:platform, :identities_repository_adapter)

  alias Platform.IAM.Ports.API.{RegisterUserResponse, LoginUserResponse}
  alias Platform.IAM.Entities.{User, Session}

  @doc """
  Register a user, then log this newly created user in.
  """
  @spec register_user(
    String.t(), String.t(), String.t(), %{remote_ip: String.t(), user_agent: String.t()}
  ) :: RegisterUserResponse.t()
  def register_user(nickname, email, password, %{remote_ip: remote_ip, user_agent: user_agent}) do
    with {:ok, _user} <- @identities_repository_adapter.register_user(%{
      nickname: nickname,
      email: email,
      password: password
    }) do
      login_res = login_user(email, password, remote_ip, user_agent)
      %RegisterUserResponse{
        user: login_res.user,
        session: login_res.session,
        errors: login_res.errors
      }
    else
      {:error, reason} -> %RegisterUserResponse{errors: [reason]}
    end
  end

  @doc """
  User login.
  """
  @spec login_user(String.t(), String.t(), String.t(), String.t()) :: LoginUserResponse.t()
  def login_user(nickname, password, remote_ip, user_agent) do
    with %{id: _} = user_data <- @identities_repository_adapter.get_user(%{nickname: nickname}),
         true                 <- Argon2.verify_pass(password, user_data.password) do
      user = User.from_data(user_data)
      with {:ok, inet_addr} <- :inet.parse_address(to_charlist(remote_ip)),
           {:ok, session}   <- @identities_repository_adapter.create_session(
             user.id,
             :crypto.strong_rand_bytes(32),
             inet_addr,
             Session.get_expiration_date(user),
             user_agent
           ) do
        %LoginUserResponse{user: user, session: session, errors: []}
      else
        {:error, reason} -> %LoginUserResponse{errors: [reason]}
      end
    else
      _ -> %LoginUserResponse{errors: [:invalid_credentials]}
    end
  end
end
