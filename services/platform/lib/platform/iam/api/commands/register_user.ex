defmodule Platform.IAM.API.Commands.RegisterUser do
  defstruct [
    :nickname,
    :email,
    :password,
    :metadata
  ]

  @type t :: %__MODULE__{
    nickname: String.t(),
    email: String.t(),
    password: String.t(),
    metadata: %{
      remote_ip: String.t(),
      user_agent: String.t()
    }
  }
end

defimpl Platform.Shared.Protocols.Command, for: Platform.IAM.API.Commands.RegisterUser do
  @identities_adapter Application.compile_env(:platform, :identities_adapter)

  alias Platform.IAM.API.Commands.LoginUser
  alias Platform.Shared.Protocols.Command

  def execute(%{nickname: nickname, email: email, password: password, metadata: metadata}) do
    with {:ok, _user} <- @identities_adapter.register_user(%{
      nickname: nickname,
      email: email,
      password: password
    }) do
      Command.execute(%LoginUser{
        email: email,
        password: password,
        metadata: metadata
      })
    end
  end
end
