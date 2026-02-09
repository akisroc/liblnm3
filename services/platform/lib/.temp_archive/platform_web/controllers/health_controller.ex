defmodule PlatformWeb.HealthController do
  use PlatformWeb, :controller

  def healthcheck(conn, _params) do
    send_resp(conn, :no_content, "")
  end
end
