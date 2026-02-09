defmodule Platform.Social.Infra.Persistence.Postgres.Schemas.User do
  @moduledoc false
  use Ecto.Schema

  alias Platform.Shared.Infra.Persistence.Postgres.Types.Nickname
  alias Platform.Shared.Infra.Persistence.Postgres.Types.Slug
  alias Platform.Shared.Infra.Persistence.Postgres.Types.Url
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  @role_user :user
  @role_curator :curator
  @role_admin :admin
  @roles [@role_user, @role_curator, @role_admin]

  @schema_prefix "social"
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
