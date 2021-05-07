return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`EventPracticeV2` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("EventPracticeV2", {
			mod_script       = "scripts/mods/EventPracticeV2/EventPracticeV2",
			mod_data         = "scripts/mods/EventPracticeV2/EventPracticeV2_data",
			mod_localization = "scripts/mods/EventPracticeV2/EventPracticeV2_localization",
		})
	end,
	packages = {
		"resource_packages/EventPracticeV2/EventPracticeV2",
	},
}
