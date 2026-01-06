defmodule PlatformWeb.SessionController do
  use PlatformWeb, :controller

  def login(conn, %{"email" => email, "password" => password}) do
    case Platform.Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = Platform.Accounts.Session.generate_session_token(
          user,
          conn.remote_ip |> :inet.ntoa() |> to_string(),
          conn |> get_req_header("user-agent") |> List.first()
        )
        |> Base.url_encode64(padding: false)

        conn
        |> put_resp_cookie("_platform_user_token", token,
          http_only: true,
          secure: true,
          same_site: "Lax",
          max_age: Platform.Accounts.Session.session_validity_in_seconds()
        )
        |> put_status(:ok)
        |> json(%{
          token: token,
          user_id: user.id,
          user_email: user.email,
          user_slug: user.slug
        })

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end
end
