defprotocol PlatformWeb.Protocols.Presentable do
  @moduledoc """
  To be implemented for each usecase response.
  """

  @doc """
  Transform a response from the hexagon into a view model.
  """
  @spec to_view_model(struct(), atom) :: map()
  def to_view_model(data, context \\ :default)
end
