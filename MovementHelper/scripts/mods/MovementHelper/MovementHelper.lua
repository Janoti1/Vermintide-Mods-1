local mod = get_mod("MovementHelper")

local fallSet = false

local backupFallDamage
local backupFallHeight 
local backupHardLanding 

function mod:on_game_state_changed() fallSet = false end

mod.on_disabled = function()
    local local_player = Managers.player:local_player()
    local player_unit = local_player.player_unit
    local movement_table =
        PlayerUnitMovementSettings.get_movement_settings_table(player_unit)
    if movement_table then
        movement_table.fall.heights.MAX_FALL_DAMAGE = backupFallDamage
        movement_table.fall.heights.MIN_FALL_DAMAGE_HEIGHT = backupFallHeight
        movement_table.fall.heights.HARD_LANDING_FALL_HEIGHT = backupHardLanding
    end

    mod:echo("[MovementHelper]: Enabled Fall Damage")
    mod:echo("[MovementHelper]: Enabled Ledge Grab") 
end

mod.on_enabled = function() 
    -- mod:echo("[MovementHelper]: Disabled Fall Damage")
    -- mod:echo("[MovementHelper]: Disabled Ledge Grab")
end



mod:hook_safe(IngameHud, "update", function(self)

    if self._currently_visible_components.EquipmentUI and not fallSet then
        fallSet = true
        mod:echo("[MovementHelper]: Disabled Fall Damage")
        mod:echo("[MovementHelper]: Disabled Ledge Grab")
        local local_player = Managers.player:local_player()
        local player_unit = local_player.player_unit
        local movement_table =
            PlayerUnitMovementSettings.get_movement_settings_table(player_unit)
        if movement_table then
            backupFallDamage = movement_table.fall.heights.MAX_FALL_DAMAGE
            backupFallHeight = movement_table.fall.heights.MIN_FALL_DAMAGE_HEIGHT
            backupHardLanding = movement_table.fall.heights.HARD_LANDING_FALL_HEIGHT

            movement_table.fall.heights.MAX_FALL_DAMAGE = 0
            movement_table.fall.heights.MIN_FALL_DAMAGE_HEIGHT = math.huge
            movement_table.fall.heights.HARD_LANDING_FALL_HEIGHT = math.huge
        end
    end

end)

mod:hook(CharacterStateHelper, "is_ledge_hanging",
         function(func, world, unit, ...)

    local local_player = Managers.player:local_player()
    local player_unit = local_player.player_unit
    if unit == player_unit then return false end

    -- Original Function
    local result = func(world, unit, ...)
    return result
end)
-- Your mod c de goes here.
-- https://vmf-docs.verminti.de
