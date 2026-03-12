local S = core.get_translator(core.get_current_modname())

local template = {
	groups = {
		handy = 1, axey = 1, building_block = 1, material_wood = 1,
		flammable = -1, compostability = 85
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 0.2,
	_mcl_silk_touch_drop = true,
}

local red = table.copy(template)
red.drop = {
	items = {
		{ items = {"mcl_mushrooms:mushroom_red"}, rarity = 9 },
		{ items = {"mcl_mushrooms:mushroom_red 2"}, rarity = 9 },
	}
}

local brown= table.copy(template)
brown.drop = {
	items = {
		{ items = {"mcl_mushrooms:mushroom_brown"}, rarity = 9 },
		{ items = {"mcl_mushrooms:mushroom_brown 2"}, rarity = 9 },
	}
}

-- Convert a number to a string with 6 binary digits
local function to_binary(num)
	local binary = ""
	while (num > 0) do
		local remainder_binary = (num % 2) > 0 and 1 or 0
		binary = binary .. remainder_binary
		num = math.floor(num/2)
	end
	binary = string.reverse(binary)
	while (string.len(binary) < 6) do
		binary = "0" .. binary
	end
	return binary
end

local function register_mushroom(color, species_id, template, d_cap, d_stem, d_stem_all, longdesc_cap, longdesc_stem)

	-- Stem texture on all sides
	local stem_full = table.copy(template)
	stem_full.description = d_stem_all
	stem_full._doc_items_longdesc = S("This decorative block is like a huge mushroom stem, but with the stem texture on all sides.")
	stem_full.tiles = { "mcl_mushrooms_mushroom_block_skin_stem.png" }
	stem_full.groups.huge_mushroom = species_id
	stem_full.groups.huge_mushroom_stem = 2
	stem_full.groups.compostability = 65
	core.register_node("mcl_mushrooms:"..color.."_mushroom_block_stem_full", stem_full)

	-- Stem
	local stem = table.copy(template)
	stem.description = d_stem
	stem._doc_items_longdesc = longdesc_stem
	stem.tiles = { "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_skin_stem.png" }
	stem.groups.huge_mushroom = species_id
	stem.groups.huge_mushroom_stem = 1
	stem.groups.compostability = 65
	core.register_node("mcl_mushrooms:"..color.."_mushroom_block_stem", stem)

	-- Mushroom block (cap)
	local function register_mushroom_cap(block, block_id, index)
		block.groups.huge_mushroom = species_id
		block.groups.huge_mushroom_cap = index
		block._mcl_burntime = 15
		core.register_node(block_id, block)
	end

	-- Each side can either be the cap or the pores texture.
	-- Cubes have 6 sides, so there's a total of 2^6 = 64 combinations
	local full_block = "mcl_mushrooms:"..color.."_mushroom_block_cap_111111"
	local block_skin = "mcl_mushrooms_mushroom_block_skin_"..color..".png"
	-- Cap blocks with pores on at least 1 side. These blocks are used internally.
	for s=0,62 do
		-- bin is a binary string with 6 digits. Each digit stands for the
		-- texture of one of the sides, in the same order as the tiles parameter.
		-- 0 = pores; 1 = cap.
		local block = table.copy(template)
		local bin = to_binary(s)
		local block_id = "mcl_mushrooms:"..color.."_mushroom_block_cap_"..bin
		block._doc_items_create_entry = false
		block._mcl_silk_touch_drop = { full_block }
		block.groups.not_in_creative_inventory = 1
		block.groups.not_in_craft_guide = 1
		block.tiles = {}
		for t=1, string.len(bin) do
			if string.sub(bin, t, t) == "1" then
				block.tiles[t] = block_skin
			else
				block.tiles[t] = "mcl_mushrooms_mushroom_block_inside.png"
			end
		end
		doc.add_entry_alias("nodes", full_block, "nodes", block_id)
		register_mushroom_cap(block, block_id, s)
	end

	-- All-faces cap. This block is exposed to the player.
	-- On placement, check adjacent mushrooms and change that side to pores.
	local block = table.copy(template)
	block.description = d_cap
	block._doc_items_longdesc = longdesc_cap
	block._doc_items_usagehelp = S("By placing huge mushroom blocks of the same species next to each other, the sides that touch each other will turn into pores permanently.")
	block.tiles = { block_skin }

	function block.on_construct(pos)
		local sides = {
			{ { x= 0, y= 1, z= 0 }, 2 },
			{ { x= 0, y=-1, z= 0 }, 1 },
			{ { x= 1, y= 0, z= 0 }, 4 },
			{ { x=-1, y= 0, z= 0 }, 3 },
			{ { x= 0, y= 0, z= 1 }, 6 },
			{ { x= 0, y= 0, z=-1 }, 5 },
		}

		-- Replace the side of a mushroom node. Returns the new node.
		-- Or nil, if unchanged.
		local function replace_side(_, node, side)
			local bin = string.sub(node.name, -6)
			if string.sub(bin, side, side) == "1" then
				local new_bin
				if side == 1 then
					new_bin = "0" .. string.sub(bin, side+1, 6)
				elseif side == 6 then
					new_bin = string.sub(bin, 1, side-1) .. "0"
				else
					new_bin = string.sub(bin, 1, side-1) .. "0" .. string.sub(bin, side+1, 6)
				end

				return { name = string.sub(node.name, 1, -7) .. new_bin }
			end
		end

		local node = core.get_node(pos)
		local species_self = core.get_item_group(node.name, "huge_mushroom")
		local node_update = table.copy(node)
		for i=1, #sides do
			local neighbor = vector.add(pos, sides[i][1])
			local neighbor_node = core.get_node(neighbor)
			local node_set = false
			if core.get_item_group(neighbor_node.name, "huge_mushroom_cap") ~= 0 and core.get_item_group(neighbor_node.name, "huge_mushroom") == species_self then
				local i2 = sides[i][2]
				local node_return = replace_side(pos, node_update, i)
				if node_return then
					node_update = node_return
					node_set = true
				end
				local new_neighbor = replace_side(neighbor, neighbor_node, i2)
				if new_neighbor then
					core.set_node(neighbor, new_neighbor)
				end
			end
			if node_set then
				core.set_node(pos, node_update)
			end
		end
	end
	register_mushroom_cap(block, full_block, 63)
end


local longdesc_red = S("Huge red mushroom blocks are the cap parts of huge red mushrooms. It consists of a red skin and can have pores on each of its sides.")
local longdesc_red_stem = S("The stem part of a huge red mushroom.")
register_mushroom("red", 1, red, S("Huge Red Mushroom Block"), S("Huge Red Mushroom Stem"), S("Huge Red Mushroom All-Faces Stem"), longdesc_red, longdesc_red_stem)


local longdesc_brown = S("Huge brown mushroom blocks are the cap parts of huge brown mushrooms. It consists of a brown skin and can have pores on each of its sides.")
local longdesc_brown_stem = S("The stem part of a huge brown mushroom.")
register_mushroom("brown", 2, brown, S("Huge Brown Mushroom Block"), S("Huge Brown Mushroom Stem"), S("Huge Brown Mushroom All-Faces Stem"), longdesc_brown, longdesc_brown_stem)

-- Legacy support
local colors = { "red", "brown" }
for c=1, 2 do
	local color = colors[c]
	core.register_alias("mcl_mushrooms:"..color.."_mushroom_block_cap_full", "mcl_mushrooms:"..color.."_mushroom_block_cap_111111")
	core.register_alias("mcl_mushrooms:"..color.."_mushroom_block_cap_top", "mcl_mushrooms:"..color.."_mushroom_block_cap_100000")
	core.register_alias("mcl_mushrooms:"..color.."_mushroom_block_pores_full", "mcl_mushrooms:"..color.."_mushroom_block_cap_000000")
end

core.register_lbm({
	label = "Replace legacy mushroom cap blocks",
	name = "mcl_mushrooms:replace_legacy_mushroom_caps",
	nodenames = { "mcl_mushrooms:brown_mushroom_block_cap_corner", "mcl_mushrooms:brown_mushroom_block_cap_side", "mcl_mushrooms:red_mushroom_block_cap_corner", "mcl_mushrooms:red_mushroom_block_cap_side" },
	action = function(pos, node)
		for c=1, 2 do
			local color = colors[c]
			if node.name == "mcl_mushrooms:"..color.."_mushroom_block_cap_side" then
				if node.param2 == 0 then
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_100001"})
				elseif node.param2 == 1 then
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_100100"}) -- OK
				elseif node.param2 == 2 then
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_100010"})
				elseif node.param2 == 3 then
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_101000"})
				else
					-- Fallback
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_101111"})
				end
			elseif node.name == "mcl_mushrooms:"..color.."_mushroom_block_cap_corner" then
				if node.param2 == 0 then
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_101001"})
				elseif node.param2 == 1 then
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_100101"}) -- OK
				elseif node.param2 == 2 then
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_100110"}) -- OK
				elseif node.param2 == 3 then
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_101010"})
				else
					-- Fallback
					core.set_node(pos, {name = "mcl_mushrooms:"..color.."_mushroom_block_cap_101111"})
				end
			end
		end
	end,
})
