defmodule Platform.Sovereignty.Infrastructure.Persistence.Schemas.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Shared.Infrastructure.Persistence.Types.{UUID7, Slug, Url, Nickname}
  alias Platform.Sovereignty.Infrastructure.Persistence.Schemas.{Kingdom, Notable}

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

  # def create(player, attrs) do
  #   player
  #   |> cast(attrs, [:nickname, :profile_picture])
  #   |> validate_required([:nickname])

  #   |> update_change(:nickname, &String.trim/1)
  #   |> validate_length(:nickname, min: 1, max: 30)
  #   |> unique_constraint(:nickname)

  #   |> UUID7.ensure_generation()

  #   |> Slug.generate(:nickname)
  # end

  # def update(player, attrs) do
  #   player
  #   |> cast(attrs, [:nickname, :profile_picture])
  #   |> validate_required([:nickname])

  #   |> update_change(:nickname, &String.trim/1)
  #   |> validate_length(:nickname, min: 1, max: 30)
  #   |> unique_constraint(:nickname)
  # end
end
