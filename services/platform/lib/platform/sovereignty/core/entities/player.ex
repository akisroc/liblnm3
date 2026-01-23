defmodule Platform.Sovereignty.Domain.Entities.Player do

  alias Platform.Shared.Domain.Types, as: SharedTypes

  defstruct [
    :id
  ]

  @type t :: %__MODULE__{
    id: SharedTypes.id()
  }
end
