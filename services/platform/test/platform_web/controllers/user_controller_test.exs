defmodule PlatformWeb.UserControllerTest do
  use PlatformWeb.ConnCase, async: true

  alias PlatformInfra.AccountsFixtures
  alias PlatformInfra.Database.Entities.User

  describe "POST /register" do
    # test "creates user with valid data", %{conn: conn} do
    #   user_params = %{
    #     username: "newuser",
    #     email: "newuser@example.com",
    #     password: "securepassword123"
    #   }

    #   conn = post(conn, ~p"/register", user: user_params)

    #   assert %{"message" => "User created", "email" => "newuser"} = json_response(conn, 201)
    # end

    test "returns errors with invalid data", %{conn: conn} do
      user_params = %{
        username: "",
        email: "invalid-email",
        password: "short"
      }

      conn = post(conn, ~p"/register", user: user_params)

      assert %{"errors" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "username")
      assert Map.has_key?(errors, "email")
      assert Map.has_key?(errors, "password")
    end

    test "returns error when email already exists", %{conn: conn} do
      _existing_user = AccountsFixtures.user_fixture(%{email: "taken@example.com"})

      user_params = %{
        username: "differentuser",
        email: "taken@example.com",
        password: "securepassword123"
      }

      conn = post(conn, ~p"/register", user: user_params)

      assert %{"errors" => %{"email" => _}} = json_response(conn, 422)
    end

    test "returns error when username already exists", %{conn: conn} do
      _existing_user = AccountsFixtures.user_fixture(%{username: "takenuser"})

      user_params = %{
        username: "takenuser",
        email: "different@example.com",
        password: "securepassword123"
      }

      conn = post(conn, ~p"/register", user: user_params)

      assert %{"errors" => %{"username" => _}} = json_response(conn, 422)
    end

    test "hashes password before storing", %{conn: conn} do
      user_params = %{
        username: "secureuser",
        email: "secure@example.com",
        password: "myplaintextpassword"
      }

      conn = post(conn, ~p"/register", user: user_params)

      assert json_response(conn, 201)

      # Verify password is hashed in database
      user = PlatformInfra.Repo.get_by(User, email: "secure@example.com")
      refute user.password == "myplaintextpassword"
      assert String.starts_with?(user.password, "$argon2")
    end
  end
end
