defmodule Platform.Roleplay do
  @lore_repository_adapter Application.compile_env(:platform, :lore_repository_adapter)

  alias Platform.Roleplay.LoreName
  alias Platform.Roleplay.Ports.API.GenerateLoreNameResponse

  @doc """
  Generate a random lore name from one of the given archetypes and
  in given bounds.

  If an empty list is given for archetypes, the engine will pick one in
  all available archetypes.

  Unicity of the name is checked in database.

  Race remains possible. The prophecy says that once in every century,
  one of our 23 billion users will have his generated name taken before
  he can submit the form. This cursed soul will have to generate again.
  """
  # Generation of one name has been benchmarked at 14µs on a
  # Ryzen 3 laptop. It will be costless in prod env. So we generate
  # 10 candidates and try them all against database at once rather
  # than making multiple I/O round trips on duplicates. That’s brutal
  # but simple and effective. The day we run short on CPU, there
  # is still room for optimization in the engine’s algo, or even for
  # rewriting it in Rust or C++.
  #
  # The function recalls itself if all candidates have been
  # rejected. This could never happen in 1000 years, but the
  # probability is not zero though, since some archetypes can be
  # narrow on short rolls. (Ex: `:swamp` archetype will often produce
  # “Vess”, “Zaj”, etc.)
  @spec generate_lore_name(
    %{archetypes: [atom()],
    min_len: non_neg_integer(),
    max_len: non_neg_integer()}
  ) :: GenerateLoreNameResponse.t()

  def generate_lore_name(%{archetypes: []} = query) do
     generate_lore_name(%{query | archetypes: LoreName.Archetypes.keys()})
  end

  def generate_lore_name(%{archetypes: archetypes, min_len: min_len, max_len: max_len} = query) do
    candidates = for _ <- 1..10 do
      LoreName.generate(archetypes, min_len, max_len)
    end
    |> @lore_repository_adapter.reject_existing_lore_names()

    case candidates do
      [head | _] -> %GenerateLoreNameResponse{name: head}
      [] -> generate_lore_name(query)
    end
  end
end
