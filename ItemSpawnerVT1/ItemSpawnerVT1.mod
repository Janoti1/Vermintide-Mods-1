return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ItemSpawnerVT1` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ItemSpawnerVT1", {
			mod_script       = "scripts/mods/ItemSpawnerVT1/ItemSpawnerVT1",
			mod_data         = "scripts/mods/ItemSpawnerVT1/ItemSpawnerVT1_data",
			mod_localization = "scripts/mods/ItemSpawnerVT1/ItemSpawnerVT1_localization",
		})
	end,
	packages = {
		"resource_packages/ItemSpawnerVT1/ItemSpawnerVT1",
	},
}
