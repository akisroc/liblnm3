defmodule Platform.Shared.Infra.Persistence.Postgres.Types.UUID7 do
  use Ecto.Type

  alias Ecto.Changeset

  @type t :: UUIDv7.t()

  @uuidv7_regex ~r/^[0-9a-f]{8}(?:\-[0-9a-f]{4}){3}-[0-9a-f]{12}$/

  def type, do: :uuid

  def cast(binary) when is_binary(binary) do
    case Regex.match?(@uuidv7_regex, binary) do
      false -> {:error, [message: "Invalid UUIDv7 format"]}
      true -> {:ok, binary}
    end
  end
  def cast(_), do: :error

  def load(binary) do
    {:ok, Ecto.UUID.cast!(binary)}
  end

  def dump(uuid) when is_binary(uuid) do
    Ecto.UUID.dump(uuid)
  end
  def dump(_), do: :error

  @doc """
  Force :id generation if not present in changeset
  """
  @spec ensure_generation(Changeset.t()) :: Changeset.t()
  def ensure_generation(changeset) do
    id = Changeset.get_field(changeset, :id)

    if is_binary(id) do
      changeset
    else
      Changeset.put_change(changeset, :id, UUIDv7.generate())
    end
  end

  def generate, do: UUIDv7.generate()

  def autogenerate, do: generate()
end
