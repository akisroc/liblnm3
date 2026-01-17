defmodule PlatformWeb.HealthController do
  use PlatformWeb, :controller

  def healthcheck(conn, _params) do
    conn
    |> send_resp(:no_content, "")
  end
end
