return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`FixRestartSoundBug` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("FixRestartSoundBug", {
			mod_script       = "scripts/mods/FixRestartSoundBug/FixRestartSoundBug",
			mod_data         = "scripts/mods/FixRestartSoundBug/FixRestartSoundBug_data",
			mod_localization = "scripts/mods/FixRestartSoundBug/FixRestartSoundBug_localization",
		})
	end,
	packages = {
		"resource_packages/FixRestartSoundBug/FixRestartSoundBug",
	},
}
