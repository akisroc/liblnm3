defmodule Platform.Roleplay.Ports.API.GenerateLoreNameResponse do
  @moduledoc false
  defstruct [
    :name
  ]

  @type t :: %__MODULE__{
          name: String.t()
        }

  @callback present(__MODULE__.t()) :: map()
end
