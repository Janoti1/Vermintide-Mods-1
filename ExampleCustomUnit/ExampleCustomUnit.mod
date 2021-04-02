return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ExampleCustomUnit` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ExampleCustomUnit", {
			mod_script       = "scripts/mods/ExampleCustomUnit/ExampleCustomUnit",
			mod_data         = "scripts/mods/ExampleCustomUnit/ExampleCustomUnit_data",
			mod_localization = "scripts/mods/ExampleCustomUnit/ExampleCustomUnit_localization",
		})
	end,
	packages = {
		"resource_packages/ExampleCustomUnit/ExampleCustomUnit",
	},
}
