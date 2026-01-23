defmodule Platform.Roleplay.Infra.Persistence.Postgres.Schemas.Kingdom do
  use Ecto.Schema

  alias Platform.Shared.Infra.Persistence.Postgres.Types.{UUID7, Slug, LoreName}
  alias Platform.Roleplay.Infra.Persistence.Postgres.Schemas.Protagonist

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
