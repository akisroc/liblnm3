defmodule Platform.Sovereignty.WarTest do
  use ExUnit.Case, async: true

  alias Platform.Sovereignty.Entities.Kingdom
  alias Platform.Sovereignty.Types.BattleOutcome
  alias Platform.Sovereignty.War

  setup do
    :rand.seed(:exsss, {1, 2, 3})

    kingdom1 = %Kingdom{
      id: "123",
      def_troop: [2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500],
      atk_troop: [2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500],
      fame: 30_000.0,
      active?: true,
      player: %{id: "abc"}
    }

    kingdom2 = %Kingdom{
      id: "456",
      def_troop: [2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500],
      atk_troop: [2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500],
      fame: 30_000.0,
      active?: true,
      player: %{id: "def"}
    }

    {:ok, kingdom1: kingdom1, kingdom2: kingdom2}
  end

  describe "attack/2 – Clauses and validations" do
    test "obvious winner wins", %{kingdom1: k1, kingdom2: k2} do
      {:ok, %BattleOutcome{} = outcome} =
        War.attack(
          %{k1 | atk_troop: [10, 10, 10, 10, 10, 10, 10, 10]},
          %{k2 | def_troop: [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]}
        )

      assert outcome.atk_wins? == false

      assert outcome.atk_fame_modifier < 0.0
      assert outcome.def_fame_modifier > 0.0
    end
  end
end
