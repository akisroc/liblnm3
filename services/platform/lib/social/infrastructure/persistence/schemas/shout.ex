defmodule Platform.Social.Infrastructure.Persistence.Schemas.Shout do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Social.Infrastructure.Persistence.Schemas.User
  alias Platform.Shared.Infrastructure.Persistence.Types.UUID7

  @content_max_length 500

  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "shouts" do
    field :content, :string

    timestamps(type: :utc_datetime)

    belongs_to :user, User
  end

  def create(shout, attrs) do
    shout
    |> cast(attrs, [:content, :user_id])
    |> validate_required([:content, :user_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: @content_max_length)

    |> assoc_constraint(:user)
  end
end
