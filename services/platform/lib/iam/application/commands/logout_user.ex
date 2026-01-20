defmodule Platform.IAM.Application.Commands.LogoutUser do

  alias Platform.Shared.Domain.Types

  defstruct [
    :user_id
  ]

  @type t :: %__MODULE__{
    user_id: Types.id()
  }

  defimpl Platform.Shared.Application.Command do
    def execute(%{user_id: _user_id}) do

    end
  end

end
