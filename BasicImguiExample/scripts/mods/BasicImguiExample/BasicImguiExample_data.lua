local mod = get_mod("BasicImguiExample")

return {
	name = "BasicImguiExample",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				keybind_global = true,
				keybind_trigger = "pressed",
				setting_id = "open_imgui",
				type = "keybind",
				keybind_type = "function_call",
				function_name = "open_imgui",
				default_value = {}
			},
		}
	}
}
