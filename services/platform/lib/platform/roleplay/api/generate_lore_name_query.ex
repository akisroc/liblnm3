defmodule Platform.Roleplay.API.GenerateLoreNameQuery do
  defstruct [
    models: [],
    min_len: 3,
    max_len: 12
  ]

  @type t :: %__MODULE__{
    models: [atom()]
  }
end
