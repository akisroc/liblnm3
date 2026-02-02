defmodule Platform.Roleplay.API.GenerateLoreNameResponse do
  defstruct [
    :name
  ]

  @type t :: %__MODULE__{
    name: String.t()
  }
end
