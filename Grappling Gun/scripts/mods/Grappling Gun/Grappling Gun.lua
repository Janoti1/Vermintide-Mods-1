local mod = get_mod("Grappling Gun")
local attached = false
local attachedPostion = nil
local attachedNorm = nil
local backupGravity = nil
local backupAccel = nil

SPProfiles[3]["careers"][1]["activated_ability"][1]["cooldown"] = 4
   

mod:hook(ActionCareerDRRanger, "_throw", function(func, self) 
    -- self:_play_vo()
    return
end)

mod:hook(WeaponUnitExtension, "start_action", function(func, self, action_name, sub_action_name, actions, t, power_level, action_init_data)
    local local_player = Managers.player:local_player()
    local player_unit = local_player.player_unit
    local locomotion_extension =
                    ScriptUnit.has_extension(player_unit,
                                                "locomotion_system")
    if locomotion_extension:is_on_ground() and action_name == "action_career_dr_3" then return end

    if action_name == "action_career_dr_3" then 
        if not mod.grapple()then return end
    elseif "action_career_release" == action_name  and attached then
        
        attachedPostion = nil

        local local_player = Managers.player:local_player()
        local player_unit = local_player.player_unit
        -- local movement_table =
        --     PlayerUnitMovementSettings.get_movement_settings_table(player_unit)
        -- if movement_table then
        --     movement_table.gravity_acceleration = backupGravity
        --     movement_table.move_acceleration_down = backupAccel
            
        -- end
        
        attached = not attached

        local status_extension = ScriptUnit.extension(player_unit,
                                                      "status_system")
        status_extension:set_noclip(false)
    elseif "action_two" == action_name and attached then return end

    func(self, action_name, sub_action_name, actions, t, power_level, action_init_data)
end)

function mod.grapple() 
    local local_player = Managers.player:local_player()
    local player_unit = local_player.player_unit
    local locomotion_extension =
                    ScriptUnit.has_extension(player_unit,
                                                "locomotion_system")
    local viewport_name = local_player.viewport_name
    local camera_position = Managers.state.camera:camera_position(
                                viewport_name)
    local camera_rotation = Managers.state.camera:camera_rotation(
                                viewport_name)
    local camera_direction = Quaternion.forward(camera_rotation)
    local range = 500

    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    local result = PhysicsWorld.immediate_raycast(physics_world,
                                                    camera_position,
                                                    camera_direction, range,
                                                    "all", "collision_filter",
                                                    "filter_ray_projectile")

    if result then
        -- Find the first collision that is a player and is not the casting player
        for i = 1, #result, 1 do
            local hit = result[i]
            local hit = result[i]
            local hit_actor = hit[4]
            local hit_unit = Actor.unit(hit_actor)
            local hit_pos = hit[1]
            local hit_norm = hit[3]
            local hit_dist = hit[2]
            local unit_breed = AiUtils.unit_breed(hit_unit)
            -- mod:echo(hit_dist)
            -- mod:echo(hit_unit)
            -- mod:echo(hit_unit ~= player_unit)
            if hit_unit ~= player_unit and unit_breed == nil and hit_dist <= mod:get("grapple-dist") then
                
                attachedPostion = Vector3Box(hit_pos)
                attachedNorm = Vector3Box(hit_norm)

                local player_pos = Unit.local_position(player_unit, 0)
                local vect = hit_pos - player_pos

                -- local movement_table =
                --     PlayerUnitMovementSettings.get_movement_settings_table(
                --         player_unit)
                -- if movement_table then
                --     backupGravity = movement_table.gravity_acceleration
                --     backupAccel = movement_table.move_acceleration_down
                --     movement_table.move_acceleration_down = 0
                --     movement_table.gravity_acceleration = 0
                -- end 

                local locomotion_extension =
                    ScriptUnit.has_extension(player_unit,
                                                "locomotion_system")
                -- locomotion_extension:add_external_velocity(vect * 5)

                -- locomotion_extension:teleport_to(player_pos + Vector3(0,0,.3))
                locomotion_extension:set_forced_velocity(Vector3.normalize(vect))

                
                savedVect = Vector3Box(Vector3.normalize(vect))
                attached = not attached
                local status_extension = ScriptUnit.extension(player_unit,
                                                      "status_system")
                status_extension:set_noclip(true)
                return true
            end
        end
    end
    return false
end

function mod.update()
    if attached then
        local drawer = Managers.state.debug:drawer({
            mode = "immediate",
            name = "DwarfGrapple"
        })
        
        local local_player = Managers.player:local_player()
        local player_unit = local_player.player_unit
        local player_pos = Unit.local_position(player_unit, 0)
        local locomotion_extension = ScriptUnit.has_extension(player_unit,
                                                              "locomotion_system")

        local grappledPosition =  attachedPostion:unbox()    
        local grappleNorm = attachedNorm:unbox() 
        drawer:circle(grappledPosition, 0.1, grappleNorm, Colors.get("red"))   
        -- drawer:line(player_pos,grappledPosition, Colors.get("red"))                                            

        local vect = grappledPosition - player_pos
        
        locomotion_extension:set_forced_velocity(Vector3.normalize(vect) * 10)


    end
    -- mod:echo("update")
end

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
