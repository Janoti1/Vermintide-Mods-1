return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Display Main Path` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Display Main Path", {
			mod_script       = "scripts/mods/Display Main Path/Display Main Path",
			mod_data         = "scripts/mods/Display Main Path/Display Main Path_data",
			mod_localization = "scripts/mods/Display Main Path/Display Main Path_localization",
		})
	end,
	packages = {
		"resource_packages/Display Main Path/Display Main Path",
	},
}
