return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Grappling Gun` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Grappling Gun", {
			mod_script       = "scripts/mods/Grappling Gun/Grappling Gun",
			mod_data         = "scripts/mods/Grappling Gun/Grappling Gun_data",
			mod_localization = "scripts/mods/Grappling Gun/Grappling Gun_localization",
		})
	end,
	packages = {
		"resource_packages/Grappling Gun/Grappling Gun",
	},
}
