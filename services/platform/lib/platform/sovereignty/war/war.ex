defmodule Platform.Sovereignty.War do
  alias Platform.Sovereignty.Ecto.Entities.Kingdom
  alias Platform.Sovereignty.War.Types.{Troop, BattleState, Unit, UnitArchetype, BattleLogEntry, Battle}

  # ============================================================================
  # CONSTANTS & BALANCING
  # ============================================================================

  # --- FIGHT MECHANICS ---
  # The fight between two units is divided in ticks. This allows to
  # apply a friction curve to the losses: the fewer the stricken,
  # the harder they are to kill.
  # ---
  # For that friction, we use hyperbolic tangent based upon the
  # difference between the two forces.
  # ---
  # Ticks: higher → more friction → less kills
  # Slope factor: higher → less friction through ticks → more kills
  # Spread: RNG multiplier range for damages (0.8 = -20%, 1.1 = +10%)
  @salvo_ticks 10
  @kill_slope_factor 3.0
  @kill_spread_min 0.8
  @kill_spread_max 1.1

  # --- VICTORY CONDITIONS ---
  # 1.10: attacker needs 10% more remaining strength than defender to win
  @victory_threshold 1.10

  # --- FAME DRAIN
  # Dampener: restraints base units’ fame drain  #
  # Underdog: clamped multiplier based on army strength ratio
  # Prestige slice: % of fame diff drained from a more famous loser
  @fame_drain_dampener 0.1
  @underdog_multiplier_min 0.2
  @underdog_multiplier_max 5.0
  @fame_difference_slice 0.05

  # ============================================================================
  # LOGIC
  # ============================================================================

  @spec attack(Kingdom.loaded(), Kingdom.loaded()) :: {:ok, Battle.t()} | {:error, any()}
  def attack(%Kingdom{} = atk_kingdom, %Kingdom{} = def_kingdom) do
    atk_initial_troop = Troop.from_raw_list(atk_kingdom.attack_troop, true)
    def_initial_troop = Troop.from_raw_list(def_kingdom.defense_troop, false)

    flat_units = format_troops_for_fight(atk_initial_troop, defending_troop)

    initial_state = %BattleState{
      units: flat_units,
      log: :queue.new()
    }

    # Battle phases
    final_state = flat_units
    |> Enum.reduce_while(initial_state, fn unit, acc_state ->

      # Fetching unit current state
      atk_unit = Enum.find(acc_state.units, &same_unit?(&1, unit))

      # Unit already wiped or initially empty
      if atk_unit.count === 0 do
        {:cont, acc_state}

      # Execute battle phase
      else
        case atk_unit |> choose_target(acc_state.units) do

          # No target candidate for current side, we pass
          nil -> {:cont, acc_state}

          # A target has been chosen, let’s strike
          def_unit ->
            {kill_count, kill_steps} = kill_steps(atk_unit, def_unit)

            {
              :cont,
              %{ acc_state |
                units:
                  acc_state.units |> Enum.map(fn unit ->
                    cond do
                      same_unit?(unit, atk_unit) -> %{unit | stroke?: true}
                      same_unit?(unit, def_unit) ->
                        %{unit | stricken?: true, count: max(0, unit.count - kill_count)}
                      true -> unit
                    end
                  end),
                log:
                  acc_state
                  |> update_log(atk_unit, def_unit, kill_steps)
            }}
        end
      end

    end)

    %Battle{
      attacker_kingdom_id: atk_kingdom.id,
      defender_kingdom_id: def_kingdom.id,
      attacker_initial_troop: atk_initial_troop,
      defender_initial_troop: def_initial_troop,
      log: :queue.to_list(final_state.log_queue),
      attacker_final_troop: final_state.units |> Enum.filter(&(&1.attacker?)),
      defender_final_troop: final_state.units |> Enum.reject(&(&1.attacker?)),
    }
    |> Battle.apply_winner()
    |> Battle.apply_fame_drain()

  end

  # Return a tuple.
  # First element is the total number of kills.
  # Second element is the list of kill steps which drove to given total.
  @doc false
  @spec kill_steps(Unit.t(), Unit.t()) :: {non_neg_integer(), [non_neg_integer()]}
  def kill_steps(u1, u2) do
    u2_initial_count = max(1, u2.count)
    slope_step = @kill_slope_factor / u2_initial_count

    # Luck ratio
    luck = @kill_spread_min + :rand.uniform() * (@kill_spread_max - @kill_spread_min)

    # Raw theoric kills before applying friction
    base_dmg =
      u1.count *
        u1.archetype.power *
        u1.archetype.kill_rate /
        u2.archetype.defense /
        @salvo_ticks *
        luck

    # Accumulating kills through ticks, applying friction
    Enum.reduce(1..@salvo_ticks, {0.0, []}, fn _tick, {acc_kill_count, acc_kill_steps} ->
      remaining_u2_count = u2.count - acc_kill_count

      if remaining_u2_count > 0 do
        friction = :math.tanh(remaining_u2_count * slope_step)
        real_tick_dmg = min(base_dmg * friction, remaining_u2_count)
        {acc_kill_count + real_tick_dmg, [trunc(real_tick_dmg) | acc_kill_steps]}
      else
        {acc_kill_count, [0 | steps]}
      end
    end)
    |> Enum.reverse()
  end

  @doc false
  @spec attacker_wins(Troop.t(), Troop.t()) :: boolean()
  def attacker_wins?(attacker_final_troop, defender_final_troop) do
    attacker_final_strength = Troop.military_strength(attacker_final_troop)
    defender_final_strength = Troop.military_strength(defender_final_troop)

    attacker_final_strength > (defender_final_strength * @victory_threshold)
  end

  @doc false
  @spec fame_drain(Troop.t(), Troop.t(), Decimal.t(), Decimal.t()) :: {Decimal.t(), Decimal.t()}
  def fame_drain(winner_initial_troop, loser_initial_troop, winner_fame, loser_fame) do
    winner_initial_strength = Troop.military_strength(winner_initial_troop)
    loser_initial_strength = Troop.military_strength(loser_initial_troop)

    # If winner’s strength is 0, that means they attacked with 0 unit.
    # In terms of business logic, this won’t happen, but let’s be
    # mathematically safe
    initial_strength_ratio = loser_initial_strength / case winner_initial_strength do
      0 -> 1
      n -> n
    end

    # BASE
    base_bounty = winner_initial_troop |> Enum.reduce(0, fn unit, acc ->
      acc + (unit.count * unit.archetype.fame_drain_rate * @fame_drain_dampener)
    end)

    # UNDERDOG MULTIPLIER
    underdog_multiplier = max(@underdog_multiplier_min, initial_strength_ratio)
    |> min(@underdog_multiplier_max)

    # PRESTIGE BONUS
    fame_diff = loser_fame - winner_fame
    prestige_bonus = max(0.0, fame_diff) * @fame_difference_slice

    drain = trunc(base_bounty * underdog_multiplier + prestige_bonus)

    # Todo: For now, fame drain is one to one. We should implement a friction
    # on successive attacks with a protection property on the kingdom and
    # a worker decrementing it every x hours
    {drain, -drain}
  end

  @spec choose_target!(Unit.t(), [Unit.t()]) :: Unit.t() | nil
  defp choose_target!(striking_unit, stricken_troop) do
    stricken_troop
    |> Enum.reject(fn candidate_unit ->
      same_side?(
        candidate_unit,
        striking_unit or
          candidate_unit.count === 0 or
          candidate_unit.stricken? or
          !can_reach?(striking_unit(candidate_unit))
      )
    end)
    |> Enum.random()
  end

  @spec choose_target(Unit.t(), [Unit.t()]) :: Unit.t() | nil
  defp choose_target(striking_unit, stricken_troop) do
    choose_target!(striking_unit, stricken_troop)
  rescue
    Enum.EmptyError -> nil
  end

  # Merge two raw lists of units into one flat list, having them shuffled
  # then sorted by speed.
  #
  # Shuffling before sorting allows to naturally randomize striking order
  # for opposite units with same speed. Otherwise, attacking b2, for example,
  # would always strike before defending b2.
  @spec format_troops_for_fight(Troop.t(), Troop.t()) :: [Unit.t()]
  defp format_troops_for_fight(attacking_troop, defending_troop) do
    [attacking_troop, defending_troop]
    |> List.flatten()
    # Naturally randomize striking order if speed equality
    |> Enum.shuffle()
    |> Enum.sort_by(& &1.archetype.speed, :desc)
  end

  # Distance units can reach all units.
  # Melee units cannot reach distance units.
  @spec can_reach?(Unit.t(), Unit.t()) :: boolean()
  defp can_reach?(%Unit{archetype: %{distance?: true}}, _), do: true
  defp can_reach?(_, %Unit{archetype: %{distance?: false}}), do: true
  defp can_reach?(_, _), do: false

  @spec same_unit?(Unit.t(), Unit.t()) :: boolean()
  defp same_unit?(u1, u2) do
    same_archetype?(u1, u2) && same_side?(u1, u2)
  end

  @spec same_archetype?(Unit.t(), Unit.t()) :: boolean()
  defp same_archetype?(u1, u2) do
    u1.archetype.id === u2.archetype.id
  end

  @spec same_side?(Unit.t(), Unit.t()) :: boolean()
  defp same_side?(u1, u2) do
    u1.attacker? === u2.attacker?
  end
end
