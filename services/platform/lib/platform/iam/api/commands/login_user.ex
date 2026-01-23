defmodule Platform.IAM.API.Commands.LoginUser do
  defstruct [
    :email,
    :password,
    :metadata
  ]

  @type t :: %__MODULE__{
    email: String.t(),
    password: String.t(),
    metadata: %{
      remote_ip: String.t(),
      user_agent: String.t()
    }
  }
end

defimpl Platform.Shared.Protocols.Command, for: Platform.IAM.API.Commands.LoginUser do
  alias Platform.IAM.API.Commands.LoginUser
  alias Platform.IAM.Core.Entities.{User, Session}

  @identities_adapter Application.compile_env(:platform, :identities_adapter)

  @spec execute(LoginUser.t()) :: {:ok, %{user: User.t(), session: Session.t()}} | {:error, any()}
  def execute(%{
    email: email,
    password: password,
    metadata: %{remote_ip: remote_ip, user_agent: user_agent}
  }) do
    with {:ok, user_data} <- @identities_adapter.get_user(%{email: email}),
         true <- Argon2.verify_pass(password, user_data.password) do
           user = User.from_data(user_data)
           with {:ok, inet_addr} <- :inet.parse_address(to_charlist(remote_ip)),
                {:ok, session} <- @identities_adapter.create_session(
                  user.id,
                  :crypto.strong_rand_bytes(32),
                  inet_addr,
                  Session.get_expiration_date(user),
                  user_agent
                ) do
             {:ok, %{user: user, session: session}}
           end
    else
      {:error, reason} -> handle_failure(reason)
    end
  end

  defp handle_failure(reason) do
    Argon2.no_user_verify()

    case reason do
      {:error, :not_found} -> {:error, :invalid_credentials}
      {:error, :unauthorized} -> {:error, :invalid_credentials}
      {:error, :user_removed} -> {:error, :invalid_credentials}
      {:error, :user_disabled} -> {:error, :user_disabled}
      {:error, reason} -> {:error, reason}
    end
  end
end
