local mod = get_mod("MovableMissionTimerV2")

return {
	name = "Movable Mission Timer",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
                setting_id = "offset_x",
                type = "numeric",
                default_value = 900,
                range = {-960, 960}
            }, {
                setting_id = "offset_y",
                type = "numeric",
                default_value = 430,
                range = {-540, 540}
            }, {
                setting_id = "mission_timer_count_font_size",
                type = "numeric",
                default_value = 32,
                range = {8, 128}
            }, 
        }
    }
}
