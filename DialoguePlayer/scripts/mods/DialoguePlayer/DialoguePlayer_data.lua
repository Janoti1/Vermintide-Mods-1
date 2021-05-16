local mod = get_mod("DialoguePlayer")

return {
	name = "DialoguePlayer",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
				keybind_global = true,
				keybind_trigger = "pressed",
				setting_id = "next_dialogue",
				type = "keybind",
				keybind_type = "function_call",
				function_name = "next",
				default_value = {}
			},
			{
				keybind_global = true,
				keybind_trigger = "pressed",
				setting_id = "previous_dialogue",
				type = "keybind",
				keybind_type = "function_call",
				function_name = "prev",
				default_value = {}
			},
			{
				keybind_global = true,
				keybind_trigger = "pressed",
				setting_id = "play_dialogue",
				type = "keybind",
				keybind_type = "function_call",
				function_name = "play_dialogue",
				default_value = {}
			}
        }
    }
}
