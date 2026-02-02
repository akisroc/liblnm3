defmodule Platform.Sovereignty.Infra.Persistence.Postgres.Schemas.Kingdom do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Sovereignty.Infra.Persistence.Postgres.Schemas.{Player, Notable}
  alias Platform.Sovereignty.Infra.Persistence.Postgres.Types.Troop
  alias Platform.Shared.Infra.Persistence.Postgres.Types.{UUID7, LoreName, Slug}
  alias Platform.Shared.Infra.Persistence.Postgres.Types

  @name_max_length 60
  @slug_max_length 120

  @type t :: %__MODULE__{
    id: UUID7.t() | nil,
    player_id: UUID7.t() | nil,
    leader_id: UUID7.t() | nil,
    name: LoreName.t() | nil,
    slug: Slug.t() | nil,
    fame: Types.fame() | nil,
    total_fame: Types.fame() | nil,
    defense_troop: [non_neg_integer()] | nil,
    attack_troop: [non_neg_integer()] | nil,
    is_active: boolean() | nil,
    is_removed: boolean() | nil,
    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil,
    player: Ecto.Association.NotLoaded.t() | Player.t(),
    leader: Ecto.Association.NotLoaded.t() | Notable.t()
  }

  @schema_prefix "sovereignty"
  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "kingdoms" do
    field :name, LoreName
    field :slug, Slug
    field :fame, :decimal, default: 30000.0
    field :total_fame, :decimal, virtual: true
    field :defense_troop, Troop, default: [0, 0, 0, 0, 0, 0, 0, 0]
    field :attack_troop, Troop, default: [0, 0, 0, 0, 0, 0, 0, 0]
    field :is_active, :boolean, default: false
    field :is_removed, :boolean, default: false

    timestamps()

    belongs_to :player, Player,
      foreign_key: :player_id,
      references: :id

    belongs_to :leader, Notable,
      foreign_key: :leader_id,
      references: :id

    has_many :notables, Notable,
      foreign_key: :kingdom_id
  end

  def register(kingdom, attrs) do
    kingdom
    |> cast(attrs, [:id, :player_id, :leader_id, :name, :is_active])
    |> validate_required([:player_id, :leader_id, :name])

    |> UUID7.ensure_generation()

    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, min: 1, max: @name_max_length)
    |> unique_constraint(:name, name: :idx_kingdoms_name_not_removed)

    |> Slug.generate(:name)
    |> validate_length(:slug, min: 1, max: @slug_max_length)
    |> unique_constraint(:slug, name: :kingdoms_slug_key)

    |> assoc_constraint(:player)
    |> assoc_constraint(:leader)
    |> foreign_key_constraint(:leader_id, name: :fk_leader_player_ownership)
  end

  def rename(kingdom, attrs) do
    kingdom
    |> cast(attrs, [:name])
    |> validate_required(:name)

    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, min: 1, max: @name_max_length)
    |> unique_constraint(:name, name: :idx_protagonists_name_not_removed)
  end

  def activate(kingdom) do
    kingdom
    |> change()
    |> put_change(:is_active, true)
  end

  def deactivate(kingdom) do
    kingdom
    |> change()
    |> put_change(:is_active, false)
  end

  def change_leader(kingdom, attrs) do
    kingdom
    |> cast(attrs, [:leader_id])
    |> validate_required(:leader_id)

    |> assoc_constraint(:leader)
  end

  def update_troops(kingdom, attrs) do
    kingdom
    |> cast(attrs, [:defense_troop, :attack_troop])

    |> check_constraint(
      :defense_troop,
      name: :chk_kingdoms_defense_troop_integrity,
      message: "invalid defense troop structure – must be a flat list of 8 positive integer"
    )
    |> check_constraint(
      :attack_troop,
      name: :chk_kingdoms_attack_troop_integrity,
      message: "invalid attack troop structure – must be a flat list of 8 positive integer"
    )
  end

  def soft_remove(kingdom) do
    kingdom
    |> change()
    |> put_change(:is_removed, true)
  end

end
