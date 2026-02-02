defmodule Platform.Sovereignty.Core.Entities.Kingdom do
  alias Platform.Sovereignty.Core.Entities.Player
  alias Platform.Sovereignty.Core.Types.Troop
  alias Platform.Shared.Domain.Types, as: SharedTypes

  defstruct [
    :id,
    :def_troop,
    :atk_troop,
    :fame,
    :active?,
    :player
  ]

  @type t :: %__MODULE__{
    id: SharedTypes.id(),
    def_troop: Troop.t() | nil,
    atk_troop: Troop.t() | nil,
    fame: float(),
    active?: boolean(),
    player: Player.t()
  }
end
