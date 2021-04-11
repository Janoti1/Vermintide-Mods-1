return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TeleportV2` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("TeleportV2", {
			mod_script       = "scripts/mods/TeleportV2/TeleportV2",
			mod_data         = "scripts/mods/TeleportV2/TeleportV2_data",
			mod_localization = "scripts/mods/TeleportV2/TeleportV2_localization",
		})
	end,
	packages = {
		"resource_packages/TeleportV2/TeleportV2",
	},
}
