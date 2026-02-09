defmodule Platform.Social.Infra.Persistence.Postgres.Schemas.Board do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Platform.Shared.Infra.Persistence.Postgres.Types.Slug
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7
  alias Platform.Social.Infra.Persistence.Postgres.Schemas.Topic
  alias Platform.Social.Infra.Persistence.Postgres.Schemas.User

  @title_max_length 60
  @slug_max_length 120
  @description_max_length 500

  @schema_prefix "social"
  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "boards" do
    field :title, :string
    field :slug, Slug
    field :description, :string

    field :is_removed, :boolean, default: false

    timestamps()

    belongs_to :user, User

    has_many :topics, Topic
  end

  def create(board, attrs) do
    board
    |> cast(attrs, [:title, :description, :user_id])
    |> validate_required([:title, :description, :user_id])
    |> update_change(:title, &String.trim/1)
    |> validate_length(:title, min: 1, max: @title_max_length)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:description, min: 1, max: @description_max_length)
    |> UUID7.ensure_generation()
    |> Slug.generate(:title)
    |> validate_length(:slug, min: 1, max: @slug_max_length)
    |> unique_constraint(:slug, name: :boards_slug_key)
    |> assoc_constraint(:user)
  end

  def update(board, attrs) do
    board
    |> cast(attrs, [:title, :description])
    |> update_change(:title, &String.trim/1)
    |> validate_length(:title, min: 1, max: @title_max_length)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:description, min: 1, max: @description_max_length)
  end

  def archive(board) do
    change(board, is_archived: true)
  end

  def soft_remove(board) do
    change(board, is_removed: true)
  end
end
