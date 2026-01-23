defmodule Platform.Shared.Infra.Persistence.Postgres.Types.LoreName do
  use Ecto.Type

  @type t :: String.t()

  @name_regex ~r/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$/

  def type, do: :string

  @spec cast(any()) :: {:ok, String.t() | nil} | {:error, Keyword.t()}
  def cast(nil), do: {:ok, nil}
  def cast(value) when is_binary(value) do
    case Regex.match?(@name_regex, value) do
      false -> {:error, [message: "Invalid name format"]}
      true -> {:ok, value}
    end
  end
  def cast(_), do: {:error, [message: "Name must be a string"]}

  def load(data) when is_binary(data), do: {:ok, data}
  def load(_), do: :error

  def dump(data) when is_binary(data), do: {:ok, data}
  def dump(_), do: :error
end
