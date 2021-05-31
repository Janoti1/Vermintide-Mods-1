local mod = get_mod("SeedTesting")

return {
	name = "SeedTesting",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
                setting_id = "item_seed_override",
                type = "checkbox",
                default_value = false
            },
        }
    }
}
