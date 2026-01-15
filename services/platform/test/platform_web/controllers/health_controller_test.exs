defmodule PlatformWeb.HealthControllerTest do
  use PlatformWeb.ConnCase, async: true

  describe "GET /ping" do
    test "returns 204", %{conn: conn} do
      response = conn
      |> get(~p"/ping")
      |> response(:no_content)

      assert response == ""
    end
  end
end
