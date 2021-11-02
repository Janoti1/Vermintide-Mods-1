return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`grudgeBosses` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("grudgeBosses", {
			mod_script       = "scripts/mods/grudgeBosses/grudgeBosses",
			mod_data         = "scripts/mods/grudgeBosses/grudgeBosses_data",
			mod_localization = "scripts/mods/grudgeBosses/grudgeBosses_localization",
		})
	end,
	packages = {
		"resource_packages/grudgeBosses/grudgeBosses",
	},
}
