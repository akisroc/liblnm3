defmodule Platform.IAM.Infra.Persistence.Postgres.Types.Password do
  use Ecto.Type

  @type t :: String.t()

  def type, do: :string

  @spec cast(any()) :: {:ok, String.t() | nil} | {:error, Keyword.t()}
  def cast(nil), do: {:ok, nil}
  def cast(value) when is_binary(value) do
    {:ok, value}
  end
  def cast(_), do: {:error, [message: "Password must be a string"]}

  def load(data) when is_binary(data), do: {:ok, data}
  def load(_), do: :error

  def dump(data) when is_binary(data), do: {:ok, data}
  def dump(_), do: :error
end
