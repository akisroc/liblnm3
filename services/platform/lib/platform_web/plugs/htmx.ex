defmodule PlatformWeb.Plugs.HTMX do
  @moduledoc false
  import Phoenix.Controller
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_req_header(conn, "hx-request") != [] do
      put_root_layout(conn, html: false)
    else
      conn
    end
  end
end
