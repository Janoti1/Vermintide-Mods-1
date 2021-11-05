local descriptions = {mod_description = {en = "grudgeBosses description"}}

local boss_enhancements = BreedEnhancements.boss
for name, data in pairs(boss_enhancements) do
    if not data.dummy_enhancement then
		descriptions[name] = {en = string.format("Disable %s", Localize(data["display_name"]))}
    end
end

return descriptions
