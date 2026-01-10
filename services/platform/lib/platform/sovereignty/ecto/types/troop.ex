defmodule Platform.Sovereignty.Ecto.Types.Troop do
  use Ecto.Type

  def type, do: {:array, :integer}

  @spec cast(any()) :: {:ok, [non_neg_integer()] | nil} | {:error, Keyword.t()}
  def cast(nil), do: {:ok, nil}
  def cast(values) when is_list(values) do
    if length(values) != 8 do
      {:error, [message: "Troop must have exactly 8 elements"]}
    else
      validate_elements(values)
    end
  end
  def cast(_), do: {:error, [message: "Troop must be a list of positive integers"]}

  def load(data) when is_list(data), do: {:ok, data}
  def load(_), do: :error

  def dump(data) when is_list(data), do: {:ok, data}
  def dump(_), do: :error

  defp validate_elements(list, acc \\ [])
  defp validate_elements([], acc), do: {:ok, Enum.reverse(acc)}
  defp validate_elements([head | tail], acc) do
    case to_int(head) do
      :error ->
        {:error, [message: "Troop must only contain integers"]}
      {:ok, val} when val < 0 ->
        {:error, [message: "Troop cannot contain negative integers"]}
      {:ok, val} ->
        validate_elements(tail, [val | acc])
    end
  end

  defp to_int(i) when is_integer(i), do: {:ok, i}
  defp to_int(s) when is_binary(s) do
    case Integer.parse(s) do
      {i, ""} -> {:ok, i}
      _ -> :error
    end
  end
  defp to_int(_), do: :error
end
