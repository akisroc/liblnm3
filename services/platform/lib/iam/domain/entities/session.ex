defmodule Platform.IAM.Domain.Entities.Session do
  alias Platform.Shared.Domain.Types, as: SharedTypes

  @admin_duration 1
  @user_duration 90

  defstruct [
    :id,
    :user_id,
    :token,
    :context,
    :ip_address,
    :user_agent,
    :inserted_at,
    :expires_at
  ]

  @type t :: %__MODULE__{
          id: SharedTypes.id(),
          user_id: SharedTypes.id(),
          token: binary() | nil,
          context: String.t() | nil,
          ip_address: binary() | nil,
          user_agent: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          expires_at: DateTime.t() | nil
        }

  def get_expiration_date(%{roles: roles}) do
    days = if Enum.member?(roles, :admin), do: @admin_duration, else: @user_duration
    DateTime.utc_now() |> DateTime.add(days, :day)
  end
end
