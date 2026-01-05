defmodule PlatformWeb.Plugs.FetchSessionUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    token = conn.req_cookies["_platform_user_token"]

    user = token && Platform.Accounts.Session.get_user_by_session_token(token)

    if user do
      assign(conn, :current_user, user)
    else
      conn
      |> put_status(:unauthorized)
      |> Phoenix.Controller.json(%{error: "Invalid or expired session"})
      |> halt()
    end
  end
end
