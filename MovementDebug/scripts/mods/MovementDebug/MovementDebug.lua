local mod = get_mod("MovementDebug")
local always_on = true
local SCREEN_WIDTH = 4096
local SCREEN_HEIGHT = 2160
-- local SCREEN_WIDTH, SCREEN_HEIGHT = UIResolution()
local last_dodge_distance = 0
local last_dodge_dur = 0
local queue = {}
local last_dodge_start_pos = nil
local last_dodge_start_time = nil
local PhysicsWorld = PhysicsWorld
local function get_x()
    local x = mod:get("offset_x")
    local x_limit = SCREEN_WIDTH -- / 2
    local max_x = math.min(mod:get("offset_x"), x_limit)
    local min_x = math.max(mod:get("offset_x"), -x_limit)
    if x == 0 then return 0 end
    local clamped_x = x > 0 and max_x or min_x
    return clamped_x
end

local function get_y()
    local y = mod:get("offset_y")
    local y_limit = SCREEN_HEIGHT -- / 2
    local max_y = math.min(mod:get("offset_y"), y_limit)
    local min_y = math.max(mod:get("offset_y"), -y_limit)
    if y == 0 then return 0 end
    local clamped_y = -(y > 0 and max_y or min_y)
    return -1 * clamped_y
end

local scenegraph_definition = {
    root = {scale = "fit", size = {1920, 1080}, position = {0, 0, UILayer.hud}}
}

local movement_debug_ui_definition = {
    scenegraph_id = "root",
    element = {
        passes = {
            {
                style_id = "current_speed_text",
                pass_type = "text",
                text_id = "current_speed_text",
                retained_mode = false,
                fade_out_duration = 5,
                content_check_function = function(content)
                    if always_on then return true end
                end
            }, {
                style_id = "avg_speed_text",
                pass_type = "text",
                text_id = "avg_speed_text",
                retained_mode = false,
                fade_out_duration = 5,
                content_check_function = function(content)
                    if always_on then return true end
                end
            }, {
                style_id = "last_dodge_distance_text",
                pass_type = "text",
                text_id = "last_dodge_distance_text",
                retained_mode = false,
                fade_out_duration = 5,
                content_check_function = function(content)
                    if always_on then return true end
                end
            }, {
                style_id = "last_dodge_dur_text",
                pass_type = "text",
                text_id = "last_dodge_dur_text",
                retained_mode = false,
                fade_out_duration = 5,
                content_check_function = function(content)
                    if always_on then return true end
                end
            }, {
                style_id = "dodging_text",
                pass_type = "text",
                text_id = "dodging_text",
                retained_mode = false,
                content_check_function = function(content)
                    if always_on then return true end
                end
            }, {
                style_id = "position_text",
                pass_type = "text",
                text_id = "position_text",
                retained_mode = false,
                fade_out_duration = 5,
                content_check_function = function(content)
                    if always_on then return true end
                end
            }, {
                style_id = "player_height_text",
                pass_type = "text",
                text_id = "player_height_text",
                retained_mode = false,
                fade_out_duration = 5,
                content_check_function = function(content)
                    if always_on then return true end
                end
            }
        }
    },
    content = {
        current_speed_text = "",
        avg_speed_text = "",
        dodging_text = "",
        last_dodge_distance_text = "",
        last_dodge_dur_text = "",
        position_text = "",
        player_height_text = ""
    },
    style = {
        current_speed_text = {
            font_type = "arial",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "left",
            horizontal_alignment = "left",
            text_color = Colors.get_table("white"),
            offset = {get_x(), get_y(), 0}
        },
        avg_speed_text = {
            font_type = "arial",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "left",
            horizontal_alignment = "left",
            text_color = Colors.get_table("white"),
            offset = {
                get_x(), get_y() - mod:get("current_speed_count_font_size"), 0
            }
        },
        last_dodge_distance_text = {
            font_type = "arial",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "left",
            horizontal_alignment = "left",
            text_color = Colors.get_table("white"),
            offset = {
                get_x(), get_y() - mod:get("current_speed_count_font_size") * 2,
                0
            }
        },
        last_dodge_dur_text = {
            font_type = "arial",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "left",
            horizontal_alignment = "left",
            text_color = Colors.get_table("white"),
            offset = {
                get_x(), get_y() - mod:get("current_speed_count_font_size") * 3,
                0
            }
        },
        dodging_text = {
            font_type = "hell_shark",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "left",
            horizontal_alignment = "left",
            text_color = Colors.get_table("white"),
            offset = {
                get_x(), get_y() - mod:get("current_speed_count_font_size") * 4,
                0
            }
        },
        position_text = {
            font_type = "arial",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "left",
            horizontal_alignment = "left",
            text_color = Colors.get_table("white"),
            offset = {0, 0, 0}
        },
        player_height_text = {
            font_type = "arial",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "left",
            horizontal_alignment = "left",
            text_color = Colors.get_table("white"),
            offset = {0, mod:get("current_speed_count_font_size"), 0}
        }
    },
    offset = {0, 0, 0}
}

function mod:on_disabled()
    mod.ui_renderer = nil
    mod.ui_scenegraph = nil
    mod.ui_widget = nil
end

function mod:on_setting_changed()
    queue = {}
    always_on = true
    if not mod.ui_widget then return end
    mod.ui_widget.style.current_speed_text.offset[1] = get_x()
    mod.ui_widget.style.current_speed_text.offset[2] = get_y()
    mod.ui_widget.style.current_speed_text.font_size =
        mod:get("current_speed_count_font_size")

    mod.ui_widget.style.avg_speed_text.offset[1] = get_x()
    mod.ui_widget.style.avg_speed_text.offset[2] =
        get_y() - mod:get("current_speed_count_font_size")
    mod.ui_widget.style.avg_speed_text.font_size =
        mod:get("current_speed_count_font_size")

    mod.ui_widget.style.last_dodge_distance_text.offset[1] = get_x()
    mod.ui_widget.style.last_dodge_distance_text.offset[2] =
        get_y() - mod:get("current_speed_count_font_size") * 2
    mod.ui_widget.style.last_dodge_distance_text.font_size =
        mod:get("current_speed_count_font_size")

    mod.ui_widget.style.last_dodge_dur_text.offset[1] = get_x()
    mod.ui_widget.style.last_dodge_dur_text.offset[2] =
        get_y() - mod:get("current_speed_count_font_size") * 3
    mod.ui_widget.style.last_dodge_dur_text.font_size =
        mod:get("current_speed_count_font_size")

    mod.ui_widget.style.dodging_text.offset[1] = get_x()
    mod.ui_widget.style.dodging_text.offset[2] =
        get_y() - mod:get("current_speed_count_font_size") * 4
    mod.ui_widget.style.dodging_text.font_size =
        mod:get("current_speed_count_font_size")

    mod.ui_widget.style.position_text.offset[1] = 0
    mod.ui_widget.style.position_text.offset[2] = 0
    mod.ui_widget.style.position_text.font_size =
        mod:get("current_speed_count_font_size")

    mod.ui_widget.style.player_height_text.offset[1] = 0
    mod.ui_widget.style.player_height_text.offset[2] = mod:get("current_speed_count_font_size")
    mod.ui_widget.style.player_height_text.font_size =
        mod:get("current_speed_count_font_size")

end

local fake_input_service = {
    get = function() return end,
    has = function() return end
}

function mod:init()
    if mod.ui_widget then return end

    local world = Managers.world:world("top_ingame_view")
    mod.ui_renderer = UIRenderer.create(world, "material",
                                        "materials/fonts/gw_fonts")
    mod.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)
    mod.ui_widget = UIWidget.init(movement_debug_ui_definition)
end

local length = 60
mod:hook_safe(IngameHud, "update", function(self)
    if not mod.ui_widget then 
        mod:init()
        return
    end
    if not self.boon_ui._is_visible and not self.observer_ui._is_visible then return end
    local t = Managers.time:time("game")
    local widget = mod.ui_widget
    local ui_renderer = mod.ui_renderer
    local ui_scenegraph = mod.ui_scenegraph

    local player_manager = Managers.player
    local local_player = player_manager:local_player()
    local player_unit = local_player and local_player.player_unit
    if not player_unit then return end

    local locomotion_extension = player_unit and
                                     ScriptUnit.has_extension(player_unit,
                                                              "locomotion_system")

    local current_speed
    local z

    if locomotion_extension then
        local current_velocity = locomotion_extension:current_velocity()
        z = current_velocity[3]
        current_speed = Vector3.length(Vector3.flat(current_velocity))
    end

    table.insert(queue, current_speed)
    if #queue > mod:get("frames") then table.remove(queue, 1) end
    local sum = 0
    for i = 1, #queue, 1 do sum = sum + queue[i] end
    local avg_speed = sum / mod:get("frames")
    -- mod:echo(avg_speed)

    local my_player_unit = Managers.player:local_player().player_unit
    local status_extension = ScriptUnit.extension(my_player_unit,
                                                  "status_system")

    local dodgeState = ""
    if status_extension:get_is_dodging() then
        dodgeState = "true"
    else
        dodgeState = "false"
    end

    local playerHeight = locomotion_extension.first_person_extension
                             .player_height_current
    local average_velocity = locomotion_extension.first_person_extension
                                 .locomotion_extension:average_velocity()
    local average_speed = Vector3.length(average_velocity)
    local move_direction = Vector3.normalize(
                               locomotion_extension:current_velocity())

    local timer_text = string.format("%-15s: %.2f", "Current Speed",
                                     current_speed)
    widget.content.current_speed_text = timer_text
    widget.content.avg_speed_text = string.format("%-15s: %.2f", "Avg Speed",
                                                  avg_speed)
    widget.content.last_dodge_distance_text =
        string.format("%s: %.2f", "Dodge Dist.", last_dodge_distance)
    widget.content.last_dodge_dur_text =
        string.format("%s: %.3fs", "Dodge Dur.", last_dodge_dur)
    if mod:get("show_dodge") then
        widget.content.dodging_text = dodgeState
    else
        widget.content.dodging_text = ""
    end
    local look_rotation = locomotion_extension.first_person_extension.look_rotation:unbox()
    
    local current_position = Unit.local_position(player_unit, 0)

    local cm = Managers.state.camera
    local str
    if cm then
		local player = Managers.player:local_player(1)
		local vp_name = player and player.viewport_name

		if vp_name then
			local pos = cm:camera_position(vp_name)
			local rot = cm:camera_rotation(vp_name)
			local text_size = 18
			widget.content.position_text = string.format("Position(%.2f, %.2f, %.2f) Rotation(%.4f, %.4f, %.4f, %.4f)", pos.x, pos.y, pos.z, Quaternion.to_elements(rot))

		end
	end
    
    -- widget.content.position_text = position_string .. " " .. str

    widget.content.player_height_text = string.format("%s: %.2f Z-Speed: %.2f", "Height", playerHeight, z)

    UIRenderer.begin_pass(ui_renderer, ui_scenegraph, fake_input_service, nil,
                          "root")

    UIRenderer.draw_widget(ui_renderer, widget)
    UIRenderer.end_pass(ui_renderer)
end)

mod:command("lookingAt", "", function()
    local player_unit = Managers.player:local_player().player_unit
    local locomotion_extension = ScriptUnit.has_extension(player_unit, "locomotion_system")
    mod:dump(locomotion_extension, "",2)
    mod.distToLookingAt()
end)

mod.distToLookingAt = function()
    local player_manager = Managers.player
    local local_player = player_manager:local_player()
    local player_unit = local_player and local_player.player_unit
    local current_position = Unit.local_position(player_unit, 0)
    local looking_at = mod:position_at_cursor(local_player)
    if looking_at then
        mod:echo("Distance: " .. Vector3.distance(current_position, looking_at))
    else
        mod:echo("Distance: nil")
    end

end

-- Get raycast position 
-- From AussiemonCreatureSpawner
mod.position_at_cursor = function(self, local_player)
    local viewport_name = local_player.viewport_name

    local camera_position = Managers.state.camera:camera_position(viewport_name)
    local camera_rotation = Managers.state.camera:camera_rotation(viewport_name)
    local camera_direction = Quaternion.forward(camera_rotation)

    local range = 500

    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")

    local new_position
    local result = PhysicsWorld.immediate_raycast(physics_world,
                                                  camera_position,
                                                  camera_direction, range,
                                                  "all", "collision_filter",
                                                  "filter_ray_horde_spawn")

    if result then
        local num_hits = #result

        for i = 1, num_hits, 1 do
            local hit = result[i]
            local hit_actor = hit[4]
            local hit_unit = Actor.unit(hit_actor)
            local ray_hit_self = local_player.player_unit and
                                     (hit_unit == local_player.player_unit)

            if not ray_hit_self then
                new_position = hit[1]
                break
            end
        end
    end

    return new_position
end

-- Get Dodge Data
mod:hook_safe(PlayerCharacterStateDodging, "on_enter", function(self, ...)
    local args = {...}
    local unit = args[1]
    local is_local_player = Managers.player:unit_owner(unit).local_player
    if not is_local_player then return end
    local start_pos = Unit.local_position(unit, 0)
    last_dodge_start_pos = {start_pos[1], start_pos[2], start_pos[3]}
    last_dodge_start_time = Managers.time:time("game")

end)

mod:hook_safe(PlayerCharacterStateDodging, "on_exit", function(self, ...)
    local args = {...}
    local unit = args[1]
    local is_local_player = Managers.player:unit_owner(unit).local_player
    if not is_local_player then return end
    local end_pos = Unit.local_position(unit, 0)
    local start_pos = Vector3(last_dodge_start_pos[1], last_dodge_start_pos[2],
                              last_dodge_start_pos[3])
    local diff = start_pos - end_pos
    last_dodge_distance = Vector3.distance(start_pos, end_pos)
    local dodge_end_time = Managers.time:time("game")
    last_dodge_dur = dodge_end_time - last_dodge_start_time

end)

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
