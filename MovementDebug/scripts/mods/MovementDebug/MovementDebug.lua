local mod = get_mod("MovementDebug")
local always_on = true
local SCREEN_WIDTH = 1920
local SCREEN_HEIGHT = 1080

local function get_x()
    local x = mod:get("offset_x")
    local x_limit = SCREEN_WIDTH / 2
    local max_x = math.min(mod:get("offset_x"), x_limit)
    local min_x = math.max(mod:get("offset_x"), -x_limit)
    if x == 0 then return 0 end
    local clamped_x = x > 0 and max_x or min_x
    return clamped_x
end

local function get_y()
    local y = mod:get("offset_y")
    local y_limit = SCREEN_HEIGHT / 2
    local max_y = math.min(mod:get("offset_y"), y_limit)
    local min_y = math.max(mod:get("offset_y"), -y_limit)
    if y == 0 then return 0 end
    local clamped_y = -(y > 0 and max_y or min_y)
    return clamped_y
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
            },
            {
                style_id = "avg_speed_text",
                pass_type = "text",
                text_id = "avg_speed_text",
                retained_mode = false,
                fade_out_duration = 5,
                content_check_function = function(content)
                    if always_on then return true end
                end
            },
            {
                style_id = "dodging_text",
                pass_type = "text",
                text_id = "dodging_text",
                retained_mode = false,
                content_check_function = function(content)
                    if always_on then return true end
                end
            }
        }
    },
    content = {
        current_speed_text = "",
        avg_speed_text = "",
        dodging_text = ""
    },
    style = {
        current_speed_text = {
            font_type = "hell_shark",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "center",
            horizontal_alignment = "center",
            text_color = Colors.get_table("white"),
            offset = {get_x(), get_y(), 0}
        },
        avg_speed_text = {
            font_type = "hell_shark",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "center",
            horizontal_alignment = "center",
            text_color = Colors.get_table("white"),
            offset = {get_x(), get_y() - mod:get("current_speed_count_font_size"), 0}
        },
        dodging_text = {
            font_type = "hell_shark",
            font_size = mod:get("current_speed_count_font_size"),
            vertical_alignment = "center",
            horizontal_alignment = "center",
            text_color = Colors.get_table("white"),
            offset = {get_x(), get_y() - mod:get("current_speed_count_font_size") * 2, 0}
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
    always_on = true
    if not mod.ui_widget then return end
    mod.ui_widget.style.current_speed_text.offset[1] = get_x()
    mod.ui_widget.style.current_speed_text.offset[2] = get_y()
    mod.ui_widget.style.current_speed_text.font_size = mod:get("current_speed_count_font_size")

    mod.ui_widget.style.avg_speed_text.offset[1] = get_x()
    mod.ui_widget.style.avg_speed_text.offset[2] = get_y() - mod:get("current_speed_count_font_size")
    mod.ui_widget.style.avg_speed_text.font_size = mod:get("current_speed_count_font_size")

    mod.ui_widget.style.dodging_text.offset[1] = get_x()
    mod.ui_widget.style.dodging_text.offset[2] =
        get_y() - mod:get("current_speed_count_font_size") *2
    mod.ui_widget.style.dodging_text.font_size = mod:get("current_speed_count_font_size")
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
	
    local locomotion_extension = player_unit and ScriptUnit.has_extension(player_unit, "locomotion_system")
    
    local current_speed
	
	if locomotion_extension then
		local current_velocity = locomotion_extension:current_velocity()
		current_speed = Vector3.length(current_velocity)
    end
    
    local my_player_unit = Managers.player:local_player().player_unit
    local status_extension = ScriptUnit.extension(my_player_unit, "status_system")
    
    local dodgeState = ""
    if status_extension:get_is_dodging() then 
        dodgeState = "true"
    else
        dodgeState = "false"
    end
    

    local playerHeight = locomotion_extension.first_person_extension.player_height_current
    local average_velocity = locomotion_extension.first_person_extension.locomotion_extension:average_velocity()
    local average_speed = Vector3.length(average_velocity)
    local move_direction = Vector3.normalize(locomotion_extension:current_velocity())
   
	local timer_text = string.format("%s: %.2f", "Current Speed", current_speed)
    widget.content.current_speed_text = timer_text
    widget.content.avg_speed_text = string.format("%s: %.2f", "Avg. Speed", average_speed)
    if mod:get("show_dodge") then
        widget.content.dodging_text = dodgeState
    else
        widget.content.dodging_text = ""
    end
    
	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, fake_input_service, nil, "root")
    UIRenderer.draw_widget(ui_renderer, widget)
    UIRenderer.end_pass(ui_renderer)
end)

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
