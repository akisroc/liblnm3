defmodule Platform.Roleplay.Core.LoreName.EngineTest do
  use ExUnit.Case, async: true

  alias Platform.Roleplay.Core.LoreName.Engine

  setup do
    :ok
  end

  describe "generate/2" do
    test "generates names" do
      assert is_binary(Engine.generate(3, 12))
    end
  end
end
