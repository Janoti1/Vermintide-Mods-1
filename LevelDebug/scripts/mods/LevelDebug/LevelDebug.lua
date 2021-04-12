local mod = get_mod("LevelDebug")
local RESPAWN_DISTANCE = 70
local END_OF_LEVEL_BUFFER = 35
local RESPAWN_TIME = 30
local SAVED_WHERE = nil
local TEXT = false
local ITEM_TEXT = false
local SPAWNER_DATA = {}
local SPAWNER_DISPLAY_DATA = {}
local GUARENTEED_DATA = {}
local enabled = false
Development._hardcoded_dev_params.disable_debug_draw = not enabled
script_data.disable_debug_draw = not enabled
DebugManager.drawer = function (self, options)
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

mod.hook_safe(mod, IngameHud, "update", function (self)
	if not self.boon_ui._is_visible or Managers.state.game_mode._level_key == "inn_level" then
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

mod.update = function ()
	if enabled then
		if mod:get("main_path") then
			mod.drawMainPath()
		end

		if mod:get("boss") then
			mod.drawBosses()
		end

		if mod:get("patrol") then
			mod.drawPats()
		end

		if mod:get("respawn") then
			mod.drawRespawns()
		end

		if mod:get("player_pos") then
			mod.drawPosition()
		end

		if mod:get("where") then
			mod.drawWhere()
		end

		if mod:get("named_spawners") and not TEXT then
			mod.drawNamedSpawners()
		end

		if mod:get("item_spawners") and not ITEM_TEXT then
			mod.drawItemSpawners()
		end

		if SAVED_WHERE then
			mod.drawSavedWhere()
		end

		if Managers.state.debug then
			for _, drawer in pairs(Managers.state.debug._drawers) do
				drawer.update(drawer, Managers.state.debug._world)
			end
		end
	end

	return 
end
mod.on_setting_changed = function (self)
	QuickDrawer:reset()
	QuickDrawerStay:reset()

	local debug_text = Managers.state.debug_text

	debug_text.clear_world_text(debug_text, "category: spawner_id")
	debug_text.clear_world_text(debug_text, "category: item_spawner_id")

	TEXT = false
	ITEM_TEXT = false

	return 
end
mod.on_game_state_changed = function (self)
	enabled = false
	SAVED_WHERE = nil
	TEXT = false
	ITEM_TEXT = false

	return 
end
mod.drawMainPath = function ()
	local level_analysis = Managers.state.conflict.level_analysis
	local h = Vector3(0, 0, 1)
	local main_paths = level_analysis.main_paths

	for i = 1, #main_paths, 1 do
		local path = main_paths[i].nodes

		for j = 1, #path, 1 do
			local position = Vector3(path[j][1], path[j][2], path[j][3])

			QuickDrawer:sphere(position + h, 0.25, Colors.get("green"))

			if j == #path and i ~= #main_paths then
				local nextPositon = Vector3(main_paths[i + 1].nodes[1][1], main_paths[i + 1].nodes[1][2], main_paths[i + 1].nodes[1][3])

				QuickDrawer:line(position + h, nextPositon + h, Colors.get("yellow"))
			elseif j ~= #path then
				local nextPositon = Vector3(path[j + 1][1], path[j + 1][2], path[j + 1][3])

				QuickDrawer:line(position + h, nextPositon + h, Colors.get("green"))
			end
		end
	end

	return 
end
mod.drawBosses = function ()
	local level_analysis = Managers.state.conflict.level_analysis
	local spawners = level_analysis.terror_spawners
	local boss_spawners = spawners.event_boss.spawners
	local h = Vector3(0, 0, 1)

	for i = 1, #boss_spawners, 1 do
		local data = boss_spawners[i]
		local spawner_pos = Unit.local_position(data[1], 0)
		local boxed_pos = Vector3Box(spawner_pos)
		local event_data = {
			event_kind = "event_boss"
		}
		local path_pos, travel_dist, move_percent, path_index, sub_index = MainPathUtils.closest_pos_at_main_path(nil, boxed_pos.unbox(boxed_pos))
		local activation_pos, _ = MainPathUtils.point_on_mainpath(nil, travel_dist - 45)

		QuickDrawer:line(spawner_pos, spawner_pos + Vector3(0, 0, 15), Color(125, 255, 0))
		QuickDrawer:sphere(spawner_pos, 5, Colors.get("red"))
		QuickDrawer:line(spawner_pos, activation_pos + h, Color(125, 255, 0))
		QuickDrawer:sphere(activation_pos + h, 0.25, Colors.get("red"))
	end

	return 
end
mod.drawPats = function ()
	local level_analysis = Managers.state.conflict.level_analysis
	local spawners = level_analysis.terror_spawners
	local patrol_spawners = spawners.event_patrol.spawners
	local h = Vector3(0, 0, 1)

	for i = 1, #patrol_spawners, 1 do
		local data = patrol_spawners[i]
		local spawner_pos = Unit.local_position(data[1], 0)
		local boxed_pos = Vector3Box(spawner_pos)
		local event_data = {
			event_kind = "event_patrol"
		}
		local path_pos, travel_dist, move_percent, path_index, sub_index = MainPathUtils.closest_pos_at_main_path(nil, boxed_pos.unbox(boxed_pos))
		local activation_pos, _ = MainPathUtils.point_on_mainpath(nil, travel_dist - 45)

		QuickDrawer:line(spawner_pos, spawner_pos + Vector3(0, 0, 15), Color(125, 255, 0))
		QuickDrawer:sphere(spawner_pos, 5, Colors.get("orange"))
		QuickDrawer:line(spawner_pos, activation_pos + h, Color(125, 255, 0))
		QuickDrawer:sphere(activation_pos + h, 0.25, Colors.get("orange"))
	end

	return 
end
mod.drawRespawns = function ()
	local up = Vector3(0, 0, 1)
	local up2 = Vector3(0, 0, 0.5)
	local respawners = Managers.state.spawn.respawn_handler._respawn_units
	local unit_local_position = Unit.local_position

	for i = 1, #respawners, 1 do
		local respawner = respawners[i]
		local best_point, best_travel_dist, move_percent, best_sub_index, best_main_path = MainPathUtils.closest_pos_at_main_path(nil, unit_local_position(respawner.unit, 0))
		local pos = unit_local_position(respawner.unit, 0)

		QuickDrawer:sphere(pos, 0.53, Colors.get("cyan"))
		QuickDrawer:line(pos, pos + Vector3(0, 0, 15), Colors.get("cyan"))

		local pos_distance = MainPathUtils.point_on_mainpath(nil, respawner.distance_through_level - RESPAWN_DISTANCE)

		QuickDrawer:line(pos + up, pos_distance + up, Colors.get("cyan"))
		QuickDrawer:sphere(pos_distance + up, 0.25, Colors.get("cyan"))
	end

	return 
end
mod.drawPosition = function ()
	local h = Vector3(0, 0, 1)
	local conflict_director = Managers.state.conflict
	local level_analysis = conflict_director.level_analysis
	local main_path_data = level_analysis.main_path_data
	local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
	local total_travel_dist = main_path_data.total_dist
	local travel_percentage = ahead_travel_dist/total_travel_dist*100
	local point = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)

	QuickDrawer:sphere(point + h, 0.25, Colors.get("purple"))

	local player_unit = Managers.player:local_player().player_unit
	local player_pos = Unit.local_position(player_unit, 0)

	QuickDrawer:line(point + h, player_pos + h, Colors.get("purple"))

	return 
end
mod.drawWhere = function ()
	local h = Vector3(0, 0, 1)
	local h2 = Vector3(0, 0, 0.5)
	local unit = mod.get_respawn_unit()
	local pos = Unit.local_position(unit, 0)
	local conflict_director = Managers.state.conflict
	local level_analysis = conflict_director.level_analysis
	local main_path_data = level_analysis.main_path_data
	local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
	local total_travel_dist = main_path_data.total_dist
	local travel_percentage = ahead_travel_dist/total_travel_dist*100
	local point = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)

	QuickDrawer:line(point + h, pos + h2, Colors.get("yellow"))
	QuickDrawer:sphere(point + h, 0.25, Colors.get("yellow"))

	return 
end
mod.drawNamedSpawners = function ()
	local debug_text = Managers.state.debug_text
	local spawner_system = Managers.state.entity:system("spawner_system")

	for event, unitTable in pairs(spawner_system._id_lookup) do
		for _, unit in pairs(unitTable) do
			local spawner_pos = Unit.local_position(unit, 0)
			local text_size = 0.5
			local z = Vector3.up()*0.5
			local color_vector = Vector3(255, 0, 200, 0)

			debug_text.output_world_text(debug_text, event, text_size, spawner_pos + z, nil, "category: spawner_id", color_vector)
		end
	end

	TEXT = true

	return 
end
mod.drawItemSpawners_old = function ()
	local debug_text = Managers.state.debug_text
	local text_size = 0.1
	local z = Vector3.up()*0.5
	local color_vector_orange = Vector3(255, 165, 0, 0)
	local color_vector_green = Vector3(0, 255, 0, 0)
	local color_vector_blue = Vector3(0, 0, 255, 0)
	local color_vector_red = Vector3(255, 0, 0, 0)
	local color_vector = Vector3(255, 255, 0, 0)
	local pickup_ext = Managers.state.entity:system("pickup_system")

	for _, pickup in pairs(pickup_ext.primary_pickup_spawners) do
		local spawner_pos = Unit.local_position(pickup, 0)
		local count = 0

		for pickup_name, pickup_settings in pairs(AllPickups) do
			if Unit.get_data(pickup, pickup_name) then
				local color = color_vector

				if string.find(pickup_name, "damage_boost") then
					color = color_vector_orange
				elseif string.find(pickup_name, "speed_boost") then
					color = color_vector_blue
				elseif string.find(pickup_name, "healing_draught") or string.find(pickup_name, "first_aid") then
					color = color_vector_green
				elseif string.find(pickup_name, "grenade") then
					color = color_vector_red
				end

				debug_text.output_world_text(debug_text, pickup_name, text_size, spawner_pos + z + Vector3.up()*count*text_size, nil, "category: item_spawner_id", color)

				count = count + 1
			end
		end

		QuickDrawerStay:sphere(spawner_pos, 0.25, Colors.get("yellow"))
	end

	ITEM_TEXT = true

	return 
end
mod.drawItemSpawners_old2 = function ()
	local debug_text = Managers.state.debug_text
	local text_size = 0.1
	local z = Vector3.up()*0.5
	local color_vector_orange = Vector3(255, 165, 0, 0)
	local color_vector_green = Vector3(0, 255, 0, 0)
	local color_vector_blue = Vector3(0, 0, 255, 0)
	local color_vector_red = Vector3(255, 0, 0, 0)
	local color_vector = Vector3(255, 255, 0, 0)
	local color_progress = Vector3(224, 255, 255, 0)
	local pickup_ext = Managers.state.entity:system("pickup_system")

	for spawn_unit, spawner_table in pairs(SPAWNER_DATA) do
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
					elseif string.find(pickup_name, "healing_draught") or string.find(pickup_name, "first_aid") then
						color = color_vector_green
					elseif string.find(pickup_name, "grenade") then
						color = color_vector_red
					end

					debug_text.output_world_text(debug_text, tostring(pickup_info[2]) .. " " .. pickup_name, text_size, spawner_pos + z + Vector3.up()*count*text_size, nil, "category: item_spawner_id", color)

					count = count + 1
				end
			end
		end

		local pogress_info = string.format("Order: %i Progress: %.2f%%", spawner_table[1][3], spawner_table[1][4]*100)

		debug_text.output_world_text(debug_text, pogress_info, text_size, spawner_pos + z + Vector3.up()*count*text_size, nil, "category: item_spawner_id", color_progress)
		QuickDrawerStay:sphere(spawner_pos, 0.25, Colors.get("yellow"))
	end

	ITEM_TEXT = true

	return 
end

mod.command(mod, "where", "", function ()
	local h = Vector3(0, 0, 1)
	local h2 = Vector3(0, 0, 0.5)
	local unit = mod.get_respawn_unit()
	local pos = Unit.local_position(unit, 0)
	local conflict_director = Managers.state.conflict
	local level_analysis = conflict_director.level_analysis
	local main_path_data = level_analysis.main_path_data
	local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
	local total_travel_dist = main_path_data.total_dist
	local travel_percentage = ahead_travel_dist/total_travel_dist*100
	local point = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)

	QuickDrawerStay:line(point + h, pos + h2, Colors.get("yellow"))
	QuickDrawerStay:sphere(point + h, 0.25, Colors.get("yellow"))

	return 
end)
mod.command(mod, "clearDraw", "", function ()
	QuickDrawer:reset()
	QuickDrawerStay:reset()

	local debug_text = Managers.state.debug_text

	debug_text.clear_world_text(debug_text, "category: spawner_id")
	debug_text.clear_world_text(debug_text, "category: item_spawner_id")

	return 
end)

mod.get_respawn_unit = function ()
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
	local main_paths = level_analysis.get_main_paths(level_analysis)
	local player_unit = Managers.player:local_player().player_unit
	local conflict_director = Managers.state.conflict
	local level_analysis = conflict_director.level_analysis
	local main_path_data = level_analysis.main_path_data
	local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
	local total_travel_dist = main_path_data.total_dist
	local travel_percentage = ahead_travel_dist/total_travel_dist*100
	local ahead_position = MainPathUtils.point_on_mainpath(nil, ahead_travel_dist)

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

	return selected_unit
end

mod.hook(mod, PickupSystem, "populate_pickups", function (func, self, checkpoint_data)
	SPAWNER_DATA = {}
	SPAWNER_DISPLAY_DATA = {}
	GUARENTEED_DATA = {}
	local level_settings = LevelHelper:current_level_settings()
	local level_pickup_settings = level_settings.pickup_settings

	if not level_pickup_settings then
		return 
	end

	local difficulty_manager = Managers.state.difficulty
	local difficulty_rank = difficulty_manager.get_difficulty_rank(difficulty_manager)
	local difficulty = difficulty_manager.get_difficulty(difficulty_manager)
	local pickup_settings = level_pickup_settings[difficulty_rank]

	mod:dump(self.primary_pickup_spawners, "", 1)

	local primary_pickup_spawners = self.primary_pickup_spawners
	local secondary_pickup_spawners = self.secondary_pickup_spawners

	local function comparator(a, b)
		local percentage_a = Unit.get_data(a, "percentage_through_level")
		local percentage_b = Unit.get_data(b, "percentage_through_level")

		fassert(percentage_a, "Level Designer working on %s, You need to rebuild paths (pickup spawners broke)", level_settings.display_name)
		fassert(percentage_b, "Level Designer working on %s, You need to rebuild paths (pickup spawners broke)", level_settings.display_name)

		return percentage_a < percentage_b
	end

	local primary_pickup_settings = pickup_settings.primary or pickup_settings

	mod.fake_spread(primary_pickup_spawners, primary_pickup_settings, comparator, nil)
	mod.saveSpawnerData()
	mod.fake_spawn_guarenteed(self)
	func(self, checkpoint_data)

	return 
end)

mod.fake_spawn_guarenteed = function (self)
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
			local can_spawn = Unit.get_data(spawner_unit, pickup_name)
			local color = color_vector

			if string.find(pickup_name, "damage_boost") then
				color = color_vector_orange
			elseif string.find(pickup_name, "speed_boost") then
				color = color_vector_blue
			elseif string.find(pickup_name, "healing_draught") or string.find(pickup_name, "first_aid") then
				color = color_vector_green
			elseif string.find(pickup_name, "grenade") then
				color = color_vector_red
			end

			if can_spawn and 0 < settings.spawn_weighting then
				table.insert(potential_pickups, {
					pickup_name,
					displayColor = {
						color[1],
						color[2],
						color[3]
					}
				})
			end
		end

		GUARENTEED_DATA[spawner_unit] = potential_pickups
	end

	mod:dump(GUARENTEED_DATA, "", 3)

	return 
end
mod.fake_spread = function (spawners, pickup_settings, comparator, seed)
	table.sort(spawners, comparator)

	for pickup_type, value in pairs(pickup_settings) do
		local num_sections = value
		local section_size = num_sections/1
		local section_start_point = 0
		local section_end_point = 0

		for i = 1, num_sections, 1 do
			local num_pickup_spawners = #spawners
			section_end_point = section_start_point + section_size

			for j = 1, num_pickup_spawners, 1 do
				local spawner_unit = spawners[j]
				local percentage_through_level = Unit.get_data(spawner_unit, "percentage_through_level")

				if (section_start_point <= percentage_through_level and percentage_through_level < section_end_point) or (num_sections == i and percentage_through_level == 1) then
					if not SPAWNER_DATA[spawner_unit] then
						SPAWNER_DATA[spawner_unit] = {}
					end

					table.insert(SPAWNER_DATA[spawner_unit], {
						pickup_type,
						i,
						j,
						percentage_through_level
					})
				end
			end

			section_start_point = section_end_point
		end
	end

	return 
end
mod.saveSpawnerData = function ()
	local color_vector_orange = Vector3(255, 165, 0)
	local color_vector_green = Vector3(0, 255, 0)
	local color_vector_blue = Vector3(0, 0, 255)
	local color_vector_red = Vector3(255, 0, 0)
	local color_vector = Vector3(255, 255, 0)
	local color_progress = Vector3(224, 255, 255, 0)
	local pickup_ext = Managers.state.entity:system("pickup_system")

	for spawn_unit, spawner_table in pairs(SPAWNER_DATA) do
		SPAWNER_DISPLAY_DATA[spawn_unit] = {
			order = spawner_table[1][3],
			progress = spawner_table[1][4]*100,
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
					elseif string.find(pickup_name, "healing_draught") or string.find(pickup_name, "first_aid") then
						color = color_vector_green
					elseif string.find(pickup_name, "grenade") then
						color = color_vector_red
					end

					table.insert(SPAWNER_DISPLAY_DATA[spawn_unit].data, {
						displayString = tostring(pickup_info[2]) .. " " .. pickup_name,
						displayColor = {
							color[1],
							color[2],
							color[3]
						}
					})

					count = count + 1
				end
			end
		end
	end

	return 
end
mod.drawItemSpawners = function ()
	local debug_text = Managers.state.debug_text
	local text_size = mod:get("item_text_mult")
	local z = Vector3.up()*0.5
	local color_vector_orange = Vector3(255, 165, 0, 0)
	local color_vector_green = Vector3(0, 255, 0, 0)
	local color_vector_blue = Vector3(0, 0, 255, 0)
	local color_vector_red = Vector3(255, 0, 0, 0)
	local color_vector = Vector3(255, 255, 0, 0)
	local color_progress = Vector3(224, 255, 255, 0)
	local pickup_ext = Managers.state.entity:system("pickup_system")

	for spawn_unit, spawner_table in pairs(SPAWNER_DISPLAY_DATA) do
		local spawner_pos = Unit.local_position(spawn_unit, 0)
		local count = 0

		for _, pickup_info in pairs(SPAWNER_DISPLAY_DATA[spawn_unit].data) do
			debug_text.output_world_text(debug_text, pickup_info.displayString, text_size, spawner_pos + z + Vector3.up()*count*text_size, nil, "category: item_spawner_id", Vector3(pickup_info.displayColor[1], pickup_info.displayColor[2], pickup_info.displayColor[3], 0))

			count = count + 1
		end

		local pogress_info = string.format("Order: %i Progress: %.2f%%", SPAWNER_DISPLAY_DATA[spawn_unit].order, SPAWNER_DISPLAY_DATA[spawn_unit].progress)

		debug_text.output_world_text(debug_text, pogress_info, text_size, spawner_pos + z + Vector3.up()*count*text_size, nil, "category: item_spawner_id", color_progress)
		QuickDrawerStay:sphere(spawner_pos, 0.25, Colors.get("yellow"))
	end

	for spawner_unit, data in pairs(GUARENTEED_DATA) do
		local spawner_pos = Unit.local_position(spawner_unit, 0)

		QuickDrawerStay:sphere(spawner_pos, 0.25, Colors.get("red"))

		local count = 0

		for _, pickup in pairs(data) do
			debug_text.output_world_text(debug_text, pickup[1], text_size, spawner_pos + z + Vector3.up()*count*text_size, nil, "category: item_spawner_id", Vector3(pickup.displayColor[1], pickup.displayColor[2], pickup.displayColor[3], 0))

			count = count + 1
		end
	end

	ITEM_TEXT = true

	return 
end

mod.command(mod, "sectionId", "", function ()
	mod:dump(SPAWNER_DISPLAY_DATA, "", 5)

	return 
end)

mod.distToLookingAt = function ()
	local player_manager = Managers.player
	local local_player = player_manager.local_player(player_manager)
	local player_unit = local_player and local_player.player_unit
	local current_position = Unit.local_position(player_unit, 0)

	mod:position_at_cursor(local_player)

	return 
end
mod.position_at_cursor = function (self, local_player)
	local viewport_name = local_player.viewport_name
	local camera_position = Managers.state.camera:camera_position(viewport_name)
	local camera_rotation = Managers.state.camera:camera_rotation(viewport_name)
	local camera_direction = Quaternion.forward(camera_rotation)
	local range = 500
	local world = Managers.world:world("level_world")
	local physics_world = World.get_data(world, "physics_world")
	local new_position = nil
	local num_shots_this_frame = 15
	local angle = math.pi/80
	local outer_angle = 0
	local outer_number = 1

	for j = 1, outer_number, 1 do
		local rotation = camera_rotation
		local rotation2 = camera_rotation

		for i = 1, num_shots_this_frame, 1 do
			rotation = mod.get_rotation(0, angle, 0, rotation)
			rotation2 = mod.get_rotation(0, angle*-1, 0, rotation2)
			local direction = Quaternion.forward(rotation)
			local is_hit, hit_pos, hit_dist, hit_norm, hit_actor = PhysicsWorld.immediate_raycast(physics_world, camera_position, direction, range, "closest", "collision_filter", "filter_player_mover")

			if is_hit then
				QuickDrawerStay:circle(hit_pos, 0.1, hit_norm, Colors.get("red"))
				QuickDrawerStay:vector(hit_pos, hit_norm*0.1, Colors.get("red"))
			end

			direction = Quaternion.forward(rotation2)
			is_hit, hit_pos, hit_dist, hit_norm, hit_actor = PhysicsWorld.immediate_raycast(physics_world, camera_position, direction, range, "closest", "collision_filter", "filter_player_mover")

			if is_hit then
				QuickDrawerStay:circle(hit_pos, 0.1, hit_norm, Colors.get("red"))
				QuickDrawerStay:vector(hit_pos, hit_norm*0.1, Colors.get("red"))
			end
		end

		outer_angle = outer_angle + angle
	end

	return new_position
end
mod.get_rotation = function (roll, pitch, yaw, current_rotation)
	local roll_rot = Quaternion(Vector3.forward(), roll)
	local pitch_rot = Quaternion(Vector3.up(), pitch)
	local yaw_rot = Quaternion(Vector3.right(), yaw)
	local combined_rotation = Quaternion.multiply(current_rotation, roll_rot)
	combined_rotation = Quaternion.multiply(combined_rotation, pitch_rot)
	combined_rotation = Quaternion.multiply(combined_rotation, yaw_rot)

	return combined_rotation
end

return 
