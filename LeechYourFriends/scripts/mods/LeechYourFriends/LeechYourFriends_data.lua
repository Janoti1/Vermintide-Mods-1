local mod = get_mod("LeechYourFriends")

return {
	name = "LeechYourFriends",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
                setting_id      = "grab",
                type            = "keybind",
                default_value   = { --[[...]] },
                keybind_global  = true,       -- optional
                keybind_trigger = "pressed",
                keybind_type    = "function_call",
                function_name   = "grab",   -- required, if (keybind_type == "function_call")
                
              },
			  {
                setting_id      = "reverse",
                type            = "keybind",
                default_value   = { --[[...]] },
                keybind_global  = true,       -- optional
                keybind_trigger = "pressed",
                keybind_type    = "function_call",
                function_name   = "reverse",   -- required, if (keybind_type == "function_call")
                
              }
        }
    }
}
