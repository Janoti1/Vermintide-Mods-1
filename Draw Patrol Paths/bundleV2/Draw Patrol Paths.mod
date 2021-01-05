return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Draw Patrol Paths` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Draw Patrol Paths", {
			mod_script       = "scripts/mods/Draw Patrol Paths/Draw Patrol Paths",
			mod_data         = "scripts/mods/Draw Patrol Paths/Draw Patrol Paths_data",
			mod_localization = "scripts/mods/Draw Patrol Paths/Draw Patrol Paths_localization",
		})
	end,
	packages = {
		"resource_packages/Draw Patrol Paths/Draw Patrol Paths",
	},
}
