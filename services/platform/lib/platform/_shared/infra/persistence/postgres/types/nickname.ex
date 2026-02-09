defmodule Platform.Shared.Infra.Persistence.Postgres.Types.Nickname do
  @moduledoc false
  use Ecto.Type

  @type t :: String.t()

  @nickname_regex ~r/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ\'’\-_\.&]+$/

  def type, do: :string

  @spec cast(any()) :: {:ok, String.t() | nil} | {:error, Keyword.t()}
  def cast(nil), do: {:ok, nil}

  def cast(value) when is_binary(value) do
    cleaned_value = String.trim(value)

    if Regex.match?(@nickname_regex, cleaned_value) do
      {:ok, cleaned_value}
    else
      {:error, [message: "Invalid nickname format"]}
    end
  end

  def cast(_), do: {:error, [message: "Nickname must be a string"]}

  def load(data) when is_binary(data), do: {:ok, data}
  def load(_), do: :error

  def dump(data) when is_binary(data), do: {:ok, data}
  def dump(_), do: :error
end
