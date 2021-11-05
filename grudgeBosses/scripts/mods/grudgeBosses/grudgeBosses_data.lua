local mod = get_mod("grudgeBosses")

local settings = {
    name = "Grudge Bosses",
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {widgets = {}}
}

mod.enhancements = {}
local boss_enhancements = BreedEnhancements.boss
for name, data in pairs(boss_enhancements) do
    if not data.dummy_enhancement then
        mod.enhancements[name] = data
		table.insert(settings["options"]["widgets"],
                 {setting_id = name, type = "checkbox", default_value = false})
    end
end

return settings 
