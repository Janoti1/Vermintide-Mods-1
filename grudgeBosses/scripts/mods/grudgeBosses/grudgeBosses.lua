local mod = get_mod("grudgeBosses")


mod:hook(TerrorEventMixer.run_functions, "spawn", function (func, event, element, ...)
  if event["data"]["event_kind"] == "event_boss" then
    element["pre_spawn_func"] = TerrorEventUtils.add_enhancements_for_difficulty
  end

	return func(event, element, ...)
end) 
 