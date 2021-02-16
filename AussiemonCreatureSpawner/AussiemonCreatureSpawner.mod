return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`AussiemonCreatureSpawner` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("AussiemonCreatureSpawner", {
			mod_script       = "scripts/mods/AussiemonCreatureSpawner/AussiemonCreatureSpawner",
			mod_data         = "scripts/mods/AussiemonCreatureSpawner/AussiemonCreatureSpawner_data",
			mod_localization = "scripts/mods/AussiemonCreatureSpawner/AussiemonCreatureSpawner_localization",
		})
	end,
	packages = {
		"resource_packages/AussiemonCreatureSpawner/AussiemonCreatureSpawner",
	},
}
