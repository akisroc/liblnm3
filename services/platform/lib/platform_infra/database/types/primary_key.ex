defmodule PlatformInfra.Database.Types.PrimaryKey do
  use Ecto.Type

  alias Ecto.Changeset

  def type, do: :uuid

  def cast(binary) when is_binary(binary), do: {:ok, binary}
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
    if Changeset.fetch_field(changeset, :id) do
      changeset
    else
      Changeset.put_change(changeset, :id, UUIDv7.generate())
    end
  end

  def autogenerate, do: UUIDv7.generate()
end
