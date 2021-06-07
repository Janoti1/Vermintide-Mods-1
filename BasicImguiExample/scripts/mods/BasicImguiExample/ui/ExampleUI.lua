ExampleUI = class(ExampleUI)
-----------------------------
-- Change to Name of your mod
------------------------------
local mod = get_mod("BasicImguiExample")

function ExampleUI.init(self)
    self._is_open = false
end

function ExampleUI.toggle(self)
    if self._is_open then
        self:close()
    else
        self:open()
    end
end

function ExampleUI.open(self)
    self._is_open = true
    Imgui.open_imgui()
end

function ExampleUI.capture_input()
    ShowCursorStack.push()
    Imgui.enable_imgui_input_system(Imgui.KEYBOARD)
    Imgui.enable_imgui_input_system(Imgui.MOUSE)
end

function ExampleUI.draw(self)
    Imgui.begin_window("ExampleUI")
    Imgui.spacing()
    
    local position = mod.position:unbox()
    Imgui.text(string.format("Position(%.2f, %.2f, %.2f)", position.x, position.y, position.z))

    Imgui.spacing()
    
    Imgui.end_window()
end

function ExampleUI.release_input()
    ShowCursorStack.pop()
    Imgui.disable_imgui_input_system(Imgui.KEYBOARD)
    Imgui.disable_imgui_input_system(Imgui.GAMEPAD)
end

function ExampleUI.close(self)
    self._is_open = false
    Imgui.close_imgui()
    -- self:release_input()
end

return ExampleUI