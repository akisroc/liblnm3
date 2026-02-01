defmodule Platform.Roleplay.Infra.Persistence.Postgres.LoreRepository do
  @behaviour Platform.Roleplay.SPI.LoreRepository

  use Ecto.Query

  alias Platform.Roleplay.Infra.Persistence.Postgres.Repo
  alias Platform.Roleplay.Infra.Persistence.Postgres.Schemas.{Protagonist, Kingdom}

  @impl true
  def reject_existing_lore_names(names) do
    protagonists_query = from p in Protagonist,
      where: p.name in ^names,
      select: p.name
    kingdoms_query = from k in Kingdom,
      where: k.name in ^names,
      select: k.name

    duplicates =
      protagonists_query
      |> union_all(^kingdoms_query)
      |> Repo.all()

    names -- duplicates
  end
end
