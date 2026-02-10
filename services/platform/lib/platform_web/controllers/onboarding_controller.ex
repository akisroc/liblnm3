defmodule PlatformWeb.OnboardingController do
  use PlatformWeb, :controller

  import PlatformWeb.OnboardingComponents

  alias Platform.IAM
  alias Platform.IAM.Ports.API.RegisterUserAndCreateSessionResponse
  alias Platform.Sovereignty
  alias Platform.Sovereignty.Ports.API.RegisterKingdomAndLeaderResponse

  def register_user(conn, %{} = _params) do
    conn
    |> render(:user_form)
  end
  def register_user(conn, %{"nickname" => nickname, "email" => email, "password" => password}) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    ua = conn |> get_req_header("user-agent") |> List.first()
    case IAM.register_user_and_create_session(nickname, email, password, ip, ua) do
      %RegisterUserAndCreateSessionResponse{user: user, session: session, errors: []} ->
        conn
        |> put_session(:token, Base.encode64(session.token))
        |> configure_session(renew: true)
        |> put_layout(false)
        |> render(:kingdom_and_leader_form, kingdom_name: "", leader_name: "")
    end
  end

  def register_kingdom_and_leader(conn, %{
        "kingdom_name" => kingdom_name,
        "leader_name" => leader_name,
        "player_id" => player_id
      }) do
    case Sovereignty.register_kingdom_and_leader(kingdom_name, leader_name, player_id) do
      %RegisterKingdomAndLeaderResponse{kingdom: kingdom, leader: leader, errors: []} ->
        conn
        |> put_resp_header("hx-redirect", ~p"/dashboard")
    end
  end

  defp render_component(conn, func, assigns \\ %{}) do
    send_resp(conn, conn.status || 200, func.(assigns))
  end
end
