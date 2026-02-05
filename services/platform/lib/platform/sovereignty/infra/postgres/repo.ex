defmodule Platform.Sovereignty.Infra.Postgres.Repo do
  use Ecto.Repo,
    otp_app: :platform,
    adapter: Ecto.Adapters.Postgres
end


# defmodule Platform.Sovereignty.Infrastructure.Persistence.Postgres.Repo do
#   alias Platform.Sovereignty.Domain.Types.Kingdom

#   alias Platform.Sovereignty.Infrastructure.Persistence.Postgres.Schemas.Kingdom, as: KingdomSchema
#   alias Platform.Shared.Infrastructure.Persistence.Types.UUID7


#   @spec fetch_fighting_kingdoms!(UUID7.t(), UUID7.t()) :: {:ok, Kingdom.t(), Kingdom.t()}
#   def fetch_fighting_kingdoms!(atk_player_id, atk_player_id) do

#     # Todo


#     # atk_kingdom = %Kingdom{
#       #   id: persistent_atk_kingdom.id,
#       #   atk_troop: persistent_atk_kingdom.atk_troop,
#       #   active?: persistent_atk_kingdom.is_active,
#       #   player: %Player{id: atk_player_id}
#       # }

#       # def_kingdom = %Kingdom{
#       #   id: persistent_def_kingdom.id,
#       #   def_troop: persistent_def_kingdom.def_troop,
#       #   active?: persistent_def_kingdom.is_active,
#       #   player: %Player{id: def_player_id}
#       # }
#   end

#   def apply_battle_outcome(outcome) do
#     PlatformInfra.Repo.transaction(fn ->
#       BattleRepo.insert!(outcome)
#       KingdomRepo.update_troops!(outcome.attacker)
#       KingdomRepo.update_troops!(outcome.defender)
#       outcome
#     end)
#   end

# end
