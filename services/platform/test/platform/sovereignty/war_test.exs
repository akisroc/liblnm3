defmodule Platform.Sovereignty.WarTest do
  use ExUnit.Case, async: true

  alias Platform.Sovereignty.Core.War
  alias Platform.Sovereignty.Core.Types.BattleOutcome
  alias Platform.Sovereignty.Core.Entities.Kingdom

  setup do
    :rand.seed(:exsss, {1, 2, 3})

    kingdom1 = %Kingdom{
      id: "123",
      def_troop: [2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500],
      atk_troop: [2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500],
      fame: 30000.0,
      active?: true,
      player: %{id: "abc"}
    }

    kingdom2 = %Kingdom{
      id: "456",
      def_troop: [2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500],
      atk_troop: [2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500],
      fame: 30000.0,
      active?: true,
      player: %{id: "def"}
    }

    {:ok, kingdom1: kingdom1, kingdom2: kingdom2}
  end

  describe "attack/2 – Clauses and validations" do

    test "obvious winner wins", %{kingdom1: k1, kingdom2: k2} do
      assert {:ok, %BattleOutcome{atk_wins?: false}} = War.attack(
        %{k1 | atk_troop: [10, 10, 10, 10, 10, 10, 10, 10]},
        %{k2 | def_troop: [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]}
      )
    end
  end
end
