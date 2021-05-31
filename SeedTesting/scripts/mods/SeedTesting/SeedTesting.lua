local mod = get_mod("SeedTesting")

local SAVED_ITEM_SEED = nil
function mod:on_enabled()
    local item_seed = mod:get("item_seed")
    if item_seed then
        SAVED_ITEM_SEED = item_seed
    else
        SAVED_ITEM_SEED = nil
        mod:set("item_seed", nil)
    end
end

mod:command("saveSeed", "", function(seed)
    local input = tonumber(seed)
    SAVED_ITEM_SEED = input
    mod:echo("[SeedTesting] Saved item seed %i", SAVED_ITEM_SEED)
    mod:set("item_seed", SAVED_ITEM_SEED)
end)

mod:hook(PickupSystem, "set_seed", function(func, self, _seed)
    if mod:get("item_seed_override") then 
        if not SAVED_ITEM_SEED then 
            mod:echo("[LevelDebug] No saved seed us /saveSeed <seedVal>")
            mod:echo("[LevelDebug] Current seed: %i", _seed)
            func(self, _seed)
            return
        end
        mod:echo("[SeedTesting] Overriding item seed to: %i", SAVED_ITEM_SEED)
        self._seed = SAVED_ITEM_SEED
	    self._starting_seed = SAVED_ITEM_SEED
    else
        mod:echo("[SeedTesting] Current item seed: %i", _seed)
        func(self, _seed)
    end
end)  

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
