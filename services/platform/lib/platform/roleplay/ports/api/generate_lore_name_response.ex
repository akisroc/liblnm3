defmodule Platform.Roleplay.Ports.API.GenerateLoreNameResponse do
  defstruct [
    :name
  ]

  @type t :: %__MODULE__{
    name: String.t()
  }

  @callback present(__MODULE__.t()) :: map()
end
