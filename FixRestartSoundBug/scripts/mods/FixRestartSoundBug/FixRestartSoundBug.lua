local mod = get_mod("FixRestartSoundBug")

mod:command("fixSound", "", function() 
    if string.find(Managers.state.game_mode._level_key, "inn_level") then
        mod:echo("[Sound]: Unable to remove sound bug in keep, must be in mission")
        return
    end
    local local_player = Managers.player:local_player()
    local player_unit = local_player.player_unit
    local first_person_extension = ScriptUnit.has_extension(player_unit, "first_person_system")
    first_person_extension:play_hud_sound_event("sfx_player_in_vortex_false")
end)   
-- Your mod code goes here.
-- https://vmf-docs.verminti.de
