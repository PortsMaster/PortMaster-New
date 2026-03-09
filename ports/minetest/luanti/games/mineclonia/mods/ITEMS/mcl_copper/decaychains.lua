mcl_copper.registered_decaychains = {}
local decay_nodes = {}
local nodename_chains = {}
local D = mcl_util.get_dynamic_translator()

local ESCAPE_CHAR = string.char(0x1b)
local function untranslate(s, ...)
	if type(s) ~= "string" then return "", {} end
	local str, esc, nest, args = s, 1, 0, {}
	local start, arg
	while esc < #str do
		esc = str:find(ESCAPE_CHAR, esc)
		if not esc then
			-- suffix, abort
			start = nil
			break
		end
		local char = str:sub(esc + 1, esc + 1)
		if esc == 1 then
			if char == "(" then
				local _, i = str:find(ESCAPE_CHAR .. "%(T@[^%)]-%)")
				start = i + 1
			elseif char == "T" then
				start = esc + 2
			else
				-- unknown code, abort (everything still has initial values)
				break
			end
			nest = 1
		elseif not start then
			-- prefix, abort (everything still has initial values)
			break
		elseif char == "(" or char == "T" then
			nest = nest + 1
		elseif char == "F" then
			if nest == 1 then
				arg = esc
			end
			nest = nest + 1
		elseif char == "E" then
			nest = nest - 1
			if nest == 1 and arg then
				args[#args + 1] = str:sub(arg + 2, esc - 1)
				str = str:sub(1, arg - 1) .. "@" .. (#args) .. str:sub(esc + 2)
				esc = arg
				arg = nil
			end
		else
			-- unknown code, abort
			start = nil
			break
		end
		esc = esc + 2
	end
	if start and nest == 0 then
		return str:sub(start, -3), args
	else
		return s, {}
	end
end

function mcl_copper.get_decayed(nodename, amount)
	amount = amount or 1
	local dc = mcl_copper.registered_decaychains[nodename_chains[nodename]]
	if not dc then return end
	local ci = table.indexof(dc.nodes,nodename) + amount
	if ci < 1 then ci = 1 end
	if ci > #dc.nodes then ci = #dc.nodes end
	return dc.nodes[ci]
end

function mcl_copper.get_undecayed(nodename, amount)
	amount = amount or 1
	local dc = mcl_copper.registered_decaychains[nodename_chains[nodename]]
	if not dc then return end
	local ci = table.indexof(dc.nodes,nodename) - amount
	if ci < 1 then ci = 1 end
	if ci > #dc.nodes then ci = #dc.nodes end
	return dc.nodes[ci]
end

function mcl_copper.spawn_particles(pos, texture)
	core.add_particlespawner({
		amount = 8,
		time = 0.25,
		minpos = vector.subtract(pos, 0.8),
		maxpos = vector.add(pos, 0.8),
		minvel = vector.zero(),
		maxvel = vector.zero(),
		minacc = {x=0, y=-0.8, z=0},
		maxacc = {x=0, y=-1, z=0},
		minexptime = 0.5,
		maxexptime = 1,
		minsize = 3,
		maxsize = 4.5,
		collisiondetection = false,
		vertical = false,
		texture = texture or "mcl_copper_anti_oxidation_particle.png^[colorize:#888888:125",
		glow = 5,
	})
end

local function append_door_suffix(nodename)
	if core.get_item_group(nodename, "door") > 0 then
		local suffix = nodename:sub(-4) -- find: _t_1, _t_2, _b_1, _b_2
		nodename = nodename:gsub(suffix, "_preserved"..suffix)
		return nodename
	end
end

local function swap_door_part(pos, node)
	if core.get_item_group(node.name, "door") > 0 then
		if node.name:find("_t_") then
			core.swap_node(vector.offset(pos,0,-1,0), {
				name = node.name:gsub("_t_", "_b_"),
				param2 = node.param2
			})
		else
			core.swap_node(vector.offset(pos,0,1,0), {
				name = node.name:gsub("_b_", "_t_"),
				param2 = node.param2
			})
		end
	end
end

local function unpreserve(itemstack, _, pointed_thing)
	local node = core.get_node(pointed_thing.under)
	local unpreserved = node.name:gsub("_preserved","")
	if core.registered_nodes[unpreserved] then
		node.name = unpreserved
		core.swap_node(pointed_thing.under,node)
		swap_door_part(pointed_thing.under,node)
	end
	return itemstack
end

local function undecay(itemstack, _, pointed_thing)
	local node = core.get_node(pointed_thing.under)
	node.name = mcl_copper.get_undecayed(node.name)
	core.swap_node(pointed_thing.under,node)
	swap_door_part(pointed_thing.under,node)
	mcl_copper.spawn_particles(pointed_thing.under)
	return itemstack
end

local function register_unpreserve(nodename,od,def)
	local nd = table.copy(od)
	if nd.description then
		local description, args = untranslate(nd.description)
		nd.description = D("Waxed " .. description, unpack(args))
	end
	nd[def.unpreserve_callback]  = function(itemstack, clicker, pointed_thing)
		if pointed_thing then
			awards.unlock(clicker:get_player_name(), "mcl:wax_off")
			return unpreserve(itemstack, clicker, pointed_thing)
		end
		return itemstack
	end
	-- Update appropriate stonecutter recipes for the preserved variant
	if nd._mcl_stonecutter_recipes then
		local new_recipes = {}
		for _, v in pairs(nd._mcl_stonecutter_recipes) do
			table.insert(new_recipes, v.."_preserved")
		end
		nd._mcl_stonecutter_recipes = new_recipes
	end
	nd.groups = table.merge(nd.groups, { affected_by_lightning = 0 })
	nd._on_lightning_strike = nil
	if od._mcl_other_slab_half then
		nd._mcl_other_slab_half = od._mcl_other_slab_half.."_preserved"
	end
	if od.stairs then
		nd.stairs = { od.stairs[1].."_preserved", od.stairs[1].."_outer_preserved", od.stairs[1].."_inner_preserved" }
		nd.drop = mcl_stairs.get_base_itemstring(nodename).."_preserved"
	end
	if nd._mcl_copper_bulb_switch_to then
		nd.drop = nd.drop and (nd.drop.."_preserved")
		nd._mcl_copper_bulb_switch_to = od._mcl_copper_bulb_switch_to.."_preserved"
	end
	if core.get_item_group(nodename, "double_slab") > 0 then
		nd.drop = mcl_stairs.get_base_itemstring(nodename).."_preserved 2"
	elseif core.get_item_group(nodename, "slab_top") > 0 then
		nd.drop = mcl_stairs.get_base_itemstring(nodename).."_preserved"
	elseif core.get_item_group(nodename, "slab") > 0 then
		nd._mcl_stairs_double_slab = nodename.."_double_preserved"
	end
	if append_door_suffix(nodename) then
		nodename = append_door_suffix(nodename)
	elseif core.get_item_group(nodename, "trapdoor") > 0 and nodename:find("_open") then
		nodename = nodename:gsub("_open","_preserved_open")
	else
		nodename = nodename .. "_preserved"
	end
	core.register_node(":"..nodename,nd)
end

local function register_undecay(nodename,def)
	local old_os = core.registered_items[nodename][def.undecay_callback]
	core.override_item(nodename,{
		[def.undecay_callback] = function(itemstack, clicker, pointed_thing)
			if old_os  then itemstack = old_os(itemstack, clicker, pointed_thing) end
			if pointed_thing then
				return undecay(itemstack, clicker, pointed_thing)
			end
			return itemstack
		end
	})
end

local function register_preserve(nodename,def,chaindef)
	local old_op = def.on_place
	core.override_item(nodename,{
		on_place =  function(itemstack, placer, pointed_thing)
			local node = core.get_node(pointed_thing.under)
			if table.indexof(chaindef.nodes,node.name) == -1 then
				if old_op then return old_op(itemstack, placer, pointed_thing) end
			elseif table.indexof(chaindef.nodes,node.name) <= #chaindef.nodes then
				if append_door_suffix(node.name) then
					node.name = append_door_suffix(node.name)
				else
					node.name = node.name.."_preserved"
				end
				if core.registered_nodes[node.name] then
					core.swap_node(pointed_thing.under,node)
					swap_door_part(pointed_thing.under,node)
					mcl_copper.spawn_particles(pointed_thing.under, "mcl_copper_anti_oxidation_particle.png^[colorize:#fcbf3c:200")
					if not core.is_creative_enabled(placer and placer:get_player_name() or "") then
						itemstack:take_item()
					end
				end
				awards.unlock(placer:get_player_name(), "mcl:wax_on")
			end
			return itemstack
		end
	})
end

-- mcl_copper.register_decaychain(name,def)
-- name: short string that describes the decaychain; will be used as index of the registration table
-- def: decaychain definition:
--{
--	preserve_group = "preserves_copper",
--		--optional: item group that when used on the node will preserve this state
--	unpreserve_callback = "_on_axe_place",
--		--optional: callback to use for unpreservation (scraping)
--	undecay_callback = "_on_axe_place",
--		--optional: callback to use for undecay (deoxidation)
--	nodes = { --order is significant
--		"mcl_copper:block",
--		"mcl_copper:block_exposed",
--		"mcl_copper:block_weathered",
--		"mcl_copper:block_oxidized",
--	}
--		--mandatory: table defining the decaychain with the undecayed state first and the most decayed state last. The order is significant here.
--}

function mcl_copper.register_decaychain(name,def)
	mcl_copper.registered_decaychains[name] = def
	assert(type(def.nodes) == "table","[mcl_copper] Failed to register decaychain "..tostring(name)..": field nodes is not a table.")
	for k,v in ipairs(def.nodes) do
		local od = core.registered_nodes[v]
		assert(od,"[mcl_copper] Error registereing decaychain: The node '"..tostring(v).." in the decaychain "..tostring(name).." does not exist.")

		nodename_chains[v] = name
		table.insert(decay_nodes,v)

		if k <= #def.nodes and def.unpreserve_callback then
			register_unpreserve(v,od,def)
		end

		if k > 1 and def.undecay_callback then --exclude first entry in chain - can't be undecayed further
			register_undecay(v,def)
		end
	end
end

core.register_on_mods_loaded(function()
	core.register_abm({
		label = "Node Decay",
		nodenames = decay_nodes,
		interval = 500,
		chance = 3,
		action = function(pos, node)
			local dc = mcl_copper.get_decayed(node.name)
			if not dc then return end
			core.swap_node(pos, {name = dc, param2 = node.param2})
		end,
	})
	for _,v in pairs(mcl_copper.registered_decaychains) do
		if v.preserve_group then
			for it,def in pairs(core.registered_items) do
				if core.get_item_group(it,v.preserve_group) > 0 then
					register_preserve(it,def,v)
				end
			end
		end
	end
	mcl_stonecutter.refresh_recipes()
end)
