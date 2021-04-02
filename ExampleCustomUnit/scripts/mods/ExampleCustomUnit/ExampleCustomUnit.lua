local mod = get_mod("ExampleCustomUnit")

local unit_path = "units/Cube"

local function spawn_package_to_player (package_name)
  local player = Managers.player:local_player()
  local world = Managers.world:world("level_world")

  if world and player and player.player_unit then
    local player_unit = player.player_unit

    local position = Unit.local_position(player_unit, 0) + Vector3(0, 0, 1)
    local rotation = Unit.local_rotation(player_unit, 0)
    local unit = World.spawn_unit(world, package_name, position, rotation)

    return unit
  end

  return nil
end

mod:command("testModel", "", function() 
    spawn_package_to_player(unit_path)
end)
-- Your mod code goes here.
-- https://vmf-docs.verminti.de
