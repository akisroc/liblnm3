defmodule Platform.Shared.Domain.Types.LoreName do
  @type t :: String.t()

  @min_length 3
  @max_length 15

  @vowels ~w(a e i o u y)
  @diphtongs ~w(ou ei ai oi eu)
  @ligatures ~w(æ œ)

  @consonants ~w(
    b c d f g h
    j k l m n p
    q r s t v w
    x z
  )
  @clusters ~w(
    br cr st
  )
  @liquids ~w(r l m n)

  @starts ~w(a eu ho ya wi wo)
  @endings ~w(us or is la on ix bu)

  @template %{
    classic: [:start, :liquid, :vowel, :cluster, :vowel, :consonant, :ending]
  }

  def generate do
    length = Enum.random(@min_length..@max_length)
    offset = Enum.random(0..1)

    [:vowel, :consonant]
    |> Stream.cycle()
    |> Stream.drop(offset)
    |> Enum.take(length)
    |> Enum.map_join(&random_grapheme/1)
    |> String.capitalize()
  end

  defp random_grapheme(:vowel), do: Enum.random(@vowels)
  defp random_grapheme(:consonant), do: Enum.random(@consonants)
end
