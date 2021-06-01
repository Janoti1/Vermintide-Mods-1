return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Shade Adjust` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Shade Adjust", {
			mod_script       = "scripts/mods/Shade Adjust/Shade Adjust",
			mod_data         = "scripts/mods/Shade Adjust/Shade Adjust_data",
			mod_localization = "scripts/mods/Shade Adjust/Shade Adjust_localization",
		})
	end,
	packages = {
		"resource_packages/Shade Adjust/Shade Adjust",
	},
}
