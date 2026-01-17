defmodule Platform.Sovereignty.Application.Queries.ShowKingdomDetails do
  @repository_adapter Application.compile_env(:platform, :kingdom_repository_adapter)

  alias Platform.Sovereignty.Domain.Entities.Kingdom
  alias Platform.Shared.Domain.Types

  defstruct [
    :kingdom_id
  ]

  @type t :: %__MODULE__{
    kingdom_id: Types.id()
  }

  # Todo: Better than map()
  # @spec execute(__MODULE__.t()) :: {:ok, map()} | {:error, any()}
  defimpl Platform.Shared.Application.Query do
    def execute(%{kingdom_id: kid}) do
      @repository_adapter.show_kingdom_details(kid)
    end
  end
end
