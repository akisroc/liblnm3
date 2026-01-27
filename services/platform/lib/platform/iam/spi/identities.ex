defmodule Platform.IAM.SPI.Identities do
  @moduledoc """
  Manages users and sessions
  """

  alias Platform.Shared.Domain.Types

  @callback get_user(token :: String.t()) :: {:ok, map()} | {:error, any()}
  @callback get_user(user :: %{id: Types.id()}) :: {:ok, map()} | {:error, any()}
  @callback get_user(user :: %{slug: String.t()}) :: {:ok, map()} | {:error, any()}
  @callback get_user(user :: %{email: String.t()}) :: {:ok, map()} | {:error, any()}
  @callback get_user(user :: %{nickname: String.t()}) :: {:ok, map()} | {:error, any()}

  @callback register_user(%{
              nickname: String.t(),
              email: String.t(),
              password: String.t()
            }) ::
              {:ok, %{id: Types.id()}} | {:error, any()}

  @callback get_session(%{token: String.t()}) :: {:ok, map()}
  @callback get_session(%{user_id: Types.id()}) :: {:ok, map()}

  @callback create_session(
              user_id :: Types.id(),
              token :: String.t(),
              inet_addr :: String.t(),
              expires_at :: DateTime.t(),
              user_agent :: String.t() | nil
            ) ::
              {:ok, %{id: Types.id(), token: String.t()}} | {:error, any()}
end
