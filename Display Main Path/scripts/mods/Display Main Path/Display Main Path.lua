local mod = get_mod("Display Main Path")

local TEXT = false
local ITEM_TEXT = false
local PRIMARY_SPAWNER_DATA = {}
local SECONDARY_SPAWNER_DATA = {}
local PRIMARY_SPAWNER_DISPLAY_DATA = {}
local SECONDARY_SPAWNER_DISPLAY_DATA = {}
local GUARENTEED_DATA = {}
local EVENT_SPAWNERS = {}
local LINE_OBJECT = nil
local WORLD = nil
local NAV_WORLD = nil
local WORLD_GUI = nil
local SCREEN_GUI = nil
local EVENT_NAME = nil


local enabled = false
Development._hardcoded_dev_params.disable_debug_draw = not enabled
script_data.disable_debug_draw = not enabled
DebugManager.drawer = function(self, options)
    options = options or {}
    local drawer_name = options.name
    local drawer = nil
    local drawer_api = DebugDrawer

    if drawer_name == nil then
        local line_object = World.create_line_object(self._world)
        drawer = drawer_api.new(drawer_api, line_object, options.mode)
        self._drawers[#self._drawers + 1] = drawer
    elseif self._drawers[drawer_name] == nil then
        local line_object = World.create_line_object(self._world)
        drawer = drawer_api.new(drawer_api, line_object, options.mode)
        self._drawers[drawer_name] = drawer
    else
        drawer = self._drawers[drawer_name]
    end

    return drawer
end
local ahead_unit = nil

mod.hook_safe(mod, IngameHud, "update", function(self)
    if not self._currently_visible_components.EquipmentUI or
        self.is_own_player_dead(self) or
        string.find(Managers.state.game_mode._level_key, "inn_level") then
        enabled = false
        Development._hardcoded_dev_params.disable_debug_draw = not enabled
        script_data.disable_debug_draw = not enabled
    else
        enabled = true
        Development._hardcoded_dev_params.disable_debug_draw = not enabled
        script_data.disable_debug_draw = not enabled
    end

    return
end)
mod:hook_safe(RespawnHandler, "set_override_respawn_group", function(self, group_id, enable)
    mod:echo("override")
    mod:echo(group_id)
    mod:echo(enable)
    mod:echo(Managers.state.game_mode:level_key())

    local h = Vector3(0, 0, 1)
    local conflict_director = Managers.state.conflict
    local level_analysis = conflict_director.level_analysis
    local main_path_data = level_analysis.main_path_data
    local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
    local total_travel_dist = main_path_data.total_dist
    local travel_percentage = ahead_travel_dist / total_travel_dist * 100
    local point = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)

    QuickDrawerStay:sphere(point + h, 0.25, Colors.get("red"))
    -- local group_data = self._respawner_groups[group_id]

	-- if not group_data then
	-- 	print("WARNING: Override Player Respawning, bad group-id: '" .. tostring(group_id) .. "'' (not registered).")

	-- 	return
	-- end

	-- print("Override Player Respawning", group_id, enable)

	-- local active_overridden = self._active_overridden_units

	-- if enable then
	-- 	for unit, respawn_data in pairs(group_data) do
	-- 		active_overridden[unit] = respawn_data
	-- 	end
	-- else
	-- 	for unit, respawn_data in pairs(group_data) do
	-- 		active_overridden[unit] = nil
	-- 	end
	-- end
end)

mod.update = function(dt)
    if enabled then
        if Managers.state.game_mode:game_mode()._adventure_spawning then
            if mod:get("main_path") then mod.drawMainPath() end
            if mod:get("player_pos") then mod.drawPosition() end
            if mod:get("boss") then mod.drawBosses() end
            if mod:get("patrol") then mod.drawPats() end
            if mod:get("respawn") then mod.drawRespawns(Managers.state.game_mode:game_mode()._adventure_spawning._respawn_handler._respawn_units) end
            if mod:get("boss_walls") then mod.drawBossWalls() end
            if mod:get("patrol_routes") then mod.drawPatrolRoutes() end
            if mod:get("item_spawners") then mod.drawItemSpawners() end
            if mod:get("debug_spawners") then mod.saveEventSpawners() end
            -- if mod:get("nav_mesh") then mod.drawNavMesh() end
        elseif Managers.state.game_mode:game_mode()._deus_spawning then
            if mod:get("main_path") then mod.drawMainPath() end
            if mod:get("player_pos") then mod.drawPosition() end
            if mod:get("boss") then mod.drawBosses() end
            if mod:get("patrol") then mod.drawPats() end
            if mod:get("respawn") then mod.drawRespawns(Managers.state.game_mode:game_mode()._deus_spawning._respawn_handler._respawn_units) end
            if mod:get("boss_walls") then mod.drawBossWalls() end
            if mod:get("patrol_routes") then mod.drawPatrolRoutes() end
            if mod:get("item_spawners") then mod.drawItemSpawners() end
            if mod:get("debug_spawners") then mod.saveEventSpawners() end
            -- if mod:get("nav_mesh") then mod.drawNavMesh() end
        end

        if Managers.state.debug then
            for _, drawer in pairs(Managers.state.debug._drawers) do
                drawer.update(drawer, Managers.state.debug._world)
            end
        end
    end

    return
end
 
mod.on_game_state_changed = function(status, state)
    enabled = false
    SAVED_WHERE = nil
    TEXT = false
    ITEM_TEXT = false

    EVENT_SPAWNERS = {}
    EVENT_NAME = nil

    if status == "enter" and state == "StateIngame" then
        WORLD = Managers.world:world("level_world")
        WORLD_GUI = World.create_world_gui(WORLD, Matrix4x4.identity(), 1, 1, "immediate", "material", "materials/fonts/gw_fonts")
        LINE_OBJECT = World.create_line_object(WORLD, false)
        SCREEN_GUI = World.create_screen_gui(WORLD, "material", "materials/fonts/gw_fonts", "immediate")
    end

    mod.saveEventSpawners()

    return
end
mod.on_setting_changed = function(self)
    QuickDrawer:reset()
    QuickDrawerStay:reset()

    local debug_text = Managers.state.debug_text

    debug_text.clear_world_text(debug_text, "category: spawner_id")
    debug_text.clear_world_text(debug_text, "category: item_spawner_id")

    TEXT = false
    ITEM_TEXT = false

    LINE_OBJECT = World.create_line_object(Managers.world:world("level_world"), false)

    return
end

mod:command("gameMode", "", function() 
    mod:echo(Managers.state.game_mode:game_mode())
    mod:dump(Managers.state.game_mode:game_mode(), "", 1)
end)

mod.command(mod, "clearDraw", "", function()
    QuickDrawer:reset()
    QuickDrawerStay:reset()

    return
end)

mod.drawMainPath = function()
    local level_analysis = Managers.state.conflict.level_analysis
    local h = Vector3(0, 0, 1)
    local main_paths = level_analysis.main_paths

    for i = 1, #main_paths, 1 do
        local path = main_paths[i].nodes

        for j = 1, #path, 1 do
            local position = Vector3(path[j][1], path[j][2], path[j][3])

            QuickDrawer:sphere(position + h, 0.25, Colors.get("green"))

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

    return
end
mod.drawBosses = function()
    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints
    local terror_spawners = level_analysis.terror_spawners
    local enemy_recycler = level_analysis.enemy_recycler

    if not boss_waypoints then return false end

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
            MainPathUtils.closest_pos_at_main_path(nil,
                                                   boxed_pos.unbox(boxed_pos))
        local activation_pos, _ = MainPathUtils.point_on_mainpath(nil,
                                                                  travel_dist -
                                                                      45)

        QuickDrawer:line(spawner_pos, spawner_pos + Vector3(0, 0, 15),
                         Color(125, 255, 0))
        QuickDrawer:sphere(spawner_pos, 5, Colors.get("red"))
        QuickDrawer:line(spawner_pos, activation_pos + h, Color(125, 255, 0))
        QuickDrawer:sphere(activation_pos + h, 0.25, Colors.get("red"))
    end

    return
end
mod.drawPats = function()
    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints
    local enemy_recycler = level_analysis.enemy_recycler

    if not boss_waypoints then
        mod:echo("No boss_waypoints found in level!")

        return false
    end

    local h = Vector3(0, 0, 1)

    for i = 1, #boss_waypoints, 1 do
        local section_waypoints = boss_waypoints[i]

        for j = 1, #section_waypoints, 1 do
            local waypoints_table = section_waypoints[j]

            if not optional_id or waypoints_table.id == optional_id then
                local spline_waypoints =
                    level_analysis.boxify_waypoint_table(level_analysis,
                                                         waypoints_table.waypoints)
                local event_data = {
                    spline_type = "patrol",
                    event_kind = "event_spline_patrol",
                    spline_id = waypoints_table.id,
                    spline_way_points = spline_waypoints
                }
                local spawner_pos = spline_waypoints[1]:unbox()
                local path_pos, travel_dist, move_percent, path_index, sub_index =
                    MainPathUtils.closest_pos_at_main_path(nil, spawner_pos)
                local activation_pos, _ =
                    MainPathUtils.point_on_mainpath(nil, travel_dist - 45)

                QuickDrawer:line(spawner_pos, spawner_pos + Vector3(0, 0, 15),
                                 Color(125, 255, 0))
                QuickDrawer:sphere(spawner_pos, 5, Colors.get("orange"))
                QuickDrawer:line(spawner_pos, activation_pos + h,
                                 Color(125, 255, 0))
                QuickDrawer:sphere(activation_pos + h, 0.15,
                                   Colors.get("orange"))
            end
        end
    end

    return
end
mod.drawPosition = function()
    local h = Vector3(0, 0, 1)
    local conflict_director = Managers.state.conflict
    local level_analysis = conflict_director.level_analysis
    local main_path_data = level_analysis.main_path_data
    local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
    local total_travel_dist = main_path_data.total_dist
    local travel_percentage = ahead_travel_dist / total_travel_dist * 100
    local point = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)

    QuickDrawer:sphere(point + h, 0.25, Colors.get("purple"))

    local player_unit = Managers.player:local_player().player_unit
    local player_pos = Unit.local_position(player_unit, 0)

    QuickDrawer:line(point + h, player_pos + h, Colors.get("purple"))

    return
end
mod.checkCollision = function()
    local player_manager = Managers.player
    local local_player = player_manager.local_player(player_manager)
    local player_unit = local_player and local_player.player_unit
    local current_position = Unit.local_position(player_unit, 0)

    mod:position_at_cursor(local_player)

    return
end
mod.position_at_cursor = function(self, local_player)
    local viewport_name = local_player.viewport_name
    local camera_position = Managers.state.camera:camera_position(viewport_name)
    local camera_rotation = Managers.state.camera:camera_rotation(viewport_name)
    local camera_direction = Quaternion.forward(camera_rotation)
    local range = 500
    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    local new_position = nil
    local num_shots_this_frame = 15
    local angle = math.pi / 80
    local outer_angle = 0
    local outer_number = 1

    for j = 1, outer_number, 1 do
        local rotation = camera_rotation
        local rotation2 = camera_rotation

        for i = 1, num_shots_this_frame, 1 do
            rotation = mod.get_rotation(0, angle, 0, rotation)
            rotation2 = mod.get_rotation(0, angle * -1, 0, rotation2)
            local direction = Quaternion.forward(rotation)
            local is_hit, hit_pos, hit_dist, hit_norm, hit_actor =
                PhysicsWorld.immediate_raycast(physics_world, camera_position,
                                               direction, range, "closest",
                                               "collision_filter",
                                               "filter_player_mover")

            if is_hit then
                QuickDrawerStay:circle(hit_pos, 0.1, hit_norm, Colors.get("red"))
                QuickDrawerStay:vector(hit_pos, hit_norm * 0.1,
                                       Colors.get("red"))
            end

            direction = Quaternion.forward(rotation2)
            is_hit, hit_pos, hit_dist, hit_norm, hit_actor =
                PhysicsWorld.immediate_raycast(physics_world, camera_position,
                                               direction, range, "closest",
                                               "collision_filter",
                                               "filter_player_mover")

            if is_hit then
                QuickDrawerStay:circle(hit_pos, 0.1, hit_norm, Colors.get("red"))
                QuickDrawerStay:vector(hit_pos, hit_norm * 0.1,
                                       Colors.get("red"))
            end
        end

        outer_angle = outer_angle + angle
    end

    return new_position
end
mod.get_rotation = function(roll, pitch, yaw, current_rotation)
    local roll_rot = Quaternion(Vector3.forward(), roll)
    local pitch_rot = Quaternion(Vector3.up(), pitch)
    local yaw_rot = Quaternion(Vector3.right(), yaw)
    local combined_rotation = Quaternion.multiply(current_rotation, roll_rot)
    combined_rotation = Quaternion.multiply(combined_rotation, pitch_rot)
    combined_rotation = Quaternion.multiply(combined_rotation, yaw_rot)

    return combined_rotation
end

mod.command(mod, "testVect", "", function()
    local player_unit = Managers.player:local_player().player_unit
    local player_pos = Unit.local_position(player_unit, 0)
    local player_manager = Managers.player
    local local_player = player_manager.local_player(player_manager)
    local viewport_name = local_player.viewport_name
    local camera_position = Managers.state.camera:camera_position(viewport_name)
    local camera_rotation = Managers.state.camera:camera_rotation(viewport_name)
    local camera_direction = Quaternion.forward(camera_rotation)

    QuickDrawerStay:vector(player_pos, camera_direction, Colors.get("red"))

    return
end)

local RESPAWN_DISTANCE = 70
local END_OF_LEVEL_BUFFER = 35
local BOSS_TERROR_EVENT_LOOKUP = {
    boss_event_minotaur = true,
    boss_event_chaos_troll = true,
    boss_event_storm_fiend = true,
    boss_event_chaos_spawn = true,
    boss_event_rat_ogre = true
}

local function drawNextRespawn()
    local unit = get_respawn_unit(true)
    local pos = Unit.local_position(unit, 0)

    QuickDrawerStay:sphere(pos, 0.53, Colors.get("red"))

    return
end

mod.drawRespawns = function(respawners)
    local up = Vector3(0, 0, 1)
    local up2 = Vector3(0, 0, 0.5)
    -- local respawners = Managers.state.game_mode:game_mode()._adventure_spawning
    --                        ._respawn_handler._respawn_units
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
        QuickDrawer:sphere(pos_distance + up, 0.25, Colors.get("cyan"))

        local s = string.format("respawer %d, dist: %.1f, newdist: %.1f", i,
                                respawner.distance_through_level,
                                best_travel_dist)

        Debug.world_sticky_text(pos, s, "yellow")
    end

    return
end

mod.drawBossWalls = function()
    local door_system = Managers.state.entity:system("door_system")
    local boss_door_units = door_system:get_boss_door_units()
    for i = 1, #boss_door_units, 1 do
        local door_position = Unit.local_position(boss_door_units[i], 0)
        local box_extents = Vector3(2, 1, 1)
        local h = Vector3(0, 0, 1)
        local pose = Matrix4x4.from_quaternion_position(
                         Quaternion.look(Vector3.up()), door_position + h)
        QuickDrawer:box(pose, box_extents, Colors.get("yellow"))
    end
end

mod.command(mod, "injectBoss", "", function()
    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints
    local terror_spawners = level_analysis.terror_spawners
    local enemy_recycler = level_analysis.enemy_recycler

    if not boss_waypoints then return false end

    local terror_event_kind = "event_boss"
    local data = terror_spawners[terror_event_kind]
    local spawners = data.spawners
    local h = Vector3(0, 0, 1)

    table.clear(enemy_recycler.main_path_events)

    for i = 1, #spawners, 1 do
        local spawner = spawners[i]
        local spawner_pos = Unit.local_position(spawner[1], 0)
        local boxed_pos = Vector3Box(spawner_pos)
        local event_data = {event_kind = "event_boss"}

        enemy_recycler.add_main_path_terror_event(enemy_recycler, boxed_pos,
                                                  "boss_event_rat_ogre", 45,
                                                  event_data)
    end

    return
end)

mod:command("injectPatrol", "", function()
    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints
    local enemy_recycler = level_analysis.enemy_recycler

    if not boss_waypoints then
        mod:echo("No boss_waypoints found in level!")

        return false
    end

    local h = Vector3(0, 0, 1)
    table.clear(enemy_recycler.main_path_events)

    for i = 1, #boss_waypoints, 1 do
        local section_waypoints = boss_waypoints[i]

        for j = 1, #section_waypoints, 1 do
            local waypoints_table = section_waypoints[j]

            if not optional_id or waypoints_table.id == optional_id then
                local spline_waypoints =
                    level_analysis.boxify_waypoint_table(level_analysis,
                                                         waypoints_table.waypoints)
                local event_data = {
                    spline_type = "patrol",
                    event_kind = "event_spline_patrol",
                    spline_id = waypoints_table.id,
                    spline_way_points = spline_waypoints
                }
                enemy_recycler.add_main_path_terror_event(enemy_recycler, spline_waypoints[1],
                                                  "boss_event_spline_patrol", 45,
                                                  event_data)
                -- add_main_path_terror_event(spline_waypoints[1], "boss_event_spline_patrol", 45, event_data)
                
            end
        end
    end
end) 



local function draw_patrol_route(route_data, col)
    local h = Vector3(0, 0, 1)
    local waypoints = route_data.waypoints
    local wp = waypoints[1]
    local p1 = Vector3(wp[1], wp[2], wp[3]) + h

    QuickDrawer:sphere(p1, 0.5, Color(255, 255, 255))

    local p2 = nil

    for i = 2, #waypoints, 1 do
        wp = waypoints[i]
        p2 = Vector3(wp[1], wp[2], wp[3]) + h

        QuickDrawer:sphere(p2, 0.5, col)
        QuickDrawer:line(p1, p2, col)

        p1 = p2
    end
end

mod.drawPatrolRoutes = function()
    local section_colors = {
        Color(255, 0, 0), Color(255, 128, 0), Color(255, 255, 0),
        Color(0, 255, 255), Color(0, 0, 255), Color(128, 0, 255),
        Color(255, 0, 255), Color(0, 255, 0)
    }

    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints

    if boss_waypoints then
        for i = 1, #boss_waypoints, 1 do
            local section = boss_waypoints[i]
            local section_color = section_colors[i]

            for j = 1, #section, 1 do
                local color = section_colors[(i + j) % 5 + 1]
                local route_data = section[j]
                draw_patrol_route(route_data, color)
            end

        end
    end
end

mod.checkCollision = function()
    local player_manager = Managers.player
    local local_player = player_manager.local_player(player_manager)
    local player_unit = local_player and local_player.player_unit
    local current_position = Unit.local_position(player_unit, 0)

    mod:position_at_cursor(local_player)

    return
end
mod.position_at_cursor = function(self, local_player)
    local viewport_name = local_player.viewport_name
    local camera_position = Managers.state.camera:camera_position(viewport_name)
    local camera_rotation = Managers.state.camera:camera_rotation(viewport_name)
    local camera_direction = Quaternion.forward(camera_rotation)
    local range = 500
    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    local new_position = nil
    local num_shots_this_frame = 15
    local angle = math.pi / 80
    local outer_angle = 0
    local outer_number = 1

    for j = 1, outer_number, 1 do
        local rotation = camera_rotation
        local rotation2 = camera_rotation

        for i = 1, num_shots_this_frame, 1 do
            rotation = mod.get_rotation(0, angle, 0, rotation)
            rotation2 = mod.get_rotation(0, angle * -1, 0, rotation2)
            local direction = Quaternion.forward(rotation)
            local is_hit, hit_pos, hit_dist, hit_norm, hit_actor =
                PhysicsWorld.immediate_raycast(physics_world, camera_position,
                                               direction, range, "closest",
                                               "collision_filter",
                                               "filter_player_mover")

            if is_hit then
                QuickDrawerStay:circle(hit_pos, 0.1, hit_norm, Colors.get("red"))
                QuickDrawerStay:vector(hit_pos, hit_norm * 0.1,
                                       Colors.get("red"))
            end

            direction = Quaternion.forward(rotation2)
            is_hit, hit_pos, hit_dist, hit_norm, hit_actor =
                PhysicsWorld.immediate_raycast(physics_world, camera_position,
                                               direction, range, "closest",
                                               "collision_filter",
                                               "filter_player_mover")

            if is_hit then
                QuickDrawerStay:circle(hit_pos, 0.1, hit_norm, Colors.get("red"))
                QuickDrawerStay:vector(hit_pos, hit_norm * 0.1,
                                       Colors.get("red"))
            end
        end

        outer_angle = outer_angle + angle
    end

    return new_position
end
mod.get_rotation = function(roll, pitch, yaw, current_rotation)
    local roll_rot = Quaternion(Vector3.forward(), roll)
    local pitch_rot = Quaternion(Vector3.up(), pitch)
    local yaw_rot = Quaternion(Vector3.right(), yaw)
    local combined_rotation = Quaternion.multiply(current_rotation, roll_rot)
    combined_rotation = Quaternion.multiply(combined_rotation, pitch_rot)
    combined_rotation = Quaternion.multiply(combined_rotation, yaw_rot)

    return combined_rotation
end

mod:hook(PickupSystem, "populate_pickups", function(func, self, checkpoint_data)
    PRIMARY_SPAWNER_DATA = {}
    SECONDARY_SPAWNER_DATA = {}
    PRIMARY_SPAWNER_DISPLAY_DATA = {}
    SECONDARY_SPAWNER_DISPLAY_DATA = {}
    GUARENTEED_DATA = {}

    local level_settings = LevelHelper:current_level_settings()
    local level_pickup_settings = level_settings.pickup_settings

    if not level_pickup_settings then
        Application.warning(
            "[PickupSystem] CURRENT LEVEL HAS NO PICKUP DATA IN ITS SETTINGS, NO PICKUPS WILL SPAWN ")

        return
    end

    local difficulty_manager = Managers.state.difficulty
    local difficulty = difficulty_manager:get_difficulty()
    local pickup_settings = level_pickup_settings[difficulty]

    if not pickup_settings then
        Application.warning(
            "[PickupSystem] CURRENT LEVEL HAS NO PICKUP DATA FOR CURRENT DIFFICULTY: %s, USING SETTINGS FOR EASY ",
            difficulty)

        pickup_settings = level_pickup_settings.default or
                              level_pickup_settings[1]
    end

    local function comparator(a, b)
        local percentage_a = Unit.get_data(a, "percentage_through_level")
        local percentage_b = Unit.get_data(b, "percentage_through_level")

        fassert(percentage_a,
                "Level Designer working on %s, You need to rebuild paths (pickup spawners broke)",
                level_settings.display_name)
        fassert(percentage_b,
                "Level Designer working on %s, You need to rebuild paths (pickup spawners broke)",
                level_settings.display_name)

        return percentage_a < percentage_b
    end

    mod.fake_spawn_guarenteed(self)

    local primary_pickup_spawners = self.primary_pickup_spawners
    local primary_pickup_settings = pickup_settings.primary or pickup_settings

    mod.fake_spread(primary_pickup_spawners, primary_pickup_settings,
                    comparator, PRIMARY_SPAWNER_DATA)
    mod.saveSpawnerData(PRIMARY_SPAWNER_DATA, PRIMARY_SPAWNER_DISPLAY_DATA)

    local secondary_pickup_spawners = self.secondary_pickup_spawners
    local secondary_pickup_settings = pickup_settings.secondary

    if secondary_pickup_settings then
        -- mod:echo("Secondary")
        mod.fake_spread(secondary_pickup_spawners, secondary_pickup_settings,
                        comparator, SECONDARY_SPAWNER_DATA)
        mod.saveSpawnerData(SECONDARY_SPAWNER_DATA,
                            SECONDARY_SPAWNER_DISPLAY_DATA)
        -- mod:dump(SECONDARY_SPAWNER_DISPLAY_DATA, "", 4)
    end

    func(self, checkpoint_data)
end)

mod.fake_spawn_guarenteed = function(self)
    local color_vector_orange = Vector3(255, 165, 0)
    local color_vector_green = Vector3(0, 255, 0)
    local color_vector_blue = Vector3(0, 0, 255)
    local color_vector_red = Vector3(255, 0, 0)
    local color_vector = Vector3(255, 255, 0)
    local color_progress = Vector3(224, 255, 255, 0)
    local spawners = self.guaranteed_pickup_spawners
    local num_spawners = #spawners
    local spawn_type = "guaranteed"

    for i = 1, num_spawners, 1 do
        local spawner_unit = spawners[i]
        local potential_pickups = {}

        for pickup_name, settings in pairs(AllPickups) do
            local can_spawn = self:_can_spawn(spawner_unit, pickup_name)
            local color = color_vector

            if string.find(pickup_name, "damage_boost") then
                color = color_vector_orange
            elseif string.find(pickup_name, "speed_boost") then
                color = color_vector_blue
            elseif string.find(pickup_name, "healing_draught") or
                string.find(pickup_name, "first_aid") then
                color = color_vector_green
            elseif string.find(pickup_name, "grenade") then
                color = color_vector_red
            end

            if can_spawn and 0 < settings.spawn_weighting then
                table.insert(potential_pickups, {
                    pickup_name,
                    displayColor = {color[1], color[2], color[3]}
                })
            end
        end

        GUARENTEED_DATA[spawner_unit] = potential_pickups
    end
end

mod.fake_spread = function(pickup_spawners, pickup_settings, comparator,
                           spawner_data)
    table.sort(pickup_spawners, comparator)
    for pickup_type, value in pairs(pickup_settings) do
        local num_sections = 0
        if type(value) == "table" then
            for pickup_name, amount in pairs(value) do
                num_sections = num_sections + amount
            end
        else
            num_sections = value
        end
        -- mod:echo(pickup_type)
        -- mod:echo(num_sections)

        local section_size = num_sections / 1
        local section_start_point = 0
        local section_end_point = 0

        for i = 1, num_sections, 1 do
            local num_pickup_spawners = #pickup_spawners
            section_end_point = section_start_point + section_size

            for j = 1, num_pickup_spawners, 1 do
                local spawner_unit = pickup_spawners[j]
                local percentage_through_level =
                    Unit.get_data(spawner_unit, "percentage_through_level")

                if (section_start_point <= percentage_through_level and
                    percentage_through_level < section_end_point) or
                    (num_sections == i and percentage_through_level == 1) then
                    if not spawner_data[spawner_unit] then
                        spawner_data[spawner_unit] = {}
                    end

                    table.insert(spawner_data[spawner_unit],
                                 {pickup_type, i, j, percentage_through_level})
                end
            end

            section_start_point = section_end_point
        end
    end
end

mod.drawItemSpawners = function()
    local debug_text = Managers.state.debug_text
    local text_size = mod:get("item_text_mult")
    local z = Vector3.up() * 0.5
    local color_vector_orange = Vector3(255, 165, 0, 0)
    local color_vector_green = Vector3(0, 255, 0, 0)
    local color_vector_blue = Vector3(0, 0, 255, 0)
    local color_vector_red = Vector3(255, 0, 0, 0)
    local color_vector = Vector3(255, 255, 0, 0)
    local color_progress = Vector3(224, 255, 255, 0)
    local pickup_ext = Managers.state.entity:system("pickup_system")

    local player_unit = Managers.player:local_player().player_unit
    local player_pos = Unit.local_position(player_unit, 0)

    local max_distance = mod:get("text_distance")
    debug_text.clear_world_text(debug_text, "category: item_spawner_id")

    for spawn_unit, spawner_table in pairs(PRIMARY_SPAWNER_DISPLAY_DATA) do
        local spawner_pos = Unit.local_position(spawn_unit, 0)
        local count = 0

        if Vector3.distance(player_pos, spawner_pos) < max_distance then
            for _, pickup_info in pairs(PRIMARY_SPAWNER_DISPLAY_DATA[spawn_unit]
                                            .data) do
                debug_text.output_world_text(debug_text,
                                             pickup_info.displayString,
                                             text_size, spawner_pos + z +
                                                 Vector3.up() * count *
                                                 text_size, nil,
                                             "category: item_spawner_id",
                                             Vector3(
                                                 pickup_info.displayColor[1],
                                                 pickup_info.displayColor[2],
                                                 pickup_info.displayColor[3], 0),
                                             "player_1")

                count = count + 1
            end

            local pogress_info = string.format("Order: %i Progress: %.2f%%",
                                               PRIMARY_SPAWNER_DISPLAY_DATA[spawn_unit]
                                                   .order,
                                               PRIMARY_SPAWNER_DISPLAY_DATA[spawn_unit]
                                                   .progress)

            debug_text.output_world_text(debug_text, pogress_info, text_size,
                                         spawner_pos + z + Vector3.up() * count *
                                             text_size, nil,
                                         "category: item_spawner_id",
                                         color_progress, "player_1")
        end
        QuickDrawer:sphere(spawner_pos, 0.25, Colors.get("yellow"))
    end

    for spawn_unit, spawner_table in pairs(SECONDARY_SPAWNER_DISPLAY_DATA) do
        local spawner_pos = Unit.local_position(spawn_unit, 0)
        local count = 0

        if Vector3.distance(player_pos, spawner_pos) < max_distance then
            for _, pickup_info in pairs(
                                      SECONDARY_SPAWNER_DISPLAY_DATA[spawn_unit]
                                          .data) do
                debug_text.output_world_text(debug_text,
                                             pickup_info.displayString,
                                             text_size, spawner_pos + z +
                                                 Vector3.up() * count *
                                                 text_size, nil,
                                             "category: item_spawner_id",
                                             Vector3(
                                                 pickup_info.displayColor[1],
                                                 pickup_info.displayColor[2],
                                                 pickup_info.displayColor[3], 0),
                                             "player_1")

                count = count + 1
            end

            local pogress_info = string.format("Order: %i Progress: %.2f%%",
                                               SECONDARY_SPAWNER_DISPLAY_DATA[spawn_unit]
                                                   .order,
                                               SECONDARY_SPAWNER_DISPLAY_DATA[spawn_unit]
                                                   .progress)

            debug_text.output_world_text(debug_text, pogress_info, text_size,
                                         spawner_pos + z + Vector3.up() * count *
                                             text_size, nil,
                                         "category: item_spawner_id",
                                         color_progress, "player_1")
        end
        QuickDrawer:sphere(spawner_pos, 0.25, Colors.get("orange"))
    end

    for spawner_unit, data in pairs(GUARENTEED_DATA) do
        local spawner_pos = Unit.local_position(spawner_unit, 0)
        QuickDrawer:sphere(spawner_pos, 0.25, Colors.get("red"))
        local count = 0
        if Vector3.distance(player_pos, spawner_pos) < max_distance then
            for _, pickup in pairs(data) do
                debug_text.output_world_text(debug_text, pickup[1], text_size,
                                             spawner_pos + z + Vector3.up() *
                                                 count * text_size, nil,
                                             "category: item_spawner_id",
                                             Vector3(pickup.displayColor[1],
                                                     pickup.displayColor[2],
                                                     pickup.displayColor[3], 0),
                                             "player_1")

                count = count + 1
            end
        end
    end

    ITEM_TEXT = true

    return
end

mod.saveSpawnerData = function(spawner_data, spawner_display_data)
    local color_vector_orange = Vector3(255, 165, 0)
    local color_vector_green = Vector3(0, 255, 0)
    local color_vector_blue = Vector3(0, 191, 255)
    local color_vector_red = Vector3(255, 0, 0)
    local color_vector_purple = Vector3(138, 43, 226)
    local color_vector = Vector3(255, 255, 0)
    local color_progress = Vector3(224, 255, 255, 0)
    local pickup_ext = Managers.state.entity:system("pickup_system")

    for spawn_unit, spawner_table in pairs(spawner_data) do
        spawner_display_data[spawn_unit] =
            {
                order = spawner_table[1][3],
                progress = spawner_table[1][4] * 100,
                data = {}
            }
        local spawner_pos = Unit.local_position(spawn_unit, 0)
        local count = 0

        for _, pickup_info in pairs(spawner_table) do
            for pickup_name, settings in pairs(Pickups[pickup_info[1]]) do
                if Unit.get_data(spawn_unit, pickup_name) then
                    local color = color_vector

                    if string.find(pickup_name, "damage_boost") then
                        color = color_vector_orange
                    elseif string.find(pickup_name, "speed_boost") then
                        color = color_vector_blue
                    elseif string.find(pickup_name, "cooldown_reduction") then
                        color = color_vector_purple
                    elseif string.find(pickup_name, "healing_draught") or
                        string.find(pickup_name, "first_aid") then
                        color = color_vector_green
                    elseif string.find(pickup_name, "grenade") then
                        color = color_vector_red
                    end

                    table.insert(spawner_display_data[spawn_unit].data, {
                        displayString = tostring(pickup_info[2]) .. " " ..
                            pickup_name,
                        displayColor = {color[1], color[2], color[3]}
                    })

                    count = count + 1
                end
            end
        end
    end

    return
end

mod.inList = function(list, check)
    for _,val in pairs(list) do
        if val == check then
            return true
        end
    end
    return false
end

mod.saveEventSpawners = function()
    local z = Vector3.up() * 0.5
    if not Managers.state.entity then return end
    local spawner_system = Managers.state.entity:system("spawner_system")
    local level_key = Managers.state.game_mode:level_key()
    local color = Color(255, 0, 200, 0)
    local color_vector = Vector3(255, 0, 200, 0) -- luacheck: ignore
    local text_size = 0.5
    local terror_events = TerrorEventBlueprints[level_key]

    local debug_text = Managers.state.debug_text
    if not terror_events then return end

    -- debug_text:clear_world_text("category: spawner_id")
    for key, event in pairs(terror_events) do
        -- mod:echo(key)
        for _, tbl in pairs(event) do
            if tbl and tbl.spawner_id then
                local spawner_unit = spawner_system:get_raw_spawner_unit(
                                         tbl.spawner_id)
                if spawner_unit then
                    if EVENT_SPAWNERS[spawner_unit] and not mod.inList(EVENT_SPAWNERS[spawner_unit], tbl.spawner_id) then
                        table.insert(EVENT_SPAWNERS[spawner_unit], tbl.spawner_id)
                    else
                        EVENT_SPAWNERS[spawner_unit] = {tbl.spawner_id}
                    end
                    -- mod:echo(spawner_unit)
                    -- local pos = Unit.local_position(spawner_unit, 0)
                    -- QuickDrawer:sphere(pos + z, 0.5, color)
                    -- debug_text.output_world_text(debug_text, tbl.spawner_id,
                    --                              text_size, pos + z, nil,
                    --                              "category: spawner_id",
                    --                              color_vector, "player_1")
                else
                    
                    local spawners = spawner_system._id_lookup[tbl.spawner_id]
                    if spawners then
                        mod:echo("Found unit for %s", tbl.spawner_id)
                        for _, spawner_unit in pairs(spawners) do
                            if EVENT_SPAWNERS[spawner_unit] and not mod.inList(EVENT_SPAWNERS[spawner_unit], tbl.spawner_id) then
                                table.insert(EVENT_SPAWNERS[spawner_unit], tbl.spawner_id)
                            else
                                EVENT_SPAWNERS[spawner_unit] = {tbl.spawner_id}
                            end
                        end
                    end
                    
                end
            end
        end
    end
    mod.draw_debug_spawners()
end

mod.draw_debug_spawners = function()
    local debug_text = Managers.state.debug_text
    local text_size = mod:get("item_text_mult")
    local z = Vector3.up() * 0.5
    local color_vector = Vector3(255, 0, 200, 0) -- luacheck: ignore
    local color = Vector3(255, 0, 200)
    debug_text:clear_world_text("category: spawner_id")
    for spawner_unit, groups in pairs(EVENT_SPAWNERS) do
        local count = 0
        local spawner_pos = Unit.local_position(spawner_unit, 0)
        QuickDrawer:sphere(spawner_pos, 0.35, Color(255, 0, 200))
        for _, name in pairs(groups) do
            debug_text.output_world_text(debug_text, name, text_size,
                                         spawner_pos + z + Vector3.up() * count *
                                             text_size, nil,
                                         "category: spawner_id", color_vector,
                                         "player_1")
            count = count + 1
        end
    end
end

-- mod.drawNavMesh = function()
--     local player_unit = Managers.player:local_player().player_unit
--     local position = Unit.world_position(player_unit, 0)
--     local offset = Vector3(0, 0, 0.2)

--     LineObject.reset(LINE_OBJECT)

--     local nav_world = Managers.state.entity:system("ai_system"):nav_world()
-- 	local triangle = GwNavTraversal.get_seed_triangle(nav_world, position)

--     if triangle == nil then
-- 		return
-- 	end

-- 	local triangles = {
-- 		triangle
-- 	}
-- 	local num_triangles = 1
-- 	local i = 0

--     local color_table = {}

--     for i = 1, 25, 1 do
--         color_table[i] = math.random(1, 15)
--     end

-- 	while num_triangles > i do
-- 		i = i + 1
-- 		triangle = triangles[i]
-- 		local p1, p2, p3 = GwNavTraversal.get_triangle_vertices(nav_world, triangle)
-- 		local triangle_center = p1 + p2 + p3
-- 		local table_index = math.ceil((triangle_center.x + triangle_center.y) % 24 + 1)
-- 		local green = color_table[table_index] * 10

-- 		Gui.triangle(WORLD_GUI, p1 + offset, p2 + offset, p3 + offset, 0, Color(150, 0, 150, 255))
-- 		LineObject.add_line(LINE_OBJECT, Color(255, 255, 255), p1 + offset, p2 + offset)
-- 		LineObject.add_line(LINE_OBJECT, Color(255, 255, 255), p1 + offset, p3 + offset)
-- 		LineObject.add_line(LINE_OBJECT, Color(255, 255, 255), p2 + offset, p3 + offset)

-- 		local neighbors = {
-- 			GwNavTraversal.get_neighboring_triangles(triangle)
-- 		}

-- 		for j = 1, #neighbors, 1 do
-- 			local neighbor = neighbors[j]
-- 			local is_in_list_already = false

-- 			for k = 1, num_triangles, 1 do
-- 				local triangle2 = triangles[k]

-- 				if GwNavTraversal.are_triangles_equal(neighbor, triangle2) then
-- 					is_in_list_already = true

-- 					break
-- 				end
-- 			end

-- 			if not is_in_list_already then
-- 				local p2_1, p2_2, p2_3 = GwNavTraversal.get_triangle_vertices(nav_world, triangle)

-- 				if Vector3.distance((p2_1 + p2_2 + p2_3) * 0.33, position) < 5 then
-- 					num_triangles = num_triangles + 1
-- 					triangles[num_triangles] = neighbor
-- 				end
-- 			end
-- 		end
-- 	end

-- 	LineObject.dispatch(WORLD, LINE_OBJECT)
-- end

-- mod:hook_safe(HordeSpawner, "play_sound", function(self, stinger_name, pos)
--     local player_unit = Managers.player:local_player().player_unit
--     local player_pos = Unit.local_position(player_unit, 0)
--     local h = Vector3(0,0,1)
--     QuickDrawerStay:sphere(pos + h, 1, Colors.get("yellow"))
--     QuickDrawerStay:line(pos + h, player_pos + h, Colors.get("yellow"))

-- end)
