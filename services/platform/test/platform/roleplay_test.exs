defmodule Platform.RoleplayTest do
  use Platform.DataCase, async: true

  alias Platform.Roleplay

  setup do
    :ok
  end

  describe "generate_lore_name/1" do
    test "checks generation" do
      :rand.seed(:exsss, {1, 2, 3})

      %{name: name} =
        Roleplay.generate_lore_name(%{
          archetypes: [:kurapika],
          min_len: 3,
          max_len: 12
        })

      assert name == "Bomoroka"
    end

    test "checks integrity with specified archetypes" do
      for _ <- 1..10 do
        %{name: name} =
          Roleplay.generate_lore_name(%{
            archetypes: [:kurapika, :swamp],
            min_len: 4,
            max_len: 11
          })

        len = String.length(name)
        assert is_binary(name)
        assert len >= 4 and len <= 11
      end

      for _ <- 1..10 do
        %{name: name} =
          Roleplay.generate_lore_name(%{
            archetypes: [:kurapika],
            min_len: 2,
            max_len: 12
          })

        len = String.length(name)
        assert is_binary(name)
        assert len >= 2 and len <= 12
      end

      for _ <- 1..10 do
        %{name: name} =
          Roleplay.generate_lore_name(%{
            archetypes: [:swamp],
            min_len: 6,
            max_len: 16
          })

        len = String.length(name)
        assert is_binary(name)
        assert len >= 6 and len <= 16
      end
    end

    test "checks integrity with omitted archetypes" do
      for _ <- 1..10 do
        %{name: name} =
          Roleplay.generate_lore_name(%{
            # Empty list
            archetypes: [],
            min_len: 4,
            max_len: 11
          })

        len = String.length(name)
        assert is_binary(name)
        assert len >= 4 and len <= 11
      end
    end
  end
end
