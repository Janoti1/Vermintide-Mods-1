local mod = get_mod("grudgeBosses")


mod:hook(TerrorEventMixer.run_functions, "spawn", function (func, event, element, ...)
  if event["data"]["event_kind"] == "event_boss" then
    element["pre_spawn_func"] = TerrorEventUtils.add_enhancements_for_difficulty
  end

	return func(event, element, ...)
end) 



-- Lord Testing
-- mod:hook(TerrorEventMixer.run_functions, "spawn_at_raw", function (func, event, element, ...)
-- mod:echo(event["data"]["event_kind"])
-- mod:dump(event, "spawn_atRaw", 5)
--   if event["name"] == "warcamp_chaos_boss" then
--     element["pre_spawn_func"] = TerrorEventUtils.add_enhancements_for_difficulty
--   end

-- 	return func(event, element, ...)
-- end)  

local function save_enhancements(  )
	BreedEnhancements.boss = {}
      for name, data in pairs(mod.enhancements) do 
        if not mod:get(name) then
          BreedEnhancements.boss[name] = data
        end
      end
end

mod.on_game_state_changed = function(status, state)
  if status == "enter" and state == "StateIngame" then
      save_enhancements()
  end
end

mod.on_setting_changed = function(self)
	save_enhancements()
end



mod:hook(TerrorEventUtils, "generate_enhanced_breed", function(func, ...)
  local status, response = pcall(func, ...)
  if  status then 
    return response
  else 
    local list = {BreedEnhancements.base.base}
	for name, data in pairs(BreedEnhancements.boss) do 
        list[#list + 1] = data
      end
    return list
  end
  	-- Add all enahancements
 	-- local list = {BreedEnhancements.base.base}
	-- for name, data in pairs(BreedEnhancements.boss) do 
    --     list[#list + 1] = data
    --   end
    -- return list
end) 

mod:hook(BossHealthUI, "_generate_attributes", function(func, ...) 
	local status, response = pcall(func, ...)
	if  status then 
		return response
	else 
		return true
	end
end)

mod:hook(TerrorEventUtils, "apply_breed_enhancements", function(func, ...)
  pcall(func, ...)
end)
 