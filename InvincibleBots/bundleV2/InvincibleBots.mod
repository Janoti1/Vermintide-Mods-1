return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`InvincibleBots` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("InvincibleBots", {
			mod_script       = "scripts/mods/InvincibleBots/InvincibleBots",
			mod_data         = "scripts/mods/InvincibleBots/InvincibleBots_data",
			mod_localization = "scripts/mods/InvincibleBots/InvincibleBots_localization",
		})
	end,
	packages = {
		"resource_packages/InvincibleBots/InvincibleBots",
	},
}
