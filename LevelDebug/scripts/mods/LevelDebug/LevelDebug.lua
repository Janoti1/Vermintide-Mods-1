local mod = get_mod("LevelDebug")
-- mod:dofile("scripts/mods/LevelDebug/game_code/debug_drawer")
-- script_data.disable_debug_draw = false

local RESPAWN_DISTANCE = 70
local END_OF_LEVEL_BUFFER = 35
local RESPAWN_TIME = 30
local SAVED_WHERE = nil
local TEXT = false

local enabled = false
Development._hardcoded_dev_params.disable_debug_draw = not enabled
script_data.disable_debug_draw = not enabled

DebugManager.drawer = function(self, options)
    options = options or {}
    local drawer_name = options.name
    local drawer
    local drawer_api = DebugDrawer -- MODIFIED. We just want debug drawer

    if drawer_name == nil then
        local line_object = World.create_line_object(self._world)
        drawer = drawer_api:new(line_object, options.mode)
        self._drawers[#self._drawers + 1] = drawer
    elseif self._drawers[drawer_name] == nil then
        local line_object = World.create_line_object(self._world)
        drawer = drawer_api:new(line_object, options.mode)
        self._drawers[drawer_name] = drawer
    else
        drawer = self._drawers[drawer_name]
    end

    return drawer
end

mod:hook_safe(IngameHud, "update", function(self)
    if not self.boon_ui._is_visible or Managers.state.game_mode._level_key ==
        "inn_level" then
        enabled = false
        Development._hardcoded_dev_params.disable_debug_draw = not enabled
        script_data.disable_debug_draw = not enabled
    else
        enabled = true
        Development._hardcoded_dev_params.disable_debug_draw = not enabled
        script_data.disable_debug_draw = not enabled
    end

end)

function mod.update()
    if enabled then
        if mod:get("main_path") then mod.drawMainPath() end
        if mod:get("boss") then mod.drawBosses() end
        if mod:get("patrol") then mod.drawPats() end
        if mod:get("respawn") then mod.drawRespawns() end
        if mod:get("player_pos") then mod.drawPosition() end
        if mod:get("where") then mod.drawWhere() end
        if mod:get("named_spawners") and not TEXT then 
            mod.drawNamedSpawners() 
        end
        if SAVED_WHERE then mod.drawSavedWhere() end

        if Managers.state.debug then
            for _, drawer in pairs(Managers.state.debug._drawers) do
                drawer:update(Managers.state.debug._world)
            end
        end
    end
end

function mod:on_setting_changed() 
    QuickDrawer:reset() 
    QuickDrawerStay:reset()
    local debug_text =  Managers.state.debug_text
    debug_text:clear_world_text("category: spawner_id")
    TEXT = false
end

-- fix errors during load screen after leaving a game
function mod:on_game_state_changed() 
    enabled = false
    SAVED_WHERE = nil
    TEXT = false 
end

function mod.drawMainPath()
    local level_analysis = Managers.state.conflict.level_analysis
    local h = Vector3(0, 0, 1)

    local main_paths = level_analysis.main_paths
    for i = 1, #main_paths, 1 do
        local path = main_paths[i].nodes
        for j = 1, #path, 1 do
            local position = Vector3(path[j][1], path[j][2], path[j][3])
            QuickDrawer:sphere(position + h, .25, Colors.get("green"))
            if j == #path and i ~= #main_paths then
                local nextPositon = Vector3(main_paths[i + 1].nodes[1][1],
                                            main_paths[i + 1].nodes[1][2],
                                            main_paths[i + 1].nodes[1][3])
                QuickDrawer:line(position + h, nextPositon + h,
                                 Colors.get("yellow"))
            elseif j ~= #path then
                local nextPositon = Vector3(path[j + 1][1], path[j + 1][2],
                                            path[j + 1][3])
                QuickDrawer:line(position + h, nextPositon + h,
                                 Colors.get("green"))
            end
        end
    end
end

function mod.drawBosses()
    local level_analysis = Managers.state.conflict.level_analysis
    local spawners = level_analysis.terror_spawners
    local boss_spawners = spawners.event_boss.spawners
    local h = Vector3(0, 0, 1)

    for i = 1, #boss_spawners, 1 do
        local data = boss_spawners[i]
        local spawner_pos = Unit.local_position(data[1], 0)

        local boxed_pos = Vector3Box(spawner_pos)
        local event_data = {event_kind = "event_boss"}

        local path_pos, travel_dist, move_percent, path_index, sub_index =
            MainPathUtils.closest_pos_at_main_path(nil, boxed_pos:unbox())
        local activation_pos, _ = MainPathUtils.point_on_mainpath(nil,
                                                                  travel_dist -
                                                                      45)

        QuickDrawer:line(spawner_pos, spawner_pos + Vector3(0, 0, 15),
                         Color(125, 255, 0))
        QuickDrawer:sphere(spawner_pos, 5, Colors.get("red"))
        QuickDrawer:line(spawner_pos, activation_pos + h, Color(125, 255, 0))
        QuickDrawer:sphere(activation_pos + h, .25, Colors.get("red"))
    end
end

function mod.drawPats()
    local level_analysis = Managers.state.conflict.level_analysis
    local spawners = level_analysis.terror_spawners
    local patrol_spawners = spawners.event_patrol.spawners
    local h = Vector3(0, 0, 1)

    for i = 1, #patrol_spawners, 1 do
        local data = patrol_spawners[i]
        local spawner_pos = Unit.local_position(data[1], 0)

        local boxed_pos = Vector3Box(spawner_pos)
        local event_data = {event_kind = "event_patrol"}

        local path_pos, travel_dist, move_percent, path_index, sub_index =
            MainPathUtils.closest_pos_at_main_path(nil, boxed_pos:unbox())
        local activation_pos, _ = MainPathUtils.point_on_mainpath(nil,
                                                                  travel_dist -
                                                                      45)

        QuickDrawer:line(spawner_pos, spawner_pos + Vector3(0, 0, 15),
                         Color(125, 255, 0))
        QuickDrawer:sphere(spawner_pos, 5, Colors.get("orange"))
        QuickDrawer:line(spawner_pos, activation_pos + h, Color(125, 255, 0))
        QuickDrawer:sphere(activation_pos + h, .25, Colors.get("orange"))
    end

end

function mod.drawRespawns()
    local up = Vector3(0, 0, 1)
    local up2 = Vector3(0, 0, .5)
    local respawners = Managers.state.spawn.respawn_handler._respawn_units
    local unit_local_position = Unit.local_position
    for i = 1, #respawners, 1 do
        local respawner = respawners[i]
        local best_point, best_travel_dist, move_percent, best_sub_index,
              best_main_path = MainPathUtils.closest_pos_at_main_path(nil,
                                                                      unit_local_position(
                                                                          respawner.unit,
                                                                          0))
        local pos = unit_local_position(respawner.unit, 0)

        QuickDrawer:sphere(pos, 0.53, Colors.get("cyan"))
        QuickDrawer:line(pos, pos + Vector3(0, 0, 15), Colors.get("cyan"))

        local pos_distance = MainPathUtils.point_on_mainpath(nil,
                                                             respawner.distance_through_level -
                                                                 RESPAWN_DISTANCE)
        QuickDrawer:line(pos + up, pos_distance + up, Colors.get("cyan"))
        QuickDrawer:sphere(pos_distance + up, .25, Colors.get("cyan"))
    end
end

function mod.drawPosition()
    local h = Vector3(0, 0, 1)

    local conflict_director = Managers.state.conflict
    local level_analysis = conflict_director.level_analysis
    local main_path_data = level_analysis.main_path_data
    local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
    local total_travel_dist = main_path_data.total_dist
    local travel_percentage = ahead_travel_dist / total_travel_dist * 100

    local point = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)
    QuickDrawer:sphere(point + h, .25, Colors.get("purple"))

    local player_unit = Managers.player:local_player().player_unit
    local player_pos = Unit.local_position(player_unit, 0)
    QuickDrawer:line(point + h, player_pos + h, Colors.get("purple"))
end

function mod.drawWhere() 
    local h = Vector3(0, 0, 1)
    local h2 = Vector3(0, 0, .5)
    local unit = mod.get_respawn_unit()
    local pos = Unit.local_position(unit, 0) 

    local conflict_director = Managers.state.conflict
    local level_analysis = conflict_director.level_analysis
    local main_path_data = level_analysis.main_path_data
    local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
    local total_travel_dist = main_path_data.total_dist
    local travel_percentage = ahead_travel_dist / total_travel_dist * 100

    local point = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)
    QuickDrawer:line(point + h, pos + h2, Colors.get("yellow"))
    QuickDrawer:sphere(point + h, .25, Colors.get("yellow"))
end

function mod.drawNamedSpawners() 
    local debug_text =  Managers.state.debug_text
    local spawner_system = Managers.state.entity:system("spawner_system")
    for event, unitTable in pairs(spawner_system._id_lookup) do 
        for _,unit in pairs(unitTable) do 
            local spawner_pos = Unit.local_position(unit, 0)
            local text_size = 0.5
            local z = Vector3.up() * 0.5
            local color_vector = Vector3(255, 0, 200, 0) -- luacheck: ignore
            debug_text:output_world_text(event, text_size, spawner_pos+z, nil, "category: spawner_id", color_vector)
        end
    end
    TEXT = true  
end

mod:command("where", "", function()
    local h = Vector3(0, 0, 1)
    local h2 = Vector3(0, 0, .5)
    local unit = mod.get_respawn_unit()
    local pos = Unit.local_position(unit, 0) 

    local conflict_director = Managers.state.conflict
    local level_analysis = conflict_director.level_analysis
    local main_path_data = level_analysis.main_path_data
    local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
    local total_travel_dist = main_path_data.total_dist
    local travel_percentage = ahead_travel_dist / total_travel_dist * 100

    local point = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)
    QuickDrawerStay:line(point + h, pos + h2, Colors.get("yellow"))
    QuickDrawerStay:sphere(point + h, .25, Colors.get("yellow"))
end) 

mod:command("clearDraw", "", function() 
    QuickDrawer:reset() 
    QuickDrawerStay:reset()
    local debug_text =  Managers.state.debug_text
    debug_text:clear_world_text("category: spawner_id")
end)

function mod.get_respawn_unit()
    local respawn_units = Managers.state.spawn.respawn_handler._respawn_units
	local active_overridden = Managers.state.spawn.respawn_handler._active_overridden_units

	if next(active_overridden) then
		for unit, respawn_data in pairs(active_overridden) do
			if respawn_data.available then
				respawn_data.available = false

				return respawn_data.unit
			end
		end

		print("No available overriden respawning units found!")

		return nil
	end

	local conflict = Managers.state.conflict
	local level_analysis = conflict.level_analysis
    local main_paths = level_analysis:get_main_paths()
    local player_unit = Managers.player:local_player().player_unit

    -- ADDED
    local conflict_director = Managers.state.conflict
    local level_analysis = conflict_director.level_analysis
    local main_path_data = level_analysis.main_path_data
    local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
    local total_travel_dist = main_path_data.total_dist
    local travel_percentage = ahead_travel_dist / total_travel_dist * 100

    local ahead_position = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)
	-- local ahead_position = Unit.local_position(player_unit, 0)

	if not ahead_position then
		return
	end

	local path_pos, travel_dist = MainPathUtils.closest_pos_at_main_path(main_paths, ahead_position)
	local total_path_dist = MainPathUtils.total_path_dist()
	local ahead_pos = MainPathUtils.point_on_mainpath(main_paths, travel_dist + RESPAWN_DISTANCE)

	if not ahead_pos then
		print("respawner: far ahead not found, using spawner behind")

		ahead_pos = MainPathUtils.point_on_mainpath(main_paths, total_path_dist - END_OF_LEVEL_BUFFER)

		fassert(ahead_pos, "Cannot find point on mainpath to respawn cage")
	end

	path_pos, travel_dist = MainPathUtils.closest_pos_at_main_path(main_paths, ahead_pos)
	local num_spawners = #respawn_units
	local greatest_distance = 0
	local selected_unit_index = nil

	for i = 1, num_spawners, 1 do
		local respawn_data = respawn_units[i]

		if respawn_data.available then
			local distance_through_level = respawn_data.distance_through_level

			if travel_dist <= distance_through_level then
				selected_unit_index = i

				break
			elseif greatest_distance < distance_through_level then
				selected_unit_index = i
				greatest_distance = distance_through_level
			end
		end
	end

	if not selected_unit_index then
		return nil
	end

	local respawn_data = respawn_units[selected_unit_index]
	local selected_unit = respawn_data.unit
	-- respawn_data.available = false

    return selected_unit
end

-- mod:command("testSpawns", "", function() 

--     local debug_text =  Managers.state.debug_text
--     local spawner_system = Managers.state.entity:system("spawner_system")
--     for event, unitTable in pairs(spawner_system._id_lookup) do 
--         mod:echo(event)
--         for _,unit in pairs(unitTable) do 
--             mod:echo(unit)
--             local spawner_pos = Unit.local_position(unit, 0)
--             QuickDrawerStay:sphere(spawner_pos, 1, Colors.get("yellow"))
--             local text_size = 0.5
--             local z = Vector3.up() * 0.5
--             local color_vector = Vector3(255, 0, 200, 0) -- luacheck: ignore
--             debug_text:output_world_text(event, text_size, spawner_pos+z, nil, "category: spawner_id", color_vector)
--         end
--     end
--     mod:dump(spawner_system._id_lookup, "", 1)
-- end)

