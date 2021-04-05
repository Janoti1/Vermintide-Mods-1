local mod = get_mod("LeechDebug")

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
  
function mod.update()
    if enabled then
        if Managers.state.debug then
            for _, drawer in pairs(Managers.state.debug._drawers) do
                drawer:update(Managers.state.debug._world)
            end
        end
    end
end

mod:hook_safe(IngameHud, "update", function(self)
    if not self._currently_visible_components.EquipmentUI or Managers.state.game_mode._level_key ==
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

local percept = false
mod:hook(BTCorruptorGrabAction, "grab_player", function(func, self, unit, blackboard)
    mod:echo("hooked") 
    local target_unit = blackboard.corruptor_target
	local self_pos = POSITION_LOOKUP[unit]
	local target_unit_pos = POSITION_LOOKUP[target_unit]
	local projectile_position = blackboard.projectile_position:unbox()
	local projectile_target_position = blackboard.projectile_target_position:unbox()
	local target_status_ext = blackboard.target_unit_status_extension
	local world = blackboard.world
	local physics_world = World.physics_world(world)
	local target_distance_squared = Vector3.distance_squared(projectile_target_position, target_unit_pos)
    QuickDrawerStay:sphere(projectile_target_position, 0.1, Colors.get("cyan"))
    QuickDrawerStay:sphere(target_unit_pos, 0.1, Colors.get("cyan"))
    QuickDrawerStay:line(target_unit_pos, projectile_target_position, Colors.get("cyan"))
	local action = blackboard.action

    mod:echo("%s: %s", "Action", action)

	if (not action.ignore_dodge and blackboard.target_dodged) or target_status_ext:is_invisible() then
        mod:echo("Condition 1")
		local dodge_pos = target_unit_pos
		local dir = Vector3.normalize(Vector3.flat(dodge_pos - self_pos))
		local forward = Quaternion.forward(Unit.local_rotation(unit, 0))
		local dot_value = Vector3.dot(dir, forward)
        local h = Vector3(0,0,1)
        QuickDrawerStay:vector(self_pos + h, dir * Vector3.distance(self_pos, dodge_pos), Colors.get("red"))
        QuickDrawerStay:vector(self_pos + h, forward * Vector3.distance(self_pos, dodge_pos), Colors.get("green"))
		local angle = math.acos(dot_value)
		local distance_squared = Vector3.distance_squared(self_pos, dodge_pos)
        QuickDrawerStay:sphere(self_pos, 0.1, Colors.get("red"))
        QuickDrawerStay:sphere(dodge_pos, 0.1, Colors.get("red"))
        QuickDrawerStay:line(dodge_pos, self_pos, Colors.get("red"))

        mod:echo("%s: %s", "distance_squared", distance_squared)
        mod:echo("%s: %s", "blackboard.action.min_dodge_angle_squared", blackboard.action.min_dodge_angle_squared)
        mod:echo("%s: %s", "angle", math.radians_to_degrees(angle))
        mod:echo("%s: %s", "blackboard.action.dodge_angle", blackboard.action.dodge_angle)
        mod:echo("%s: %s", "target_distance_squared", target_distance_squared)
        mod:echo("%s: %s", "mult", blackboard.action.dodge_distance * blackboard.action.dodge_distance)
        -- mod:echo("Perception")
        -- percept = true
        -- blackboard.attack_success = PerceptionUtils.is_position_in_line_of_sight(unit, self_pos, target_unit_pos, physics_world)

		if (distance_squared < blackboard.action.min_dodge_angle_squared and math.radians_to_degrees(angle) <= blackboard.action.dodge_angle) or target_distance_squared < blackboard.action.dodge_distance * blackboard.action.dodge_distance then
            mod:echo("Perception")
            percept = true
			blackboard.attack_success = PerceptionUtils.is_position_in_line_of_sight(unit, self_pos, target_unit_pos, physics_world)
		else
			QuestSettings.check_corruptor_dodge(target_unit)

			blackboard.attack_success = false
		end
	elseif (not not action.ignore_dodge and blackboard.action.max_distance_squared < Vector3.distance_squared(self_pos, target_unit_pos)) or target_distance_squared > 25 then
        mod:echo("Condition 2")
		blackboard.attack_success = false
	else
        mod:echo("Condition 3")
		blackboard.attack_success = PerceptionUtils.is_position_in_line_of_sight(unit, self_pos + Vector3.up(), target_unit_pos + Vector3.up(), physics_world)
	end

	if blackboard.attack_success then
		local first_person_extension = ScriptUnit.has_extension(blackboard.corruptor_target, "first_person_system")

		if blackboard.attack_success and first_person_extension then
			first_person_extension:animation_event("shake_get_hit")
		end

		blackboard.grabbed_unit = blackboard.corruptor_target
		slot14 = blackboard.action.grabbed_sound_event_2d
	else
		blackboard.attack_aborted = true
	end
end)



mod:hook(PerceptionUtils, "is_position_in_line_of_sight", function (func, unit, from_position, target_position, physics_world, collision_filter)
    if percept then 
        mod:echo("sight")
        collision_filter = collision_filter or "filter_ai_line_of_sight_check"
        local to_target = target_position - from_position
        local direction = Vector3.normalize(to_target)
        local distance = Vector3.length(to_target)

        if Vector3.length(direction) <= 0 then
            return false
        end

        QuickDrawerStay:sphere(from_position, .1, Colors.get("yellow"))
        QuickDrawerStay:sphere(target_position, .1, Colors.get("cyan"))
        QuickDrawerStay:vector(from_position, direction * distance, Colors.get("yellow"))

        local result, hit_position, hit_distance, normal, actor = PhysicsWorld.immediate_raycast(physics_world, from_position, direction, distance, "closest", "collision_filter", collision_filter)
        local no_hit = not result
        mod:echo(no_hit)
        -- if no_hit then
        --     QuickDrawerStay:sphere(hit_position, .1, Colors.get("yellow"))
        --     QuickDrawerStay:line(from_position, hit_position, Colors.get("yellow"))

        -- else
        --     mod:echo("no hit")
        -- end
        percept = false
        return no_hit, hit_position
    else 
        return func(unit, from_position, target_position, physics_world, collision_filter)
    end
end) 

mod:command("clearDraw", "", function()
    QuickDrawer:reset()
    QuickDrawerStay:reset()
end)
-- Your mod code goes here.
-- https://vmf-docs.verminti.de
