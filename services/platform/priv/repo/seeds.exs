# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Platform.Repo.insert!(%Platform.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

admin_password = System.get_env("ADMIN_PASSWORD") || "devdevdev"
admin_params = %{
  username: "Admin",
  email: "admin@akisroc.org",
  password: admin_password
}

Platform.Repo.transaction(fn ->
  case Platform.Repo.get_by(Platform.Accounts.User, email: admin_params.email) do
    nil ->
      case Platform.Accounts.register_user(admin_params) do
        {:ok, _user} ->
          IO.puts("✅ Admin created")
        {:error, changeset} ->
          IO.puts("❌ Critical error on admin creation")
          IO.inspect(changeset.errors)
          Platform.Repo.rollback(:registration_failed)
      end

    _user -> IO.puts("Admin already exists. Seed ignored.")
  end
end)
