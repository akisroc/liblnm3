defmodule Platform.IAM.Application.Commands.LoginUser do

  defstruct [
    :email,
    :password
  ]

  @type t :: %__MODULE__{
    email: String.t(),
    password: String.t()
  }

  defimpl Platform.Shared.Application.Command do
    def execute(%{email: _email, password: _password}) do

    end
  end

end
