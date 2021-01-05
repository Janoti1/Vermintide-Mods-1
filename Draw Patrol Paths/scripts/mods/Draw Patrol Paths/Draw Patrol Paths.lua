local mod = get_mod("Draw Patrol Paths")
mod:dofile("scripts/mods/Draw Patrol Paths/game_code/debug_drawer")
script_data.disable_debug_draw = false

function mod.update()
    if Managers.state.debug then
        for _, drawer in pairs(Managers.state.debug._drawers) do
            drawer:update(Managers.state.debug._world)
        end
    end
end

local function draw_patrol_route(route_data, col) 
    local h = Vector3(0,0,1)
    local waypoints = route_data.waypoints
    local wp = waypoints[1]
    local p1 = Vector3(wp[1], wp[2], wp[3]) + h

    QuickDrawerStay:sphere(p1, 0.5, Color(255, 255, 255))

    local p2 = nil

    for i = 2, #waypoints, 1 do
        wp = waypoints[i]
        p2 = Vector3(wp[1], wp[2], wp[3]) + h 

        QuickDrawerStay:sphere(p2, 0.5, col)
        QuickDrawerStay:line(p1, p2, col)

        p1 = p2 
    end
end

mod:command("drawPat", "", function()     
    local section_colors = {
        Color(0, 255, 40),
		Color(0, 255, 255),
		Color(200, 25, 40),
		Color(255, 0, 255),
		Color(220, 200, 0)
    }
    
    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints

    if boss_waypoints then
        for i = 1, #boss_waypoints, 1 do
            local section = boss_waypoints[i]
            local section_color = section_colors[i]

            for j = 1, #section, 1 do
                local color = section_colors[(i + j) % 5 + 1]
                local route_data = section[j]
                draw_patrol_route(route_data, color)
            end
                
            
        end
    end
end) 

mod:command("drawPatClear", "", function()     
    QuickDrawerStay:reset()
end) 

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
