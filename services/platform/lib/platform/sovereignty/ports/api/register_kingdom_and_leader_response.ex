defmodule Platform.Sovereignty.Ports.API.RegisterKingdomAndLeaderResponse do
  @moduledoc false
  alias Platform.Sovereignty.Entities.Kingdom
  alias Platform.Sovereignty.Entities.Notable

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
