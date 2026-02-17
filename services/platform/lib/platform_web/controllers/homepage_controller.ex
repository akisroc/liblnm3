defmodule PlatformWeb.HomepageController do
  use PlatformWeb, :controller

  def homepage(conn, %{} = _params) do
    conn
     |> render(:homepage)
  end

  #defp render_component(conn, func, assigns \\ %{}) do
  #  send_resp(conn, conn.status || 200, func.(assigns))
  #end
end
