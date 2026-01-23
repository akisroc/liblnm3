defmodule Platform.IAM.Infrastructure.IdentitiesControllerTest do
  use Platform.IAM.Infrastructure.Web.ConnCase, async: true

  alias Platform.IAM.Infrastructure.Persistence.Postgres.Schemas.User
  alias Platform.IAM.Infrastructure.Persistence.Postgres.Repositories.Identities

  describe "register_user/2" do
    @valid_attrs %{
      "nickname" => "P3ndra",
      "email" => "p3ndra@akisroc.org",
      "password" => "p3ndra1234!p3ndra1234!p3ndra1234!",
      "kingdom_name" => "Saranium",
      "leader_name" => "Harkkadius"
    }

    test "creates user, sets secure cookie and returns JSON", %{conn: conn} do
      conn = post(conn, ~p"/iam/register-user", @valid_attrs)

      assert %{
        "id" => user_id,
        "nickname" => "P3ndra",
        "email" => "p3ndra@akisroc.org",
        "slug" => _,
        "profile_picture" => _
      } = json_response(conn, 200)

      assert Identities.get_user(%{id: user_id})
    end
  end
end
