return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`DialoguePlayer` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("DialoguePlayer", {
			mod_script       = "scripts/mods/DialoguePlayer/DialoguePlayer",
			mod_data         = "scripts/mods/DialoguePlayer/DialoguePlayer_data",
			mod_localization = "scripts/mods/DialoguePlayer/DialoguePlayer_localization",
		})
	end,
	packages = {
		"resource_packages/DialoguePlayer/DialoguePlayer",
	},
}
