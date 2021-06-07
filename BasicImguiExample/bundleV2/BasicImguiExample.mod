return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`BasicImguiExample` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("BasicImguiExample", {
			mod_script       = "scripts/mods/BasicImguiExample/BasicImguiExample",
			mod_data         = "scripts/mods/BasicImguiExample/BasicImguiExample_data",
			mod_localization = "scripts/mods/BasicImguiExample/BasicImguiExample_localization",
		})
	end,
	packages = {
		"resource_packages/BasicImguiExample/BasicImguiExample",
	},
}
