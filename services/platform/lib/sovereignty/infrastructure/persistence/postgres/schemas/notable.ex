defmodule Platform.Sovereignty.Infrastructure.Persistence.Postgres.Schemas.Notable do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Shared.Infrastructure.Persistence.Postgres.Types.{UUID7, LoreName, Slug, Url}
  alias Platform.Sovereignty.Infrastructure.Persistence.Postgres.Schemas.{Player, Kingdom}

  @name_max_length 30
  @slug_max_length 60

  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "protagonists" do
    field :name, LoreName
    field :fame, :decimal, default: Decimal.new("0.0")
    field :slug, Slug
    field :is_anonymous, :boolean, default: true
    field :profile_picture, Url
    field :biography, :string
    field :is_removed, :boolean, default: false

    timestamps()

    belongs_to :player, Player,
      foreign_key: :player_id,
      references: :id

    belongs_to :kingdom, Kingdom,
      foreign_key: :kingdom_id,
      references: :id
  end

  def register(notable, attrs) do
    notable
    |> cast(attrs, [:id, :player_id, :kingdom_id, :name])
    |> validate_required([:player_id, :kingdom_id, :name])

    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, min: 1, max: @name_max_length)
    |> unique_constraint(:name, name: :idx_protagonists_name_not_removed)

    |> UUID7.ensure_generation()
    |> Slug.generate(:name)
    |> validate_length(:slug, min: 1, max: @slug_max_length)
    |> unique_constraint(:slug, name: :protagonists_slug_key)

    |> assoc_constraint(:player)
    |> assoc_constraint(:kingdom)
  end

  def relocate(notable, attrs) do
    notable
    |> cast(attrs, [:kingdom_id])
    |> validate_required(:kingdom_id)

    |> assoc_constraint(:kingdom)
    |> foreign_key_constraint(
      :kingdom_id,
      name: :fk_kingdom_has_leader,
      message: "cannot relocate a leader from its kingdom – must change leader first"
    )
  end

  def adjust_fame(notable, attrs) do
    notable
    |> cast(attrs, [:fame])
    |> validate_required(:fame)
  end

  def soft_remove(notable) do
    notable
    |> change()
    |> put_change(:is_removed, true)
  end
end
