defmodule Platform.Sovereignty.Infrastructure.Persistence.Postgres.Schemas.Player do
  use Ecto.Schema

  alias Platform.Shared.Infrastructure.Persistence.Postgres.Types.{UUID7, Slug, Url, Nickname}
  alias Platform.Sovereignty.Infrastructure.Persistence.Postgres.Schemas.{Kingdom, Notable}

  @primary_key {:id, UUID7, autogenerate: false}
  @foreign_key_type UUID7

  schema "users" do
    field :nickname, Nickname
    field :profile_picture, Url
    field :slug, Slug

    has_many :kingdoms, Kingdom
    has_many :notables, Notable

    timestamps()
  end
end
