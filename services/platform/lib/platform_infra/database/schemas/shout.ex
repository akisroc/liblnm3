defmodule PlatformInfra.Database.Schemas.Shout do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlatformInfra.Database.Schemas.User
  alias PlatformInfra.Database.Types.PrimaryKey

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  @type t :: %__MODULE__{
    id: PrimaryKey.t() | nil,
    user_id: PrimaryKey.t() | nil,
    content: String.t() | nil,
    inserted_at: DateTime.t() | nil,
    updated_at: DateTiime.t() | nil,
    user: Ecto.Association.NotLoaded.t() | User.t()
  }

  @type loaded :: %__MODULE__{
    id: PrimaryKey.t(),
    user_id: PrimaryKey.t(),
    content: String.t(),
    inserted_at: DateTime.t(),
    updated_at: DateTiime.t(),
    user: Ecto.Association.NotLoaded.t() | User.t()
  }

  schema "shouts" do
    field :content, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(shout, attrs) do
    shout
    |> cast(attrs, [:content, :user_id])
    |> validate_required([:content, :user_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: 500)
  end
end
