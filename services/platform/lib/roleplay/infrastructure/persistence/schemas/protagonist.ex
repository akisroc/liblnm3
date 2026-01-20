defmodule Platform.Roleplay.Infrastructure.Persistence.Schemas.Protagonist do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Roleplay.Infrastructure.Persistence.Schemas.{Player, Kingdom}
  alias Platform.Shared.Infrastructure.Persistence.Types.{UUID7, LoreName, Slug, Url}

  @biography_max_length 500000
  @name_max_length 30

  @type t :: %__MODULE__{
    id: String.t() | nil,
    user_id: String.t() | nil,
    kingdom_id: String.t() | nil,
    name: String.t() | nil,
    fame: Decimal.t() | nil,
    slug: String.t() | nil,
    is_anonymous: boolean() | nil,
    biography: String.t() | nil,
    is_removed: boolean() | nil,
    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil,
    user: Ecto.Association.NotLoaded.t() | User.t(),
    kingdom: Ecto.Association.NotLoaded.t() | Kingdom.t()
  }

  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "protagonist" do
    field :name, LoreName
    field :biography, :string
    field :fame, :decimal, default: Decimal.new("0.0")
    field :profile_picture, :boolean, default: true
    field :is_anonymous, :boolean, default: true
    field :slug, Slug
    field :is_removed, :boolean, default: false

    timestamps()

    belongs_to :user, Player
    belongs_to :kingdom, Kingdom
  end

  def register(protagonist, attrs) do
    protagonist
    |> cast(attrs, [:name, :biography, :profile_picture, :is_anonymous, :player_id, :kingdom_id])
    |> validate_required([:name, :player_id])

    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, min: 1, max: @name_max_length)

    |> validate_length(:biography, min: 1, max: @biography_max_length)

    |> assoc_constraint(:player)
    |> assoc_constraint(:kingdom)
  end

  def update(protagonist, attrs) do
    protagonist
    |> cast(attrs, [:name, :biography, :profile_picture, :is_anonymous, :kingdom_id])

    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, min: 1, max: @name_max_length)

    |> validate_length(:biography, min: 1, max: @biography_max_length)

    |> assoc_constraint(:kingdom)
  end

  def rename(notable, attrs) do
    notable
    |> cast(attrs, [:name])
    |> validate_required(:name)

    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, min: 1, max: @name_max_length)
    |> unique_constraint(:name, name: :idx_protagonists_name_not_removed)
  end

  def adjust_fame(notable, attrs) do
    notable
    |> cast(attrs, [:fame])
    |> validate_required(:fame)
  end

  def anonymize(protagonist) do
    protagonist
    |> change()
    |> put_change(:is_anonymous, true)
  end

  def deanonymize(protagonist) do
    protagonist
    |> change()
    |> put_change(:is_anonymous, false)
  end

  def soft_remove(protagonist) do
    protagonist
    |> change()
    |> put_change(:is_removed, true)
  end

end
