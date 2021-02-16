return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`LevelDebug` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("LevelDebug", {
			mod_script       = "scripts/mods/LevelDebug/LevelDebug",
			mod_data         = "scripts/mods/LevelDebug/LevelDebug_data",
			mod_localization = "scripts/mods/LevelDebug/LevelDebug_localization",
		})
	end,
	packages = {
		"resource_packages/LevelDebug/LevelDebug",
	},
}
