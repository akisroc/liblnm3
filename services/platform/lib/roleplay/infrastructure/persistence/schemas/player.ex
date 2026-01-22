defmodule Platform.Roleplay.Infrastructure.Persistence.Schemas.Player do
  use Ecto.Schema

  alias Platform.Shared.Infrastructure.Persistence.Types.{UUID7, Slug, Url, Nickname}
  alias Platform.Roleplay.Infrastructure.Persistence.Schemas.{Protagonist, Chronicle}

  @primary_key {:id, UUID7, autogenerate: false}
  @foreign_key_type UUID7

  schema "users" do
    field :nickname, Nickname
    field :profile_picture, Url
    field :slug, Slug

    has_many :protagonists, Protagonist
    has_many :chronicles, Chronicle

    timestamps()
  end
end
