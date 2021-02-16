return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MovementDebug` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("MovementDebug", {
			mod_script       = "scripts/mods/MovementDebug/MovementDebug",
			mod_data         = "scripts/mods/MovementDebug/MovementDebug_data",
			mod_localization = "scripts/mods/MovementDebug/MovementDebug_localization",
		})
	end,
	packages = {
		"resource_packages/MovementDebug/MovementDebug",
	},
}
