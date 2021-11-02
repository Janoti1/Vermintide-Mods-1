return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ritual` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ritual", {
			mod_script       = "scripts/mods/ritual/ritual",
			mod_data         = "scripts/mods/ritual/ritual_data",
			mod_localization = "scripts/mods/ritual/ritual_localization",
		})
	end,
	packages = {
		"resource_packages/ritual/ritual",
	},
}
