defmodule PlatformInfra.Database.Types.Slug do
  use Ecto.Type

  alias Ecto.Changeset

  # Allow:
  # Normal prefixed slug (see generate/2 function)
  # Full uuidv7 in edge cases
  @slug_regex ~r/^(?:[a-z0-9]+(?:-[a-z0-9]+)*|[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12})$/

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
  ensure unicity. We use 8 characters to prevent birthday
  paradox: ~4,29 billion combinations, so we would need
  65’536 resources with same given field’s value for
  the risk of collision to become statically significative.

  `id` field must be hydrated at this stage, or the function
  will do nothing and return Changeset without generating
  slug.

  If for some reason the field’s value is not sluggable
  and becomes "", we fallback to the full primary key.
  This is extreme case, shouldn’t happen much.
  """
  @spec generate(Changeset.t() | binary(), atom() | binary()) :: Changeset.t()
  def generate(%Changeset{} = changeset, field) do
    id = Changeset.get_field(changeset, :id)
    value = Changeset.get_field(changeset, field)

    if is_binary(id) && is_binary(value) do
      changeset |> Changeset.put_change(:slug, generate(id, value))
    else
      changeset
    end
  end
  def generate(id, value) when is_binary(id) and is_binary(value) do
    suffix = Slugger.slugify_downcase(value)

    if suffix == "" do
      id
    else
      "#{String.slice(id, -8, 8)}-#{suffix}"
    end
  end
end
