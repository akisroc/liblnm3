defmodule Platform.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @username_regex ~r/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ\'’\-]+$/
  @email_regex ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
  @url_regex ~r/^https?:\/\/[\w\d\-._~:?#\[\]@!$&'()*+,;=%\/]+$/

  schema "users" do
    field :username, :string
    field :email, :string

    field :plain_password, :string, virtual: true
    field :password, :string

    field :profile_picture, :string
    field :slug, :string
    field :is_enabled, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :profile_picture, :password, :slug, :is_enabled])
    |> validate_required([:username, :email, :profile_picture, :password, :is_enabled])
    |> unique_constraint([:username, :email, :slug])

    |> update_change(:username, &String.trim/1)
    |> validate_length(:username, min: 1, max: 30)
    |> validate_format(:username, @username_regex)

    |> update_change(:email, &String.trim/1)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 1, max: 500)
    |> validate_format(:email, @email_regex)

    |> validate_length(:profile_picture, min: 1, max: 500)
    |> validate_format(:profile_picture, @url_regex)

    |> validate_length(:plain_password, min: 8, max: 72)
    |> put_password_hash()

    |> generate_slug()
  end

  defp put_password_hash(changeset) do
    if password = get_change(changeset, :plain_password) do
      put_change(changeset, :password, Argon2.hash_pwd_salt(password))
    else
      changeset
    end
  end

  defp generate_slug(changeset) do
    if username = get_change(changeset, :username) do
      put_change(changeset, :slug, Slugger.slugify(username))
    else
      changeset
    end
  end
end
