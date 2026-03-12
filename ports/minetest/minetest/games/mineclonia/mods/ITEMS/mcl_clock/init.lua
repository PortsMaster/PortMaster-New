local S = core.get_translator(core.get_current_modname())
mcl_clock = {}

mcl_clock.old_time = -1

local clock_frames = 64

-- Timer for random clock spinning
local random_timer = 0.0
local random_timer_trigger = 1.0 -- random clock spinning tick in seconds. Increase if there are performance problems
local random_frame = math.random(0, clock_frames-1)

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
	local t = clock_frames * core.get_timeofday()
	t = round(t)
	if t == clock_frames then t = 0 end
	return tostring((t + (clock_frames / 2)) % clock_frames)
end

core.register_craftitem("mcl_clock:clock", {
	description = S("Clock"),
	_tt_help = S("Displays the time of day in the Overworld"),
	_doc_items_longdesc = S("Clocks are tools which shows the current time of day in the Overworld."),
	_doc_items_usagehelp = S("The clock contains a rotating disc with a sun symbol (yellow disc) and moon symbol and a little “pointer” which shows the current time of day by estimating the real position of the sun and the moon in the sky. Noon is represented by the sun symbol and midnight is represented by the moon symbol."),
	inventory_image = mcl_clock.images[1],
	groups = { tool=1, clock = 1, disable_repair=1 },
	wield_image = "",
	_on_entity_step = function(self, dtime, itemstring)
		self._clock_timer = (self._clock_timer or 0) - dtime
		if self._clock_timer > 0 then return end
		self._clock_timer = 5
		local stack = ItemStack(itemstring)
		local m = stack:get_meta()
		m:set_string("inventory_image", mcl_clock.images[mcl_clock.get_clock_frame() + 1])
		m:set_string("wield_image", mcl_clock.images[mcl_clock.get_clock_frame() + 1])
		self.object:set_properties({
			wield_item = stack:to_string()
		})
	end
})

-- This timer makes sure the clocks get updated from time to time regardless of time_speed,
-- just in case some clocks in the world go wrong
local force_clock_update_timer = 0

core.register_globalstep(function(dtime)
	local now = mcl_clock.get_clock_frame()
	force_clock_update_timer = force_clock_update_timer + dtime
	random_timer = random_timer + dtime

	-- This causes the random spinning of the clock
	if random_timer >= random_timer_trigger then
		random_frame = (random_frame + math.random(-4, 4)) % clock_frames
		random_timer = 0
	end

	if mcl_clock.old_time == now and force_clock_update_timer < 1 then
		return
	end
	force_clock_update_timer = 0

	mcl_clock.old_time = now
	mcl_clock.random_frame = random_frame

	for player in mcl_util.connected_players() do
		local inv = player:get_inventory()
		for s, stack in pairs(inv:get_list("main")) do
			if core.get_item_group(stack:get_name(), "clock") > 0 then
				stack:set_name("mcl_clock:clock") -- compat to effectively rename clocks - aliases do not do this.
				local frame
				-- Clocks do not work in certain zones
				if not mcl_worlds.clock_works(player:get_pos()) then
					frame = random_frame
				else
					frame = now
				end

				local m = stack:get_meta()
				m:set_string("wield_image", mcl_clock.images[frame + 1])
				m:set_string("inventory_image", mcl_clock.images[frame + 1])
				inv:set_stack("main", s, stack)
			end
		end
	end
end)

core.register_on_craft(function(itemstack)
	if itemstack:get_name() == "mcl_clock:clock" then
		itemstack:get_meta():set_string("inventory_image", mcl_clock.images[mcl_clock.get_clock_frame()])
	end
end)

core.register_craft({
	output = "mcl_clock:clock",
	recipe = {
		{"", "mcl_core:gold_ingot", ""},
		{"mcl_core:gold_ingot", "mcl_redstone:redstone", "mcl_core:gold_ingot"},
		{"", "mcl_core:gold_ingot", ""}
	}
})

for a=0,clock_frames-1,1 do
	core.register_alias("mcl_clock:clock_"..tostring(a), "mcl_clock:clock")
end

