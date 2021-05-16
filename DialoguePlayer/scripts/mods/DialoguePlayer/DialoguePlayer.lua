local mod = get_mod("DialoguePlayer") 
local dialogue = {}
local selected_dialogue = 0



mod.getAllDialogue = function()
    for key,value in pairs(DialogueLookup) do 
        if string.match(key,"[a-zA-Z]") then
            table.insert( dialogue, key )
        end
    end
    
    table.sort(dialogue)
end

mod.getAllDialogue() 


---------------------
-- Chat Commands
---------------------

mod:command("dialogueFilterByKey", " enter key to search", function(searchKey)
    if not searchKey then 
        mod:echo("ERROR: Please pass in an arg to search. Example:\n/dialogueFilterByKey pwh")
        return
    end

    selected_dialogue = 0
    table.clear(dialogue)

    for key,value in pairs(DialogueLookup) do 
        if string.match(key,"[a-zA-Z]") and string.find( string.lower(key), string.lower(searchKey) )then
            table.insert( dialogue, key )
        end
    end
end)

mod:command("dialogueFilterByWord", " Enter the words in the localized text you are looking for", function(words)
    if not words then 
        mod:echo("ERROR: Please pass in an arg to search. Example:\n/dialogueFilterByWord elf")
        return 
    end

    selected_dialogue = 0
    table.clear(dialogue)
    for key,value in pairs(DialogueLookup) do 
        if string.match(key,"[a-zA-Z]") and string.find( string.lower(Localize(key)), string.lower(words) )then
            table.insert( dialogue, key )
        end
    end
end)

mod:command("dialogueClearFilter", " Clears searches", function()
    selected_dialogue = 0
    table.clear(dialogue)
    mod.getAllDialogue()
end)


------------------
--  Key Binding
------------------

mod.next = function() 
    selected_dialogue = (selected_dialogue + 1) % #dialogue
    mod:echo(dialogue[selected_dialogue + 1])
end

mod.prev = function() 
    selected_dialogue = (selected_dialogue - 1) % #dialogue
    mod:echo(dialogue[selected_dialogue + 1])
end

mod.play_dialogue = function() 
    local world = Managers.world:world("level_world")
    local wwise_world = Managers.world:wwise_world(world)
    local event = dialogue[selected_dialogue + 1]
    local ok = WwiseWorld.trigger_event(wwise_world, event)
    mod:echo("\nPlaying: %q \nLocalize: \"%s\"", event, Localize(event))
end

-- Your mod code goes here.
-- https://vmf-docs.verminti.de
