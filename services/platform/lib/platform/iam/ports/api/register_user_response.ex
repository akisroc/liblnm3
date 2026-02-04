defmodule Platform.IAM.Ports.API.RegisterUserResponse do

  alias Platform.IAM.Entities.{User, Session}

  defstruct [
    :user,
    :session,
    :errors
  ]

  @type t :: %__MODULE__{
    user: User.t(),
    session: Session.t(),
    errors: [String.t()]
  }

  @callback present(__MODULE__.t()) :: map()
end
