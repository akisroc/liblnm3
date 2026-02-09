defmodule Platform.IAM.Infra.Postgres.Types.Email do
  @moduledoc false
  use Ecto.Type

  @type t :: String.t()

  @email_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/

  def type, do: :string

  @spec cast(any()) :: {:ok, String.t() | nil} | {:error, Keyword.t()}
  def cast(nil), do: {:ok, nil}

  def cast(value) when is_binary(value) do
    cleaned_value = value |> String.trim() |> String.downcase()

    if Regex.match?(@email_regex, cleaned_value) do
      {:ok, cleaned_value}
    else
      {:error, [message: "Invalid email format"]}
    end
  end

  def cast(_), do: {:error, [message: "Email must be a string"]}

  def load(data) when is_binary(data), do: {:ok, data}
  def load(_), do: :error

  def dump(data) when is_binary(data), do: {:ok, data}
  def dump(_), do: :error
end
