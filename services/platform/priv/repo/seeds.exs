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

# INITIAL ADMIN
admin_params = %{
  username: System.get_env("ADMIN_USERNAME") || "Admin",
  email: System.get_env("ADMIN_EMAIL") || "admin@akisroc.org",
  password: System.get_env("ADMIN_PASSWORD") || "devdevdev"
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

Platform.Repo.transaction(fn ->
  for _ <- 1..50 do
    user = %Platform.Accounts.User{}
    |> Platform.Accounts.User.changeset(%{
      username: Faker.Internet.user_name(),
      email: Faker.Internet.safe_email(),
      password: Faker.String.base64(16)
    })
    |> Platform.Repo.insert!()

    %Platform.Accounts.Session{}
    |> Platform.Accounts.Session.changeset(%{
      user_id: user.id,
      token: :crypto.hash(:sha256, :crypto.strong_rand_bytes(32)),
      ip_address: Faker.Internet.ip_v4_address(),
      user_agent: Faker.Internet.UserAgent.desktop_user_agent(),
      expires_at: Platform.Accounts.Session.expires_at(user)
    })
    |> Platform.Repo.insert!()
  end
end)
