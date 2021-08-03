local mod = get_mod("DisableCharacterDialog")


mod:hook(DialogueSystem, "rpc_play_dialogue_event", function(func, self, channel_id, go_id, is_level_unit, dialogue_id, dialogue_index)
    local dialogue_actor_unit = Managers.state.network:game_object_or_level_unit(go_id, is_level_unit)

	if not dialogue_actor_unit then
		return
	end

	if FROZEN[dialogue_actor_unit] then
		return
	end

	local dialogue_name = NetworkLookup.dialogues[dialogue_id]
	local dialogue = self.dialogues[dialogue_name]
	local extension = self.unit_extension_data[dialogue_actor_unit]
	local sound_event, subtitles_event, anim_face_event, anim_dialogue_event = DialogueQueries.get_dialogue_event(dialogue, dialogue_index)
	local modified_event = nil
	local career_name = extension.context.player_career
    local level_key = Managers.state.game_mode:level_key()

    -- Allow dialog that is not from a career or all dialog in keep
    if not career_name or string.find(level_key, "inn_level") or string.find(level_key, "morris_hub")then
        return func(self, channel_id, go_id, is_level_unit, dialogue_id, dialogue_index)
    end
    return
end)
-- Your mod code goes here.
-- https://vmf-docs.verminti.de  
