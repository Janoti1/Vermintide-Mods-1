local mod = get_mod("SaltsGlaive")

local unit_glaive = "units/mods/SaltsGlaive/glaive"

-------------
-- Glaive
-----------

for k, v in pairs(WeaponSkins.skins) do
    if string.find(k, "2h_billhook_skin") then
        v["right_hand_unit"] = unit_glaive
    end
end
-- WeaponSkins.skins["wh_2h_billhook_skin_01"]["right_hand_unit"] = unit_glaive
local nwlid = #NetworkLookup.inventory_packages + 1
NetworkLookup.inventory_packages[nwlid] = unit_glaive
NetworkLookup.inventory_packages[unit_glaive] = nwlid

nwlid = #NetworkLookup.inventory_packages + 1
NetworkLookup.inventory_packages[nwlid] = unit_glaive .. "_3p"
NetworkLookup.inventory_packages[unit_glaive .. "_3p"] = nwlid

mod:hook(PackageManager, "load",
         function(func, self, package_name, reference_name, callback,
                  asynchronous, prioritize)
    if package_name ~= unit_glaive and package_name ~= unit_glaive .. "_3p" then
        func(self, package_name, reference_name, callback, asynchronous,
             prioritize)
    end
end)

mod:hook(PackageManager, "unload",
         function(func, self, package_name, reference_name)
    if package_name ~= unit_glaive and package_name ~= unit_glaive .. "_3p" then
        func(self, package_name, reference_name)
    end
end)

mod:hook(PackageManager, "has_loaded",
         function(func, self, package, reference_name)
    if package == unit_glaive or package == unit_glaive .. "_3p" then
        return true
    end
    return func(self, package, reference_name)
end)



-- Your mod code goes here.
-- https://vmf-docs.verminti.de
