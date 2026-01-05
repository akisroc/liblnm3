defmodule PlatformWeb.SessionController do
  use PlatformWeb, :controller

  def login(conn, %{"email" => email, "password" => password}) do
    case Platform.Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = Platform.Accounts.Session.generate_session_token(user)

        conn
        |> put_resp_cookie("_platform_user_token", token,
          http_only: true,
          secure: true,
          same_site: "Lax",
          max_age: 60 * 60 * 24 * 120 # 120 days
        )

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end
end
