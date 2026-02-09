defmodule Platform.Roleplay.Infra.Postgres.LoreRepositoryAdapter do
  @moduledoc false
  @behaviour Platform.Roleplay.Ports.SPI.LoreRepository

  import Ecto.Query

  alias Platform.Roleplay.Infra.Postgres.Repo
  alias Platform.Roleplay.Infra.Postgres.Schemas.Kingdom
  alias Platform.Roleplay.Infra.Postgres.Schemas.Protagonist

  @impl true
  def reject_existing_lore_names(names) do
    protagonists_query =
      from p in Protagonist,
        where: p.name in ^names,
        select: p.name

    kingdoms_query =
      from k in Kingdom,
        where: k.name in ^names,
        select: k.name

    duplicates =
      protagonists_query
      |> union_all(^kingdoms_query)
      |> Repo.all()

    names -- duplicates
  end
end
