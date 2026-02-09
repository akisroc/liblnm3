defmodule Platform.Roleplay.LoreName.Archetypes do
  @moduledoc """
  Fetch lore names archetypes from sibling .exs files.

  Won’t compile if a name graph is malformed.
  """

  # ---
  # COMPILE TIME
  # ---

  validate_archetype! = fn chain, filename ->
    unless Map.has_key?(chain, :start) do
      raise CompileError,
        file: filename,
        description: "Lore name graph must contain key “:start”"
    end

    valid_keys = chain |> Map.keys() |> MapSet.new()

    errors =
      Enum.reduce(chain, [], fn {source, transitions}, acc ->
        Enum.reduce(transitions, acc, fn {token, _weight}, err_acc ->
          cond do
            token == :end ->
              err_acc

            MapSet.member?(valid_keys, token) ->
              err_acc

            true ->
              ["[#{filename}] Dead end: token “#{source}” targets undefined “#{token}”" | err_acc]
          end
        end)
      end)

    unless Enum.empty?(errors) do
      raise CompileError,
        file: filename,
        description: "\n" <> Enum.join(errors, "\n")
    end

    chain
  end

  @archetypes_dir Path.join(__DIR__, "archetypes")
  files = Path.wildcard(Path.join(@archetypes_dir, "*.exs"))

  archetypes_map =
    for file <- files, into: %{} do
      # Tell to compiler to recompile on change
      @external_resource file

      {data, _} = Code.eval_file(file)

      validate_archetype!.(data, file)

      archetype_key = file |> Path.basename(".exs") |> String.to_atom()

      {archetype_key, data}
    end

  @archetypes archetypes_map

  # ---
  # RUNTIME
  # ---

  def get(archetype_key) when is_atom(archetype_key), do: Map.get(@archetypes, archetype_key)
  def all, do: @archetypes
  def keys, do: Map.keys(@archetypes)
end
