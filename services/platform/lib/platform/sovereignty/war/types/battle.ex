defmodule Platform.Sovereignty.War.Types.Battle do
  alias Platform.Ecto.Types.PrimaryKey
  alias Platform.Sovereignty.War
  alias Platform.Sovereignty.War.Types.{Troop, Unit, BattleLogEntry}
  alias Platform.Sovereignty.Ecto.Entities.Kingdom

  defstruct [
    :attacker_kingdom_id,
    :defender_kingdom_id,
    :attacker_initial_troop,
    :defender_initial_troop,
    log: [],
    :attacker_final_troop,
    :defender_final_troop,
    attacker_wins?: false,
    attacker_fame_modifier: 0.0,
    defender_fame_modifier: 0.0
  ]

  @type t :: %__MODULE__{
    attacker_kingdom_id: PrimaryKey.t(),
    defender_kingdom_id: PrimaryKey.t(),
    attacker_initial_troop: Troop.t(),
    defender_initial_troop: Troop.t(),
    log: [BattleLogEntry.t()],
    attacker_final_troop: Troop.t(),
    defender_final_troop: Troop.t(),
    attacker_wins?: boolean(),
    attacker_fame_modifier: Decimal.t(),
    defender_fame_modifier: Decimal.t()
  }

  @doc false
  @spec apply_winner!(__MODULE__.t()) :: __MODULE__.t()
  def apply_winner!(battle) when !is_nil(battle.attacker_final_troop) and !is_nil(battle.defender_final_troop) do
    %__MODULE__{
      battle |
      attacker_wins?: War.attacker_wins?(battle.attacker_final_troop, battle.defender_final_troop)
    }
  end
  def appl_winner!(_) do
    raise RuntimeError, message: "Cannot apply winner before hydrating final troops states"
  end

  @doc false
  @spec apply_fame_drain!(__MODULE__.t()) :: __MODULE__.t()
  def apply_fame_drain!(battle) when !is_nil(battle.attacker?) do
    {winner_initial_troop, loser_initial_troop, winner_fame, loser_fame} =
      if battle.attacker_wins? do
        {
          battle.attacker_initial_troop, battle.defender_initial_troop,
          battle.attacker_kingdom.fame, battle.defender_kingdom.fame
        }
      else
        {
          battle.defender_initial_troop, battle.attacker_initial_troop,
          battle.defender_kingdom.fame, battle.attacker_kingdom.fame
        }
      end

    {winner_modifier, loser_modifier} = War.fame_drain(
      winner_initial_troop, loser_initial_troop, winner_fame, loser_fame
    )

    {attacker_modifier, defender_modifier} =
      if battle.attacker_wins? do
        {winner_modifier, loser_modifier}
      else
        {loser_modifier, winner_modifier}
      end

    %__MODULE__{
      battle |
      attacker_fame_modifier: attacker_modifier,
      defender_fame_modifier: defender_modifier
    }
  end
  def apply_fame_drain!(_) do
    raise RuntimeError, message: "Cannot apply fame drain before processing who won"
  end
end
