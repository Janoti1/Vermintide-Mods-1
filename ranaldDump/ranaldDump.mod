return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ranaldDump` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ranaldDump", {
			mod_script       = "scripts/mods/ranaldDump/ranaldDump",
			mod_data         = "scripts/mods/ranaldDump/ranaldDump_data",
			mod_localization = "scripts/mods/ranaldDump/ranaldDump_localization",
		})
	end,
	packages = {
		"resource_packages/ranaldDump/ranaldDump",
	},
}
