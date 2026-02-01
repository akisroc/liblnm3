defmodule Platform.Roleplay.Core.LoreName.Models do
  @moduledoc """
  Fetch lore names models from sibling .exs files.

  Won’t compile if a name graph is malformed.
  """

  # ---
  # COMPILE TIME
  # ---

  validate_model! = fn chain, filename ->
    if not Map.has_key?(chain, :start) do
      raise CompileError,
        file: filename,
        description: "Lore name graph must contain key “:start”"
    end

    valid_keys = Map.keys(chain) |> MapSet.new()

    errors =
      Enum.reduce(chain, [], fn {source, transitions}, acc ->
        Enum.reduce(transitions, acc, fn {token, _weight}, err_acc ->
          cond do
            token == :end -> err_acc
            MapSet.member?(valid_keys, token) -> err_acc
            true ->
              ["[#{filename}] Dead end: token “#{source}” targets undefined “#{token}”" | err_acc]
          end
        end)
      end)

    if length(errors) > 0 do
      raise CompileError,
        file: filename,
        description: "\n" <> Enum.join(errors, "\n")
    end

    chain
  end

  @models_dir Path.join(__DIR__, "models")
  files = Path.wildcard(Path.join(@models_dir, "*.exs"))

  models_map = for file <- files, into: %{} do
    # Tell to compiler to recompile on change
    @external_resource file

    {data, _} = Code.eval_file(file)

    validate_model!.(data, file)

    model_key = file |> Path.basename(".exs") |> String.to_atom()

    {model_key, data}
  end

  @models models_map


  # ---
  # RUNTIME
  # ---

  def get(model_key) when is_atom(model_key), do: Map.get(@models, model_key)
  def all, do: @models
  def keys, do: Map.keys(@models)
end
