local mod = get_mod("InvincibleBots")


mod:hook(PlayerUnitHealthExtension, "add_damage", function(func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, backstab_multiplier)
	if self.is_bot then return end 
	func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, backstab_multiplier)
end)    
-- Your mod code goes here.
-- https://vmf-docs.verminti.de
