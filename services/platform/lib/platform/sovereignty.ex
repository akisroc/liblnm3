defmodule Platform.Sovereignty do
  @kingships_repository_adapter Application.compile_env(:platform, :kingships_repository_adapter)

  # alias Platform.Sovereignty.Entities.Kingdom
  alias Platform.Sovereignty.Ports.API.RegisterKingdomAndLeaderResponse

  @doc """
  Register a new Kingdom with a new Notable as its leader.
  """
  @spec register_kingdom_and_leader(String.t(), String.t(), String.t()) :: RegisterKingdomAndLeaderResponse
  def register_kingdom_and_leader(kingdom_name, leader_name, player_id) do
    with {:ok, %{kingdom: kingdom, leader: leader}} <- @kingships_repository_adapter.register_kingdom_and_leader(
      kingdom_name, leader_name, player_id
    ) do
      %RegisterKingdomAndLeaderResponse{
        kingdom: kingdom,
        leader: leader,
        errors: []
      }
    else
      {:error, reason} -> %RegisterKingdomAndLeaderResponse{errors: [reason]}
    end
  end
end
