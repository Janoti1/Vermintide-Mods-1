local mod = get_mod("AussiemonCreatureSpawner")

mod.SETTING_NAMES = {
	HOTKEY = "hotkey",
}

local mod_data = {
	name = "AussiemonCreatureSpawner",
	description = mod:localize("mod_description"),
}
mod_data.options_widgets = {
	{
		["setting_name"] = "spawn",
		["widget_type"] = "keybind",
		["text"] = "Spawn Enemy",
		-- ["tooltip"] = mod:localize("hotkey_tooltip"),
		["default_value"] = {},
		["action"] = "do_spawn"
	},
	{
		["setting_name"] = "next",
		["widget_type"] = "keybind",
		["text"] = "Next Enemy",
		-- ["tooltip"] = mod:localize("hotkey_tooltip"),
		["default_value"] = {},
		["action"] = "do_next"
	},
	{
		["setting_name"] = "kill",
		["widget_type"] = "keybind",
		["text"] = "Kill Enemies",
		-- ["tooltip"] = mod:localize("hotkey_tooltip"),
		["default_value"] = {},
		["action"] = "do_kill"
	},
}

return mod_data

