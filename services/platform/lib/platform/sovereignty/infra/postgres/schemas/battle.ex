defmodule Platform.Sovereignty.Infra.Postgres.Schemas.Battle do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Sovereignty.Infra.Postgres.Types.Troop
  alias Platform.Sovereignty.Infra.Postgres.Schemas.Kingdom
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  @type t :: %__MODULE__{
    id: String.t() | nil,
    attacker_kingdom_id: String.t() | nil,
    defender_kingdom_id: String.t() | nil,
    attacker_initial_troop: [non_neg_integer()] | nil,
    defender_initial_troop: [non_neg_integer()] | nil,
    log: map() | nil,
    attacker_final_troop: [non_neg_integer()] | nil,
    defender_final_troop: [non_neg_integer()] | nil,
    attacker_wins: boolean() | nil,
    attacker_fame_modifier: float() | nil,
    defender_fame_modifier: float() | nil,
    inserted_at: DateTime.t() | nil,
    attacker_kingdom: Ecto.Association.NotLoaded.t() | Kingdom.t(),
    defender_kingdom: Ecto.Association.NotLoaded.t() | Kingdom.t()
  }

  @schema_prefix "sovereignty"
  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "battles" do
    field :attacker_initial_troop, Troop
    field :defender_initial_troop, Troop
    field :log, :map
    field :attacker_final_troop, Troop
    field :defender_final_troop, Troop
    field :attacker_wins, :boolean
    field :attacker_fame_modifier, :decimal
    field :defender_fame_modifier, :decimal

    timestamps(updated_at: false)

    belongs_to :attacker_kingdom, Kingdom
    belongs_to :defender_kingdom, Kingdom
  end

  def register(battle, attrs) do
    battle
    |> cast(attrs, [
      :attacker_kingdom_id,
      :defender_kingdom_id,
      :attacker_initial_troop,
      :defender_initial_troop,
      :log,
      :attacker_final_troop,
      :defender_final_troop,
      :attacker_wins?,
      :attacker_fame_modifier,
      :defender_fame_modifier
    ])
    |> validate_required([
      :attacker_kingdom_id,
      :defender_kingdom_id,
      :attacker_initial_troop,
      :defender_initial_troop,
      :log,
      :attacker_final_troop,
      :defender_final_troop,
      :attacker_wins?,
      :attacker_fame_modifier,
      :defender_fame_modifier
    ])
    |> foreign_key_constraint(:attacker_kingdom_id)
    |> foreign_key_constraint(:defender_kingdom_id)
    |> check_constraint(:attacker_kingdom_id, name: :chk_battles_attacker_is_not_defender)
    |> check_constraint(:attacker_initial_troop, name: :chk_battles_attacker_initial_troop_integrity)
    |> check_constraint(:defender_initial_troop, name: :chk_battles_defender_initial_troop_integrity)
    |> check_constraint(:attacker_final_troop, name: :chk_battles_attacker_final_troop_integrity)
    |> check_constraint(:defender_final_troop, name: :chk_battles_defender_final_troop_integrity)
    |> check_constraint(:log, name: :chk_log_integrity)
  end
end
