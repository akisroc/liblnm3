defmodule Platform.Roleplay.Infra.Postgres.Schemas.Chronicle do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Platform.Roleplay.Infra.Postgres.Schemas.Chapter
  alias Platform.Roleplay.Infra.Postgres.Schemas.Player
  alias Platform.Shared.Infra.Persistence.Postgres.Types.LoreName
  alias Platform.Shared.Infra.Persistence.Postgres.Types.Slug
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  @title_max_length 60
  @slug_max_length 120
  @description_max_length 15_000

  @schema_prefix "roleplay"
  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "chronicles" do
    field :title, LoreName
    field :slug, Slug
    field :description, :string
    field :is_closed, :boolean, default: false

    field :is_removed, :boolean, default: false

    timestamps()

    belongs_to :narrator, Player

    has_many :chapters, Chapter
  end

  def create(chronicle, attrs) do
    chronicle
    |> cast(attrs, [:title, :description, :narrator_id])
    |> validate_required([:title, :narrator_id])
    |> update_change(:title, &String.trim/1)
    |> validate_length(:title, min: 1, max: @title_max_length)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:description, min: 1, max: @description_max_length)
    |> UUID7.ensure_generation()
    |> Slug.generate(:title)
    |> validate_length(:slug, min: 1, max: @slug_max_length)
    |> unique_constraint(:slug, name: :chronicles_slug_key)
    |> assoc_constraint(:narrator)
  end

  def update(chronicle, attrs) do
    chronicle
    |> cast(attrs, [:title, :description])
    |> update_change(:title, &String.trim/1)
    |> validate_length(:title, min: 1, max: @title_max_length)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:description, min: 1, max: @description_max_length)
  end

  def transfer_narratorship(chronicle, %{id: new_narrator_id} = _new_narrator) do
    transfer_narratorship(chronicle, new_narrator_id)
  end

  def transfer_narratorship(chronicle, new_narrator_id) do
    chronicle
    |> change(narrator_id: new_narrator_id)
    |> assoc_constraint(:narrator)
  end

  def archive(chronicle) do
    change(chronicle, is_archived: true)
  end

  def soft_remove(user) do
    change(user, is_removed: true)
  end
end
