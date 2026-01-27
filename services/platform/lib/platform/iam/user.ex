defmodule Platform.IAM.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :nickname, :string
    field :email, :string
    field :password, :string
    field :remember_me, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :email, :password, :remember_me])
    |> validate_required([:nickname, :email, :password, :remember_me])
  end
end
