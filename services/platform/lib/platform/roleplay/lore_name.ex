defmodule Platform.Roleplay.LoreName do
  @moduledoc false
  alias Platform.Roleplay.LoreName.Archetypes

  @type t :: String.t()

  def generate(min_len, max_len) do
    generate(Archetypes.keys(), min_len, max_len)
  end

  def generate([key | _] = keys, min_len, max_len) when is_atom(key) do
    keys |> Enum.random() |> generate(min_len, max_len)
  end

  def generate(key, min_len, max_len) when is_atom(key) do
    model = Archetypes.get(key)

    fn -> build_name(model) end
    |> Stream.repeatedly()
    |> Stream.reject(fn name ->
      len = String.length(name)
      len < min_len or len > max_len
    end)
    |> Enum.at(0)
  end

  defp build_name(model, current_token \\ :start, acc \\ "") do
    case pick_token(model, current_token) do
      :end ->
        String.capitalize(acc)

      next ->
        build_name(model, next, acc <> next)
    end
  end

  # Weighted random selection
  defp pick_token(%{} = model, key) do
    index =
      model[key]
      |> Enum.reduce(0, fn {_, weight}, acc -> acc + weight end)
      |> :rand.uniform()

    pick_token(model[key], index)
  end

  defp pick_token([{token, _}], _), do: token
  defp pick_token([{token, weight} | _], index) when weight >= index, do: token
  defp pick_token([{_, weight} | tail], index), do: pick_token(tail, index - weight)
end
