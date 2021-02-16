local mod = get_mod("MovementDebug")

return {
	name = "MovementDebug",
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
            },
            {
                setting_id = "show_dodge",
                type = "checkbox",
                default_value = false
            },
             {
                setting_id = "current_speed_count_font_size",
                type = "numeric",
                default_value = 32,
                range = {8, 128}
            }, 
        }
    }
}
