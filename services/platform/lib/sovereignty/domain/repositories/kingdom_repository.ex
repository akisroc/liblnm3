defmodule Platform.Sovereignty.Domain.Repositories.KingdomRepository do
  alias Platform.Sovereignty.Domain.Entities.{Kingdom, Notable, Battle}
  alias Platform.Sovereignty.Domain.Types.BattleOutcome

  alias Platform.Shared.Domain.Types, as: SharedTypes

  @callback register_with_leader(
    kingdom_name: SharedTypes.lore_name(),
    leader_name: SharedTypes.lore_name(),
    player_id: SharedTypes.id()
  ) :: {:ok, %{kingdom: Kingdom.t(), leader: Notable.t()}} | {:error, any()}

  @callback apply_battle_outcome(
    outcome: BattleOutcome.t()
  ) :: {:ok, Battle.t()} | {:error, any()}

  # Todo: Custom type instead of map()
  @callback show_kingdom_details(
    kingdom_id: SharedTypes.id()
  ) :: {:ok, map()} | {:error, any()}
end
