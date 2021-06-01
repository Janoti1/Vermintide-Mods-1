local mod = get_mod("Shade Adjust")

return {
	name = "Shade Adjust",
	is_togglable = true,
	description = mod.localize(mod, "mod_description"),
	options = {
		widgets = {
			{
				decimals_number = 2,
				setting_id = "invis_duration",
				type = "numeric",
				default_value = 5,
				range = {
					1,
					10
				}
			},
			{
				decimals_number = 2,
				setting_id = "crit_duration",
				type = "numeric",
				default_value = 4,
				range = {
					1,
					10
				}
			},
			{
				decimals_number = 2,
				setting_id = "cdr",
				type = "numeric",
				default_value = -0.45,
				range = {
					-1,
					0
				}
			},
			{
				decimals_number = 2,
				setting_id = "base_cooldown",
				type = "numeric",
				default_value = 60,
				range = {
					1,
					300
				}
			} 
			
		}
	}
} 
