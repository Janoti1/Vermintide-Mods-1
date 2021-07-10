local mod = get_mod("NoZoom")

mod:hook(GenericStatusExtension, "set_zooming", function(func, self, zooming, camera_name)
    if camera_name == "zoom_in" or not self.zooming then 
        return func(self, zooming, "zoom_in_trueflight")
    else 
        return func(self, zooming, camera_name)
    end
end)
  
-- Your mod code goes here.
-- https://vmf-docs.verminti.de
