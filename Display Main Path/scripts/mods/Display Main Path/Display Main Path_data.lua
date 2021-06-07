local mod = get_mod("Display Main Path")

return {
	name = "Level Debug",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
                setting_id = "main_path",
                type = "checkbox",
                default_value = true
			},
			{
                setting_id = "player_pos",
                type = "checkbox",
                default_value = false
            },
			{
                setting_id = "boss",
                type = "checkbox",
                default_value = false
            },{
                setting_id = "patrol",
                type = "checkbox",
                default_value = false
            },{
                setting_id = "respawn",
                type = "checkbox",
                default_value = false
            },
            {
                setting_id = "boss_walls",
                type = "checkbox",
                default_value = false
            },
            {
                setting_id = "patrol_routes",
                type = "checkbox",
                default_value = false
            },
            {
                setting_id = "item_spawners",
                type = "checkbox",
                default_value = false
            },
            {
                setting_id = "item_text_mult",
                type = "numeric",
                default_value = 0.1,
                range = {0.01, 1},
				decimals_number = 2
			},
            {
                setting_id = "text_distance",
                type = "numeric",
                default_value = 20,
                range = {1, 1000},
				decimals_number = 0
			},
            {
                setting_id = "debug_spawners",
                type = "checkbox",
                default_value = false
            },
            {
				keybind_global = true,
				keybind_trigger = "pressed",
				setting_id = "check_collision",
				type = "keybind",
				keybind_type = "function_call",
				function_name = "checkCollision",
				default_value = {}
			},
            {
                setting_id = "nav_mesh",
                type = "checkbox",
                default_value = false
            }
        }
    }
} 
