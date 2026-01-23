# defmodule Platform.IAM.Infra.Web.IdentitiesController do

#   alias Platform.IAM.API.Commands.{RegisterUser, LoginUser, LogoutUser}
#   alias Platform.Shared.Protocols.Command

#   def register_user(conn, %{
#     "nickname" => nickname,
#     "email" => email,
#     "password" => password,
#     "kingdom_name" => kingdom_name,
#     "leader_name" => leader_name
#   }) do
#     command = %RegisterUser{
#       nickname: nickname,
#       email: email,
#       password: password,
#       metadata: %{
#         remote_ip: conn.remote_ip |> :inet.ntoa() |> to_string(),
#         user_agent: conn |> get_req_header("user-agent") |> List.first()
#       }
#     }

#     with {:ok, %{user: user, session: session}} <- Command.execute(command) do
#       conn
#       |> put_resp_cookie(
#         "_lnm_platform_user_token",
#         Base.url_encode64(session.token, padding: false),
#         http_only: true,
#         secure: true,
#         same_site: "Lax",
#         domain: ".localhost", # Todo
#         path: "/",
#         max_age: DateTime.diff(session.expires_at, DateTime.utc_now(), :second)
#       )
#       |> put_status(:ok)
#       |> json(%{
#         id: user.id,
#         nickname: user.nickname,
#         email: user.email,
#         profile_picture: user.profile_picture,
#         slug: user.slug
#       })
#     end
#   end
# end
