local mod = get_mod("EventPracticeV2")

return {
	name = "EventPracticeV2",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
			{
                setting_id = "composition",
                type = "checkbox",
                default_value = false
            },
			{
                setting_id = "pacing",
                type = "checkbox",
                default_value = false
            },
            {
                setting_id = "intensity",
                type = "checkbox",
                default_value = false
            },
        }
    }
}
