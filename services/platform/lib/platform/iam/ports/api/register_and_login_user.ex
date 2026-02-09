defmodule Platform.IAM.Ports.API.RegisterAndLoginUserResponse do
  @moduledoc false
  alias Platform.IAM.Entities.Session
  alias Platform.IAM.Entities.User

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
