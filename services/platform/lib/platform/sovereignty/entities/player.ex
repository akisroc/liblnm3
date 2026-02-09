defmodule Platform.Sovereignty.Entities.Player do
  @moduledoc false
  alias Platform.Shared.Domain.Types, as: SharedTypes

  defstruct [
    :id
  ]

  @type t :: %__MODULE__{
          id: SharedTypes.id()
        }
end
