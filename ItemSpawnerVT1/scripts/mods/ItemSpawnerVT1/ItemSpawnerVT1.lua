local mod = get_mod("ItemSpawnerVT1")
mod.pickups = {}
mod.item_ndx = 0

function storeItems() 
    if mod:get("unsafe_items") then
        mod.pickups = {}
        for pickup_name, pickup_settings in pairs(AllPickups) do
            table.insert(mod.pickups, pickup_name )
        end
    else
        mod.pickups = {"healing_draught", "speed_boost_potion", "damage_boost_potion", "fire_grenade_t2", "frag_grenade_t2", "frag_grenade_t1", "first_aid_kit", "all_ammo", "explosive_barrel", "all_ammo_small", "fire_grenade_t1"}
    end
end

storeItems()

mod.spawn_item = function() 
    local pickup_name = mod.pickups[mod.item_ndx + 1]
    mod:pcall(function() 
        local spawn_method = "rpc_spawn_pickup_with_physics"
        if pickup_name == "all_ammo" then
            spawn_method = "rpc_spawn_pickup"
        end
    
        local local_player_unit = Managers.player:local_player().player_unit
        Managers.state.network.network_transmit:send_rpc_server(
            spawn_method,
            NetworkLookup.pickup_names[pickup_name],
            Unit.local_position(local_player_unit, 0),
            Unit.local_rotation(local_player_unit, 0),
            NetworkLookup.pickup_spawn_types['dropped']
        )
    end)
end

mod.next_item = function() 
    mod.item_ndx = (mod.item_ndx + 1) % #mod.pickups
    mod:echo("[Item]: " .. mod.pickups[mod.item_ndx + 1 ])
end


function mod:on_setting_changed()
    mod:echo("[Item]: Reloading items")
    storeItems()
end

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
