local mod = get_mod("Special Powder")

mod:hook_safe(ActionShotgun, "_start_shooting", function(self)
    local player_manager = Managers.player
    local local_player = player_manager:local_player()
    local player_unit = local_player.player_unit

    local locomotion_extension = ScriptUnit.has_extension(player_unit,
                                                          "locomotion_system")

    if self.owner_unit == player_unit and
        not locomotion_extension:is_on_ground() then
        local viewport_name = local_player.viewport_name
        local camera_rotation = Managers.state.camera:camera_rotation(
                                    viewport_name)
        local camera_direction = Quaternion.forward(camera_rotation)

        locomotion_extension:add_external_velocity(
            Vector3.normalize(Vector3(-1 * camera_direction.x,
                                      -1 * camera_direction.y,
                                      -1 * camera_direction.z)) *
                                  mod:get("power"))

    end
end)

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
