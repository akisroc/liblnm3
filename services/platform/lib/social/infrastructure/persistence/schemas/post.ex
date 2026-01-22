defmodule Platform.Social.Infrastructure.Persistence.Schemas.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Social.Infrastructure.Persistence.Schemas.{User, Topic}
  alias Platform.Shared.Infrastructure.Persistence.Types.UUID7

  @content_max_length 10000

  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "posts" do
    field :content, :string

    timestamps()

    belongs_to :user, User
    belongs_to :topic, Topic
  end

  def create(post, attrs) do
    post
    |> cast(attrs, [:content, :user_id, :topic_id])
    |> validate_required([:content, :user_id, :topic_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: @content_max_length)

    |> assoc_constraint(:user)
    |> assoc_constraint(:topic)
  end

  def update(post, attrs) do
    post
    |> cast(attrs, [:content])
    |> validate_required(:content)

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: @content_max_length)
  end
end
