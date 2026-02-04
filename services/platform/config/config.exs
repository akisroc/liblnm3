# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :platform,
  ecto_repos: [
    Platform.Shared.Outbox.Infra.Persistence.Postgres.Repo,
    Platform.IAM.Infra.Persistence.Postgres.Repo,
    Platform.Roleplay.Infra.Postgres.Repo,
    Platform.Social.Infra.Persistence.Postgres.Repo,
    Platform.Sovereignty.Infra.Persistence.Postgres.Repo
  ],
  generators: [timestamp_type: :utc_datetime]

config :platform, Platform.Shared.Outbox.Infra.Persistence.Postgres.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_foreign_key: [type: :binary_id]

config :platform, Platform.IAM.Infra.Persistence.Postgres.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_foreign_key: [type: :binary_id]

config :platform, Platform.Roleplay.Infra.Postgres.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_foreign_key: [type: :binary_id]

config :platform, Platform.Social.Outbox.Infra.Persistence.Postgres.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_foreign_key: [type: :binary_id]

config :platform, Platform.Sovereignty.Outbox.Infra.Persistence.Postgres.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_foreign_key: [type: :binary_id]

# Configures the endpoint
config :platform, PlatformWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: PlatformWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Platform.PubSub,
  live_view: [signing_salt: "platform_liveview"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :platform, Platform.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# SECONDARY ADAPTERS
config :platform, :identities_adapter,
  Platform.IAM.Infra.Persistence.Postgres.Repositories.Identities

config :platform, :kingships_adapter,
  Platform.Sovereignty.Infra.Persistence.Postgres.Repositories.Kingships

config :platform, :lore_repository_adapter,
  Platform.Roleplay.Infra.Postgres.LoreRepository

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
