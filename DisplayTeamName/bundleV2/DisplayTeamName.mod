return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`DisplayTeamName` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("DisplayTeamName", {
			mod_script       = "scripts/mods/DisplayTeamName/DisplayTeamName",
			mod_data         = "scripts/mods/DisplayTeamName/DisplayTeamName_data",
			mod_localization = "scripts/mods/DisplayTeamName/DisplayTeamName_localization",
		})
	end,
	packages = {
		"resource_packages/DisplayTeamName/DisplayTeamName",
	},
}
