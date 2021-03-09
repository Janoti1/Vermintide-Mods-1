local mod = get_mod("ConflagVortex")
local saveBreed = {}
local savePos = {}
local saveOptions = {}
local savedConflagPos = Vector3(0,0,0)
local x = 0
local y = 0
local z = 0
local positionBox

local ACTIONS = BreedActions.chaos_vortex
BreedBehaviors.chaos_vortex = {
	"BTSelector",
	{
		"BTVortexSpawnAction",
		condition = "spawn",
		name = "spawn"
	},
	name = "chaos_vortex"
}

VortexTemplates["standard"]["full_fx_radius"] = 1
VortexTemplates["standard"]["full_outer_radius"] = 1
VortexTemplates["standard"]["min_fx_radius"] = 1
VortexTemplates["standard"]["full_inner_radius"] = 1
VortexTemplates["standard"]["time_of_life"][1] = 4
VortexTemplates["standard"]["time_of_life"][2] = 5
mod:command("vortex", "", function() 
    -- mod:dump(VortexTemplates, "", 4)
    local player_manager = Managers.player
    local local_player = player_manager:local_player()
    local player_unit = local_player and local_player.player_unit
    local current_position = Unit.local_position(player_unit, 0)

	saveBreed["behavior"] = "wiz_vortex"

    

    local vortex_queue_id = Managers.state.conflict:spawn_queued_unit(saveBreed, Vector3Box(current_position), QuaternionBox(Quaternion.identity()), "vortex", nil, nil, saveOptions)
    -- Managers.state.entity:system("surrounding_aware_system"):add_system_event(player_unit, "enemy_attack", DialogueSettings.see_vortex_distance, "attack_tag", "chaos_vortex_spawned")
    -- Managers.state.entity:system("surrounding_aware_system"):add_system_event(vortex_unit, "enemy_attack", DialogueSettings.see_vortex_distance, "attack_tag", "chaos_vortex_spawned")

    -- Managers.state.entity:system("ai_bot_group_system"):ranged_attack_started(player_unit, player_unit, "chaos_vortex")

    -- Managers.state.unit_spawner:spawn_network_unit("units/decals/decal_vortex_circle_inner", "network_synched_dummy_unit", nil, current_position)
end)   

mod:hook_safe(BTChaosSorcererSummoningAction, "_spawn_vortex", function(self, unit, blackboard, t, dt, target_position, vortex_data)
    vortex_data = vortex_data or blackboard.vortex_data
	local action = blackboard.action
	local vortex_pos = vortex_data.vortex_spawn_pos:unbox()
	local vortex_template_name = blackboard.breed.vortex_template_name or action.vortex_template_name
	local vortex_template = VortexTemplates[vortex_template_name]
	local breed_name = vortex_template.breed_name
	local breed = Breeds[breed_name]
	local vortex_units = vortex_data.vortex_units
	local queued_vortex = vortex_data.queued_vortex
	local spawn_category = "vortex"
	local link_decal_units = action.link_decal_units_to_vortex
	local inner_decal_unit = vortex_data.inner_decal_unit
	local outer_decal_unit = vortex_data.outer_decal_unit
    local optional_data = {
		prepare_func = function (breed, extension_init_data)
			extension_init_data.ai_supplementary_system = {
				vortex_template_name = vortex_template_name or "standard",
				inner_decal_unit = link_decal_units and inner_decal_unit,
				outer_decal_unit = link_decal_units and outer_decal_unit,
				owner_unit = unit
			}
		end,
		spawned_func = function (vortex_unit, breed, optional_data)
			local spawn_queue_index = optional_data.spawn_queue_index
			queued_vortex[spawn_queue_index] = nil
			vortex_units[#vortex_units + 1] = vortex_unit
			local vortex_blackboard = BLACKBOARDS[vortex_unit]
			vortex_blackboard.master_unit = unit

			Managers.state.entity:system("surrounding_aware_system"):add_system_event(vortex_unit, "enemy_attack", DialogueSettings.see_vortex_distance, "attack_tag", "chaos_vortex_spawned")
		end
	}
	
    -- mod:echo("vortex")
	-- mod:echo(vortex_template_name)
	-- mod:echo(breed_name)
    -- mod:echo(breed)
    -- mod:dump(breed, "", 2)
    saveBreed = breed
    savePos = vortex_pos
    saveOptions = optional_data
end) 

mod:hook_safe(ActionGeiserTargeting, "finish", function(self, reason, data) 
	if data == nil then return end 
	mod:echo(positionBox)
	-- mod:echo(savedConflagPos)
	-- local vector = Vector3(savedConflagPos[1], savedConflagPos[2], savedConflagPos[3])
	-- mod:echo(savedConflagPos[1])
	Managers.state.conflict:spawn_queued_unit(saveBreed, positionBox, QuaternionBox(Quaternion.identity()), "vortex", nil, nil, saveOptions)
	-- mod:echo("conflag")
	-- mod:dump(data, "", 5)
end)

local function ballistic_raycast(physics_world, max_steps, max_time, position, velocity, gravity, collision_filter, visualize)
	local time_step = max_time / max_steps

	for i = 1, max_steps, 1 do
		local new_position = position + velocity * time_step
		local delta = new_position - position
		local direction = Vector3.normalize(delta)
		local distance = Vector3.length(delta)
		local result, hit_position, hit_distance, normal, actor = PhysicsWorld.immediate_raycast(physics_world, position, direction, distance, "closest", "collision_filter", collision_filter)

		if hit_position then
			return result, hit_position, hit_distance, normal, actor
		end

		velocity = velocity + gravity * time_step
		position = new_position
	end

	return false, position
end
mod:hook_safe(ActionGeiserTargeting, "client_owner_post_update", function(self, dt, t, world, can_damage) 
	local time_to_shoot = self.time_to_shoot
	local current_action = self.current_action

	if current_action.overcharge_interval then
		self.overcharge_timer = self.overcharge_timer + dt

		if current_action.overcharge_interval <= self.overcharge_timer then
			if self.overcharge_extension then
				local overcharge_amount = PlayerUnitStatusSettings.overcharge_values[current_action.overcharge_type]

				self.overcharge_extension:add_charge(overcharge_amount)
			end

			self.overcharge_timer = 0
		end
	end

	local player_position = POSITION_LOOKUP[self.owner_unit]
	local first_person_position = POSITION_LOOKUP[self.first_person_unit]
	local first_person_rotation = Unit.world_rotation(self.first_person_unit, 0)

	if self.fire_at_gaze_offset then
		first_person_rotation = Quaternion.multiply(first_person_rotation, QuaternionBox.unbox(self.fire_at_gaze_offset))
	end

	local position = nil
	local physics_world = World.get_data(world, "physics_world")
	local max_steps = 10
	local max_time = 1.5
	local speed = self.speed
	local angle = self.angle
	local velocity = Quaternion.forward(Quaternion.multiply(first_person_rotation, Quaternion(Vector3.right(), angle))) * speed
	local gravity = Vector3(0, 0, self.gravity)
	local collision_filter = "filter_geiser_check"
	local result, hit_position, _, normal = ballistic_raycast(physics_world, max_steps, max_time, first_person_position, velocity, gravity, collision_filter, self.debug_draw)
	position = hit_position
	positionBox = Vector3Box(position)
	-- mod:echo(position)
	-- Managers.state.conflict:spawn_queued_unit(saveBreed, Vector3Box(position), QuaternionBox(Quaternion.identity()), "vortex", nil, nil, saveOptions)

	savedConflagPos = position
	x = position[1]
	y = position[1]
	z = position[1]

	-- mod:echo(x)
end) 

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
