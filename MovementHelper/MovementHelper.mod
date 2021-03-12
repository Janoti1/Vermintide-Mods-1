return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MovementHelper` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("MovementHelper", {
			mod_script       = "scripts/mods/MovementHelper/MovementHelper",
			mod_data         = "scripts/mods/MovementHelper/MovementHelper_data",
			mod_localization = "scripts/mods/MovementHelper/MovementHelper_localization",
		})
	end,
	packages = {
		"resource_packages/MovementHelper/MovementHelper",
	},
}
