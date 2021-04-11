local mod = get_mod("TeleportV2")

return {
	name = "TeleportV2",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				keybind_global = true,
				keybind_trigger = "pressed",
				setting_id = "teleport",
				type = "keybind",
				keybind_type = "function_call",
				function_name = "getTeleport",
				default_value = {}
			}
		}
	}
} 
