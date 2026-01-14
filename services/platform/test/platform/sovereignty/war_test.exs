defmodule Platform.Sovereignty.WarTest do
  use ExUnit.Case, async: true

  alias Platform.Sovereignty.War
  alias Platform.Sovereignty.War.Types.{Troop, Unit, UnitArchetype, BattleOutcome}

  setup do
    :rand.seed(:exsss, {1, 2, 3})

    b1 = UnitArchetype.get!(:b1)
    b2 = UnitArchetype.get!(:b2)
    b3 = UnitArchetype.get!(:b3)
    b4 = UnitArchetype.get!(:b4)
    b5 = UnitArchetype.get!(:b5)
    b6 = UnitArchetype.get!(:b6)
    b7 = UnitArchetype.get!(:b7)
    b8 = UnitArchetype.get!(:b8)

    {:ok, b1: b1, b2: b2, b3: b3, b4: b4, b5: b5, b6: b6, b7: b7, b8: b8}
  end

  describe "attack/4 – Clauses and validations" do
    test "accepts troops as raw lists of integers, %", %{b1: b1} do
      atk_troop = [2500, 0, 0, 0, 0, 0, 0, 0]
      def_troop = [1, 0, 0, 0, 0, 0, 0, 0]

      assert {:ok, %BattleOutcome{} = outcome} = War.attack(atk_troop, def_troop, 1000.0, 1000.0)
      asert outcome.attacker_wins? === true
    end

    test "returns error on invalid raw list length" do
      invalid_troop = [1000, 0]
      valid_troop = [1000, 0, 0, 0, 0, 0, 0, 0]

      assert {:error, :invalid_troop_format} = War.attack(invalid_troop, invalid_troop, 1000.0, 1000.0)
      assert {:error, :invalid_troop_format} = War.attack(invalid_troop, valid_troop, 1000.0, 1000.0)
      assert {:error, :invalid_troop_format} = War.attack(valid_troop, invalid_troop, 1000.0, 1000.0)
    end
  end
end
