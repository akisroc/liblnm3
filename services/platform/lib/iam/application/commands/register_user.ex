defmodule Platform.IAM.Application.Commands.RegisterUser do
  @identities_adapter Application.compile_env(:platform, :identities_adapter)

  defstruct [
    :email,
    :nickname,
    :password,
    :metadata,
    :provisioning_data
  ]

  @type t :: %__MODULE__{
          email: String.t(),
          nickname: String.t(),
          password: String.t(),
          metadata: %{
            remote_ip: String.t(),
            user_agent: String.t()
          },
          provisioning_data: map()
        }

  defimpl Platform.Shared.Application.Command do
    alias Platform.IAM.Application.Commands.LoginUser
    alias Platform.Shared.Application.Command

    def execute(%{
          email: email,
          nickname: nickname,
          password: password,
          metadata: metadata,
          provisioning_data: provisioning_data
        }) do
      with {:ok, user} <- @identities_adapter.register_user(email, nickname, password, provisioning_data) do
        Command.execute(%LoginUser{
          email: email,
          password: password,
          metadata: metadata
        })
      end
    end
  end
end
