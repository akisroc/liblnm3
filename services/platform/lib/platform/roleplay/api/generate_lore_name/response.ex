defmodule Platform.Roleplay.Api.GenerateLoreName.Response do
  defstruct [
    :name
  ]

  @type t :: %__MODULE__{
    name: String.t()
  }
end
