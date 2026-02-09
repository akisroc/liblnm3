defmodule Platform.Roleplay.Infra.Postgres.Schemas.Kingdom do
  @moduledoc false
  use Ecto.Schema

  alias Platform.Roleplay.Infra.Postgres.Schemas.Protagonist
  alias Platform.Shared.Infra.Persistence.Postgres.Types.LoreName
  alias Platform.Shared.Infra.Persistence.Postgres.Types.Slug
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  @schema_prefix "roleplay"
  @primary_key {:id, UUID7, autogenerate: false}
  @foreign_key_type UUID7

  schema "kingdoms" do
    field :name, LoreName
    field :fame, :decimal
    field :slug, Slug

    timestamps()

    has_many :protagonists, Protagonist
  end
end
