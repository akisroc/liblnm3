defmodule Platform.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :nickname, :string
      add :email, :string
      add :password, :string
      add :remember_me, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
