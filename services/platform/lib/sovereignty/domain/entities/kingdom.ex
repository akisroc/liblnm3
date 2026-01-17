defmodule Platform.Sovereignty.Domain.Entities.Kingdom do
  alias Platform.Sovereignty.Domain.Entities.Player
  alias Platform.Sovereignty.Domain.Types.Troop
  alias Platform.Shared.Domain.Types, as: SharedTypes

  defstruct [
    :id,
    :def_troop,
    :atk_troop,
    :active?,
    :player
  ]

  @type t :: %__MODULE__{
    id: SharedTypes.id(),
    def_troop: Troop.t() | nil,
    atk_troop: Troop.t() | nil,
    active?: boolean(),
    player: Player.t()
  }
end
