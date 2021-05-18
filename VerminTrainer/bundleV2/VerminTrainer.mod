return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`VerminTrainer` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("VerminTrainer", {
			mod_script       = "scripts/mods/VerminTrainer/VerminTrainer",
			mod_data         = "scripts/mods/VerminTrainer/VerminTrainer_data",
			mod_localization = "scripts/mods/VerminTrainer/VerminTrainer_localization",
		})
	end,
	packages = {
		"resource_packages/VerminTrainer/VerminTrainer",
	},
}
