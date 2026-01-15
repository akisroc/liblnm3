defmodule PlatformInfra.Database.Types.Url do
  use Ecto.Type

  @url_regex ~r/^https?:\/\/[\w\d\-._~:?#\[\]@!$&'()*+,;=%\/]+$/
  @min_length 10
  @max_length 2048

  def type, do: :string

  @spec cast(any()) :: {:ok, String.t() | nil} | {:error, Keyword.t()}
  def cast(nil), do: {:ok, nil}
  def cast(value) when is_binary(value) do
    len = byte_size(value) # Faster than String.length/1 for ASCII

    cond do
      len < @min_length -> {:error, [message: "URL length must not be less than #{@min_length}"]}
      len > @max_length -> {:error, [message: "URL length must not exceed #{@max_length}"]}
      !Regex.match?(@url_regex, value) -> {:error, [message: "Invalid URL format"]}
      true -> validate_uri(value)
    end
  end
  def cast(_), do: {:error, [message: "URL must be a string"]}

  def load(data) when is_binary(data), do: {:ok, data}
  def load(_), do: :error

  def dump(data) when is_binary(data), do: {:ok, data}
  def dump(_), do: :error

  defp validate_uri(value) do
    case URI.new(value) do
      {:ok, %URI{scheme: s, host: h}} when s in ["http", "https"] and is_binary(h) ->
        if String.contains?(h, ".") do
          {:ok, value}
        else
          {:error, [message: "URL host must be a valid domain"]}
        end

      {:ok, _} ->
        {:error, [message: "Invalid URL scheme or missing host"]}

      {:error, part} ->
        {:error, [message: "Invalid URL component: #{part}"]}
    end
  end

end
