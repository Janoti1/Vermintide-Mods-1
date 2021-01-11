local mod = get_mod("Display Main Path")
mod:dofile("scripts/mods/Display Main Path/game_code/debug_drawer")
script_data.disable_debug_draw = false

function mod.update ()
	if Managers.state.debug then
	  for _, drawer in pairs(Managers.state.debug._drawers) do
		drawer:update(Managers.state.debug._world)
	  end
	end
  end

  local RESPAWN_DISTANCE = 70
  local END_OF_LEVEL_BUFFER = 35
  local BOSS_TERROR_EVENT_LOOKUP = {
	  boss_event_chaos_spawn = true,
	  boss_event_storm_fiend = true,
	  boss_event_chaos_troll = true,
	  boss_event_minotaur = true,
	  boss_event_rat_ogre = true
  }

mod:command("pickup", "", function()
	local player_unit = Managers.player:local_player().player_unit
	local pickup_ext = Managers.state.entity:system("pickup_system")
	mod:echo(pickup_ext)
	mod:dump(pickup_ext.primary_pickup_spawners, "t", 1) 
	local primary_pickup_spawners = pickup_ext.primary_pickup_spawners

	for i = 1, #primary_pickup_spawners, 1 do
		mod:echo(primary_pickup_spawners[i])
		local item_pos = Unit.local_position(primary_pickup_spawners[i], 0)
		mod:echo(item_pos)
		QuickDrawerStay:sphere(item_pos, .25, Colors.get("blue"))

	end
	local secondary_pickup_spawners = pickup_ext.secondary_pickup_spawners

	for i = 1, #secondary_pickup_spawners, 1 do
		mod:echo(secondary_pickup_spawners[i])
		local item_pos = Unit.local_position(secondary_pickup_spawners[i], 0)
		mod:echo(item_pos)
		QuickDrawerStay:sphere(item_pos, .25, Colors.get("green"))

	end
	
	local guaranteed_pickup_spawners = pickup_ext.guaranteed_pickup_spawners

	for i = 1, #guaranteed_pickup_spawners, 1 do
		mod:echo(guaranteed_pickup_spawners[i])
		local item_pos = Unit.local_position(guaranteed_pickup_spawners[i], 0)
		mod:echo(item_pos)
		QuickDrawerStay:sphere(item_pos, .25, Colors.get("red"))

	end
end)


local RENDER = false 

local function get_respawn_unit(ignore_boss_doors)
    local respawn_units = Managers.state.game_mode:game_mode()
                              ._adventure_spawning._respawn_handler
                              ._respawn_units
    local active_overridden = Managers.state.game_mode:game_mode()
                                  ._adventure_spawning._respawn_handler
                                  ._active_overridden_units

    if next(active_overridden) then
        for unit, respawn_data in pairs(active_overridden) do
            if respawn_data.available then
                respawn_data.available = false

                print("Returning override respawn unit")

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
    local ahead_position = Unit.local_position(player_unit, 0)

    local ahead_main_path_index = conflict.main_path_info.current_path_index

    if not ahead_position then return end

    local _, ahead_unit_travel_dist = MainPathUtils.closest_pos_at_main_path(
                                          main_paths, ahead_position)
    local total_path_dist = MainPathUtils.total_path_dist()
    local ahead_pos = MainPathUtils.point_on_mainpath(main_paths,
                                                      ahead_unit_travel_dist +
                                                          RESPAWN_DISTANCE)

    if not ahead_pos then
        print("respawner: far ahead not found, using spawner behind")

        ahead_pos = MainPathUtils.point_on_mainpath(main_paths,
                                                    total_path_dist -
                                                        END_OF_LEVEL_BUFFER)

        fassert(ahead_pos, "Cannot find point on mainpath to respawn cage")
    end

    local path_pos, wanted_respawn_travel_dist =
        MainPathUtils.closest_pos_at_main_path(main_paths, ahead_pos)
    local door_system = Managers.state.entity:system("door_system")
    local boss_door_units = door_system:get_boss_door_units()
    local enemy_recycler = conflict.enemy_recycler
    local current_terror_event =
        enemy_recycler.main_path_events[enemy_recycler.current_main_path_event_id]
    local current_terror_event_type = current_terror_event and
                                          current_terror_event[3]
    local has_upcoming_boss_terror_event =
        BOSS_TERROR_EVENT_LOOKUP[current_terror_event_type]
    local current_terror_event_travel_dist =
        enemy_recycler.current_main_path_event_activation_dist
    local boss_door_between_travel_dist = nil
    local closest_boss_door_travel_dist = 0
    local closest_door_dist = math.huge
    local has_close_boss_door = nil

    for i = 1, #boss_door_units, 1 do
        local door_unit = boss_door_units[i]
        local door_position = Unit.world_position(door_unit, 0)
        local door_extension = ScriptUnit.extension(door_unit, "door_system")
        local door_state = door_extension.current_state
        local _, door_travel_dist = MainPathUtils.closest_pos_at_main_path(
                                        main_paths, door_position)
        local dist_to_door = door_travel_dist - ahead_unit_travel_dist

        if closest_door_dist > dist_to_door and dist_to_door >= 0 and
            ((door_state and door_state == "closed") or
                (has_upcoming_boss_terror_event and
                    current_terror_event_travel_dist < door_travel_dist)) then
            closest_door_dist = dist_to_door
            closest_boss_door_travel_dist = door_travel_dist
            has_close_boss_door = true
        end
    end

    local num_spawners = #respawn_units
    local greatest_distance = 0
    local selected_unit_index = nil

    for i = 1, num_spawners, 1 do
        local respawn_data = respawn_units[i]

        if respawn_data.available then
            local distance_through_level = respawn_data.distance_through_level

            if has_close_boss_door then
                if wanted_respawn_travel_dist <= distance_through_level and
                    distance_through_level < closest_boss_door_travel_dist then
                    selected_unit_index = i

                    break
                elseif greatest_distance < distance_through_level and
                    distance_through_level < closest_boss_door_travel_dist then
                    selected_unit_index = i
                    greatest_distance = distance_through_level
                end
            elseif wanted_respawn_travel_dist <= distance_through_level then
                selected_unit_index = i

                break
            elseif greatest_distance < distance_through_level then
                selected_unit_index = i
                greatest_distance = distance_through_level
            end
        end
    end

    if not selected_unit_index then return nil end

    local respawn_data = respawn_units[selected_unit_index]
    local selected_unit = respawn_data.unit
    -- respawn_data.available = false

    return selected_unit
end

local function drawBossWalls() 
    local door_system = Managers.state.entity:system("door_system")
    local boss_door_units = door_system:get_boss_door_units()
    for i = 1, #boss_door_units, 1 do
        local door_position = Unit.local_position(boss_door_units[i], 0)
        local box_extents = Vector3(2, 1, 1)
        local h = Vector3(0,0,1)
        local pose = Matrix4x4.from_quaternion_position(Quaternion.look(Vector3.up()), door_position + h)
        QuickDrawerStay:box(pose, box_extents, Colors.get("yellow"))
    end
end

local function drawBosses()
    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints
    local terror_spawners = level_analysis.terror_spawners
    local enemy_recycler = level_analysis.enemy_recycler

    if not boss_waypoints then return false end

    print("SPAWN BOSS SPLINES")

    local terror_event_kind = "event_boss"
    local data = terror_spawners[terror_event_kind]
    local spawners = data.spawners
    local h = Vector3(0, 0, 1)

    for i = 1, #spawners, 1 do
        local spawner = spawners[i]
        local spawner_pos = Unit.local_position(spawner[1], 0)
        local boxed_pos = Vector3Box(spawner_pos)
        local event_data = {event_kind = "event_boss"}

        local path_pos, travel_dist, move_percent, path_index, sub_index =
            MainPathUtils.closest_pos_at_main_path(nil, boxed_pos:unbox())
        local activation_pos, _ = MainPathUtils.point_on_mainpath(nil,
                                                                  travel_dist -
                                                                      45)

        QuickDrawerStay:line(spawner_pos, spawner_pos + Vector3(0, 0, 15),
                             Color(125, 255, 0))
        QuickDrawerStay:sphere(spawner_pos, 5, Colors.get("red"))
        QuickDrawerStay:line(spawner_pos, activation_pos + h, Color(125, 255, 0))
        QuickDrawerStay:sphere(activation_pos + h, .25, Colors.get("red"))
    end

end

local function drawPats()
    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints
    local enemy_recycler = level_analysis.enemy_recycler

    if not boss_waypoints then
        print("No boss_waypoints found in level!")

        return false
    end

    local h = Vector3(0, 0, 1)

    print("SPAWN BOSS SPLINES")

    for i = 1, #boss_waypoints, 1 do
        local section_waypoints = boss_waypoints[i]

        for j = 1, #section_waypoints, 1 do
            local waypoints_table = section_waypoints[j]

            if not optional_id or waypoints_table.id == optional_id then
                local spline_waypoints =
                    level_analysis:boxify_waypoint_table(
                        waypoints_table.waypoints)
                local event_data = {
                    spline_type = "patrol",
                    event_kind = "event_spline_patrol",
                    spline_id = waypoints_table.id,
                    spline_way_points = spline_waypoints
                }

                print("INJECTING BOSS SPLINE ID", waypoints_table.id)

                local spawner_pos = spline_waypoints[1]:unbox()
                local path_pos, travel_dist, move_percent, path_index, sub_index =
                    MainPathUtils.closest_pos_at_main_path(nil, spawner_pos)
                local activation_pos, _ =
                    MainPathUtils.point_on_mainpath(nil, travel_dist - 45)

                QuickDrawerStay:line(spawner_pos,
                                     spawner_pos + Vector3(0, 0, 15),
                                     Color(125, 255, 0))
                QuickDrawerStay:sphere(spawner_pos, 5, Colors.get("orange"))
                QuickDrawerStay:line(spawner_pos, activation_pos + h,
                                     Color(125, 255, 0))
                QuickDrawerStay:sphere(activation_pos + h, .25,
                                       Colors.get("orange"))
            end
        end
    end
end

local function drawNextRespawn()
    local unit = get_respawn_unit(true)
    local pos = Unit.local_position(unit, 0)
    QuickDrawerStay:sphere(pos, 0.53, Colors.get("red"))
end

local function drawRespawns()
    local up = Vector3(0, 0, 1)
    local up2 = Vector3(0, 0, .5)
    local respawners = Managers.state.game_mode:game_mode()._adventure_spawning
                           ._respawn_handler._respawn_units
    local unit_local_position = Unit.local_position

    for i = 1, #respawners, 1 do
        local respawner = respawners[i]
        local best_point, best_travel_dist, move_percent, best_sub_index,
              best_main_path = MainPathUtils.closest_pos_at_main_path(nil,
                                                                      unit_local_position(
                                                                          respawner.unit,
                                                                          0))
        local pos = unit_local_position(respawner.unit, 0)

        QuickDrawerStay:sphere(pos, 0.53, Colors.get("cyan"))
        QuickDrawerStay:line(pos, pos + Vector3(0, 0, 15), Colors.get("cyan"))

        local pos_distance = MainPathUtils.point_on_mainpath(nil, respawner.distance_through_level - RESPAWN_DISTANCE)
        QuickDrawerStay:line(pos + up , pos_distance + up, Colors.get("cyan"))
        QuickDrawerStay:sphere(pos_distance + up, .25, Colors.get("cyan"))

        local s = string.format("respawer %d, dist: %.1f, newdist: %.1f", i,
                                respawner.distance_through_level,
                                best_travel_dist)

        Debug.world_sticky_text(pos, s, "yellow")
    end
end

local function drawMainPath()
    local level_analysis = Managers.state.conflict.level_analysis
    local h = Vector3(0, 0, 1)

    local main_paths = level_analysis.main_paths
    for i = 1, #main_paths, 1 do
        local path = main_paths[i].nodes
        for j = 1, #path, 1 do
            local position = Vector3(path[j][1], path[j][2], path[j][3])
            QuickDrawerStay:sphere(position + h, .25, Colors.get("green"))
            if j == #path and i ~= #main_paths then
                local nextPositon = Vector3(main_paths[i + 1].nodes[1][1],
                                            main_paths[i + 1].nodes[1][2],
                                            main_paths[i + 1].nodes[1][3])
                QuickDrawerStay:line(position + h, nextPositon + h,
                                     Colors.get("yellow"))
            elseif j ~= #path then
                local nextPositon = Vector3(path[j + 1][1], path[j + 1][2],
                                            path[j + 1][3])
                QuickDrawerStay:line(position + h, nextPositon + h,
                                     Colors.get("green"))
            end
        end
    end
end

local function render()
    if mod:get("main_path") then drawMainPath() end
    if mod:get("boss") then drawBosses() end
    if mod:get("patrol") then drawPats() end
    if mod:get("respawn") then drawRespawns() end
    if mod:get("boss_walls") then drawBossWalls() end 
end

mod:command("drawMainPath", "", function() render() end)

mod:hook_safe(IngameHud, "update", function(self)
    -- If the EquipmentUI isn't visible or the player is dead
    -- then let's not show the Dodge Count UI
    if not self._currently_visible_components.EquipmentUI or
        self:is_own_player_dead() or Managers.state.game_mode._level_key ==
        "inn_level" then
        RENDER = false
        return
    end

    if not RENDER then
        render()
        RENDER = true
    end

    local t = Managers.time:time("game")
    local player_unit = Managers.player:local_player().player_unit
    local status_system = ScriptUnit.has_extension(player_unit, "status_system")

    if not status_system or not player_unit then return end

	if mod:get("player_pos") then
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
		QuickDrawer:line(point + h, player_pos +h, Colors.get("purple"))
	end

end)


function mod:on_setting_changed()
    QuickDrawerStay:reset()
    render()
end


mod:command("injectBoss", "", function() 
    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints
    local terror_spawners = level_analysis.terror_spawners
    local enemy_recycler = level_analysis.enemy_recycler

    if not boss_waypoints then
        return false
    end

    local terror_event_kind = "event_boss"
    local data = terror_spawners[terror_event_kind]
    local spawners = data.spawners
    local h = Vector3(0, 0, 1)

    table.clear(enemy_recycler.main_path_events)


    for i = 1, #spawners, 1 do
        local spawner = spawners[i]
    
        local spawner_pos = Unit.local_position(spawner[1], 0)
        local boxed_pos = Vector3Box(spawner_pos)
        local event_data = {
            event_kind = "event_boss"
        }


        enemy_recycler:add_main_path_terror_event(boxed_pos, "boss_event_rat_ogre", 45, event_data)

    end

end) 

mod:command("where", "", function()
    local h = Vector3(0, 0, 1)
    local h2 = Vector3(0, 0, .5)
    local unit = get_respawn_unit(true)
    local pos = Unit.local_position(unit, 0) 

    -- QuickDrawerStay:sphere(pos, 0.53, Colors.get("red"))
    local conflict_director = Managers.state.conflict
    local level_analysis = conflict_director.level_analysis
    local main_path_data = level_analysis.main_path_data
    local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
    local total_travel_dist = main_path_data.total_dist
    local travel_percentage = ahead_travel_dist / total_travel_dist * 100

    local point = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)
    QuickDrawerStay:line(point + h, pos + h2, Colors.get("yellow"))
    QuickDrawerStay:sphere(point + h, .25, Colors.get("yellow"))
    -- mod:dump( get_respawn_unit(true),"t", 2)
    
end) 

local function set_invisible(player_unit, set_status)
    if Unit.alive(player_unit) then
        local status_extension = ScriptUnit.extension(player_unit,
                                                      "status_system")
        status_extension:set_invisible(set_status)
        status_extension:set_noclip(set_status)
    end
end


mod:command("invisOn", "", function()
    local player_unit = Managers.player:local_player().player_unit
    set_invisible(player_unit, true)
end)

mod:command("invisOff", "", function()
    local player_unit = Managers.player:local_player().player_unit
    set_invisible(player_unit, false)
end)

