defmodule Platform.SovereigntyTest do
  use Platform.DataCase, async: true

  alias Platform.IAM
  alias Platform.Sovereignty

  setup do
    :ok
  end

  describe "register_kingdom_and_leader/3" do
    test "inserts in database" do
      for _ <- 1..5 do
        suffix = 4 |> :crypto.strong_rand_bytes() |> Base.encode16(case: :lower)

        nickname = "Harkka#{suffix}"
        email = "lnm#{suffix}@lnm.lnm"
        kingdom_name = "Saranium#{suffix}"
        leader_name = "Harkkadius#{suffix}"
        password = "123412341234"

        %{user: %{id: player_id}} = IAM.register_user(nickname, email, password)

        %{kingdom: kingdom, leader: leader, errors: errors} =
          Sovereignty.register_kingdom_and_leader(
            kingdom_name,
            leader_name,
            player_id
          )

        assert errors == []

        assert kingdom.name == kingdom_name
        assert kingdom.player_id == player_id

        assert leader.name == leader_name
        assert leader.player_id == player_id

        assert kingdom.leader_id == leader.id
        assert leader.kingdom_id == kingdom.id
      end
    end
  end
end
