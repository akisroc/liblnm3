defmodule Platform.Shared.Infrastructure.Persistence.Schemas.Shout do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Shared.Infrastructure.Persistence.Schemas.Protagonist
  alias Platform.Shared.Infrastructure.Persistence.Types.UUID7

  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "shouts" do
    field :content, :string

    belongs_to :protagonist, Protagonist

    timestamps(type: :utc_datetime)
  end

  def create_changeset(shout, attrs) do
    shout
    |> cast(attrs, [:content, :protagonist_id])
    |> validate_required([:content, :protagonist_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: 500)
  end
end
