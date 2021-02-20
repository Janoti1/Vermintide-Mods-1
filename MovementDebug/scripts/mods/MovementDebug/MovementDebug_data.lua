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
                range = {0, 2560}
            }, {
                setting_id = "offset_y",
                type = "numeric",
                default_value = 430,
                range = {0, 1440}
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
			{
                setting_id = "frames",
                type = "numeric",
                default_value = 720,
				range = {1, 4320},
				decimals_number = 2
            },
            {
                setting_id      = "get_dist",
                type            = "keybind",
                default_value   = { --[[...]] },
                keybind_global  = true,       -- optional
                keybind_trigger = "pressed",
                keybind_type    = "function_call",
                function_name   = "distToLookingAt",   -- required, if (keybind_type == "function_call")
                
              }

        }
    }
}
