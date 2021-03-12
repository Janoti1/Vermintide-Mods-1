return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Special Powder` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Special Powder", {
			mod_script       = "scripts/mods/Special Powder/Special Powder",
			mod_data         = "scripts/mods/Special Powder/Special Powder_data",
			mod_localization = "scripts/mods/Special Powder/Special Powder_localization",
		})
	end,
	packages = {
		"resource_packages/Special Powder/Special Powder",
	},
}
