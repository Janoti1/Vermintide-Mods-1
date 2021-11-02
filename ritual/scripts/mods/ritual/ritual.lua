local mod = get_mod("ritual")
local spawn_lists = {
	skaven = {
		"skaven_plague_monk",
		"skaven_clan_rat",
		"skaven_plague_monk",
		"skaven_clan_rat",
		"skaven_plague_monk",
		"skaven_clan_rat"
	},
	chaos = {
		"chaos_marauder",
		"chaos_marauder",
		"chaos_marauder",
		"chaos_marauder",
		"chaos_marauder"
	}
}
local spawn_categories = table.keys(spawn_lists)
local event_settings = {
	whitebox = {
		ritual_locations = {
			{
				0,
				0,
				0,
				0
			}
		}
	},
	dlc_portals = {
		ritual_locations = {
			{
				-178.758,
				224.85,
				-45.733,
				0
			}
		}
	},
	bell = {
		ritual_locations = {
			{
				-62.059746,
				-178.81282,
				-34.657001,
				0
			}
		}
	},
	military = {
		ritual_locations = {
			{
				91,
				147,
				-19.5,
				90
			}
		}
	},
	dlc_castle = {
		ritual_locations = {
			{
				5.584873,
				65.619408,
				0,
				-40
			}
		}
	},
	ussingen = {
		ritual_locations = {
			{
				-4.573383,
				-160.917343,
				1.135474,
				0
			}
		}
	}
}
local hard_mode_mutators = {
	"geheimnisnacht_2021_hard_mode"
}
local function side_objective_picked_up()
	local pop_chat = true
	local message = Localize("system_chat_geheimnisnacht_2021_hard_mode_on")

	Managers.chat:add_local_system_message(1, message, pop_chat)

	local mutator_handler = Managers.state.game_mode._mutator_handler

	mutator_handler:initialize_mutators(hard_mode_mutators)

	for i = 1, #hard_mode_mutators, 1 do
		mutator_handler:activate_mutator(hard_mode_mutators[i])
	end
end

local function side_objective_picked_dropped()
	local pop_chat = true
	local message = Localize("system_chat_geheimnisnacht_2021_hard_mode_off")

	Managers.chat:add_local_system_message(1, message, pop_chat)

	local mutator_handler = Managers.state.game_mode._mutator_handler

	for i = 1, #hard_mode_mutators, 1 do
		local mutator_name = hard_mode_mutators[i]
		local mutator_active = mutator_handler:has_activated_mutator(mutator_name)

		if mutator_active then
			mutator_handler:deactivate_mutator(mutator_name)
		end
	end
end

MutatorTemplates["geheimnisnacht_2021"]["server_start_function"] = function(context, data)
    local level_key = Managers.state.game_mode:level_key()
		local settings = event_settings[level_key]

		if settings then
			local ritual_locations = settings.ritual_locations
			local up = Vector3.up()

			for i = 1, #ritual_locations, 1 do
				local location = ritual_locations[i]
				local pos = Vector3(location[1], location[2], location[3])
				local rot = Quaternion.axis_angle(up, math.rad(location[4]))

				data.template.spawn_ritual_ring(pos, rot)
			end

			local inventory_system = Managers.state.entity:system("inventory_system")

			inventory_system:register_event_objective("wpn_geheimnisnacht_2021_side_objective", side_objective_picked_up, side_objective_picked_dropped)
		else 
      local level_key = Managers.state.game_mode:level_key()
      if string.find(level_key, "inn_level") or string.find(level_key, "morris_hub") then 
        return
      end
      local loaded = PackageManager:has_loaded("resource_packages/dlcs/geheimnisnacht_2021_event", geheimnisnacht_2021)
      if not loaded then
        mod:echo("[RITUAL]: Loading package: %s", resource_packages/dlcs/geheimnisnacht_2021_event)
        PackageManager:load("resource_packages/dlcs/geheimnisnacht_2021_event", "geheimnisnacht_2021", nil, true, nil)
      end
      mod:echo("[RITUAL]: Injecting Ritual Site")
      local level_analysis = Managers.state.conflict.level_analysis
      local main_paths = level_analysis.main_paths
      local node = nil
      if main_paths[2] then 
        node = main_paths[2].nodes[1]
      elseif main_paths[1] then
        node = main_paths[1].nodes[1]
      else 
        return
      end

      local pos = Vector3(node[1], node[2], node[3])
      local up = Vector3.up()

      local rot = Quaternion.axis_angle(up, math.rad(0))
      data.template.spawn_ritual_ring(pos, rot)

      local inventory_system = Managers.state.entity:system("inventory_system")

			inventory_system:register_event_objective("wpn_geheimnisnacht_2021_side_objective", side_objective_picked_up, side_objective_picked_dropped)

    end
end

mod.on_game_state_changed = function(status, state)
    if status == "enter" and state == "StateIngame" then
        local mutator_handler = Managers.state.game_mode._mutator_handler

        if not mutator_handler:has_activated_mutator("geheimnisnacht_2021") then
            mod:echo("[RITUAL]: Activating %s", Localize("display_name_mutator_geheimnisnacht_2021"))
            mutator_handler:activate_mutator("geheimnisnacht_2021")
        end

        if not mutator_handler:has_activated_mutator("night_mode") then
            mod:echo("[RITUAL]: Activating %s", Localize("display_name_mutator_night_mode"))
            mutator_handler:activate_mutator("night_mode")
        end
    end
end


 