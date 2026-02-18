defmodule PlatformWeb.SplashpageController do
  use PlatformWeb, :controller

  plug :put_layout, false

  def splashpage(conn, %{} = _params) do
    render(conn, :splashpage)
  end

  # defp render_component(conn, func, assigns \\ %{}) do
  #  send_resp(conn, conn.status || 200, func.(assigns))
  # end
end
