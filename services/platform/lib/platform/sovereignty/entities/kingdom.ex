defmodule Platform.Sovereignty.Entities.Kingdom do
  @moduledoc false
  alias Platform.Shared.Domain.Types, as: SharedTypes
  alias Platform.Sovereignty.Entities.Notable
  alias Platform.Sovereignty.Entities.Player
  alias Platform.Sovereignty.Types.Troop

  defstruct [
    :id,
    :name,
    :def_troop,
    :atk_troop,
    :fame,
    :active?,
    :leader_id,
    :leader,
    :player_id,
    :player
  ]

  @type t :: %__MODULE__{
          id: SharedTypes.id(),
          name: String.t(),
          def_troop: Troop.t() | nil,
          atk_troop: Troop.t() | nil,
          fame: float(),
          active?: boolean(),
          leader_id: SharedTypes.id(),
          leader: Notable.t() | nil,
          player_id: SharedTypes.id(),
          player: Player.t() | nil
        }

  @spec new(map()) :: __MODULE__.t()
  def new(data) do
    %__MODULE__{
      id: data.id,
      name: data.name,
      def_troop: data.def_troop,
      atk_troop: data.atk_troop,
      fame: data.fame,
      active?: data.active?,
      leader_id: data.leader_id,
      leader: data.leader,
      player_id: data.player_id,
      player: data.player
    }
  end
end
