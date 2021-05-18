local mod = get_mod("VerminTrainer")
local compositions = {}
local selected_composition = 0
local enabled = false

mod.get_comps = function()
    selected_composition = 0
    table.clear(compositions)
    for key,sub in pairs(HordeWaveCompositions) do 
        for key2, value in pairs(sub) do
            table.insert( compositions, value )
        end
    end
end

mod.on_enabled = function()
    mod.get_comps()
end
 

mod.on_game_state_changed = function(status, state)
    if status == "enter" and state == "StateIngame" then
        mod.get_comps()
    end
end

-- Function to enable/disable various spawn-related debug parameters.
mod.set_pacing = function()
	enabled = not enabled -- Flipping our boolean argument, since "true" here means disabled.
	mod:echo("[VerminTrainer] Pacing Disabled: %s", enabled)
	
	-- These are a set of debug variables within the game that are usually dormant. 
	-- By setting these to 'true', the various enemy spawning systems are told not to spawn their stuff.
	script_data.ai_mini_patrol_disabled = enabled
	script_data.ai_critter_spawning_disabled = enabled
	script_data.ai_horde_spawning_disabled = enabled
	script_data.ai_roaming_spawning_disabled = enabled
	script_data.ai_boss_spawning_disabled = enabled
	script_data.ai_rush_intervention_disabled = enabled
	--script_data.ai_bots_disabled = enabled -- This one just removes the bots
	script_data.ai_specials_spawning_disabled = enabled
	script_data.ai_pacing_disabled = enabled
	script_data.ai_outside_navmesh_intervention_disabled = enabled
end

mod:command("training", "", function()
	mod.set_pacing()
end)


mod.get_pos_ahead_or_behind_players_on_mainpath = function(check_ahead, dist, raw_dist, side_id)
	local conflict_director = Managers.state.conflict
	local main_path_info = conflict_director.main_path_info
	local player_unit = Managers.player:local_player().player_unit
	local wanted_pos, to_player_dir = nil
	local hidden = true

	if player_unit then
		local player_info = conflict_director.main_path_player_info[player_unit]
		local dist = player_info.travel_dist + dist * ((check_ahead and 1) or -1)

		if dist < 0 then
			return false
		end

		local path_pos, path_index = MainPathUtils.point_on_mainpath(nil, dist)

		if path_pos then
			local dir = Unit.local_position(player_unit, 0) - path_pos
			wanted_pos = path_pos
			to_player_dir = dir
		end
	end

	if wanted_pos then
		local side = Managers.state.side:get_side(side_id)
		local player_positions = side.ENEMY_PLAYER_POSITIONS
		local h = Vector3(0, 0, 1)

		for j = 1, #player_positions, 1 do
			local avoid_pos = player_positions[j]
			local los = PerceptionUtils.position_has_line_of_sight_to_any_player(wanted_pos + h)

			if los then
				hidden = false

				print("Horde spawn position is within line of sight of players, aborting")

				break
			end
		end
	end

	local is_within_raw_distance = false

	if hidden and to_player_dir then
		local distance = Vector3.length(to_player_dir)

		if raw_dist < distance then
			is_within_raw_distance = true
		end
	end

	if hidden and is_within_raw_distance then
		return true, wanted_pos, to_player_dir
	else
		return false
	end
end

mod:command("getPos", "", function()
    local player_unit = Managers.player:local_player().player_unit
    local current_position = Unit.local_position(player_unit, 0)
    local current_rotation = Unit.local_rotation(player_unit, 0)

    mod:echo(current_position)
    mod:echo(current_rotation)
	mod:echo(Managers.state.game_mode:level_key())

    mod:dump(HordeWaveCompositions, "", 2)
end)

mod.spawnComposition = function(comp_name) 
    local player_unit = Managers.player:local_player().player_unit
    local conflict_director = Managers.state.conflict;
    local horde_spawner = conflict_director.horde_spawner

	local main_path_chance_spawning_ahead = 0.5
	local roll = math.random()
	local spawn_horde_ahead = roll <= main_path_chance_spawning_ahead
	local main_path_dist_from_players = 25
	local raw_dist_from_players = 25
	local side_id = 2

	local success, blob_pos, to_player_dir = mod.get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, main_path_dist_from_players, raw_dist_from_players, side_id)
	if not success then
		success, blob_pos, to_player_dir = mod.get_pos_ahead_or_behind_players_on_mainpath(not spawn_horde_ahead, main_path_dist_from_players, raw_dist_from_players, side_id)

		if not success then
			local roll = math.random()
			local spawn_horde_ahead = roll <= main_path_chance_spawning_ahead
			local distance_bonus = 20
			success, blob_pos, to_player_dir = mod.get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, main_path_dist_from_players + distance_bonus, raw_dist_from_players, side_id)
		end
	end

    -- -- local success, blob_pos, to_player_dir = horde_spawner:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

    -- local chosen_wave_composition = HordeWaveCompositions["chaos_huge_shields"]
    -- composition_type = chosen_wave_composition[math.random(#chosen_wave_composition)]

    local composition = CurrentHordeSettings.compositions_pacing[comp_name]
    local spawn_list, num_to_spawn = nil
    spawn_list, num_to_spawn = horde_spawner:compose_blob_horde_spawn_list(comp_name)

    -- local blob_pos = Vector3(-117.278, -166.673, 21.6376)
    local num_columns = 6
	local group_size = 0
	local rot = Unit.local_rotation(player_unit, 0)
	local max_attempts = 8
	local nav_world = conflict_director.nav_world
	if not nav_world or not blob_pos then 
		mod:echo("[VerminTrainer] Horde failed")
		return 
	end

	for i = 1, num_to_spawn, 1 do
		local spawn_pos = nil

		for j = 1, max_attempts, 1 do
			local offset = nil

			if j == 1 then
				offset = Vector3(-num_columns / 2 + i % num_columns, -num_columns / 2 + math.floor(i / num_columns), 0)
			else
				offset = Vector3(4 * math.random() - 2, 4 * math.random() - 2, 0)
			end

			spawn_pos = LocomotionUtils.pos_on_mesh(nav_world, blob_pos + offset * 2)

			if spawn_pos then
				local breed = Breeds[spawn_list[i]]
				local optional_data = {
					side_id = side_id
				}

				conflict_director:spawn_queued_unit(breed, Vector3Box(spawn_pos), QuaternionBox(rot), "hidden_spawn", nil, "horde_hidden", optional_data, nil)

				group_size = group_size + 1

				break
			end
		end
	end

    conflict_director:add_horde(group_size)
	mod:echo("[VerminTrainer] Horde spawned")

end

-- 

mod.next_composition = function() 
    selected_composition = (selected_composition + 1) % #compositions
    mod:echo(compositions[selected_composition + 1])
end

mod.prev_composition = function() 
    selected_composition = (selected_composition - 1) % #compositions
    mod:echo(compositions[selected_composition + 1])
end

mod.spawn_composition = function()
	local level_key = Managers.state.game_mode:level_key()
	if string.find(level_key, "inn_level") or string.find(level_key, "morris_hub") then
		mod:echo("[VerminTrainer] Error: You are in keep")
		return
	end
    mod.spawnComposition(compositions[selected_composition + 1])
end 
 
-- [MOD][VerminTrainer][ECHO] vector_blob
-- <>
-- [optional_wave_composition] = chaos_huge_shields (string)
-- [multiple_horde_count] = 1 (number)
-- [horde_wave] = multi_consecutive_wave (string)
-- </>
-- [MOD][VerminTrainer][ECHO] 2
-- [MOD][VerminTrainer][ECHO] true

-- [MOD][VerminTrainer][ECHO] vector_blob
-- <>
-- [horde_wave] = multi_last_wave (string)
-- [optional_wave_composition] = chaos_huge_shields (string)
-- </>
-- [MOD][VerminTrainer][ECHO] 2
-- [MOD][VerminTrainer][ECHO] true

-- [MOD][VerminTrainer][ECHO] vector_blob
-- <>
-- [optional_wave_composition] = chaos_huge_berzerker (string)
-- [multiple_horde_count] = 2 (number)
-- [horde_wave] = multi_first_wave (string)
-- </>
-- [MOD][VerminTrainer][ECHO] 2
-- [MOD][VerminTrainer][ECHO] nil

-- [MOD][VerminTrainer][ECHO] vector_blob
-- <>
-- [optional_wave_composition] = chaos_huge_berzerker (string)
-- [multiple_horde_count] = 1 (number)
-- [horde_wave] = multi_consecutive_wave (string)
-- </>
-- [MOD][VerminTrainer][ECHO] 2
-- [MOD][VerminTrainer][ECHO] true

-- [MOD][VerminTrainer][ECHO] vector_blob
-- <>
-- [horde_wave] = multi_last_wave (string)
-- [optional_wave_composition] = chaos_huge_berzerker (string)
-- </>
-- [MOD][VerminTrainer][ECHO] 2
-- [MOD][VerminTrainer][ECHO] true



-- mod:command("horde", "", function()
	--     local player_unit = Managers.player:local_player().player_unit
	--     local conflict_director = Managers.state.conflict;
	--     local horde_spawner = conflict_director.horde_spawner
	
	--     -- local success, blob_pos, to_player_dir = horde_spawner:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)
	
	--     local chosen_wave_composition = HordeWaveCompositions["chaos_huge_shields"]
	--     composition_type = chosen_wave_composition[math.random(#chosen_wave_composition)]
	
	--     local composition = CurrentHordeSettings.compositions_pacing["chaos_huge_berzerker"]
	--     mod:dump(composition, "", 2)
	--     local spawn_list, num_to_spawn = nil
	--     spawn_list, num_to_spawn = horde_spawner:compose_blob_horde_spawn_list("chaos_huge_berzerker")
	
	--     local blob_pos = Vector3(-117.278, -166.673, 21.6376)
	--     local num_columns = 6
	-- 	local group_size = 0
	-- 	local rot = Unit.local_rotation(player_unit, 0)
	-- 	local max_attempts = 8
	-- 	local nav_world = conflict_director.nav_world
	
	-- 	for i = 1, num_to_spawn, 1 do
	-- 		local spawn_pos = nil
	
	-- 		for j = 1, max_attempts, 1 do
	-- 			local offset = nil
	
	-- 			if j == 1 then
	-- 				offset = Vector3(-num_columns / 2 + i % num_columns, -num_columns / 2 + math.floor(i / num_columns), 0)
	-- 			else
	-- 				offset = Vector3(4 * math.random() - 2, 4 * math.random() - 2, 0)
	-- 			end
	
	-- 			spawn_pos = LocomotionUtils.pos_on_mesh(nav_world, blob_pos + offset * 2)
	
	-- 			if spawn_pos then
	-- 				local breed = Breeds[spawn_list[i]]
	-- 				local optional_data = {
	-- 					side_id = side_id
	-- 				}
	
	-- 				conflict_director:spawn_queued_unit(breed, Vector3Box(spawn_pos), QuaternionBox(rot), "hidden_spawn", nil, "horde_hidden", optional_data, nil)
	
	-- 				group_size = group_size + 1
	
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	
	--     conflict_director:add_horde(group_size)
		
	--     -- local extra_data = {
	--     --     ["optional_wave_composition"] = chaos_huge_shields,
	--     --     ["multiple_horde_count"] = 1,
	--     --     ["horde_wave"] =multi_first_wave
	--     -- }
	--     -- horde_spawner:execute_vector_blob_horde(extra_data, 1, true) 
	--     -- mod:dump(horde_spawner, "", 1)
	-- end)
-- Your mod code goes here.
-- https://vmf-docs.verminti.de
