defmodule Platform.Roleplay.LoreNameTest do
  use ExUnit.Case, async: true

  alias Platform.Roleplay.LoreName

  setup do
    :ok
  end

  describe "generate/2" do
    test "checks integrity for 10000 random generations" do
      for _ <- 1..10000 do
        name = LoreName.generate(5, 10)
        len = String.length(name)
        assert is_binary(name)
        assert len >= 3 and len <= 12
      end
    end
  end
end
