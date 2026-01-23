defmodule Platform.Sovereignty.Infra.Persistence.Postgres.Repositories.Kingships do
  @behaviour Platform.Sovereignty.SPI.Kingships

  alias Ecto.Multi

  alias Platform.Sovereignty.Infra.Persistence.Postgres.Repo
  alias Platform.Sovereignty.Infra.Persistence.Postgres.Schemas.{Kingdom, Notable}
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  def register_kingdom_and_leader(kingdom_name, leader_name, player_id) do
    kingdom_id = UUID7.generate()
    leader_id = UUID7.generate()

    Multi.new()
    |> Multi.insert(
      :kingdom,
      Kingdom.register(%Kingdom{
        id: kingdom_id,
        player_id: player_id,
        leader_id: leader_id,
        name: kingdom_name
      })
    )
    |> Multi.insert(
      :leader,
      Notable.register(%Notable{
        id: leader_id,
        player_id: player_id,
        kingdom_id: kingdom_id,
        name: leader_name
      })
    )
    |> Repo.transaction()
  end
end
