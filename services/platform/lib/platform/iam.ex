defmodule Platform.IAM do
  @moduledoc """
  Handle accounts / identities.
  """

  alias Platform.IAM.Entities.Session
  alias Platform.IAM.Entities.User
  alias Platform.IAM.Ports.API.LoginUserResponse
  alias Platform.IAM.Ports.API.RegisterAndLoginUserResponse
  alias Platform.IAM.Ports.API.RegisterUserResponse

  @identities_repository_adapter Application.compile_env(
                                   :platform,
                                   :identities_repository_adapter
                                 )

  @doc """
  User registration
  """
  @spec register_user(String.t(), String.t(), String.t()) :: RegisterUserResponse.t()
  def register_user(nickname, email, password) do
    case @identities_repository_adapter.register_user(nickname, email, password) do
      {:ok, user} -> %RegisterUserResponse{user: user, errors: []}
      {:error, reason} -> %RegisterUserResponse{errors: [reason]}
    end
  end

  @doc """
  User login.
  """
  @spec login_user(String.t(), String.t(), String.t(), String.t()) :: LoginUserResponse.t()
  def login_user(nickname, password, remote_ip, user_agent) do
    with %{id: _} = user_data <- @identities_repository_adapter.get_user(%{nickname: nickname}),
         true <- Argon2.verify_pass(password, user_data.password) do
      user = User.new(user_data)

      with {:ok, inet_addr} <- :inet.parse_address(to_charlist(remote_ip)),
           {:ok, session} <-
             @identities_repository_adapter.create_session(
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
      _ -> %LoginUserResponse{errors: ["Invalid credentials"]}
    end
  end

  @doc """
  Register a user, then log this newly created user in.
  """
  @spec register_and_login_user(
          String.t(),
          String.t(),
          String.t(),
          %{remote_ip: String.t(), user_agent: String.t()}
        ) :: RegisterAndLoginUserResponse.t()
  def register_and_login_user(nickname, email, password, %{remote_ip: remote_ip, user_agent: user_agent}) do
    with %{errors: [], user: user} <- register_user(nickname, email, password),
         %{errors: [], session: session} <- login_user(nickname, password, remote_ip, user_agent) do
      %RegisterAndLoginUserResponse{
        user: user,
        session: session,
        errors: []
      }
    else
      %{errors: errors} -> %RegisterAndLoginUserResponse{errors: errors}
    end
  end
end
