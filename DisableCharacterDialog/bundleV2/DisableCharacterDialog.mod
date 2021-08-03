return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`DisableCharacterDialog` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("DisableCharacterDialog", {
			mod_script       = "scripts/mods/DisableCharacterDialog/DisableCharacterDialog",
			mod_data         = "scripts/mods/DisableCharacterDialog/DisableCharacterDialog_data",
			mod_localization = "scripts/mods/DisableCharacterDialog/DisableCharacterDialog_localization",
		})
	end,
	packages = {
		"resource_packages/DisableCharacterDialog/DisableCharacterDialog",
	},
}
