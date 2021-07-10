return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`NoZoom` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("NoZoom", {
			mod_script       = "scripts/mods/NoZoom/NoZoom",
			mod_data         = "scripts/mods/NoZoom/NoZoom_data",
			mod_localization = "scripts/mods/NoZoom/NoZoom_localization",
		})
	end,
	packages = {
		"resource_packages/NoZoom/NoZoom",
	},
}
