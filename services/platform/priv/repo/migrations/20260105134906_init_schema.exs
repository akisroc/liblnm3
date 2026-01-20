defmodule PlatformInfra.Repo.Migrations.InitSchema do
  @moduledoc """
  First database schema initialization.

  Incremental migrations won’t be used during initial
  development phase. The files init_db.sql and deinit_db.sql
  will be maintained instead, and the dev database locally
  reset at each alteration if needed.

  This method will no longer be used once the application is
  in production. At this time, Ecto’s migration system is to
  be used as intended.
  """

  use Ecto.Migration

  def up do
    execute_sql_file Application.app_dir(:platform, "priv/repo/migrations/init_db.sql")

  end

  def down do
    execute_sql_file Application.app_dir(:platform, "priv/repo/migrations/deinit_db.sql")
  end

  # Ecto cannot execute multiple `xxx;` SQL commands at once.
  # Have to split SQL into multiple subcommands when calling an
  # external file.
  #
  # The split is simple, so keep the SQL file simple too:
  # Blocks end with two semicolons
  defp execute_sql_file(path) do
    path
    |> File.read!()
    |> String.split(~r/;;\s*\n/)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 === ""))
    |> Enum.each(&execute/1)
  end
end
