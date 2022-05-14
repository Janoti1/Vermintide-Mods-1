local mod = get_mod("DisplayTeamName")

local always_on = true

local SCREEN_WIDTH = 1920
local SCREEN_HEIGHT = 1080
local TEAM_NAME = ""

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
 
local team_name_ui_definition = {
    scenegraph_id = "root",
    element = {
        passes = {
            {
                style_id = "team_name_text",
                pass_type = "text",
                text_id = "team_name_text",
                retained_mode = false,
                fade_out_duration = 5,
                content_check_function = function(content)
                    if always_on then return true end
                end
            }, 
        }
    },
    content = {
        team_name_text = "",
    },
    style = {
        team_name_text = {
            font_type = "hell_shark",
            font_size = mod:get("font_size"),
            vertical_alignment = "center",
            horizontal_alignment = "center",
            text_color = Colors.get_table("white"),
            offset = {get_x(), get_y(), 0}
        },
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
    mod.ui_widget.style.team_name_text.offset[1] = get_x()
    mod.ui_widget.style.team_name_text.offset[2] = get_y()
    mod.ui_widget.style.team_name_text.font_size = mod:get("font_size")
    
end

function mod:on_enabled() 
    local team = mod:get("team_name")
    if team then
        TEAM_NAME = team
    else
        TEAM_NAME = "<Set Team Name>"
        mod:set("team_name", "<Set Team Name>")
    end
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
    mod.ui_widget = UIWidget.init(team_name_ui_definition)
end

mod:command("setTeam", "", function(...)
    local name = table.concat( {...}, " ")
    mod:set("team_name", name, true)
    TEAM_NAME = name
end)

mod:hook_safe(IngameHud, "update", function(self)
    if not mod.ui_widget then 
        mod:init()
        return
    end
		
    --local hudvisible = Managers.player:local_player().network_manager.matchmaking_manager._ingame_ui.ingame_hud._currently_visible_components ~= {}
    --if not hudvisible then return end  
		
    if not self._currently_visible_components.EquipmentUI then 
        return 
    end	
		
    local widget = mod.ui_widget
    local ui_renderer = mod.ui_renderer
    local ui_scenegraph = mod.ui_scenegraph
	widget.content.team_name_text = TEAM_NAME
	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, fake_input_service, nil, "root")
    UIRenderer.draw_widget(ui_renderer, widget)
    UIRenderer.end_pass(ui_renderer)
end)   


-- Your mod code goes here.
-- https://vmf-docs.verminti.de


-- Your mod code goes here.
-- https://vmf-docs.verminti.de
