defmodule Platform.Social.Infrastructure.Persistence.Schemas.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Social.Infrastructure.Persistence.Schemas.{User, Board, Post}
  alias Platform.Shared.Infrastructure.Persistence.Types.{UUID7, Slug}

  @title_max_length 60
  @slug_max_length 120

  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "topics" do
    field :title, :string
    field :slug, Slug
    field :is_archived, :boolean, default: false

    field :is_removed, :boolean, default: false

    timestamps()

    belongs_to :user, User
    has_many :posts, Post
  end

  def create(topic, attrs) do
    topic
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])

    |> update_change(:title, &String.trim/1)
    |> validate_length(:title, min: 1, max: @title_max_length)

    |> UUID.ensure_generation()
    |> Slug.generate(:title)

    |> assoc_constraint(:user)
  end

  def update(topic, attrs) do
    topic
    |> cast(attrs, [:title])
    |> validate_required(:title)

    |> update_change(:title, &String.trim/1)
    |> validate_length(:title, min: 1, max: @title_max_length)
  end

  def archive(topic) do
    topic |> change(is_archived: true)
  end

  def soft_remove(topic) do
    topic |> change(is_removed: true)
  end

end
