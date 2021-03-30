return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`SaltsGlaive` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("SaltsGlaive", {
			mod_script       = "scripts/mods/SaltsGlaive/SaltsGlaive",
			mod_data         = "scripts/mods/SaltsGlaive/SaltsGlaive_data",
			mod_localization = "scripts/mods/SaltsGlaive/SaltsGlaive_localization",
		})
	end,
	packages = {
		"resource_packages/SaltsGlaive/SaltsGlaive",
	},
}
