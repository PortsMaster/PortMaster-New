mcl_paintings = {}

local modname = core.get_current_modname()
local S = core.get_translator(modname)
local C = core.colorize

local wood = "mcl_paintings_frame.png"

-- a painting definition has these fields
-- width         - integer
-- height        - integer
-- texture       - the texture
-- legacy_motive - the old (and extremely stupid) painting identifier, used for backwards compability
local registered_paintings = {}
local registered_painting_aliases = {}
local maximum_width = 0
local maximum_height = 0
local search_distance = 0

function mcl_paintings.register_painting_alias(alias, original_name)
	registered_painting_aliases[alias] = original_name
end

function mcl_paintings.register_painting(name, def)
	def.name = name
	registered_paintings[name] = def
	maximum_width = math.max(maximum_width, def.width)
	maximum_height = math.max(maximum_height, def.height)

	-- Calculating the distance between the bottom left corner of a painting and the center of another painting in the worst
	-- possible case. The worst case is when the two paintings are on perpendicular walls and both are the biggest possible
	-- paintings
	search_distance = math.sqrt(maximum_width^2 + (math.max(maximum_width, maximum_height) / 2)^2 + (1.5 * maximum_height)^2)
end

local function is_node_okay_for_placement(under_node, above_node)
	return above_node.name == "air" and  under_node.name ~= "air"
end

-- fancy rounding algorith that takes the direction into account
-- so when going from positive to negative. -23.5 would go to -23
-- but when going from negative to positive. it would go from -23.5 to -24
local function fancy_round(val, dir_sign)
	local frac = math.abs(val - math.floor(val))
	if frac == 0.5 then
		if dir_sign > 0 then
			return val + 0.5
		else
			return val - 0.5
		end
	else
		return math.round(val)
	end
end

local function rotate_dir_90_deg_clockwise(dir)
	local rotated_dir = vector.copy(dir)

	-- inlined linear transformation to rotate 90 degrees clockwise
	--    i   j
	-- x [-1,  0]
	-- y [0, 1]
	rotated_dir.x = -dir.z
	rotated_dir.z = dir.x

	return rotated_dir
end

local function get_biggest_painting_for_position(pos, dir, stack)
	local dir_perpendicular = rotate_dir_90_deg_clockwise(dir)

	-- Since this is a non trivial algorith i guess i will make a little write up.
	--
	-- The first thing it does is index all positions that are already taken by other paintings. Its done with getting the
	-- nearest paintings and using their position and width/height to find the position of the bottom left corner of the
	-- painting, and from there, index all the positions
	--
	-- The next thing we do is get the possible painting sizes in the `placement_ranges` table. This is done by scanning each
	-- Y slice and searching how wide it can be in that slice. But do note that its not "what is the maximum extend this slice
	-- is uninterrupted" but rather "How wide can a painting be with this height and this width". The differenc is that the
	-- extend can't be bigger than the previous elements (the job of ensuring this is done by `maximum_so_far`), otherwise it
	-- would have holes. Each Y slice is terminated either by an invalid placement (see `is_node_okay_for_placement`) or if it
	-- was indexed as taken by another painting (see the above paragraph)
	--
	-- Now that we figured out how big the painting can be for an arbitrary width and height, we iterate each painting and pick
	-- the ones with biggest volume. We store the results in a table so that we can pick the final result at random

	-- A table where each element represents the Y level (starting from the bottom).
	-- Where the value is the maximum extend of the width for a painting that wide and that high
	local placement_ranges = {}
	local maximum_so_far = maximum_width

	local neighbouring_painting_positions = {}

	for obj in core.objects_inside_radius(pos, search_distance) do
		local l = obj:get_luaentity()
		if l and l.name == "mcl_paintings:painting" then
			local pdef = registered_paintings[l._painting_name]
			local obj_pos = obj:get_pos()
			local painting_dir = core.wallmounted_to_dir(l._facing)
			local painting_dir_perpendicular = rotate_dir_90_deg_clockwise(painting_dir)

			local start_position = vector.offset(obj_pos, -painting_dir_perpendicular.x * (pdef.width / 2), -pdef.height / 2, -painting_dir_perpendicular.z * pdef.width / 2)

			start_position.x = fancy_round(start_position.x, painting_dir_perpendicular.x)
			start_position.z = fancy_round(start_position.z, painting_dir_perpendicular.z)
			start_position.y = math.ceil(start_position.y)
			for y = 0, pdef.height - 1 do
				for i = 0, pdef.width - 1 do
					neighbouring_painting_positions[core.hash_node_position(vector.offset(start_position, i * painting_dir_perpendicular.x, y, i * painting_dir_perpendicular.z))] = true
				end
			end
		end
	end

	for y = 0, maximum_height do
		local i = 0
		while i < maximum_so_far do
			local offset_pos = vector.offset(pos, i * dir_perpendicular.x, y, i * dir_perpendicular.z)
			local offset_above_pos = offset_pos + dir
			local node_under = core.get_node(offset_pos)
			local node_above = core.get_node(offset_above_pos)

			local above_hash = core.hash_node_position(offset_above_pos)
			if is_node_okay_for_placement(node_under, node_above) and not neighbouring_painting_positions[above_hash] then
				i = i + 1
			else
				break
			end
		end

		maximum_so_far = math.min(i, maximum_so_far)
		table.insert(placement_ranges, maximum_so_far)
	end

	local maximum_volume = -1
	local canditates = {}
	local meta = stack:get_meta()
	local painting = meta:get_string("mcl_paintings:placed_painting")
	local width = meta:get_int("mcl_paintings:width")
	local height = meta:get_int("mcl_paintings:height")

	if painting ~= "" and width ~= 0 and height ~= 0 then
		if placement_ranges[height] and width <= placement_ranges[height] then
			return registered_paintings[painting]
		else
			return nil
		end
	end

	for _, pdef in pairs(registered_paintings) do
		if pdef.width <= placement_ranges[pdef.height] then
			local painting_volume = pdef.width * pdef.height
			if maximum_volume < painting_volume then
				canditates = {pdef}
				maximum_volume = painting_volume
			elseif maximum_volume == painting_volume then
				table.insert(canditates, pdef)
			end
		end
	end

	if #canditates == 0 then
		return nil
	end

	return canditates[math.random(1, #canditates)]
end

core.register_craftitem("mcl_paintings:painting", {
	description = S("Painting"),
	inventory_image = "mcl_paintings_painting.png",
	groups = {deco_block = 1},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then return itemstack end

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local dir = vector.subtract(pointed_thing.above, pointed_thing.under)
		if dir.y ~= 0 then return itemstack end

		local pdef = get_biggest_painting_for_position(pointed_thing.under, dir, itemstack)
		if not pdef then return end

		local wallm = core.dir_to_wallmounted(dir)
		if not wallm then return itemstack end

		local staticdata = {
			_facing = wallm,
			_painting_name = pdef.name
		}

		local side_offset = pdef.width / 2 - 0.5
		local dir_perpendicular_dir = rotate_dir_90_deg_clockwise(dir)

		local obj = core.add_entity(
			vector.subtract(
				pointed_thing.above,
				vector.multiply(dir, 0.5-5/256)) + vector.new(
					dir_perpendicular_dir.x * side_offset,
					pdef.height / 2 - 0.5,
					dir_perpendicular_dir.z * side_offset
				),
			"mcl_paintings:painting",
			core.serialize(staticdata)
		)
		if not obj then return itemstack end

		if not core.is_creative_enabled(placer:get_player_name()) then
			itemstack:take_item()
		end
		return itemstack
	end,
	_get_all_virtual_items = function ()
		local output = {deco = {}}
		for name, def in pairs(registered_paintings) do
			local stack = ItemStack("mcl_paintings:painting")
			local meta = stack:get_meta()
			meta:set_string("mcl_paintings:placed_painting", name)
			meta:set_string("mcl_paintings:title", def.title)
			meta:set_int("mcl_paintings:width", def.width)
			meta:set_int("mcl_paintings:height", def.height)
			tt.reload_itemstack_description(stack)
			table.insert(output.deco, stack:to_string())
		end
		return output
	end
})

local function size_to_minmax_entity(size)
	return -size/2, size/2
end

local function set_entity(object, pdef)

	if not pdef then
		core.log("error", "[mcl_paintings] Painting loaded with missing painting values!")
	end

	local ent = object:get_luaentity()
	local wallm = ent._facing
	local exmin, exmax = size_to_minmax_entity(pdef.width)
	local eymin, eymax = size_to_minmax_entity(pdef.height)
	local visual_size = { x=pdef.width-0.0001, y=pdef.height-0.0001, z=1/32 }

	local box
	if wallm == 2 then
		box = { -3/128, eymin, exmin, 1/64, eymax, exmax }
	elseif wallm == 3 then
		box = { -1/64, eymin, exmin, 3/128, eymax, exmax }
	elseif wallm == 4 then
		box = { exmin, eymin, -3/128, exmax, eymax, 1/64 }
	elseif wallm == 5 then
		box = { exmin, eymin, -1/64, exmax, eymax, 3/128 }
	end

	object:set_properties({
		selectionbox = box,
		visual_size = visual_size,
		textures = { wood, wood, wood, wood, pdef.texture, wood },
	})

	local dir = core.wallmounted_to_dir(wallm)

	if not dir then return end

	object:set_yaw(core.dir_to_yaw(dir))
end

core.register_entity("mcl_paintings:painting", {
	initial_properties = {
		visual = "cube",
		visual_size = { x=0.999, y=0.999, z=1/32 },
		selectionbox = { -1/64, -0.5, -0.5, 1/64, 0.5, 0.5 },
		physical = false,
		collide_with_objects = false,
		textures = { wood, wood, wood, wood, wood, wood },
		hp_max = 1,
	},

	_mcl_pistons_unmovable = true,
	_facing = 2,
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		if staticdata and staticdata ~= "" then
			local data = core.deserialize(staticdata)
			if data then
				self._facing = data._facing
				self._painting_name = data._painting_name

				-- Putting the old mcl_painting crap to grave
				if data._motive then
					local successfully_converted = false
					for pname, pdef in pairs(registered_paintings) do
						if pdef.legacy_motive
								and pdef.height == data._ysize
								and pdef.width == data._xsize
								and pdef.legacy_motive == data._motive then

							successfully_converted = true
							self._painting_name = pname
							break
						end
					end

					if not successfully_converted then
						self.object:remove()
						core.log("error", "Could not migrate painting to the new system")
						return
					end
				end
			end
		end


		while not registered_paintings[self._painting_name] do
			if registered_painting_aliases[self._painting_name] then
				self._painting_name = registered_painting_aliases[self._painting_name]
			else
				core.log("error", "Could not find painting definition for `" .. self._painting_name .. "`")
				self.object:remove()
				return
			end
		end

		set_entity(self.object, registered_paintings[self._painting_name])
	end,
	get_staticdata = function(self)
		local data = {
			_facing = self._facing,
			_painting_name = self._painting_name
		}
		return core.serialize(data)
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage) ---@diagnostic disable-line: unused-local
		if puncher and puncher:is_player() then
			local kname = puncher:get_player_name()
			local pos = self.object:get_pos()
			if not mcl_util.check_position_protection(pos, puncher) then
				self.object:remove()
				if not core.is_creative_enabled(kname) then
					core.add_item(pos, "mcl_paintings:painting")
				end
			end
		end
	end,
})

core.register_craft({
	output = "mcl_paintings:painting",
	recipe = {
		{ "mcl_core:stick", "mcl_core:stick", "mcl_core:stick" },
		{ "mcl_core:stick", "group:wool", "mcl_core:stick" },
		{ "mcl_core:stick", "mcl_core:stick", "mcl_core:stick" },
	}
})

dofile(core.get_modpath(modname).."/registrations.lua")

tt.register_snippet(function(itemstring, _, itemstack)
	local result = ""
	if itemstring == "mcl_paintings:painting" and itemstack then
		local meta = itemstack:get_meta()
		local title = meta:get_string("mcl_paintings:title")
		local width = meta:get_int("mcl_paintings:width")
		local height = meta:get_int("mcl_paintings:height")
		if title ~= "" then
			result = C(mcl_colors.YELLOW, title)
			if width ~= 0 and height ~= 0 then
				result = result.."\n"..C(mcl_colors.WHITE, width.." X "..height)
			end
		end
	end
	return result ~= "" and result or nil
end)
