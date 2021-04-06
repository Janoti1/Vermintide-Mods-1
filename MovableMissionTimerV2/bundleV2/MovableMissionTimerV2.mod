return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MovableMissionTimerV2` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("MovableMissionTimerV2", {
			mod_script       = "scripts/mods/MovableMissionTimerV2/MovableMissionTimerV2",
			mod_data         = "scripts/mods/MovableMissionTimerV2/MovableMissionTimerV2_data",
			mod_localization = "scripts/mods/MovableMissionTimerV2/MovableMissionTimerV2_localization",
		})
	end,
	packages = {
		"resource_packages/MovableMissionTimerV2/MovableMissionTimerV2",
	},
}
