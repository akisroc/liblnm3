defmodule Platform.Roleplay.Core.LoreName.Generator do

  alias Platform.Roleplay.Core.LoreName.Archetype

  @default_archetype :zelda

  # ---
  # PRECOMPUTE ARCHETYPES
  # ---

  # Expand compressed groups of phonemes from archetypes.
  # Input: [{~w(a b), 2}, {~w(c), 3}]
  # Output: ["a", "b", "a", "b", "c", "c", "c"]
  expand_weighted_groups = fn groups ->
    Enum.flat_map(groups, fn {items, weight} ->
      Enum.flat_map(items, fn item -> List.duplicate(item, weight) end)
    end)
  end

  # Gaussian distribution for name length.
  compute_length_pool = fn archetype ->
    Enum.flat_map(archetype.length_min..archetype.length_max, fn length ->
      prob =
        :math.exp(-:math.pow(length - archetype.length_peak, 2)
        / (2 * :math.pow(archetype.length_spread, 2)))
      List.duplicate(length, max(1, round(prob * 100)))
    end)
  end

  for archetype <- Archetype.all() do
    length_pool = compute_length_pool.(archetype)
    vowels_pool = expand_weighted_groups.(archetype.vowels)
    consonants_pool= expand_weighted_groups.(archetype.consonants)

    def generate(unquote(archetype.identifier)) do
      length = Enum.random(unquote(length_pool))

      start_type =
        if :rand.uniform() < unquote(archetype.start_with_consonant_prob) do
          :consonant
        else
          :vowel
        end

      offset = if start_type == :vowel, do: 0, else: 1

      [:vowel, :consonant]
      |> Stream.cycle()
      |> Stream.drop(offset)
      |> Enum.take(length)
      |> Enum.map_join(fn
        :vowel -> Enum.random(unquote(vowels_pool))
        :consonant -> Enum.random(unquote(consonants_pool))
      end)
      |> String.capitalize()
    end
  end
  def generate(_), do: generate(@default_archetype)
  def generate, do: generate(@default_archetype)
end
