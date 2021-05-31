return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`SeedTesting` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("SeedTesting", {
			mod_script       = "scripts/mods/SeedTesting/SeedTesting",
			mod_data         = "scripts/mods/SeedTesting/SeedTesting_data",
			mod_localization = "scripts/mods/SeedTesting/SeedTesting_localization",
		})
	end,
	packages = {
		"resource_packages/SeedTesting/SeedTesting",
	},
}
