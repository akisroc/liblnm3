defmodule Platform.Sovereignty.Infra.Postgres.KingshipsRepositoryAdapter do
  @behaviour Platform.Sovereignty.Ports.SPI.KingshipsRepository

  @repo Application.compile_env(:platform, :sovereignty_repo_adapter)

  alias Ecto.Multi
  alias Ecto.Changeset

  alias Platform.Sovereignty.Infra.Postgres.Schemas.{Kingdom, Notable}
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  alias Platform.Sovereignty.Entities.Kingdom, as: SovereigntyKingdom
  alias Platform.Sovereignty.Entities.Notable, as: SovereigntyNotable

  @impl true
  def register_kingdom_and_leader(kingdom_name, leader_name, player_id) do
    kingdom_id = UUID7.generate()
    leader_id = UUID7.generate()

    result = Multi.new()
    |> Multi.run(:defer_constraints, fn repo, _ ->
      sql = "SET CONSTRAINTS \
            fk_kingdom_has_leader, fk_kingdoms_leader_id, fk_protagonists_kingdom_id \
            DEFERRED;"
      case repo.query(sql) do
        {:ok, _result} -> {:ok, :deferred}
        error -> error
      end
    end)
    |> Multi.insert(
      :tmp_leader,
      Notable.register(%Notable{}, %{
        id: leader_id,
        player_id: player_id,
        kingdom_id: nil,
        name: leader_name
      })
    )
    |> Multi.insert(
      :kingdom,
      Kingdom.register(%Kingdom{}, %{
        id: kingdom_id,
        player_id: player_id,
        leader_id: leader_id,
        name: kingdom_name
      })
    )
    |> Multi.update(
      :leader,
      fn %{tmp_leader: leader} -> Notable.relocate(leader, %{kingdom_id: kingdom_id}) end
    )
    |> @repo.transaction()

    case result do
      {:ok, %{kingdom: kingdom, leader: leader}} ->
        {:ok, %{kingdom: SovereigntyKingdom.new(kingdom), leader: SovereigntyNotable.new(leader)}}
      {:error, _operation, changeset, _changes} ->
        {:error, errors_on(changeset)}
    end
  end

  defp errors_on(changeset) do
    Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
