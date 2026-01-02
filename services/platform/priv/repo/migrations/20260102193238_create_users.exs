defmodule Platform.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :profile_picture, :string
      add :password, :string
      add :slug, :string
      add :is_enabled, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
