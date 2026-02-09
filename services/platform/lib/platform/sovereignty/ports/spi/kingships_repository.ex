defmodule Platform.Sovereignty.Ports.SPI.KingshipsRepository do
  @moduledoc false
  alias Platform.Shared.Domain.Types, as: SharedTypes
  alias Platform.Sovereignty.Entities.Kingdom
  alias Platform.Sovereignty.Entities.Notable

  @callback register_kingdom_and_leader(
              kingdom_name :: SharedTypes.lore_name(),
              leader_name :: SharedTypes.lore_name(),
              player_id :: SharedTypes.id()
            ) :: {:ok, %{kingdom: Kingdom.t(), leader: Notable.t()}} | {:error, any()}
end
