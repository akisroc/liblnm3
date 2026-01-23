defmodule Platform.Sovereignty.Infra.Persistence.Postgres.Schemas.Missive do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Sovereignty.Infra.Persistence.Postgres.Schemas.Kingdom
  alias Platform.Shared.Infra.Persistence.Postgres.Types.UUID7

  @content_max_length 10000

  @schema_prefix "sovereignty"
  @primary_key {:id, UUID7, autogenerate: true}
  @foreign_key_type UUID7

  schema "missives" do
    field :content, :string
    field :is_read, :boolean, default: false

    timestamps(updated_at: false)

    belongs_to :sender, Kingdom
    belongs_to :receiver, Kingdom
  end

  def create(missive, attrs) do
    missive
    |> cast(attrs, [:content, :sender_id, :receiver_id])
    |> validate_required([:content, :sender_id, :receiver_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: @content_max_length)

    |> assoc_constraint(:sender)
    |> assoc_constraint(:receiver)

    |> check_constraint(
      :receiver,
      name: :chk_missives_sender_is_not_receiver,
      message: "sender and receiver can’t be se same kingdom"
    )
  end

  def read(missive) do
    missive
    |> change()
    |> put_change(:is_read, true)
  end
end
