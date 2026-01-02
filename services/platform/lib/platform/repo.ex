defmodule Platform.Repo do
  use Ecto.Repo,
    otp_app: :platform,
    adapter: Ecto.Adapters.Postgres

  def autogenerate(:binary_id) do
    Uniq.UUID.uuidv7()
  end
end
