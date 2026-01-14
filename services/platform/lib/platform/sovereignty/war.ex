defmodule Platform.Sovereignty.War do
  alias Platform.Sovereignty.War.Engine

  @doc """
  One troop attacks another troop.

  This battle produces an outcome.

  Given troops must be lists of 8 positive integers, representing
  an LNM troop: number of b1s, number of b2s, number of b3s, etc.

  Outcome is a struct.
  """
  @spec attack([non_neg_integer()], [non_neg_integer()], float(), float()) :: {:ok, BattleOutcome.t()} | {:error, any()}
  def attack([_,_,_,_,_,_,_,_] = atk_raw_troop, [_,_,_,_,_,_,_,_] = def_raw_troop, atk_fame, def_fame) do
    Engine.attack(atk_raw_troop, def_raw_troop, atk_fame, def_fame)
  end
end
