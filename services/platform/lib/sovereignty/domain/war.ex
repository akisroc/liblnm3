defmodule Platform.Sovereignty.War do
  alias Platform.Sovereignty.War.Engine
  alias Platform.Sovereignty.War.Types.BattleOutcome

  @doc """
  One troop attacks another troop.

  This battle produces an outcome.

  Given troops must be lists of 8 positive integers, representing
  an LNM troop: number of b1s, number of b2s, number of b3s, etc.

  Outcome is a BattleOutcome struct.
  """
  @spec attack([non_neg_integer()], [non_neg_integer()], float(), float()) :: {:ok, BattleOutcome.t()} | {:error, any()}
  def attack(atk_troop, def_troop, atk_fame, def_fame) do
    Engine.attack(atk_troop, def_troop, atk_fame, def_fame)
  end
end
