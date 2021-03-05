local mod = get_mod("ItemSpawnerVT1")

return {
	name = "ItemSpawnerVT1",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {         
            {
                setting_id      = "spawn_item",
                type            = "keybind",
                default_value   = { --[[...]] },
                keybind_global  = true,       -- optional
                keybind_trigger = "pressed",
                keybind_type    = "function_call",
                function_name   = "spawn_item",   -- required, if (keybind_type == "function_call")
                
              },
			  {
                setting_id      = "next_item",
                type            = "keybind",
                default_value   = { --[[...]] },
                keybind_global  = true,       -- optional
                keybind_trigger = "pressed",
                keybind_type    = "function_call",
                function_name   = "next_item",   -- required, if (keybind_type == "function_call")
                
              },
			  {
                setting_id = "unsafe_items",
                type = "checkbox",
                default_value = false
			}
        }
    }
}
