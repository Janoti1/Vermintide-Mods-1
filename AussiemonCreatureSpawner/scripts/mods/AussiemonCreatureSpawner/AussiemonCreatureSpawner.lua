local mod = get_mod("AussiemonCreatureSpawner")

mod.do_spawn = function() 
    local conflict_director = Managers.state.conflict
    conflict_director:debug_spawn_breed(0)
    mod:echo("[Spawn]: " .. conflict_director._debug_breed)
end

mod.do_next = function() 
    local conflict_director = Managers.state.conflict
    conflict_director:debug_spawn_switch_breed(0)
	mod:echo("[Switch]: " .. conflict_director._debug_breed)
end

mod.do_kill = function() 
    local conflict_director = Managers.state.conflict
    conflict_director:destroy_all_units()
	mod:echo("[Spawn]: Removed all enemies.")
end


--[[
	Prevents crashing the game when spawning Krench outside the proper area.
	Krench(es) spawned outsid the proper area don't spawn allies / don't reloacate before warding.
	
	The original copyright notice from the Aussiemon's Krench mutation mod can be found at the end of this file.
	
	Author: Xq
]]--


local may_spawn_allies = true

mod:hook(BTSpawnAllies, "enter", function(func, self, unit, blackboard, t)
    local action			= self._tree_node.action_data
	local spawn_group		= action.spawn_group
	local spawner_system	= Managers.state.entity:system("spawner_system")
	if spawner_system._id_lookup[spawn_group] == nil then
		-- the function replace below is needed for the AiBreedSnippets.on_storm_vermin_champion_update hook to take effect
		Breeds.skaven_storm_vermin_champion.run_on_update = AiBreedSnippets.on_storm_vermin_champion_update
		self._activate_ward(self, unit, blackboard)
		may_spawn_allies = false
		return
	else
		may_spawn_allies = true
		return func(self, unit, blackboard, t)
	end
end)

-- Catch nil spawning allies flag, taken from Aussiemon's Krench mutaion mod. Adapted for QoL by Xq.
mod:hook(BTSpawnAllies, "run", function (func, self, unit, blackboard, t, dt)
    if blackboard.spawning_allies == nil then
		return "done"
	else
		return func(self, unit, blackboard, t, dt)
	end
end)

mod:hook(GameNetworkManager, "anim_event", function(func, self, unit, event)
    local status, err = pcall(func, self, unit, event)
	
	if not status then
		mod:echo("Hook: GameNetworkManager.anim_event no status")
	end
end)

-- Stop artificially spawned Krenches spamming clan rats
mod:hook(AiBreedSnippets, "on_storm_vermin_champion_update", function(func, unit, blackboard, t, dt)
    if not may_spawn_allies then
		blackboard.trickle_timer = math.huge
	end
	func(unit, blackboard, t, dt)
end)

if not Breeds.skaven_storm_vermin_champion.combat_spawn_stinger then
	Breeds.skaven_storm_vermin_champion.combat_spawn_stinger = "Play_enemy_stormvermin_champion_electric_floor"
end