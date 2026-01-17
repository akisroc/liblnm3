defmodule Platform.Sovereignty.Application.Commands.LaunchAttack do

  alias Platform.Sovereignty.Infrastructure.Persistence.KingdomRepo
  alias Platform.Sovereignty.Infrastructure.Persistence.BattleRepo
  
  defstruct [:atk_kingdom_id, :def_kingdom_id]

  def execute(%__MODULE__{} = cmd) do
    with {:ok, atk_kingdom} <- KingdomRepo.get(cmd.atk_kingdom_id)
         {:ok, def_kingdom} <- KingdomRepo.get(cmd.def_kingdom_id)
         true               <- atk_kingdom.id !== def_kingdom.id do
   
      with {:ok, outcome} <- solve_battle(
        atk_kingdom.attack_troop,
        def_kingdom.defense_troop,
        atk_kingdom.fame,
        def_kingdom.fame
      ) do
        
        BattleRepo.save_battle_result(outcome, atk_kingdom, def_kingdom)
      end
  end

end
