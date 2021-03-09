return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`LeechYourFriends` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("LeechYourFriends", {
			mod_script       = "scripts/mods/LeechYourFriends/LeechYourFriends",
			mod_data         = "scripts/mods/LeechYourFriends/LeechYourFriends_data",
			mod_localization = "scripts/mods/LeechYourFriends/LeechYourFriends_localization",
		})
	end,
	packages = {
		"resource_packages/LeechYourFriends/LeechYourFriends",
	},
}
