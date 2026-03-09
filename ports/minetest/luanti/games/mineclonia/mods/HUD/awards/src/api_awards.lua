-- Copyright (c) 2013-18 rubenwardy. MIT.
local S = awards.translator

function awards.register_award(name, def)
	def.name = name

	-- Add Triggers
	if def.trigger and def.trigger.type then
		local tdef = awards.registered_triggers[def.trigger.type]
		assert(tdef, "Trigger not found: " .. def.trigger.type)
		tdef:on_register(def)
	end

	function def:can_unlock(data)
		if not self.requires then
			return true
		end

		for i=1, #self.requires do
			if not data.unlocked[self.requires[i]] then
				return false
			end
		end
		return true
	end

	-- Add Award
	awards.registered_awards[name] = def

	local tdef = awards.registered_awards[name]
	if def.description == nil and tdef.getDefaultDescription then
		def.description = tdef:getDefaultDescription()
	end
end


-- This function is called whenever a target condition is met.
-- It checks if a player already has that award, and if they do not,
-- it gives it to them
----------------------------------------------
--awards.unlock(name, award)
-- name - the name of the player
-- award - the name of the award to give
function awards.unlock(name, award)
	-- Ensure the player is online.
	if not core.get_player_by_name(name) then
		return
	end

	-- Access Player Data
	local data  = awards.player(name)
	local awdef = awards.registered_awards[award]
	assert(awdef, "Unable to unlock an award which doesn't exist!")

	if data.disabled or
			(data.unlocked[award] and data.unlocked[award] == award) then
		return
	end

	if not awdef:can_unlock(data) then
		core.log("warning", "can_unlock returned false in unlock of " ..
				award .. " for " .. name)
		return
	end

	-- Unlock Award
	core.log("action", name.." has unlocked award "..award)
	if core.settings:get_bool("mcl_showAdvancementMessages", true) then
		core.chat_send_all(S("@1 has made the advancement @2", name, core.colorize(mcl_colors.GREEN, "[" .. (awdef.title or award) .. "]")))
	end
	data.unlocked[award] = award
	awards.save()

	-- Give Prizes
	if awdef and awdef.prizes then
		for i = 1, #awdef.prizes do
			local itemstack = ItemStack(awdef.prizes[i])
			if not itemstack:is_empty() then
				local receiverref = core.get_player_by_name(name)
				if receiverref then
					receiverref:get_inventory():add_item("main", itemstack)
				end
			end
		end
	end

	-- Run callbacks
	if awdef.on_unlock and awdef.on_unlock(name, awdef) then
		return
	end
	for _, callback in pairs(awards.on_unlock) do
		if callback(name, awdef) then
			return
		end
	end

	-- Get Notification Settings
	local title = awdef.title or award
	local desc = awdef.description or ""
	local background = awdef.hud_background or awdef.background or "awards_bg_default.png"
	local icon = (awdef.icon or "awards_unknown.png") .. "^[resize:32x32"
                -- Sounds
                local sound
                if awdef.type == "Challenge" then
                    sound = {name="awards_challenge_complete"}
                else
                    sound = {name="awards_ui_toast_in"}
                end

	-- Do Notification
	if sound then
		-- Enforce sound delay to prevent sound spamming
		local lastsound = data.lastsound
		if lastsound == nil or os.difftime(os.time(), lastsound) >= 1 then
			core.sound_play(sound, {to_player=name})
			data.lastsound = os.time()
		end
	end

	if awards.show_mode == "chat" then
		local chat_announce
		if awdef.secret then
			chat_announce = S("Hidden Advancement Unlocked: @1", title)
		else
			chat_announce = S("Advancement Unlocked: @1", title)
		end
		-- use the chat console to send it
		core.chat_send_player(name, chat_announce)
		if desc~="" then
			core.chat_send_player(name, desc)
		end
	else
		local player = core.get_player_by_name(name)
		local one = player:hud_add({
			type = "image",
			name = "award_bg",
			scale = {x = 1, y = 1},
			text = background,
			position = {x = 0.5, y = 0.05},
			offset = {x = 0, y = 138},
			alignment = {x = 0, y = -1},
			z_index = 101,
		})
        local hud_announce
        if awdef.secret == true then
	        hud_announce = core.colorize("#ff0000", S("Hidden Advancement Unlocked!"))
        elseif awdef.type == "Goal" then
            hud_announce = core.colorize("#ffff00", S("Goal Reached!"))
        elseif awdef.type == "Challenge" then
            hud_announce = core.colorize("#fc86fc", S("Challenge Complete!"))
        else
            hud_announce = core.colorize("#ffff00", S("Advancement Made!"))
        end
		local two = player:hud_add({
			type = "text",
			name = "award_au",
			number = 0xFFFFFF,
			scale = {x = 100, y = 20},
			text = hud_announce,
			position = {x = 0.5, y = 0.05},
			offset = {x = 0, y = 45},
			alignment = {x = 0, y = -1},
			z_index = 102,
		})
		local three = player:hud_add({
			type = "text",
			name = "award_title",
			number = 0xFFFFFF,
			scale = {x = 100, y = 20},
			text = title,
			position = {x = 0.5, y = 0.05},
			offset = {x = 0, y = 100},
			alignment = {x = 0, y = -1},
			z_index = 103,
		})
		local four = player:hud_add({
			type = "image",
			name = "award_icon",
			scale = {x = 2, y = 2}, -- adjusted for 32x32 from x/y = 4
			text = icon,
			position = {x = 0.5, y = 0.05},
			offset = {x = -200.5, y = 126},
			alignment = {x = 0, y = -1},
			z_index = 104,
		})
		core.after(4, function()
			local player2 = core.get_player_by_name(name)
			if player2 then
				player2:hud_remove(one)
				player2:hud_remove(two)
				player2:hud_remove(three)
				player2:hud_remove(four)
			end
		end)
	end
end

function awards.remove(name, award)
	local data  = awards.player(name)
	local awdef = awards.registered_awards[award]
	assert(awdef, "Unable to remove an award which doesn't exist!")

	if data.disabled or
			(not data.unlocked[award]) then
		return
	end

	core.log("action", "Award " .. award .." has been removed from ".. name)
	data.unlocked[award] = nil
	awards.save()
end

function awards.get_award_states(name)
	local hash_is_unlocked = {}
	local retval = {}

	-- Add all unlocked awards
	local data = awards.player(name)
	if data and data.unlocked then
		for awardname, _ in pairs(data.unlocked) do
			local def = awards.registered_awards[awardname]
			if def then
				hash_is_unlocked[awardname] = true
				local score = -100000

				local difficulty = def.difficulty or 1
				if def.trigger and def.trigger.target then
					difficulty = difficulty * def.trigger.target
				end
				score = score + difficulty

				retval[#retval + 1] = {
					name     = awardname,
					def      = def,
					unlocked = true,
					started  = true,
					score    = score,
					progress = nil,
				}
			end
		end
	end

	-- Add all locked awards
	for _, def in pairs(awards.registered_awards) do
		if not hash_is_unlocked[def.name] and def:can_unlock(data) then
			local progress = def.get_progress and def:get_progress(data)
			local started = false
			local score = def.difficulty or 1
			if def.secret then
				score = 1000000
			elseif def.trigger and def.trigger.target and progress then
				local perc = progress.current / progress.target
				score = score * (1 - perc) * def.trigger.target
				if perc < 0.001 then
					score = score + 100
				else
					started = true
				end
			else
				score = 100
			end

			retval[#retval + 1] = {
				name     = def.name,
				def      = def,
				unlocked = false,
				started  = started,
				score    = score,
				progress = progress,
			}
		end
	end

	table.sort(retval, function(a, b)
		return a.score < b.score
	end)
	return retval
end
