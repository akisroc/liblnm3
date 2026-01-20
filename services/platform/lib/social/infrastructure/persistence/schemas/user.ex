defmodule Platform.Social.Infrastructure.Persistence.Schemas.User do
  use Ecto.Schema

  alias Platform.Shared.Infrastructure.Persistence.Types.{UUID7, Nickname, Slug, Url}

  @role_user :user
  @role_curator :curator
  @role_admin :admin
  @roles [@role_user, @role_curator, @role_admin]

  @primary_key {:id, UUID7, autogenerate: false}
  @foreign_key_type UUID7

  schema "users" do
    field :nickname, Nickname
    field :profile_picture, Url
    field :slug, Slug
    field :roles, {:array, Ecto.Enum}, values: @roles
    field :is_enabled, :boolean, default: true
    field :is_removed, :boolean, default: false

    timestamps()
  end
end
