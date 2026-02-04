defmodule Platform.IAM.Entities.User do
  alias Platform.Shared.Domain.Types, as: SharedTypes

  defstruct [
    :id,
    :nickname,
    :email,
    :password,
    :profile_picture,
    :slug,
    :roles,
    :platform_theme,
    :is_enabled,
    :is_removed,
    :inserted_at,
    :updated_at
  ]

  @type t :: %__MODULE__{
          id: SharedTypes.id(),
          nickname: String.t() | nil,
          email: String.t() | nil,
          password: String.t() | nil,
          profile_picture: String.t() | nil,
          slug: String.t() | nil,
          roles: [String.t()] | nil,
          platform_theme: String.t() | nil,
          is_enabled: boolean() | nil,
          is_removed: boolean() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  def from_data(data) do
    %__MODULE__{
      id: data.id,
      nickname: data.nickname,
      email: data.email,
      password: data.password,
      profile_picture: data.profile_picture,
      slug: data.slug,
      roles: data.roles,
      platform_theme: data.platform_theme,
      is_enabled: data.is_enabled,
      is_removed: data.is_removed,
      inserted_at: data.inserted_at,
      updated_at: data.updated_at
    }
  end

  @spec can_login?(__MODULE__.t()) :: {:error, :user_removed} | {:error, :user_disabled} | :ok
  def can_login?(%{is_removed: true}), do: {:error, :user_removed}
  def can_login?(%{is_enabled: false}), do: {:error, :user_disabled}
  def can_login?(_), do: :ok
end
