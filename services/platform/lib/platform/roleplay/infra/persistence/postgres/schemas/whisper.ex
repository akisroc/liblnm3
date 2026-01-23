defmodule Platform.Roleplaye.Infra.Persistence.Postgres.Schemas.Whisper do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Roleplay.Infra.Persistence.Postgres.Schemas.Protagonist
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  @schema_prefix "roleplay"
  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "whispers" do
    field :content, :string
    field :is_read, :boolean, default: false

    belongs_to :sender, Protagonist
    belongs_to :receiver, Protagonist

    timestamps()
  end

  def create(whisper, attrs) do
    whisper
    |> cast(attrs, [:content, :sender_id, :receiver_id])
    |> validate_required([:content, :sender_id, :receiver_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: 500)

    |> assoc_constraint(:sender)
    |> assoc_constraint(:receiver)

    |> check_constraint(
      :receiver,
      name: :chk_whispers_sender_is_not_receiver,
      message: "sender and receiver can’t be se same kingdom"
    )
  end

  def edit(whisper, content) when is_binary(content) do
    whisper
    |> change()
    |> validate_mutable_content()
    |> put_change(:content, content)
  end

  def read(whisper) do
    whisper |> change(is_read: true)
  end

  defp validate_mutable_content(changeset) do
    if get_change(changeset, :content) do
      if changeset.data.is_read do
        add_error(changeset, :content, "cannot modify content from a whisper which has been read")
      else
        changeset
      end
    else
      changeset
    end
  end
end
