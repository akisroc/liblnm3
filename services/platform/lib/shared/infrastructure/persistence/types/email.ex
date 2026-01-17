defmodule Platform.Shared.Infrastructure.Persistence.Types.Email do
  use Ecto.Type

  alias Ecto.Changeset

  @type t :: String.t()

  @email_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/

  def type, do: :string

  @spec cast(any()) :: {:ok, String.t() | nil} | {:error, Keyword.t()}
  def cast(nil), do: {:ok, nil}
  def cast(value) when is_binary(value) do
    case Regex.match?(@name_regex, value) do
      false -> {:error, [message: "Invalid email format"]}
      true -> {:ok, value}
    end
  end
  def cast(_), do: {:error, [message: "Email must be a string"]}

  def load(data) when is_binary(data), do: {:ok, data}
  def load(_), do: :error

  def dump(data) when is_binary(data), do: {:ok, data}
  def dump(_), do: :error
end
