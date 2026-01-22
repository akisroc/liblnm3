defmodule Platform.Roleplay.Infrastructure.Persistence.Schemas.Chapter do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Roleplay.Infrastructure.Persistence.Schemas.{Chronicle, Protagonist}
  alias Platform.Shared.Infrastructure.Persistence.Types.UUID7

  @content_max_length 25000

  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "chapters" do
    field :content, :string

    timestamps()

    belongs_to :chronicle, Chronicle
    belongs_to :protagonist, Protagonist
  end

  def create(chapter, attrs) do
    chapter
    |> cast(attrs, [:content, :chronicle_id, :protagonist_id])
    |> validate_required([:content, :chronicle_id, :protagonist_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: @content_max_length)

    |> assoc_constraint(:chronicle)
    |> assoc_constraint(:protagonist)
  end

  def update(chapter, attrs) do
    chapter
    |> cast(attrs, [:content])
    |> validate_required(:content)

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: @content_max_length)
  end
end
