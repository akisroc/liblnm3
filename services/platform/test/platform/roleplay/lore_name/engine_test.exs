defmodule Platform.Roleplay.Core.LoreName.EngineTest do
  use ExUnit.Case, async: true

  alias Platform.Roleplay.Core.LoreName.Engine

  setup do
    :ok
  end

  describe "generate/2" do
    test "checks integrity for 10000 random generations" do
      for _ <- 1..10000 do
        name = Engine.generate(5, 10)
        len = String.length(name)
        assert is_binary(name)
        assert len >= 3 and len <= 12
      end
    end
  end
end
