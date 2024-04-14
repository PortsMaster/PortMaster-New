-- Copyright (c) 2013-18 rubenwardy. MIT.

local S = awards.translator

function awards.get_formspec(name, to, sid)
	local formspec = ""
	local awards_list = awards.get_award_states(name)

	if #awards_list == 0 then
		formspec = formspec .. "label[3.9,1.5;"..minetest.formspec_escape(S("Error: No achivements available.")).."]"
		formspec = formspec .. "button_exit[4.2,2.3;3,1;close;"..minetest.formspec_escape(S("OK")).."]"
		return formspec
	end
	sid = awards_list[sid] and sid or 1

	-- Sidebar
	local sitem = awards_list[sid]
	local sdef = sitem.def
	if sdef and sdef.secret and not sitem.unlocked then
		formspec = formspec .. "label[1,2.75;"..
				minetest.formspec_escape(S("(Secret Award)")).."]"..
				"image[1,0;3,3;awards_unknown.png]"
		if sdef and sdef.description then
			formspec = formspec	.. "textarea[0.25,3.25;4.8,1.7;;"..
					minetest.formspec_escape(
							S("Unlock this award to find out what it is."))..";]"
		end
	else
		local title = sitem.name
		if sdef and sdef.title then
			title = sdef.title
		end
		local status = "@1"
		if sitem.unlocked then
			-- Don't actually use translator here. We define empty S() to fool the update_translations script
			-- into extracting that string for the templates.
			local function S(str)
				return str
			end
			status = S("@1 (unlocked)")
		end

		formspec = formspec .. "textarea[0.5,3.1;4.8,1.45;;" ..
			S(status, minetest.formspec_escape(title)) ..
			";]"

		if sdef and sdef.icon then
			formspec = formspec .. "image[0.45,0;3.5,3.5;" .. sdef.icon .. "]"  -- adjusted values from 0.6,0;3,3
		end

		if sitem.progress then
			local barwidth = 3.95
			local perc = sitem.progress.current / sitem.progress.target
			local label = sitem.progress.label
			if perc > 1 then
				perc = 1
			end
			formspec = formspec .. "background[0,8.24;" .. barwidth ..",0.4;awards_progress_gray.png;false]"
			formspec = formspec .. "background[0,8.24;" .. (barwidth * perc) ..",0.4;awards_progress_green.png;false]"
			if label then
				formspec = formspec .. "label[1.6,8.15;" .. minetest.formspec_escape(label) .. "]"
			end
		end

		if sdef and sdef.description then
			formspec = formspec .. "box[-0.05,3.75;3.9,4.2;#000]"
			formspec = formspec	.. "textarea[0.25,3.75;3.9,4.2;;" ..
					minetest.formspec_escape(sdef.description) .. ";]"
		end
	end

	-- Create list box
	formspec = formspec .. "textlist[4,0;3.8,8.6;awards;"
	local first = true
	for _, award in pairs(awards_list) do
		local def = award.def
		if def then
			if not first then
				formspec = formspec .. ","
			end
			first = false

			if def.secret and not award.unlocked then
				formspec = formspec .. "#707070"..minetest.formspec_escape(S("(Secret Award)"))
			else
				local title = award.name
				if def and def.title then
					title = def.title
				end
				-- title = title .. " [" .. award.score .. "]"
				if award.unlocked then
					formspec = formspec .. minetest.formspec_escape(title)
				elseif award.started then
					formspec = formspec .. "#c0c0c0".. minetest.formspec_escape(title)
				else
					formspec = formspec .. "#a0a0a0".. minetest.formspec_escape(title)
				end
			end
		end
	end
	return formspec .. ";"..sid.."]"
end


function awards.show_to(name, to, sid, text)
	if name == "" or name == nil then
		name = to
	end
	local data = awards.player(to)
	if name == to and data.disabled then
		minetest.chat_send_player(name, S("You've disabled awards. Type /awards enable to reenable."))
		return
	end
	if text then
		local awards_list = awards.get_award_states(name)
		if #awards_list == 0 then
			minetest.chat_send_player(to, S("Error: No award available."))
			return
		elseif not data or not data.unlocked  then
			minetest.chat_send_player(to, S("You have not unlocked any awards."))
			return
		end
		minetest.chat_send_player(to, string.format(S("%s’s awards:"), name))

		for str, _ in pairs(data.unlocked) do
			local def = awards.registered_awards[str]
			if def then
				if def.title then
					if def.description then
						minetest.chat_send_player(to, string.format("%s: %s", def.title, def.description))
					else
						minetest.chat_send_player(to, def.title)
					end
				else
					minetest.chat_send_player(to, str)
				end
			end
		end
	else

		-- Show formspec to user
		minetest.show_formspec(to,"awards:awards",
			"size[8,8.6]" ..
			awards.get_formspec(name, to, sid))
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "awards:awards" then
		return false
	end
	if fields.quit then
		return true
	end
	local name = player:get_player_name()
	if fields.awards then
		local event = minetest.explode_textlist_event(fields.awards)
		if event.type == "CHG" then
			awards.show_to(name, name, event.index, false)
		end
	end

	return true
end)
