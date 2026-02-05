defmodule Platform.Sovereignty.Ports.API.RegisterKingdomAndLeaderResponse do
  alias Platform.Sovereignty.Entities.{Kingdom, Notable}

  defstruct [
    :kingdom,
    :leader,
    :errors
  ]

  @type t :: %__MODULE__{
    kingdom: Kingdom.t(),
    leader: Notable.t(),
    errors: [String.t()]
  }

  @callback present(__MODULE__.t()) :: map()
end
