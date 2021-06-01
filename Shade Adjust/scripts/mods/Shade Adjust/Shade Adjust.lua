local mod = get_mod("Shade Adjust")
local kerillian_shade_activated_ability_duration = 5
local kerillian_shade_activated_ability_quick_cooldown_duration = 5
local kerillian_shade_activated_ability_quick_cooldown_crit_duration = 4
local kerillian_shade_activated_ability_quick_cooldown_buff_multiplier = -0.45
local base_cooldown = 60

-- local function set_noclip(player_unit, set_status)
-- 	if Unit.alive(player_unit) then
-- 		local status_extension = ScriptUnit.extension(player_unit, "status_system")

-- 		status_extension.set_noclip(status_extension, set_status)
-- 	end

-- 	return 
-- end

-- mod.hook(mod, BuffExtension, "_remove_sub_buff", function (func, self, buff, ...)
-- 	if buff.buff_type == "kerillian_shade_activated_ability_quick_cooldown_crit" and not self.is_husk then
-- 		local locomotion_extension = ScriptUnit.extension(self._unit, "locomotion_system")

-- 		locomotion_extension.set_mover_filter_property(locomotion_extension, "enemy_noclip", false)
-- 	end

-- 	return func(self, buff, ...)
-- end)
-- mod.hook(mod, BuffExtension, "add_buff", function (func, self, template_name, ...)
-- 	if template_name == "kerillian_shade_activated_ability_quick_cooldown_crit" then
-- 		set_noclip(self._unit, true)
-- 	end

-- 	return func(self, template_name, ...)
-- end)
-- mod.hook(mod, GenericStatusExtension, "set_noclip", function (func, self, no_clip)
-- 	local buff_extension = self.buff_extension
-- 	local has_shade_crit = buff_extension.has_buff_type(buff_extension, "kerillian_shade_activated_ability_quick_cooldown_crit")

-- 	if has_shade_crit and not no_clip then
-- 		return 
-- 	end

-- 	return func(self, no_clip)
-- end)

local function updateValues()
	local we = TalentBuffTemplates.wood_elf
	we.kerillian_shade_activated_ability.buffs[1].duration = mod:get("invis_duration")
	we.kerillian_shade_activated_ability_quick_cooldown.buffs[1].duration = mod:get("invis_duration")
	we.kerillian_shade_activated_ability_quick_cooldown_crit.buffs[1].duration = mod:get("crit_duration")
	we.kerillian_shade_activated_ability_quick_cooldown_buff.buffs[1].multiplier = mod:get("cdr")
    SPProfiles[4]["careers"][3]["activated_ability"][1]["cooldown"] = mod:get("base_cooldown")

	for _, buffs in pairs(TalentBuffTemplates) do
		table.merge_recursive(BuffTemplates, buffs)
	end

	return 
end

local function resetValues()
	local we = TalentBuffTemplates.wood_elf
	we.kerillian_shade_activated_ability.buffs[1].duration = kerillian_shade_activated_ability_duration
	we.kerillian_shade_activated_ability_quick_cooldown.buffs[1].duration = kerillian_shade_activated_ability_quick_cooldown_duration
	we.kerillian_shade_activated_ability_quick_cooldown_crit.buffs[1].duration = kerillian_shade_activated_ability_quick_cooldown_crit_duration
	we.kerillian_shade_activated_ability_quick_cooldown_buff.buffs[1].multiplier = kerillian_shade_activated_ability_quick_cooldown_buff_multiplier
    SPProfiles[4]["careers"][3]["activated_ability"][1]["cooldown"] = base_cooldown
    
	for _, buffs in pairs(TalentBuffTemplates) do
		table.merge_recursive(BuffTemplates, buffs)
	end

	return 
end

mod.on_disabled = function (self)
	mod:echo("disable")
	resetValues()

	return 
end
mod.on_enabled = function (self)
	mod:echo("enable")
	updateValues()

	return 
end
mod.on_setting_changed = function (self)
	updateValues()

	return 
end

return 
