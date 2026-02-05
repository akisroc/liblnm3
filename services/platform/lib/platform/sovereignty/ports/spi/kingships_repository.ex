defmodule Platform.Sovereignty.Ports.SPI.KingshipsRepository do
  alias Platform.Sovereignty.Entities.{Kingdom, Notable}

  alias Platform.Shared.Domain.Types, as: SharedTypes

  @callback register_kingdom_and_leader(
              kingdom_name :: SharedTypes.lore_name(),
              leader_name :: SharedTypes.lore_name(),
              player_id :: SharedTypes.id()
            ) :: {:ok, %{kingdom: Kingdom.t(), leader: Notable.t()}} | {:error, any()}
end
