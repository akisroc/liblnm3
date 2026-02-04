# defmodule Platform.IAM.Infra.Web.IdentitiesController do

#   use PlatformWeb, :controller

#   alias Ecto.Changeset

#   alias Platform.IAM.API.Commands.RegisterUser
#   alias Platform.Shared.Protocols.Command

#   def register_user(conn, %{"nickname" => nickname, "email" => email, "password" => password}) do
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
#         slug: user.slug
#       })
#     else
#       {:error, %Changeset{} = changeset} ->
#         conn
#         |> put_status(:unprocessable_entity)
#         |> json(%{errors: Changeset.traverse_errors(changeset, &format_error/1)})
#       {:error, _operation, %Changeset{} = changeset, _changes} ->
#         conn
#         |> put_status(:unprocessable_entity)
#         |> json(%{errors: Changeset.traverse_errors(changeset, &format_error/1)})
#       {:error, reason} ->
#         conn
#         |> put_status(:bad_request)
#         |> json(%{errors: [inspect(reason)]})
#     end
#   end
#   def register_user(conn, _params) do
#     conn
#     |> put_status(:bad_request)
#     |> json(%{error: "Missing required fields. Must specify nickname, email and password."})
#   end

#   defp format_error({msg, opts}) do
#     Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
#       opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
#     end)
#   end
# end
