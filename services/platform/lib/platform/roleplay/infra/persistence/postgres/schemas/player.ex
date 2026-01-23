defmodule Platform.Roleplay.Infra.Postgres.Persistence.Schemas.Player do
  use Ecto.Schema

  alias Platform.Shared.Infra.Persistence.Postgres.Types.{UUID7, Slug, Url, Nickname}
  alias Platform.Roleplay.Infra.Persistence.Postgres.Schemas.{Protagonist, Chronicle}

  @schema_prefix "roleplay"
  @primary_key {:id, UUID7, autogenerate: false}
  @foreign_key_type UUID7

  schema "players" do
    field :nickname, Nickname
    field :profile_picture, Url
    field :slug, Slug

    has_many :protagonists, Protagonist
    has_many :chronicles, Chronicle

    timestamps()
  end
end
