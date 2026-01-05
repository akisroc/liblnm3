defmodule Platform.EctoTypes.UUIDv7 do
  use Ecto.Type
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

  def autogenerate, do: UUIDv7.generate()
end
