defmodule Platform.Roleplay.Infra.Postgres.Schemas.Chapter do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Platform.Roleplay.Infra.Postgres.Schemas.Chronicle
  alias Platform.Roleplay.Infra.Postgres.Schemas.Protagonist
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  @content_max_length 25_000

  @schema_prefix "roleplay"
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
