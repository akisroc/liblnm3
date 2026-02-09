defmodule Platform.IAM.Ports.API.RegisterUserResponse do
  @moduledoc false
  alias Platform.IAM.Entities.User

  defstruct [
    :user,
    :errors
  ]

  @type t :: %__MODULE__{
          user: User.t(),
          errors: [String.t()]
        }

  @callback present(__MODULE__.t()) :: map()
end
