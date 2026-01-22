defmodule Platform.Shared.Domain.Events.UserRegistered do

  alias Platform.Shared.Domain.Entities.User

  @derive Jason.Encoder

  @message_type "user_registered"

  defstruct [
    :user_id,
    :email,
    :type,
    :occured_at,
    :provisioning_data
  ]

  @type t :: %__MODULE__{
    user_id: binary(),
    email: String.t(),
    type: String.t(),
    occured_at: DateTime.t(),
    provisioning_data: %{
      kingdom_name: String.t(),
      leader_name: String.t()
    } | %{}
  }

  @spec new(User.t(), map()) :: __MODULE__.t()
  def new(%User{}, provisioning_data) do
    %__MODULE__{
      user_id: user.id,
      email: user.email,
      type: @message_type,
      provisioning_data: provisioning_data,
      occured_at: DateTime.utc_now()
    }
  end

  @spec message_type :: @message_type
  def message_type, do: @message_type
end
