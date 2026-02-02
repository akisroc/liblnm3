ExUnit.start()

repos = [
  Platform.Shared.Outbox.Infra.Persistence.Postgres.Repo,
  Platform.IAM.Infra.Persistence.Postgres.Repo,
  Platform.Roleplay.Infra.Persistence.Postgres.Repo,
  Platform.Social.Infra.Persistence.Postgres.Repo,
  Platform.Sovereignty.Infra.Persistence.Postgres.Repo
]

Enum.each(repos, fn repo ->
  Ecto.Adapters.SQL.Sandbox.mode(repo, :manual)
end)
