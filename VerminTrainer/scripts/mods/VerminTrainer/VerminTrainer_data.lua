local mod = get_mod("VerminTrainer")

return {
	name = "VerminTrainer",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
				keybind_global = true,
				keybind_trigger = "pressed",
				setting_id = "next_composition",
				type = "keybind",
				keybind_type = "function_call",
				function_name = "next_composition",
				default_value = {}
			},
			{
				keybind_global = true,
				keybind_trigger = "pressed",
				setting_id = "previous_composition",
				type = "keybind",
				keybind_type = "function_call",
				function_name = "prev_composition",
				default_value = {}
			},
			{
				keybind_global = true,
				keybind_trigger = "pressed",
				setting_id = "spawn_composition",
				type = "keybind",
				keybind_type = "function_call",
				function_name = "spawn_composition",
				default_value = {}
			}
        }
    }
}
