defmodule Platform.Roleplay.API.GenerateLoreName.Query do
  defstruct [
    models: [],
    min_len: 3,
    max_len: 12
  ]

  @type t :: %__MODULE__{
    models: [] | [atom()]
  }

  defimpl Platform.Shared.Protocols.Query do
    @lore_repository_adapter Application.compile_env(:platform, :lore_repository_adapter)

    alias Platform.Roleplay.Core.LoreName.Engine
    alias Platform.Roleplay.API.GenerateLoreName.{Query, Response}

    # Generation of one name has been benched at 14µs on a
    # Ryzen 3 laptop. It’s costless. So we generate 10 candidates
    # and try them all against database at once rather than
    # making multiple I/O round trips on duplicates. That’s brutal
    # but simple and effective. The day we run short on CPU, there
    # is still room for optimization in the engine, or even for
    # rewriting it in C or Rust.
    #
    # The function recalls itself if all candidates have been
    # rejected. This could never happen in 1000 years, but the
    # probability is not zero though, since some models can be
    # narrow on short rolls. (Ex: `:snake` model will often produce
    # “Vess”, “Zaj”, etc.)
    def execute(%{models: []} = cmd), do: execute(%{cmd | models: Engine.keys()})
    def execute(%{models: models, min_len: min_len, max_len: max_len} = cmd) do
      candidates = for _ <- 1..10 do
        Engine.generate(models, min_len, max_len)
      end
      |> @lore_repository_adapter.reject_existing_lore_names()

      case candidates do
        [head | _] -> %Response{name: head}
        [] -> execute(cmd)
      end
    end
  end
end
