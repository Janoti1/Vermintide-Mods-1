return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ConflagVortex` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ConflagVortex", {
			mod_script       = "scripts/mods/ConflagVortex/ConflagVortex",
			mod_data         = "scripts/mods/ConflagVortex/ConflagVortex_data",
			mod_localization = "scripts/mods/ConflagVortex/ConflagVortex_localization",
		})
	end,
	packages = {
		"resource_packages/ConflagVortex/ConflagVortex",
	},
}
