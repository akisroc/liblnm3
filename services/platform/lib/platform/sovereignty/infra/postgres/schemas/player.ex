defmodule Platform.Sovereignty.Infra.Postgres.Schemas.Player do
  use Ecto.Schema

  alias Platform.Shared.Infra.Persistence.Postgres.Types.{UUID7, Slug, Url, Nickname}
  alias Platform.Sovereignty.Infra.Postgres.Schemas.{Kingdom, Notable}

  @schema_prefix "sovereignty"
  @primary_key {:id, UUID7, autogenerate: false}
  @foreign_key_type UUID7

  schema "players" do
    field :nickname, Nickname
    field :profile_picture, Url
    field :slug, Slug

    has_many :kingdoms, Kingdom
    has_many :notables, Notable

    timestamps()
  end
end
