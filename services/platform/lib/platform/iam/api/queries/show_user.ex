defmodule Platform.IAM.API.Queries.ShowUser do

  alias Platform.Shared.Domain.Types

  defstruct [
    :user_id,
    :slug
  ]

  @type t :: %__MODULE__{
    user_id: Types.id(),
    slug: String.t()
  }

  defimpl Platform.Shared.Protocols.Command do
    def execute(%{user_id: _id, slug: nil}) do

    end

    def execute(%{user_id: nil, slug: _slug}) do

    end
  end

end
