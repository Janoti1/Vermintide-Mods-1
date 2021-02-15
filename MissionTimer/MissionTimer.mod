return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MissionTimer` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("MissionTimer", {
			mod_script       = "scripts/mods/MissionTimer/MissionTimer",
			mod_data         = "scripts/mods/MissionTimer/MissionTimer_data",
			mod_localization = "scripts/mods/MissionTimer/MissionTimer_localization",
		})
	end,
	packages = {
		"resource_packages/MissionTimer/MissionTimer",
	},
}
