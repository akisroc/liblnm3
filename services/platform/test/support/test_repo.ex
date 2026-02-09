defmodule Platform.TestRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :platform,
    adapter: Ecto.Adapters.Postgres
end
