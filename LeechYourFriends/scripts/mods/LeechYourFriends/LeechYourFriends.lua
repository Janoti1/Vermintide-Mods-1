local mod = get_mod("LeechYourFriends")

local grabbed = {}
local reverse = {}

function mod:on_game_state_changed()
    grabbed = {}
end

function isGrabbed(unit)
    for ndx, units in pairs(grabbed) do
        if unit == units then 
            return ndx;
        end
    end

end

function mod.grab() 
    mod.findAlly("normal")
end

function mod.reverse() 
    mod.findAlly("reverse")
end

function mod.findAlly(findType)
    local local_player = Managers.player:local_player()
    local player_unit = local_player.player_unit
    
    local viewport_name = local_player.viewport_name
    local camera_position = Managers.state.camera:camera_position(viewport_name)
    local camera_rotation = Managers.state.camera:camera_rotation(viewport_name)
    local camera_direction = Quaternion.forward(camera_rotation)
    local range = 500

    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")

    -- Get what you are looking at
    local result =
        PhysicsWorld.immediate_raycast(physics_world, camera_position,
                                       camera_direction, range, "all",
                                       "collision_filter",
                                       "filter_player_hit_box_and_static_check")

    if result then
        -- Find the first collision that is a player and is not the casting player
        for i = 1, #result, 1 do
            local hit = result[i]
            local hit = result[i]
            local hit_actor = hit[4]
            local hit_unit = Actor.unit(hit_actor)
            if hit_unit ~= player_unit then
                local unit_breed = AiUtils.unit_breed(hit_unit)
                if unit_breed and type(unit_breed) == "table" then
                    if unit_breed["is_hero"] then 
                        if findType == "reverse" then
                            StatusUtils.set_grabbed_by_corruptor_network("chaos_corruptor_grabbed", player_unit, true, hit_unit)
                            table.insert(reverse, hit_unit)
                            return
                        elseif findType == "normal" then
                            if not isGrabbed(hit_unit) then 
                                StatusUtils.set_grabbed_by_corruptor_network("chaos_corruptor_grabbed", hit_unit, true, player_unit)
                                table.insert(grabbed, hit_unit)
                                return
                            end
                        end 
                    end
                end

            end
            
        end

    end
end


mod:command("leechFree", "", function() 
    local local_player = Managers.player:local_player()
    local player_unit = local_player.player_unit

    for ndx, units in pairs(grabbed) do
        StatusUtils.set_grabbed_by_corruptor_network("chaos_corruptor_released",units, false, player_unit)
    end

    for ndx, units in pairs(reverse) do
        StatusUtils.set_grabbed_by_corruptor_network("chaos_corruptor_released",player_unit, false, units)
    end

    grabbed = {}
    reverse = {}
end)

mod:command("leechSelf", "", function()
    local local_player = Managers.player:local_player()
    local player_unit = local_player.player_unit
    StatusUtils.set_grabbed_by_corruptor_network("chaos_corruptor_grabbed", player_unit, true, player_unit)
    table.insert( grabbed, player_unit)
end) 

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
