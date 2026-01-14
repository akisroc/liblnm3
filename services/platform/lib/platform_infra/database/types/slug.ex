defmodule PlatformInfra.Database.Types.Slug do
  use Ecto.Type

  alias Ecto.Changeset

  @slug_regex ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/

  def type, do: :string

  @spec cast(any()) :: {:ok, String.t() | nil} | {:error, Keyword.t()}
  def cast(nil), do: {:ok, nil}
  def cast(value) when is_binary(value) do
    case Regex.match?(@slug_regex, value) do
      false -> {:error, [message: "Invalid slug format"]}
      true -> {:ok, value}
    end
  end
  def cast(_), do: {:error, [message: "Slug must be a string"]}

  def load(data) when is_binary(data), do: {:ok, data}
  def load(_), do: :error

  def dump(data) when is_binary(data), do: {:ok, data}
  def dump(_), do: :error

  @doc """
  Slug is prefixed with the last characters of UUIDv7 to
  ensure unicity.

  `id` field must be hydrated at this stage, or the function
  will do nothing and return Changeset without generating
  slug.
  """
  @spec generate(Changeset.t(), atom()) :: Changeset.t()
  def generate(changeset, field) do
    id = Changeset.fetch_field(changeset, :id)
    value = Changeset.fetch_field(changeset, field)

    if id && value do
      Changeset.put_change(
        changeset,
        :slug,
        "#{String.slice(id, -6, 6)}-#{value}"
      )
    else
      changeset
    end
  end
end
