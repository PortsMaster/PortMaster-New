local S = minetest.get_translator(minetest.get_current_modname())

--[[
  mcl_clock, renew of the renew of the mcl_clock mod

  Original from Echo, here: http://forum.minetest.net/viewtopic.php?id=3795
]]--

mcl_clock = {}

-- This is the itemstring of the default clock item. It is used for the default inventory image, help entries, and the like
mcl_clock.stereotype = "mcl_clock:clock"

mcl_clock.old_time = -1

local clock_frames = 64

-- Timer for random clock spinning
local random_timer = 0.0
local random_timer_trigger = 1.0 -- random clock spinning tick in seconds. Increase if there are performance problems
local random_frame = math.random(0, clock_frames-1)

-- Image of all possible faces
mcl_clock.images = {}
for frame=0, clock_frames-1 do
	local sframe = tostring(frame)
	if string.len(sframe) == 1 then
		sframe = "0" .. sframe
	end
	table.insert(mcl_clock.images, "mcl_clock_clock_"..sframe..".png")
end

local function round(num)
	return math.floor(num + 0.5)
end

function mcl_clock.get_clock_frame()
	local t = clock_frames * minetest.get_timeofday()
	t = round(t)
	if t == clock_frames then t = 0 end
	return tostring(t)
end

local doc_mod = minetest.get_modpath("doc")

-- Register items
function mcl_clock.register_item(name, image, creative, frame)
	local g = 1
	if creative then
		g = 0
	end
	local use_doc = name == mcl_clock.stereotype
	if doc_mod and not use_doc then
		doc.add_entry_alias("craftitems", mcl_clock.stereotype, "craftitems", name)
	end
	local longdesc, usagehelp, tt
	if use_doc then
		longdesc = S("Clocks are tools which shows the current time of day in the Overworld.")
		usagehelp = S("The clock contains a rotating disc with a sun symbol (yellow disc) and moon symbol and a little “pointer” which shows the current time of day by estimating the real position of the sun and the moon in the sky. Noon is represented by the sun symbol and midnight is represented by the moon symbol.")
		tt = S("Displays the time of day in the Overworld")
	end
	minetest.register_craftitem(name, {
		description = S("Clock"),
		_tt_help = tt,
		_doc_items_create_entry = use_doc,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		inventory_image = image,
		groups = {not_in_creative_inventory=g, tool=1, clock=frame, disable_repair=1},
		wield_image = "",
	})
end

-- This timer makes sure the clocks get updated from time to time regardless of time_speed,
-- just in case some clocks in the world go wrong
local force_clock_update_timer = 0

minetest.register_globalstep(function(dtime)
	local now = mcl_clock.get_clock_frame()
	force_clock_update_timer = force_clock_update_timer + dtime
	random_timer = random_timer + dtime
	-- This causes the random spinning of the clock
	if random_timer >= random_timer_trigger then
		random_frame = (random_frame + math.random(-4, 4)) % clock_frames
		random_timer = 0
	end

	if mcl_clock.old_time == now and force_clock_update_timer < 60 then
		return
	end
	force_clock_update_timer = 0

	mcl_clock.old_time = now
	mcl_clock.random_frame = random_frame

	for p, player in pairs(minetest.get_connected_players()) do
		for s, stack in pairs(player:get_inventory():get_list("main")) do
			local frame
			-- Clocks do not work in certain zones
			if not mcl_worlds.clock_works(player:get_pos()) then
				frame = random_frame
			else
				frame = now
			end

			local count = stack:get_count()
			if stack:get_name() == mcl_clock.stereotype then
				player:get_inventory():set_stack("main", s, "mcl_clock:clock_"..frame.." "..count)
			elseif minetest.get_item_group(stack:get_name(), "clock") ~= 0 then
				player:get_inventory():set_stack("main", s, "mcl_clock:clock_"..frame.." "..count)
			end
		end
	end
end)

-- Immediately set correct clock time after crafting
minetest.register_on_craft(function(itemstack)
	if itemstack:get_name() == mcl_clock.stereotype then
		itemstack:set_name("mcl_clock:clock_"..mcl_clock.get_clock_frame())
	end
end)

-- Clock recipe
minetest.register_craft({
	output = mcl_clock.stereotype,
	recipe = {
		{"", "mcl_core:gold_ingot", ""},
		{"mcl_core:gold_ingot", "mesecons:redstone", "mcl_core:gold_ingot"},
		{"", "mcl_core:gold_ingot", ""}
	}
})

-- Clock tool
mcl_clock.register_item(mcl_clock.stereotype, mcl_clock.images[1], true, 1)

-- Faces
for a=0,clock_frames-1,1 do
	local b = a
	if b > 31 then
		b = b - 32
	else
		b = b + 32
	end
	mcl_clock.register_item("mcl_clock:clock_"..tostring(a), mcl_clock.images[b+1], false, a+1)
end

