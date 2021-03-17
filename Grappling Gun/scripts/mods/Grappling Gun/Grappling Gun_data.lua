local mod = get_mod("Grappling Gun")

return {
	name = "Grappling Gun",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
              {
                setting_id = "grapple-dist",
                type = "numeric",
                default_value = 20,
                range = {1,100}
            }
        }
    }
}
