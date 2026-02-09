defmodule Platform.IAM.Infra.Postgres.Schemas.User do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Platform.IAM.Infra.Postgres.Types.Email
  alias Platform.IAM.Infra.Postgres.Types.Password
  alias Platform.Shared.Infra.Persistence.Postgres.Types.Nickname
  alias Platform.Shared.Infra.Persistence.Postgres.Types.Slug
  alias Platform.Shared.Infra.Persistence.Postgres.Types.Url
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  @role_user :user
  @role_curator :curator
  @role_admin :admin
  @roles [@role_user, @role_curator, @role_admin]

  @theme_dark :dark
  @theme_light :light
  @themes [@theme_dark, @theme_light]

  @nickname_min_length 1
  @nickname_max_length 30
  @email_min_length 1
  @email_max_length 500
  @password_min_length 8
  @password_max_length 250
  @slug_max_length 60

  @schema_prefix "iam"
  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "users" do
    field :nickname, Nickname
    field :email, Email
    # Hides password in logs
    field :password, Password, redact: true
    field :profile_picture, Url
    field :slug, Slug
    field :roles, {:array, Ecto.Enum}, values: @roles
    field :platform_theme, Ecto.Enum, values: @themes
    field :is_enabled, :boolean, default: true
    field :is_removed, :boolean, default: false

    timestamps()
  end

  def create(user, attrs) do
    user
    |> cast(attrs, [:nickname, :email, :password])
    |> validate_required([:nickname, :email, :password])
    |> validate_length(:nickname, min: @nickname_min_length, max: @nickname_max_length)
    |> validate_length(:email, min: @email_min_length, max: @email_max_length)
    |> UUID7.ensure_generation()
    |> Slug.generate(:nickname)
    |> validate_length(:slug, min: 1, max: @slug_max_length)
    |> unique_constraint(:slug, name: :users_slug_key)
    |> validate_subset(:roles, @roles)
    |> validate_inclusion(:platform_theme, @themes)
    |> validate_length(:password, min: @password_min_length, max: @password_max_length)
    |> hash_password()
    |> unique_constraint(:nickname, name: :idx_users_nickname_not_removed)
    |> unique_constraint(:email, name: :idx_users_email_not_removed)
    |> unique_constraint(:slug, name: :users_slug_key)
  end

  def update(user, attrs) do
    user
    |> cast(attrs, [:nickname, :email, :profile_picture, :password, :platform_theme])
    |> update_change(:nickname, &String.trim/1)
    |> validate_length(:nickname, min: 1, max: @nickname_max_length)
    |> update_change(:email, &String.trim/1)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 1, max: @email_max_length)
    |> unique_constraint(:nickname, name: :idx_users_nickname_not_removed)
    |> unique_constraint(:email, name: :idx_users_email_not_removed)
  end

  def promote_to_curator(user) do
    user
    |> change()
    |> put_change(:roles, Enum.uniq([@role_curator | user.roles]))
  end

  def promote_to_admin(user) do
    user
    |> change()
    |> put_change(:roles, Enum.uniq([@role_admin | user.roles]))
  end

  def downgrade_from_curator(user) do
    user
    |> change()
    |> put_change(:roles, user.roles -- [@role_curator])
  end

  def downgrade_from_admin(user) do
    user
    |> change()
    |> put_change(:roles, user.roles -- [@role_admin])
  end

  def ban(user) do
    user
    |> change()
    |> put_change(:is_enabled, false)
  end

  def unban(user) do
    user
    |> change()
    |> put_change(:is_enabled, true)
  end

  def soft_remove(user) do
    user
    |> change()
    |> put_change(:is_removed, true)
  end

  def nickname_min_length, do: @nickname_min_length
  def nickname_max_length, do: @nickname_max_length
  def email_min_length, do: @email_min_length
  def email_max_length, do: @email_max_length
  def password_min_length, do: @password_min_length
  def password_max_length, do: @password_max_length

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password, Argon2.hash_pwd_salt(password, argon2_config()))
    else
      changeset
    end
  end

  # Todo: Could (should) be in global configs
  defp argon2_config do
    env = Application.get_env(:platform, :env, :prod)

    case env do
      :test ->
        [
          t_cost: 1,
          m_cost: 6,
          parallelism: 1,
          argon2_type: 2
        ]

      :dev ->
        [
          t_cost: 2,
          m_cost: 12,
          parallelism: System.schedulers_online(),
          argon2_type: 2
        ]

      :prod ->
        [
          t_cost: 4,
          # 2^18 KiB => 256MiB
          m_cost: 18,
          parallelism: 2,
          # Argon2id
          argon2_type: 2
        ]
    end
  end
end
