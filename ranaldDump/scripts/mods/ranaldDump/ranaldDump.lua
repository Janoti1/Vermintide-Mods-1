local mod = get_mod("ranaldDump")

local locale_code = Application.user_setting("language_id")
local out_dir = os.getenv("HOMEDRIVE") .. os.getenv("HOMEPATH") .. "\\Desktop\\"

local heroOrder = {
  [1] = "es_mercenary",
  [2] = "es_huntsman",
  [3] = "es_knight",
  [4] = "es_questingknight",
  [5] = "dr_ranger",
  [6] = "dr_ironbreaker",
  [7] = "dr_slayer",
  [8] = "dr_engineer",
  [9] = "we_waywatcher",
  [10] = "we_maidenguard",
  [11] = "we_shade",
  [12] = "we_thornsister",
  [13] = "wh_captain",
  [14] = "wh_bountyhunter",
  [15] = "wh_zealot",
  [16] = "wh_holder",
  [17] = "bw_adept",
  [18] = "bw_scholar",
  [19] = "bw_unchained",
  [20] = "bw_holder" 
}
local heroId = {
  ["es_mercenary"] = 1,
  ["es_huntsman"] = 2,
  ["es_knight"] = 3,
  ["es_questingknight"] = 16,
  ["dr_ranger"] = 4,
  ["dr_ironbreaker"] = 5,
  ["dr_slayer"] = 6,
  ["dr_engineer"] = 17,
  ["we_waywatcher"] = 7,
  ["we_maidenguard"] = 8,
  ["we_shade"] = 9,
  ["we_thornsister"] = 18,
  ["wh_captain"] = 10,
  ["wh_bountyhunter"] = 11,
  ["wh_zealot"] = 12,
  ["wh_holder"] = 19,
  ["bw_adept"] = 13,
  ["bw_scholar"] = 14,
  ["bw_unchained"] = 15,
  ["bw_holder"] = 20
} 
  

local function tableContains(table, key) 
  return table[key] ~= nil
end 

-- Apparently # accomplishes this
local function tableSize(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

local function getTalentDescription()
  talents = {}
  for key, value in pairs(Talents) do 
    for _, talent in pairs(value) do 
      local nameStatus, nameResponse = pcall(Localize, talent["name"])
      if nameStatus then
        talents[talent["name"]] = {
          description = UIUtils.format_localized_description(talent["description"], talent["description_values"])
        }
        
      end
      
    end
  end
  return talents
end

local function writePerks(file, depth, perks) 
  file:write(string.format("%s\"perks\": [\n", depth))
  for perk in pairs(perks) do
    file:write(string.format("%s\t{\n", depth)) 
    file:write(string.format("%s\t\t\"name\": \"%s\",\n", depth, perks[perk]["name"])) 
    file:write(string.format("%s\t\t\"description\": \"%s\"\n", depth, perks[perk]["description"])) 
    file:write(string.format("%s\t}", depth)) 
    if perk ~= #perks then
      file:write(",")
    end
    file:write("\n")
  end
  file:write(string.format("%s],\n", depth))
end

local function writeTalents(file, depth, talents)
  file:write(string.format("%s\"talents\": [\n", depth))
  for talent in pairs(talents) do 
    file:write(string.format("%s\t{\n", depth))
    file:write(string.format("%s\t\t\"name\": \"%s\",\n", depth, talents[talent]["name"]))
    file:write(string.format("%s\t\t\"description\": \"%s\"\n", depth, string.gsub(talents[talent]["description"], "[\r\n]", "")))
    file:write(string.format("%s\t}", depth))
    if talent ~= #talents then
      file:write(",")
    end
    file:write("\n")
  end
  file:write(string.format("%s]\n", depth))
end

local function writeHero(file, id, heroData)
  local depth = "\t\t"
  file:write("\t{\n")
  
  -- Missing hero
  if heroData == nil then
    file:write(string.format("%s\"id\": %d\n", depth, id))
    file:write("\t}")
    return
  end

  -- TODO: fix heroName
  file:write(string.format("%s\"id\": %d,\n", depth, heroData["id"]))
  file:write(string.format("%s\"name\": \"%s\",\n", depth, heroData["name"]))
  file:write(string.format("%s\"codeName\": \"%s\",\n", depth, heroData["codeName"]))
  file:write(string.format("%s\"heroName\": \"%s\",\n", depth, heroData["name"]))
  file:write(string.format("%s\"health\": %d,\n", depth, heroData["health"]))
  -- passive
  file:write(string.format("%s\"passive\": {\n", depth))
  file:write(string.format("%s\t\"name\": \"%s\",\n", depth, heroData["passive"]["name"]))
  file:write(string.format("%s\t\"description\": \"%s\"\n", depth, heroData["passive"]["description"]))
  file:write(string.format("%s},\n", depth))
  -- skill
  file:write(string.format("%s\"skill\": {\n", depth))
  file:write(string.format("%s\t\"name\": \"%s\",\n", depth, heroData["skill"]["name"]))
  file:write(string.format("%s\t\"description\": \"%s\",\n", depth, heroData["skill"]["description"]))
  file:write(string.format("%s\t\"cooldown\": \"%s\"\n", depth, heroData["skill"]["cooldown"]))
  file:write(string.format("%s},\n", depth))
  -- perks
  writePerks(file, depth, heroData["perks"])
  -- talents
  writeTalents(file, depth, heroData["talents"])

  file:write("\t}")
end

mod:command("heroes", " Dump Hero Info", function(filePath) 
  if filePath then
    out_dir = filePath
  end

  talentDescriptions = getTalentDescription()

  local heroInfo = {}
  
  for name, settings in pairs(CareerSettings) do 
    if heroId[name] ~= nil then 
      local career = {}
      career["id"] = heroId[name]
      career["name"] = Localize(name)
      career["codeName"] = name
      career["health"] = settings.attributes.max_hp
      career["passive"] = {
        name = Localize(settings.passive_ability.display_name),
        description = Localize(settings.passive_ability.description)
      }
      career["skill"] = {
        name = Localize(settings.activated_ability[1].display_name),
        description = Localize(settings.activated_ability[1].description),
        cooldown = settings.activated_ability[1].cooldown
      }
      perks = {} 
      local numPerks = #settings.passive_ability.perks
      for i = 1, numPerks, 1 do
        perks[i] = {
          name = Localize(settings.passive_ability.perks[i].display_name),
          description = Localize(settings.passive_ability.perks[i].description)
        }
      end

      career["perks"] = perks


      local count = 1
      local allTalents = {}
      for row,talents in pairs(TalentTrees[settings.profile_name][settings.talent_tree_index]) do 
        for _,talent in pairs(talents) do 
          allTalents[count] = {
            name = Localize(talent),
            description = talentDescriptions[talent]["description"]
          }
          count = count + 1
        end
      end

      career["talents"] = allTalents
      heroInfo[name] = career
    end
    
  end 

  local file = io.open(string.format("%s%s", out_dir, "Heroes.js"),"w+")
  file:write("export const heroesData = [\n")
  local numHeroes = #heroOrder
  for i = 1, numHeroes, 1 do
    writeHero(file, heroId[heroOrder[i]], heroInfo[heroOrder[i]])
    if i ~= numHeroes then
      file:write(",\n")
    end
  end

  file:write("\n]")
  file:close() 
end)

mod.charCanWield = function(canWield, char)
  for _,v in pairs(canWield) do
    if (v == char) then 
      return true
    end
  end
  return false
end

mod.getCharCanWield = function(canWield)
  for _,v in pairs(canWield) do
    if (v == "dr_slayer" or v == "es_questingknight") then 
      return v
    end
  end
end

mod:command("weapons", "", function() 
  local file = io.open(string.format("%s%s", out_dir, "weapons.js"),"w+")
  file:write("export const weaponsData = [\n")
  for k, v in pairs(ItemMasterList) do 
    local type = v.slot_type
    if (type == "ranged" or type == "melee") and not string.find(k, "magic") and not string.find(k, "career_skill")then 
      local weapon_template = Weapons[v.template]
      file:write("\t{\n")
      file:write(string.format("\t\t\"name\": \"%s\", \n", Localize(k)))
      file:write(string.format("\t\t\"codeName\": \"%s\", \n", k))
      file:write(string.format("\t\t\"flavorText\": \"%s\", \n", Localize(v.description)))
      file:write(string.format("\t\t\"description\": \"%s\", \n", table.concat( weapon_template.tooltip_keywords, ", ")))
      local localizedTooltips = {}
      for _,tip in pairs(weapon_template.tooltip_keywords) do 
        table.insert( localizedTooltips, Localize(tip))
      end
      file:write(string.format("\t\t\"tooltipLocalized\": \"%s\", \n", table.concat( localizedTooltips, ", ")))
      file:write(string.format("\t\t\"dodgeDistance\": \"%s\", \n", weapon_template.buffs.change_dodge_distance.external_optional_multiplier))
      file:write(string.format("\t\t\"dodgeSpeed\": \"%s\", \n", weapon_template.buffs.change_dodge_speed.external_optional_multiplier))
      file:write(string.format("\t\t\"stamina\": \"%s\", \n", weapon_template.dodge_count))
      file:write(string.format("\t\t\"blockInnerCost\": \"%s\", \n", weapon_template.block_fatigue_point_multiplier))
      file:write(string.format("\t\t\"blockOuterCost\": \"%s\", \n", weapon_template.outer_block_fatigue_point_multiplier))
      file:write(string.format("\t\t\"blockAngle\": \"%s\", \n", weapon_template.block_angle))
      -- file:write(string.format("\t\t\"canWield\": \"%s\", \n", table.concat(v.can_wield, ", ")))
      if (type == "melee") then
        file:write(string.format("\t\t\"canWieldPrimary\": [\"%s\"], \n", table.concat(v.can_wield, "\", \"")))
        if (mod.charCanWield(v.can_wield, "dr_slayer") or mod.charCanWield(v.can_wield, "es_questingknight")) then
          local char = mod.getCharCanWield(v.can_wield)
          file:write(string.format("\t\t\"canWieldSecondary\": [\"%s\"], \n", char))
        else
          file:write("\t\t\"canWieldSecondary\": [], \n")
        end
      else 
        file:write("\t\t\"canWieldPrimary\": [], \n")
        file:write(string.format("\t\t\"canWieldSecondary\": [\"%s\"], \n", table.concat(v.can_wield, "\", \"")))
      end
      file:write(string.format("\t\t\"traitCategory\": \"%s\", \n", type))
      file:write(string.format("\t\t\"propertyCategory\": \"%s\", \n", type))
      file:write("\t},\n")
    end
  end
  file:write("\n]")
  file:close() 
end) 

mod:command("traits", "", function() 
  local file = io.open(string.format("%s%s", out_dir, "traits.js"),"w+")
  file:write("export const traitData = [\n")
  for k,v in pairs(WeaponTraits.combinations) do 
    file:write("\t{\n")
    file:write(string.format("\t\t\"%s\": [ \n", k))
    
    local traits = {}
    for _,whyfatshark in pairs(v) do 
      file:write("\t\t\t{\n")
      for _,trait in pairs(whyfatshark) do 
        file:write(string.format("\t\t\t\t\"codeName\": \"%s\", \n", trait))
        mod:echo(trait)
        local traitInfo = WeaponTraits.traits[trait]
        file:write(string.format("\t\t\t\t\"name\": \"%s\", \n", Localize(traitInfo.display_name)))
        file:write(string.format("\t\t\t\t\"name\": \"%s\", \n", UIUtils.format_localized_description(traitInfo.advanced_description, traitInfo.description_values)))
        mod:echo(Localize(traitInfo.display_name))
        mod:echo("%s", UIUtils.format_localized_description(traitInfo.advanced_description, traitInfo.description_values))

      end
      file:write("\t\t\t},\n")
    end
    
    file:write("\t\t],\n")
    file:write("\t},\n")
  end
  file:write("\n]")
  file:close() 
  mod:dump(WeaponTraits.combinations, "", 2)
end) 

mod:command("properties", "", function() 
  local file = io.open(string.format("%s%s", out_dir, "properties.js"),"w+")
  file:write("export const propertiesData = {\n")

  for k,v in pairs(WeaponProperties.combinations) do 
    -- file:write("\t{\n")
    file:write(string.format("\t\t\"%s\": { \n", k))
    mod:echo(k)
    local properties = {}
    for _,combos in pairs(v.unique) do 
      for _,props in pairs(combos) do
        if not properties[props] then
          local propertyInfo = WeaponProperties.properties[props]
          mod:echo("%s", Localize(propertyInfo.display_name))
          mod:echo("%s", Localize(propertyInfo.advanced_description))
          local description, advanced_description = UIUtils.get_property_description(props, 0)
          mod:echo("%s", description)
          mod:echo("%s", advanced_description)
          mod:echo("%s", Localize(propertyInfo.advanced_description))
          -- mod:echo("%s", UIUtils.format_localized_description(propertyInfo.advanced_description, 100))
          properties[props] = {name=description, range=advanced_description, description=Localize(propertyInfo.advanced_description)}

          -- properties[props] = {name=Localize(propertyInfo.display_name), description=string.format("%s",UIUtils.format_localized_description(propertyInfo.advanced_description, propertyInfo.description_values))}
        end 
      end
    end

    for prop,typeProps in pairs(properties) do 
      file:write(string.format("\t\t\t\"%s\": { \n", prop))
      -- file:write(string.format("\t\t\t\t\"name\": \"%s\", \n", typeProps.name:gsub( "[0-9+.%%]","" )))
      file:write(string.format("\t\t\t\t\"name\": \"%s\", \n", typeProps.name:gsub( "%s*+[0-9.]+%%*%s*","" )))
      file:write(string.format("\t\t\t\t\"description\": \"%s\", \n", typeProps.description))
      file:write(string.format("\t\t\t\t\"range\": \"%s\", \n", typeProps.range:gsub( "%s+[(]+","(" )))
      file:write("\t\t\t},\n")
      mod:dump(typeProps, k, 3)
    end 
    file:write(string.format("\t\t},\n"))
    -- file:write("\t},\n")
  end
  file:write("\n]")
  file:close() 

end)
  


 