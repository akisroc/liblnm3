defmodule Platform.Social.Infra.Persistence.Postgres.Repo do
  use Ecto.Repo,
    otp_app: :platform,
    adapter: Ecto.Adapters.Postgres
end
