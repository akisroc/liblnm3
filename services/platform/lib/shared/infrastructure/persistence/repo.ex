defmodule Platform.Shared.Infrastructure.Persistence.Repo do
  use Ecto.Repo,
    otp_app: :platform,
    adapter: Ecto.Adapters.Postgres
end
