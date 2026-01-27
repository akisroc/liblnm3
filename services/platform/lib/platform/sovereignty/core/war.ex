defmodule Platform.Sovereignty.Core.War do
  alias Platform.Sovereignty.Core.War.Engine
  alias Platform.Sovereignty.Core.Types.{Troop, BattleOutcome}
  alias Platform.Sovereignty.Core.Entities.Kingdom

  # Todo: Fame shouldn’t be accessed like a simple float. It also
  # involves Kingdom’s Protagonists respective fames.

  @spec attack(Kingdom.t(), Kingdom.t()) :: {:ok, BattleOutcome.t()} | {:error, atom()}
  def attack(atk_kingdom, def_kingdom) do
    with :ok              <- check_attack_conditions(atk_kingdom, def_kingdom),
         {:ok, atk_troop} <- Troop.from_raw(atk_kingdom.attack_troop, true),
         {:ok, def_troop} <- Troop.from_raw(def_kingdom.defense_troop, false) do

      Engine.attack(atk_troop, def_troop, atk_kingdom.fame, def_kingdom.fame)
    end
  end

  @spec check_attack_conditions(Kingdom.t(), Kingdom.t()) :: :ok | {:error, atom()}
  defp check_attack_conditions(atk_kingdom, def_kingdom) do
    cond do
      atk_kingdom.id === def_kingdom.id -> {:error, :self_attacking_kingdom}
      !atk_kingdom.is_active            -> {:error, :inactive_attacker_kingdom}
      !def_kingdom.is_active            -> {:error, :inactive_defenser_kingdom}
      true                              -> :ok
    end
  end

end
