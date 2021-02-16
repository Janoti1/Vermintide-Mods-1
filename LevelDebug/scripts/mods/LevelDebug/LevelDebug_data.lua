local mod = get_mod("LevelDebug")

return {
	name = "LevelDebug",
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
                setting_id = "where",
                type = "checkbox",
                default_value = false
            },
            {
                setting_id = "named_spawners",
                type = "checkbox",
                default_value = false
            }
        }
    }
}
