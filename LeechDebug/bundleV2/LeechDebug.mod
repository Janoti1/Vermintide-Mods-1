return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`LeechDebug` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("LeechDebug", {
			mod_script       = "scripts/mods/LeechDebug/LeechDebug",
			mod_data         = "scripts/mods/LeechDebug/LeechDebug_data",
			mod_localization = "scripts/mods/LeechDebug/LeechDebug_localization",
		})
	end,
	packages = {
		"resource_packages/LeechDebug/LeechDebug",
	},
}
