defmodule Platform.IAM.Application.Commands.RegisterUser do

  defstruct [
    :email,
    :nickname,
    :password
  ]

  @type t :: %__MODULE__{
    email: String.t(),
    nickname: String.t(),
    password: String.t()
  }

  defimpl Platform.Shared.Application.Command do
    def execute(%{email: _email, nickname: _nickname, password: _password}) do

    end
  end

end
