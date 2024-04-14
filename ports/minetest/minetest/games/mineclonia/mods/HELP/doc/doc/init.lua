local S = minetest.get_translator("doc")
local F = function(f) return minetest.formspec_escape(S(f)) end

-- Compability for 0.4.14 or earlier
local colorize
if minetest.colorize then
	colorize = minetest.colorize
else
	colorize = function(color, text) return text end
end

doc = {}

-- Some informational variables
-- DO NOT CHANGE THEM AFTERWARDS AT RUNTIME!

-- Version number (follows the SemVer specification 2.0.0)
doc.VERSION = {}
doc.VERSION.MAJOR = 1
doc.VERSION.MINOR = 2
doc.VERSION.PATCH = 1
doc.VERSION.STRING = doc.VERSION.MAJOR.."."..doc.VERSION.MINOR.."."..doc.VERSION.PATCH

-- Formspec information
doc.FORMSPEC = {}
-- Width of formspec
doc.FORMSPEC.WIDTH = 15
doc.FORMSPEC.HEIGHT = 10.5

--[[ Recommended bounding box coordinates for widgets to be placed in entry pages. Make sure
all entry widgets are completely inside these coordinates to avoid overlapping. ]]
doc.FORMSPEC.ENTRY_START_X = 0
doc.FORMSPEC.ENTRY_START_Y = 0.5
doc.FORMSPEC.ENTRY_END_X = doc.FORMSPEC.WIDTH
doc.FORMSPEC.ENTRY_END_Y = doc.FORMSPEC.HEIGHT - 0.5
doc.FORMSPEC.ENTRY_WIDTH = doc.FORMSPEC.ENTRY_END_X - doc.FORMSPEC.ENTRY_START_X
doc.FORMSPEC.ENTRY_HEIGHT = doc.FORMSPEC.ENTRY_END_Y - doc.FORMSPEC.ENTRY_START_Y

--TODO: Use container formspec element later

-- Internal helper variables
local DOC_INTRO = S("This is the help.")

local COLOR_NOT_VIEWED = "#00FFFF"	-- cyan
local COLOR_VIEWED = "#FFFFFF"		-- white
local COLOR_HIDDEN = "#999999"		-- gray
local COLOR_ERROR = "#FF0000"		-- red

local CATEGORYFIELDSIZE = {
	WIDTH = math.ceil(doc.FORMSPEC.WIDTH / 4),
	HEIGHT = math.floor(doc.FORMSPEC.HEIGHT-1),
}

doc.data = {}
doc.data.categories = {}
doc.data.aliases = {}
-- Default order (includes categories of other mods from the Docuentation System modpack)
doc.data.category_order = {"basics", "nodes", "tools", "craftitems", "advanced"}
doc.data.category_count = 0
doc.data.players = {}

-- Space for additional APIs
doc.sub = {}

-- Status variables
local set_category_order_was_called = false

-- Returns the entry definition and true entry ID of an entry, taking aliases into account
local function get_entry(category_id, entry_id)
	local category = doc.data.categories[category_id]
	local entry
	if category ~= nil then
		entry = category.entries[entry_id]
	end
	if category == nil or entry == nil then
		local c_alias = doc.data.aliases[category_id]
		if c_alias then
			local alias = c_alias[entry_id]
			if alias then
				category_id = alias.category_id
				entry_id = alias.entry_id
				category = doc.data.categories[category_id]
				if category then
					entry = category.entries[entry_id]
				else
					return nil
				end
			else
				return nil
			end
		else
			return nil
		end
	end
	return entry, category_id, entry_id
end

--[[ Core API functions ]]

-- Add a new category
function doc.add_category(id, def)
	if doc.data.categories[id] == nil and id ~= nil then
		doc.data.categories[id] = {}
		doc.data.categories[id].entries = {}
		doc.data.categories[id].entry_count = 0
		doc.data.categories[id].hidden_count = 0
		doc.data.categories[id].def = def
		-- Determine order position
		local order_id = nil
		for i=1,#doc.data.category_order do
			if doc.data.category_order[i] == id then
				order_id = i
				break
			end
		end
		if order_id == nil then
			table.insert(doc.data.category_order, id)
			doc.data.categories[id].order_position = #doc.data.category_order
		else
			doc.data.categories[id].order_position = order_id
		end
		doc.data.category_count = doc.data.category_count + 1
		return true
	else
		return false
	end
end

-- Add a new entry
function doc.add_entry(category_id, entry_id, def)
	local cat = doc.data.categories[category_id]
	if cat ~= nil then
		local hidden = def.hidden or (def.hidden == nil and cat.def.hide_entries_by_default)
		if hidden then
			cat.hidden_count = cat.hidden_count + 1
			def.hidden = hidden
		end
		cat.entry_count = doc.data.categories[category_id].entry_count + 1
		if def.name == nil or def.name == "" then
			minetest.log("warning", "[doc] Nameless entry added. Entry ID: "..entry_id)
		end
		cat.entries[entry_id] = def
		return true
	else
		return false
	end
end

-- Marks a particular entry as viewed by a certain player, which also
-- automatically reveals it
function doc.mark_entry_as_viewed(playername, category_id, entry_id)
	local entry, category_id, entry_id = get_entry(category_id, entry_id)
	if not entry then
		return
	end
	if doc.data.players[playername].stored_data.viewed[category_id] == nil then
		doc.data.players[playername].stored_data.viewed[category_id] = {}
		doc.data.players[playername].stored_data.viewed_count[category_id] = 0
	end
	if doc.entry_exists(category_id, entry_id) and doc.data.players[playername].stored_data.viewed[category_id][entry_id] ~= true then
		doc.data.players[playername].stored_data.viewed[category_id][entry_id] = true
		doc.data.players[playername].stored_data.viewed_count[category_id] = doc.data.players[playername].stored_data.viewed_count[category_id] + 1
		-- Needed because viewed entries get a different color
		doc.data.players[playername].entry_textlist_needs_updating = true
	end
	doc.mark_entry_as_revealed(playername, category_id, entry_id)
end

-- Marks a particular entry as revealed/unhidden by a certain player
function doc.mark_entry_as_revealed(playername, category_id, entry_id)
	local entry, category_id, entry_id = get_entry(category_id, entry_id)
	if not entry then
		return
	end
	if doc.data.players[playername].stored_data.revealed[category_id] == nil then
		doc.data.players[playername].stored_data.revealed[category_id] = {}
		doc.data.players[playername].stored_data.revealed_count[category_id] = doc.get_entry_count(category_id) - doc.data.categories[category_id].hidden_count
	end
	if doc.entry_exists(category_id, entry_id) and entry.hidden and doc.data.players[playername].stored_data.revealed[category_id][entry_id] ~= true then
		doc.data.players[playername].stored_data.revealed[category_id][entry_id] = true
		doc.data.players[playername].stored_data.revealed_count[category_id] = doc.data.players[playername].stored_data.revealed_count[category_id] + 1
		-- Needed because a new entry is added to the list of visible entries
		doc.data.players[playername].entry_textlist_needs_updating = true
		-- Notify player of entry revelation
		if doc.data.players[playername].stored_data.notify_on_reveal == true then
			if minetest.get_modpath("central_message") ~= nil then
				local cat = doc.data.categories[category_id]
				cmsg.push_message_player(minetest.get_player_by_name(playername), S("New help entry unlocked: @1 > @2", cat.def.name, entry.name))
			end
			-- To avoid sound spamming, don't play sound more than once per second
			local last_sound = doc.data.players[playername].last_reveal_sound
			if last_sound == nil or os.difftime(os.time(), last_sound) >= 1 then
				-- Play notification sound
				minetest.sound_play({ name = "doc_reveal", gain = 0.2 }, { to_player = playername }, true)
				doc.data.players[playername].last_reveal_sound = os.time()
			end
		end
	end
end

-- Reveal
function doc.mark_all_entries_as_revealed(playername)
	-- Has at least 1 new entry been revealed?
	local reveal1 = false
	for category_id, category in pairs(doc.data.categories) do
		if doc.data.players[playername].stored_data.revealed[category_id] == nil then
			doc.data.players[playername].stored_data.revealed[category_id] = {}
			doc.data.players[playername].stored_data.revealed_count[category_id] = doc.get_entry_count(category_id) - doc.data.categories[category_id].hidden_count
		end
		for entry_id, _ in pairs(category.entries) do
			if doc.data.players[playername].stored_data.revealed[category_id][entry_id] ~= true then
				doc.data.players[playername].stored_data.revealed[category_id][entry_id] = true
				doc.data.players[playername].stored_data.revealed_count[category_id] = doc.data.players[playername].stored_data.revealed_count[category_id] + 1
				reveal1 = true
			end
		end
	end

	local msg
	if reveal1 then
		-- Needed because new entries are added to player's view on entry list
		doc.data.players[playername].entry_textlist_needs_updating = true

		msg = S("All help entries revealed!")

		-- Play notification sound (ignore sound limit intentionally)
		minetest.sound_play({ name = "doc_reveal", gain = 0.2 }, { to_player = playername }, true)
		doc.data.players[playername].last_reveal_sound = os.time()
	else
		msg = S("All help entries are already revealed.")
	end
	-- Notify
	if minetest.get_modpath("central_message") ~= nil then
		cmsg.push_message_player(minetest.get_player_by_name(playername), msg)
	else
		minetest.chat_send_player(playername, msg)
	end
end

-- Returns true if the specified entry has been viewed by the player
function doc.entry_viewed(playername, category_id, entry_id)
	local _, category_id, entry_id = get_entry(category_id, entry_id)
	if doc.data.players[playername].stored_data.viewed[category_id] == nil then
		return false
	else
		return doc.data.players[playername].stored_data.viewed[category_id][entry_id] == true
	end
end

-- Returns true if the specified entry is hidden from the player
function doc.entry_revealed(playername, category_id, entry_id)
	local _, category_id, entry_id = get_entry(category_id, entry_id)
	local hidden = doc.data.categories[category_id].entries[entry_id].hidden
	if doc.data.players[playername].stored_data.revealed[category_id] == nil then
		return not hidden
	else
		if hidden then
			return doc.data.players[playername].stored_data.revealed[category_id][entry_id] == true
		else
			return true
		end
	end
end

-- Returns category definition
function doc.get_category_definition(category_id)
	if doc.data.categories[category_id] == nil then
		return nil
	end
	return doc.data.categories[category_id].def
end

-- Returns entry definition
function doc.get_entry_definition(category_id, entry_id)
	if not doc.entry_exists(category_id, entry_id) then
		return nil
	end
	local entry, _, _  = get_entry(category_id, entry_id)
	return entry
end

-- Opens the main documentation formspec for the player
function doc.show_doc(playername)
	if doc.get_category_count() <= 0 then
		minetest.show_formspec(playername, "doc:error_no_categories", doc.formspec_error_no_categories())
		return
	end
	local formspec = doc.formspec_core()..doc.formspec_main(playername)
	minetest.show_formspec(playername, "doc:main", formspec)
end

-- Opens the documentation formspec for the player at the specified category
function doc.show_category(playername, category_id)
	if doc.get_category_count() <= 0 then
		minetest.show_formspec(playername, "doc:error_no_categories", doc.formspec_error_no_categories())
		return
	end
	doc.data.players[playername].catsel = nil
	doc.data.players[playername].category = category_id
	doc.data.players[playername].entry = nil
	local formspec = doc.formspec_core(2)..doc.formspec_category(category_id, playername)
	minetest.show_formspec(playername, "doc:category", formspec)
end

-- Opens the documentation formspec for the player showing the specified entry in a category
function doc.show_entry(playername, category_id, entry_id, ignore_hidden)
	if doc.get_category_count() <= 0 then
		minetest.show_formspec(playername, "doc:error_no_categories", doc.formspec_error_no_categories())
		return
	end
	local _, category_id, entry_id = get_entry(category_id, entry_id)
	if ignore_hidden or doc.entry_revealed(playername, category_id, entry_id) then
		local playerdata = doc.data.players[playername]
		playerdata.category = category_id
		playerdata.entry = entry_id

		doc.mark_entry_as_viewed(playername, category_id, entry_id)
		playerdata.entry_textlist_needs_updating = true
		doc.generate_entry_list(category_id, playername)

		playerdata.catsel = playerdata.catsel_list[entry_id]
		playerdata.galidx = 1

		local formspec = doc.formspec_core(3)..doc.formspec_entry(category_id, entry_id, playername)
		minetest.show_formspec(playername, "doc:entry", formspec)
	else
		minetest.show_formspec(playername, "doc:error_hidden", doc.formspec_error_hidden(category_id, entry_id))
	end
end

-- Returns true if and only if:
-- * The specified category exists
-- * This category contains the specified entry
-- Aliases are taken into account
function doc.entry_exists(category_id, entry_id)
	return get_entry(category_id, entry_id) ~= nil
end

-- Sets the order of categories in the category list
function doc.set_category_order(categories)
	local reverse_categories = {}
	for cid=1,#categories do
		reverse_categories[categories[cid]] = cid
	end
	doc.data.category_order = categories
	for cid, cat in pairs(doc.data.categories) do
		if reverse_categories[cid] == nil then
			table.insert(doc.data.category_order, cid)
		end
	end
	reverse_categories = {}
	for cid=1, #doc.data.category_order do
		reverse_categories[categories[cid]] = cid
	end

	for cid, cat in pairs(doc.data.categories) do
		cat.order_position = reverse_categories[cid]
	end
	if set_category_order_was_called then
		minetest.log("warning", "[doc] doc.set_category_order was called again!")
	end
	set_category_order_was_called = true
end

-- Adds an alias for an entry. Attempting to open an entry by an alias name
-- results in opening the entry of the original name.
function doc.add_entry_alias(category_id_orig, entry_id_orig, category_id_alias, entry_id_alias)
	if not doc.data.aliases[category_id_alias] then
		doc.data.aliases[category_id_alias] = {}
	end
	doc.data.aliases[category_id_alias][entry_id_alias] = { category_id = category_id_orig, entry_id = entry_id_orig }
end

-- Returns number of categories
function doc.get_category_count()
	return doc.data.category_count
end

-- Returns number of entries in category
function doc.get_entry_count(category_id)
	return doc.data.categories[category_id].entry_count
end

-- Returns how many entries have been viewed by the player
function doc.get_viewed_count(playername, category_id)
	local playerdata = doc.data.players[playername]
	if playerdata == nil then
		return nil
	end
	local count = playerdata.stored_data.viewed_count[category_id]
	if count == nil then
		playerdata.stored_data.viewed[category_id] = {}
		count = 0
		playerdata.stored_data.viewed_count[category_id] = count
		return count
	else
		return count
	end
end

-- Returns how many entries have been revealed by the player
function doc.get_revealed_count(playername, category_id)
	local playerdata = doc.data.players[playername]
	if playerdata == nil then
		return nil
	end
	local count = playerdata.stored_data.revealed_count[category_id]
	if count == nil then
		playerdata.stored_data.revealed[category_id] = {}
		count = doc.get_entry_count(category_id) - doc.data.categories[category_id].hidden_count
		playerdata.stored_data.revealed_count[category_id] = count
		return count
	else
		return count
	end
end

-- Returns how many entries are hidden from the player
function doc.get_hidden_count(playername, category_id)
	local playerdata = doc.data.players[playername]
	if playerdata == nil then
		return nil
	end
	local total = doc.get_entry_count(category_id)
	local rcount = playerdata.stored_data.revealed_count[category_id]
	if rcount == nil then
		return total
	else
		return total - rcount
	end
end

-- Returns the currently viewed entry and/or category of the player
function doc.get_selection(playername)
	local playerdata = doc.data.players[playername]
	if playerdata ~= nil then
		local cat = playerdata.category
		if cat then
			local entry = playerdata.entry
			if entry then
				return cat, entry
			else
				return cat
			end
		else
			return nil
		end
	else
		return nil
	end
end

-- Template function templates, to be used for build_formspec in doc.add_category
doc.entry_builders = {}

-- Scrollable freeform text
doc.entry_builders.text = function(data)
	local formstring = doc.widgets.text(data, doc.FORMSPEC.ENTRY_START_X, doc.FORMSPEC.ENTRY_START_Y, doc.FORMSPEC.ENTRY_WIDTH - 0.4, doc.FORMSPEC.ENTRY_HEIGHT)
	return formstring
end

-- Scrollable freeform text with an optional standard gallery (3 rows, 3:2 aspect ratio)
doc.entry_builders.text_and_gallery = function(data, playername)
	-- How much height the image gallery “steals” from the text widget
	local stolen_height = 0
	local formstring = ""
	-- Only add the gallery if images are in the data, otherwise, the text widget gets all of the space
	if data.images ~= nil then
		local gallery
		gallery, stolen_height = doc.widgets.gallery(data.images, playername, nil, doc.FORMSPEC.ENTRY_END_Y + 0.2, nil, nil, nil, nil, false)
		formstring = formstring .. gallery
	end
	formstring = formstring .. doc.widgets.text(data.text,
		doc.FORMSPEC.ENTRY_START_X,
		doc.FORMSPEC.ENTRY_START_Y,
		doc.FORMSPEC.ENTRY_WIDTH - 0.4,
		doc.FORMSPEC.ENTRY_HEIGHT - stolen_height)

	return formstring
end

doc.widgets = {}

-- Scrollable freeform text
doc.widgets.text = function(data, x, y, width, height)
	if x == nil then
		x = doc.FORMSPEC.ENTRY_START_X
	end
	-- Offset to table[], which was used for this in a previous version
	local xfix = x + 0.35
	if y == nil then
		y = doc.FORMSPEC.ENTRY_START_Y
	end
	if width == nil then
		width = doc.FORMSPEC.ENTRY_WIDTH
	end
	if height == nil then
		height = doc.FORMSPEC.ENTRY_HEIGHT
	end
	-- Weird offset for textarea[]
	local heightfix = height + 1

	-- Also add background box
	local formstring = "box["..tostring(x-0.175)..","..tostring(y)..";"..tostring(width)..","..tostring(height)..";#000000]" ..
			"textarea["..tostring(xfix)..","..tostring(y)..";"..tostring(width)..","..tostring(heightfix)..";;;"..minetest.formspec_escape(data).."]"
	return formstring
end

-- Image gallery
-- Currently, only one gallery per entry is supported. TODO: Add support for multiple galleries in an entry (low priority)
doc.widgets.gallery = function(imagedata, playername, x, y, aspect_ratio, width, rows, align_left, align_top)
	if playername == nil then return nil end -- emergency exit

	local formstring = ""

	-- Defaults
	if x == nil then
		if align_left == false then
			x = doc.FORMSPEC.ENTRY_END_X
		else
			x = doc.FORMSPEC.ENTRY_START_X
		end
	end
	if y == nil then
		if align_top == false then
			y = doc.FORMSPEC.ENTRY_END_Y
		else
			y = doc.FORMSPEC.ENTRY_START_Y
		end
	end
	if width == nil then width = doc.FORMSPEC.ENTRY_WIDTH end
	if rows == nil then rows = 3 end

	if align_left == false then
		x = x - width
	end

	local imageindex = doc.data.players[playername].galidx
	doc.data.players[playername].maxgalidx = #imagedata
	doc.data.players[playername].galrows = rows

	if aspect_ratio == nil then aspect_ratio = (2/3) end
	local pos = 0
	local totalimagewidth, iw, ih
	local bw = 0.5
	local buttonoffset = 0
	if #imagedata > rows then
		totalimagewidth = width - bw*2
		iw = totalimagewidth / rows
		ih = iw * aspect_ratio
		if align_top == false then
			y = y - ih
		end

		local tt
		if imageindex > 1 then
			formstring = formstring .. "button["..x..","..y..";"..bw..","..ih..";doc_button_gallery_prev;"..F("<").."]"
			if rows == 1 then
				tt = F("Show previous image")
			else
				tt = F("Show previous gallery page")
			end
			formstring = formstring .. "tooltip[doc_button_gallery_prev;"..tt.."]"
		end
		if (imageindex + rows) <= #imagedata then
			local rightx = buttonoffset + (x + rows * iw)
			formstring = formstring .. "button["..rightx..","..y..";"..bw..","..ih..";doc_button_gallery_next;"..F(">").."]"
			if rows == 1 then
				tt = F("Show next image")
			else
				tt = F("Show next gallery page")
			end
			formstring = formstring .. "tooltip[doc_button_gallery_next;"..tt.."]"
		end
		buttonoffset = bw
	else
		totalimagewidth = width
		iw = totalimagewidth / rows
		ih = iw * aspect_ratio
		if align_top == false then
			y = y - ih
		end
	end
	for i=imageindex, math.min(#imagedata, (imageindex-1)+rows) do
		local xoffset = buttonoffset + (x + pos * iw)
		local nx = xoffset - 0.2
		local ny = y - 0.05
		if imagedata[i].imagetype == "item" then
			formstring = formstring .. "item_image["..xoffset..","..y..";"..iw..","..ih..";"..imagedata[i].image.."]"
		else
			formstring = formstring .. "image["..xoffset..","..y..";"..iw..","..ih..";"..imagedata[i].image.."]"
		end
		formstring = formstring .. "label["..nx..","..ny..";"..i.."]"
		pos = pos + 1
	end

	return formstring, ih
end

-- Direct formspec
doc.entry_builders.formspec = function(data)
	return data
end

--[[ Internal stuff ]]

-- Loading and saving player data
do
	local filepath = minetest.get_worldpath().."/doc.mt"
	local file = io.open(filepath, "r")
	if file then
		minetest.log("action", "[doc] doc.mt opened.")
		local string = file:read()
		io.close(file)
		if(string ~= nil) then
			local savetable = minetest.deserialize(string)
			for name, players_stored_data in pairs(savetable.players_stored_data) do
				doc.data.players[name] = {}
				doc.data.players[name].stored_data = players_stored_data
			end
			minetest.log("action", "[doc] doc.mt successfully read.")
		end
	end
end

function doc.save_to_file()
	local savetable = {}
	savetable.players_stored_data = {}
	for name, playerdata in pairs(doc.data.players) do
		savetable.players_stored_data[name] = playerdata.stored_data
	end

	local savestring = minetest.serialize(savetable)

	local filepath = minetest.get_worldpath().."/doc.mt"
	local file = io.open(filepath, "w")
	if file then
		file:write(savestring)
		io.close(file)
		minetest.log("action", "[doc] Wrote player data into "..filepath..".")
	else
		minetest.log("error", "[doc] Failed to write player data into "..filepath..".")
	end
end

minetest.register_on_leaveplayer(function(player)
	doc.save_to_file()
end)

minetest.register_on_shutdown(function()
	minetest.log("action", "[doc] Server shuts down. Player data is about to be saved.")
	doc.save_to_file()
end)

--[[ Functions for internal use ]]

function doc.formspec_core(tab)
	if tab == nil then tab = 1 else tab = tostring(tab) end
	return "size["..doc.FORMSPEC.WIDTH..","..doc.FORMSPEC.HEIGHT.."]"..
	"tabheader[0,0;doc_header;"..
	minetest.formspec_escape(S("Category list")) .. "," ..
	minetest.formspec_escape(S("Entry list")) .. "," ..
	minetest.formspec_escape(S("Entry")) .. ";"
	..tab..";false;false]"
	-- Let the Game decide on the style, such as background, etc.
end

function doc.formspec_main(playername)
	local formstring = "textarea[0.35,0;"..doc.FORMSPEC.WIDTH..",1;;;"..minetest.formspec_escape(DOC_INTRO) .. "\n"
	local notify_checkbox_x, notify_checkbox_y
	if doc.get_category_count() >= 1 then
		formstring = formstring .. F("Please select a category you wish to learn more about:").."]"
		if doc.get_category_count() <= (CATEGORYFIELDSIZE.WIDTH * CATEGORYFIELDSIZE.HEIGHT)  then
			local y = 1
			local x = 1
			-- Show all categories in order
			for c=1,#doc.data.category_order do
				local id = doc.data.category_order[c]
				local data = doc.data.categories[id]
				local bw = doc.FORMSPEC.WIDTH / math.floor(((doc.data.category_count-1) / CATEGORYFIELDSIZE.HEIGHT)+1)
				-- Skip categories which do not exist
				if data ~= nil then
					-- Category buton
					local button = "button["..((x-1)*bw)..","..y..";"..bw..",1;doc_button_category_"..id..";"..minetest.formspec_escape(data.def.name).."]"
					local tooltip = ""
					-- Optional description
					if data.def.description ~= nil then
					tooltip = "tooltip[doc_button_category_"..id..";"..minetest.formspec_escape(data.def.description).."]"
					end
					formstring = formstring .. button .. tooltip
					y = y + 1
					if y > CATEGORYFIELDSIZE.HEIGHT then
						x = x + 1
						y = 1
					end
				end
			end
			notify_checkbox_x = 0
			notify_checkbox_y = doc.FORMSPEC.HEIGHT-0.5
		else
			formstring = formstring .. "textlist[0,1;"..(doc.FORMSPEC.WIDTH-0.2)..","..(doc.FORMSPEC.HEIGHT-2)..";doc_mainlist;"
			for c=1,#doc.data.category_order do
				local id = doc.data.category_order[c]
				local data = doc.data.categories[id]
				formstring = formstring .. minetest.formspec_escape(data.def.name)
				if c < #doc.data.category_order then
					formstring = formstring .. ","
				end
			end
			local sel = doc.data.categories[doc.data.players[playername].category]
			if sel ~= nil then
				formstring = formstring .. ";"
				formstring = formstring .. doc.data.categories[doc.data.players[playername].category].order_position
			end
			formstring = formstring .. "]"
			formstring = formstring .. "button[0,"..(doc.FORMSPEC.HEIGHT-1)..";3,1;doc_button_goto_category;"..F("Show category").."]"
			notify_checkbox_x = 3.5
			notify_checkbox_y = doc.FORMSPEC.HEIGHT-1
		end
		local text
		if minetest.get_modpath("central_message") then
			text = F("Notify me when new help is available")
		else
			text = F("Play notification sound when new help is available")
		end
		formstring = formstring .. "checkbox["..notify_checkbox_x..","..notify_checkbox_y..";doc_setting_notify_on_reveal;"..text..";"..
		tostring(doc.data.players[playername].stored_data.notify_on_reveal == true) .. "]"
	else
		formstring = formstring .. "]"
	end
	return formstring
end

function doc.formspec_error_no_categories()
	local formstring = "size[8,6]textarea[0.25,0;8,6;;"
	formstring = formstring ..
	minetest.formspec_escape(
		colorize(COLOR_ERROR, S("Error: No help available.")) .. "\n\n" ..
S("No categories have been registered, but they are required to provide help.").."\n"..
S("The Documentation System [doc] does not come with help contents on its own, it needs additional mods to add help content. Please make sure such mods are enabled on for this world, and try again.")) .. "\n\n" ..
S("Recommended mods: doc_basics, doc_items, doc_identifier, doc_encyclopedia.")
	formstring = formstring .. ";]button_exit[3,5;2,1;okay;"..F("OK").."]"
	return formstring
end

function doc.formspec_error_hidden(category_id, entry_id)
	local formstring = "size[8,6]textarea[0.25,0;8,6;;"
	formstring = formstring .. minetest.formspec_escape(
	colorize(COLOR_ERROR, S("Error: Access denied.")) .. "\n\n" ..
	S("Access to the requested entry has been denied; this entry is secret. You may unlock access by progressing in the game. Figure out on your own how to unlock this entry."))
	formstring = formstring .. ";]button_exit[3,5;2,1;okay;"..F("OK").."]"
	return formstring
end

function doc.generate_entry_list(cid, playername)
	local formstring
	if doc.data.players[playername].entry_textlist == nil
	or doc.data.players[playername].catsel_list == nil
	or doc.data.players[playername].category ~= cid
	or doc.data.players[playername].entry_textlist_needs_updating == true then
		local entry_textlist = "textlist[0,1;"..(doc.FORMSPEC.WIDTH-0.2)..","..(doc.FORMSPEC.HEIGHT-2)..";doc_catlist;"
		local counter = 0
		doc.data.players[playername].entry_ids = {}
		local entries = doc.get_sorted_entry_names(cid)
		doc.data.players[playername].catsel_list = {}
		for i=1, #entries do
			local eid = entries[i]
			local edata = doc.data.categories[cid].entries[eid]
			if doc.entry_revealed(playername, cid, eid) then
				table.insert(doc.data.players[playername].entry_ids, eid)
				doc.data.players[playername].catsel_list[eid] = counter + 1
				-- Colorize entries based on viewed status
				local viewedprefix = COLOR_NOT_VIEWED
				local name = edata.name
				if name == nil or name == "" then
					name = S("Nameless entry (@1)", eid)
					if doc.entry_viewed(playername, cid, eid) then
						viewedprefix = "#FF4444"
					else
						viewedprefix = COLOR_ERROR
					end
				elseif doc.entry_viewed(playername, cid, eid) then
					viewedprefix = COLOR_VIEWED
				end
				entry_textlist = entry_textlist .. viewedprefix .. minetest.formspec_escape(name) .. ","
				counter = counter + 1
			end
		end
		if counter >= 1  then
			entry_textlist = string.sub(entry_textlist, 1, #entry_textlist-1)
		end
		local catsel = doc.data.players[playername].catsel
		if catsel then
			entry_textlist = entry_textlist .. ";"..catsel
		end
		entry_textlist = entry_textlist .. "]"
		doc.data.players[playername].entry_textlist = entry_textlist
		formstring = entry_textlist
		doc.data.players[playername].entry_textlist_needs_updating = false
	else
		formstring = doc.data.players[playername].entry_textlist
	end
	return formstring
end

function doc.get_sorted_entry_names(cid)
	local sort_table = {}
	local entry_table = {}
	local cat = doc.data.categories[cid]
	local used_eids = {}
	-- Helper function to extract the entry ID out of the output table
	local extract = function(entry_table)
		local eids = {}
		for k,v in pairs(entry_table) do
			local eid = v.eid
			table.insert(eids, eid)
		end
		return eids
	end
	-- Predefined sorting
	if cat.def.sorting == "custom" then
		for i=1,#cat.def.sorting_data do
			local new_entry = table.copy(cat.entries[cat.def.sorting_data[i]])
			new_entry.eid = cat.def.sorting_data[i]
			table.insert(entry_table, new_entry)
			used_eids[cat.def.sorting_data[i]] = true
		end
	end
	for eid,entry in pairs(cat.entries) do
		local new_entry = table.copy(entry)
		new_entry.eid = eid
		if not used_eids[eid] then
			table.insert(entry_table, new_entry)
		end
		table.insert(sort_table, entry.name)
	end
	if cat.def.sorting == "custom" then
		return extract(entry_table)
	else
		table.sort(sort_table)
	end
	local reverse_sort_table = table.copy(sort_table)
	for i=1, #sort_table do
		reverse_sort_table[sort_table[i]] = i
	end
	local comp
	if cat.def.sorting ~= "nosort" then
		-- Sorting by user function
		if cat.def.sorting == "function" then
			comp = cat.def.sorting_data
		-- Alphabetic sorting
		elseif cat.def.sorting == "abc" or cat.def.sorting == nil then
			comp = function(e1, e2)
				if reverse_sort_table[e1.name] < reverse_sort_table[e2.name] then return true else return false end
			end
		end
		table.sort(entry_table, comp)
	end

	return extract(entry_table)
end

function doc.formspec_category(id, playername)
	local formstring
	if id == nil then
		formstring = "label[0,0;"..F("Help > (No Category)") .. "]"
		formstring = formstring .. "label[0,0.5;"..F("You haven't chosen a category yet. Please choose one in the category list first.").."]"
		formstring = formstring .. "button[0,1;3,1;doc_button_goto_main;"..F("Go to category list").."]"
	else
		formstring = "label[0,0;"..minetest.formspec_escape(S("Help > @1", doc.data.categories[id].def.name)).."]"
		local total = doc.get_entry_count(id)
		if total >= 1 then
			local revealed = doc.get_revealed_count(playername, id)
			if revealed == 0 then
				formstring = formstring .. "label[0,0.5;"..minetest.formspec_escape(S("Currently all entries in this category are hidden from you.").."\n"..S("Unlock new entries by progressing in the game.")).."]"
				formstring = formstring .. "button[0,1.5;3,1;doc_button_goto_main;"..F("Go to category list").."]"
			else
				formstring = formstring .. "label[0,0.5;"..F("This category has the following entries:").."]"
				formstring = formstring .. doc.generate_entry_list(id, playername)
				formstring = formstring .. "button[0,"..(doc.FORMSPEC.HEIGHT-1)..";3,1;doc_button_goto_entry;"..F("Show entry").."]"
				formstring = formstring .. "label["..(doc.FORMSPEC.WIDTH-4)..","..(doc.FORMSPEC.HEIGHT-1)..";"..minetest.formspec_escape(S("Number of entries: @1", total)).."\n"
				local viewed = doc.get_viewed_count(playername, id)
				local hidden = total - revealed
				local new = total - viewed - hidden
				-- TODO/FIXME: Check if number of hidden/viewed entries is always correct
				if viewed < total then
					formstring = formstring .. colorize(COLOR_NOT_VIEWED, minetest.formspec_escape(S("New entries: @1", new)))
					if hidden > 0 then
						formstring = formstring .. "\n"
						formstring = formstring .. colorize(COLOR_HIDDEN, minetest.formspec_escape(S("Hidden entries: @1", hidden))).."]"
					else
						formstring = formstring .. "]"
					end
				else
					formstring = formstring .. F("All entries read.").."]"
				end
			end
		else
			formstring = formstring .. "label[0,0.5;"..F("This category is empty.").."]"
			formstring = formstring .. "button[0,1.5;3,1;doc_button_goto_main;"..F("Go to category list").."]"
		end
	end
	return formstring
end

function doc.formspec_entry_navigation(category_id, entry_id)
	if doc.get_entry_count(category_id) < 1 then
		return ""
	end
	local formstring = ""
	formstring = formstring .. "button["..(doc.FORMSPEC.WIDTH-2)..","..(doc.FORMSPEC.HEIGHT-0.5)..";1,1;doc_button_goto_prev;"..F("<").."]"
	formstring = formstring .. "button["..(doc.FORMSPEC.WIDTH-1)..","..(doc.FORMSPEC.HEIGHT-0.5)..";1,1;doc_button_goto_next;"..F(">").."]"
	formstring = formstring .. "tooltip[doc_button_goto_prev;"..F("Show previous entry").."]"
	formstring = formstring .. "tooltip[doc_button_goto_next;"..F("Show next entry").."]"
	return formstring
end

function doc.formspec_entry(category_id, entry_id, playername)
	local formstring
	if category_id == nil then
		formstring = "label[0,0;"..F("Help > (No Category)") .. "]"
		formstring = formstring .. "label[0,0.5;"..F("You haven't chosen a category yet. Please choose one in the category list first.").."]"
		formstring = formstring .. "button[0,1;3,1;doc_button_goto_main;"..F("Go to category list").."]"
	elseif entry_id == nil then
		formstring = "label[0,0;"..minetest.formspec_escape(S("Help > @1 > (No Entry)", doc.data.categories[category_id].def.name)) .. "]"
		if doc.get_entry_count(category_id) >= 1 then
			formstring = formstring .. "label[0,0.5;"..F("You haven't chosen an entry yet. Please choose one in the entry list first.").."]"
			formstring = formstring .. "button[0,1.5;3,1;doc_button_goto_category;"..F("Go to entry list").."]"
		else
			formstring = formstring .. "label[0,0.5;"..F("This category does not have any entries.").."]"
			formstring = formstring .. "button[0,1.5;3,1;doc_button_goto_main;"..F("Go to category list").."]"
		end
	else

		local category = doc.data.categories[category_id]
		local entry = get_entry(category_id, entry_id)
		local ename = entry.name
		if ename == nil or ename == "" then
			ename = S("Nameless entry (@1)", entry_id)
		end
		formstring = "style_type[textarea;textcolor=#FFFFFF]"
		formstring = formstring .. "label[0,0;"..minetest.formspec_escape(S("Help > @1 > @2", category.def.name, ename)).."]"
		formstring = formstring .. category.def.build_formspec(entry.data, playername)
		formstring = formstring .. doc.formspec_entry_navigation(category_id, entry_id)
	end
	return formstring
end

function doc.process_form(player,formname,fields)
	local playername = player:get_player_name()
	--[[ process clicks on the tab header ]]
	if(formname == "doc:main" or formname == "doc:category" or formname == "doc:entry") then
		if fields.doc_header ~= nil then
			local tab = tonumber(fields.doc_header)
			local formspec, subformname, contents
			local cid, eid
			cid = doc.data.players[playername].category
			eid = doc.data.players[playername].entry
			if(tab==1) then
				contents = doc.formspec_main(playername)
				subformname = "main"
			elseif(tab==2) then
				contents = doc.formspec_category(cid, playername)
				subformname = "category"
			elseif(tab==3) then
				doc.data.players[playername].galidx = 1
				contents = doc.formspec_entry(cid, eid, playername)
				if cid ~= nil and eid ~= nil then
					doc.mark_entry_as_viewed(playername, cid, eid)
				end
				subformname = "entry"
			end
			formspec = doc.formspec_core(tab)..contents
			minetest.show_formspec(playername, "doc:" .. subformname, formspec)
			return
		end
	end
	if(formname == "doc:main") then
		for cid,_ in pairs(doc.data.categories) do
			if fields["doc_button_category_"..cid] then
				doc.data.players[playername].catsel = nil
				doc.data.players[playername].category = cid
				doc.data.players[playername].entry = nil
				doc.data.players[playername].entry_textlist_needs_updating = true
				local formspec = doc.formspec_core(2)..doc.formspec_category(cid, playername)
				minetest.show_formspec(playername, "doc:category", formspec)
				break
			end
		end
		if fields["doc_mainlist"] then
			local event = minetest.explode_textlist_event(fields["doc_mainlist"])
			local cid = doc.data.category_order[event.index]
			if cid ~= nil then
				if event.type == "CHG" then
					doc.data.players[playername].catsel = nil
					doc.data.players[playername].category = cid
					doc.data.players[playername].entry = nil
					doc.data.players[playername].entry_textlist_needs_updating = true
				elseif event.type == "DCL" then
					doc.data.players[playername].catsel = nil
					doc.data.players[playername].category = cid
					doc.data.players[playername].entry = nil
					doc.data.players[playername].entry_textlist_needs_updating = true
					local formspec = doc.formspec_core(2)..doc.formspec_category(cid, playername)
					minetest.show_formspec(playername, "doc:category", formspec)
				end
			end
		end
		if fields["doc_button_goto_category"] then
			local cid = doc.data.players[playername].category
			doc.data.players[playername].catsel = nil
			doc.data.players[playername].entry = nil
			doc.data.players[playername].entry_textlist_needs_updating = true
			local formspec = doc.formspec_core(2)..doc.formspec_category(cid, playername)
			minetest.show_formspec(playername, "doc:category", formspec)
		end
		if fields["doc_setting_notify_on_reveal"] then
			doc.data.players[playername].stored_data.notify_on_reveal = fields["doc_setting_notify_on_reveal"] == "true"
		end
	elseif(formname == "doc:category") then
		if fields["doc_button_goto_entry"] then
			local cid = doc.data.players[playername].category
			if cid ~= nil then
				local eid = nil
				local eids, catsel = doc.data.players[playername].entry_ids, doc.data.players[playername].catsel
				if eids ~= nil and catsel ~= nil then
					eid = eids[catsel]
				end
				doc.data.players[playername].galidx = 1
				local formspec = doc.formspec_core(3)..doc.formspec_entry(cid, eid, playername)
				minetest.show_formspec(playername, "doc:entry", formspec)
				doc.mark_entry_as_viewed(playername, cid, eid)
			end
		end
		if fields["doc_button_goto_main"] then
			local formspec = doc.formspec_core(1)..doc.formspec_main(playername)
			minetest.show_formspec(playername, "doc:main", formspec)
		end
		if fields["doc_catlist"] then
			local event = minetest.explode_textlist_event(fields["doc_catlist"])
			if event.type == "CHG" then
				doc.data.players[playername].catsel = event.index
				doc.data.players[playername].entry = doc.data.players[playername].entry_ids[event.index]
				doc.data.players[playername].entry_textlist_needs_updating = true
			elseif event.type == "DCL" then
				local cid = doc.data.players[playername].category
				local eid = nil
				local eids, catsel = doc.data.players[playername].entry_ids, event.index
				if eids ~= nil and catsel ~= nil then
					eid = eids[catsel]
				end
				doc.mark_entry_as_viewed(playername, cid, eid)
				doc.data.players[playername].entry_textlist_needs_updating = true
				doc.data.players[playername].galidx = 1
				local formspec = doc.formspec_core(3)..doc.formspec_entry(cid, eid, playername)
				minetest.show_formspec(playername, "doc:entry", formspec)
			end
		end
	elseif(formname == "doc:entry") then
		if fields["doc_button_goto_main"] then
			local formspec = doc.formspec_core(1)..doc.formspec_main(playername)
			minetest.show_formspec(playername, "doc:main", formspec)
		elseif fields["doc_button_goto_category"] then
			local formspec = doc.formspec_core(2)..doc.formspec_category(doc.data.players[playername].category, playername)
			minetest.show_formspec(playername, "doc:category", formspec)
		elseif fields["doc_button_goto_next"] then
			if doc.data.players[playername].catsel == nil then return end -- emergency exit
			local eids = doc.data.players[playername].entry_ids
			local cid = doc.data.players[playername].category
			local new_catsel= doc.data.players[playername].catsel + 1
			local new_eid = eids[new_catsel]
			if #eids > 1 and new_catsel <= #eids then
				doc.mark_entry_as_viewed(playername, cid, new_eid)
				doc.data.players[playername].catsel = new_catsel
				doc.data.players[playername].entry = new_eid
				doc.data.players[playername].galidx = 1
				local formspec = doc.formspec_core(3)..doc.formspec_entry(cid, new_eid, playername)
				minetest.show_formspec(playername, "doc:entry", formspec)
			end
		elseif fields["doc_button_goto_prev"] then
			if doc.data.players[playername].catsel == nil then return end -- emergency exit
			local eids = doc.data.players[playername].entry_ids
			local cid = doc.data.players[playername].category
			local new_catsel= doc.data.players[playername].catsel - 1
			local new_eid = eids[new_catsel]
			if #eids > 1 and new_catsel >= 1 then
				doc.mark_entry_as_viewed(playername, cid, new_eid)
				doc.data.players[playername].catsel = new_catsel
				doc.data.players[playername].entry = new_eid
				doc.data.players[playername].galidx = 1
				local formspec = doc.formspec_core(3)..doc.formspec_entry(cid, new_eid, playername)
				minetest.show_formspec(playername, "doc:entry", formspec)
			end
		elseif fields["doc_button_gallery_prev"] then
			local cid, eid = doc.get_selection(playername)
			if doc.data.players[playername].galidx - doc.data.players[playername].galrows > 0 then
				doc.data.players[playername].galidx = doc.data.players[playername].galidx - doc.data.players[playername].galrows
			end
			local formspec = doc.formspec_core(3)..doc.formspec_entry(cid, eid, playername)
			minetest.show_formspec(playername, "doc:entry", formspec)
		elseif fields["doc_button_gallery_next"] then
			local cid, eid = doc.get_selection(playername)
			if doc.data.players[playername].galidx + doc.data.players[playername].galrows <= doc.data.players[playername].maxgalidx then
				doc.data.players[playername].galidx = doc.data.players[playername].galidx + doc.data.players[playername].galrows
			end
			local formspec = doc.formspec_core(3)..doc.formspec_entry(cid, eid, playername)
			minetest.show_formspec(playername, "doc:entry", formspec)
		end
	else
		if fields["doc_inventory_plus"] and minetest.get_modpath("inventory_plus") then
			doc.show_doc(playername)
			return
		end
	end
end

minetest.register_on_player_receive_fields(doc.process_form)

minetest.register_chatcommand("helpform", {
	params = "",
	description = S("Open a window providing help entries about Minetest and more"),
	privs = {},
	func = function(playername, param)
		doc.show_doc(playername)
	end,
	}
)

minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	local playerdata = doc.data.players[playername]
	if playerdata == nil then
		-- Initialize player data
		doc.data.players[playername] = {}
		playerdata = doc.data.players[playername]
		-- Gallery index, stores current index of first displayed image in a gallery
		playerdata.galidx = 1
		-- Maximum gallery index (index of last image in gallery)
		playerdata.maxgalidx = 1
		-- Number of rows in an gallery of the current entry
		playerdata.galrows = 1
		-- Table for persistant data
		playerdata.stored_data = {}
		-- Contains viewed entries
		playerdata.stored_data.viewed = {}
		-- Count viewed entries
		playerdata.stored_data.viewed_count = {}
		-- Contains revealed/unhidden entries
		playerdata.stored_data.revealed = {}
		-- Count revealed entries
		playerdata.stored_data.revealed_count = {}
	else
		-- Completely rebuild viewed and revealed counts from scratch
		for cid, cat in pairs(doc.data.categories) do
			if playerdata.stored_data.viewed[cid] == nil then
				playerdata.stored_data.viewed[cid] = {}
			end
			if playerdata.stored_data.revealed[cid] == nil then
				playerdata.stored_data.revealed[cid] = {}
			end
			local vc = 0
			local rc = doc.get_entry_count(cid) - doc.data.categories[cid].hidden_count
			for eid, entry in pairs(cat.entries) do
				if playerdata.stored_data.viewed[cid][eid] then
					vc = vc + 1
					playerdata.stored_data.revealed[cid][eid] = true
				end
				if playerdata.stored_data.revealed[cid][eid] and entry.hidden then
					rc = rc + 1
				end
			end
			playerdata.stored_data.viewed_count[cid] = vc
			playerdata.stored_data.revealed_count[cid] = rc
		end
	end

	-- Add button for Inventory++
	if minetest.get_modpath("inventory_plus") ~= nil then
		inventory_plus.register_button(player, "doc_inventory_plus", S("Help"))
	end
end)

---[[ Add buttons for inventory mods ]]
local button_action = function(player)
	doc.show_doc(player:get_player_name())
end

-- Unified Inventory
if minetest.get_modpath("unified_inventory") ~= nil then
	unified_inventory.register_button("doc", {
		type = "image",
		image = "doc_button_icon_hires.png",
		tooltip = S("Help"),
		action = button_action,
	})
end

-- sfinv_buttons
if minetest.get_modpath("sfinv_buttons") ~= nil then
	sfinv_buttons.register_button("doc", {
		image = "doc_button_icon_lores.png",
		tooltip = S("Collection of help texts"),
		title = S("Help"),
		action = button_action,
	})
end


minetest.register_privilege("help_reveal", {
	description = S("Allows you to reveal all hidden help entries with /help_reveal"),
	give_to_singleplayer = false
})

minetest.register_chatcommand("help_reveal", {
	params = "",
	description = S("Reveal all hidden help entries to you"),
	privs = { help_reveal = true },
	func = function(name, param)
		doc.mark_all_entries_as_revealed(name)
	end,
})
