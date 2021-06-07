local mod = get_mod("BasicImguiExample")

-------------------------------------------------------
-- Update Path. Your mod name will at least be different
-------------------------------------------------------
local ExampleUI = mod:dofile("scripts/mods/BasicImguiExample/ui/ExampleUI")
mod.example_ui = ExampleUI:new()

-- This function is referenced in the _data.lua file as a keybind
-- See: https://vmf-docs.verminti.de/#/widgets?id=keybind
function mod.open_imgui()
	-- _is_open is some internal state to the UI class
	if mod.example_ui._is_open then
		mod.example_ui:close()
	else
		mod.example_ui:open()
	end
end

-- mod.update is a function VMF calls every game tick
-- See: https://vmf-docs.verminti.de/#/events?id=update
function mod.update()
    if mod.example_ui and mod.example_ui._is_open then
        mod.example_ui:draw()
    end
end

-- Hook the function you want to get data from and save the data
mod:hook_safe(IngameHud, "update", function(self)
    local player_manager = Managers.player
	local local_player = player_manager.local_player(player_manager)
	local player_unit = local_player and local_player.player_unit

	if not player_unit then
		return 
	end

    mod.position = Vector3Box(Unit.local_position(player_unit, 0))

end)
