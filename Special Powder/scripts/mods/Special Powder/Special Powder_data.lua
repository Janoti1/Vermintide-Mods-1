local mod = get_mod("Special Powder")

return {
	name = "Special Powder",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
                setting_id = "power",
                type = "numeric",
                default_value = 25,
                range = {1, 500},
				decimals_number = 0
			},
			
        }
    }
}
