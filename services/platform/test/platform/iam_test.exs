defmodule Platform.IAMTest do
  use Platform.DataCase

  alias Platform.IAM

  describe "users" do
    alias Platform.IAM.User

    import Platform.IAMFixtures

    @invalid_attrs %{password: nil, nickname: nil, email: nil, remember_me: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert IAM.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert IAM.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{password: "some password", nickname: "some nickname", email: "some email", remember_me: true}

      assert {:ok, %User{} = user} = IAM.create_user(valid_attrs)
      assert user.password == "some password"
      assert user.nickname == "some nickname"
      assert user.email == "some email"
      assert user.remember_me == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = IAM.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{password: "some updated password", nickname: "some updated nickname", email: "some updated email", remember_me: false}

      assert {:ok, %User{} = user} = IAM.update_user(user, update_attrs)
      assert user.password == "some updated password"
      assert user.nickname == "some updated nickname"
      assert user.email == "some updated email"
      assert user.remember_me == false
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = IAM.update_user(user, @invalid_attrs)
      assert user == IAM.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = IAM.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> IAM.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = IAM.change_user(user)
    end
  end
end
