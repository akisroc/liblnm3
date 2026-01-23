defmodule Platform.Social.Infra.Persistence.Postgres.Schemas.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Social.Infra.Persistence.Postgres.Schemas.{User, Board, Post}
  alias Platform.Shared.Infra.Persistence.Postgres.Types.{UUID7, Slug}

  @title_max_length 60
  @slug_max_length 120

  @schema_prefix "social"
  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "topics" do
    field :title, :string
    field :slug, Slug
    field :is_archived, :boolean, default: false

    field :is_removed, :boolean, default: false

    timestamps()

    belongs_to :user, User
    belongs_to :board, Board
    has_many :posts, Post
  end

  def create(topic, attrs) do
    topic
    |> cast(attrs, [:title, :user_id, :board_id])
    |> validate_required([:title, :user_id, :board_id])

    |> update_change(:title, &String.trim/1)
    |> validate_length(:title, min: 1, max: @title_max_length)

    |> UUID7.ensure_generation()
    |> Slug.generate(:title)
    |> validate_length(:slug, min: 1, max: @slug_max_length)
    |> unique_constraint(:slug, name: :topics_slug_key)

    |> assoc_constraint(:user)
    |> assoc_constraint(:board)
  end

  def update(topic, attrs) do
    topic
    |> cast(attrs, [:title, :board_id])
    |> validate_required(:title, :board_id)

    |> update_change(:title, &String.trim/1)
    |> validate_length(:title, min: 1, max: @title_max_length)

    |> assoc_constraint(:board)
  end

  def archive(topic) do
    topic |> change(is_archived: true)
  end

  def soft_remove(topic) do
    topic |> change(is_removed: true)
  end

end
