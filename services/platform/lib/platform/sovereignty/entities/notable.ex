defmodule Platform.Sovereignty.Entities.Notable do
  alias Platform.Sovereignty.Entities.{Kingdom, Player}
  alias Platform.Shared.Domain.Types, as: SharedTypes

  defstruct [
    :id,
    :name,
    :fame,
    :kingdom_id,
    :kingdom,
    :player_id,
    :player
  ]

  @type t :: %__MODULE__{
    id: SharedTypes.id(),
    name: String.t(),
    fame: float(),
    kingdom_id: SharedTypes.id(),
    kingdom: Kingdom.t() | nil,
    player_id: SharedTypes.id(),
    player: Player.t() | nil
  }

  @spec new(map()) :: __MODULE__.t()
  def new(data) do
    %__MODULE__{
      id: data.id,
      name: data.name,
      fame: data.fame,
      kingdom_id: data.kingdom_id,
      kingdom: data.kingdom,
      player_id: data.player_id,
      player: data.player
    }
  end
end
