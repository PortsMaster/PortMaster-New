local modname = core.get_current_modname()
local S = core.get_translator(modname)
local SHOWITEM_INTERVAL = 2
local EJECTITEM_INTERVAL = 0.5
local LOOT_KEY = modname .. ":loot"
local VISITED_KEY = modname .. ":visited_players"
local RINGBUFFER_SIZE = tonumber(core.settings:get("mcl_vaults_looter_list_length")) or 128

local function can_open(pos, player)
	if not player or not player:is_player() then return false end
	local rb = mcl_util.ringbuffer.get_from_node_meta(pos, VISITED_KEY, RINGBUFFER_SIZE)
	return not rb:indexof(player:get_player_name())
end

local function try_open(pos, player)
	if not player or not player:is_player() then return false end
	local rb = mcl_util.ringbuffer.get_from_node_meta(pos, VISITED_KEY, RINGBUFFER_SIZE)
	return rb:insert_if_not_exists(player:get_player_name(), true)
end

local function get_eligible_player_near(pos, distance)
	for v in core.objects_inside_radius(pos, distance) do
		if v:is_player() and can_open(pos, v) then return v end
	end
end

local function get_vault_def(pos)
	local node = pos and core.get_node(pos)
	local def = node and core.registered_nodes[node.name]
	return def and def._mcl_vault_name and mcl_vaults.registered_vaults[def._mcl_vault_name], node
end

local function generate_loot(pos)
	local def = get_vault_def(pos)
	if def then
		local loot = {}
		for _, stack in pairs(mcl_loot.get_multi_loot(def.loot, PcgRandom(os.time()))) do
			table.insert(loot, stack:to_string())
		end
		local meta = core.get_meta(pos)
		meta:set_string(LOOT_KEY, core.serialize(loot))
		meta:mark_as_private(LOOT_KEY)
	end
end

local function get_next_loot(pos)
	local meta = core.get_meta(pos)
	local loot_string = meta:get_string(LOOT_KEY)
	local loot = core.deserialize(loot_string)
	if type(loot) ~= "table" then
		-- loot data missing or invalid -> clean metadata
		if loot_string ~= "" then
			core.log("warning", "[mcl_vaults]: cleaning invalid loot data at pos " .. core.pos_to_string(pos, 0) .. ": " .. dump(loot_string))
		end
		meta:set_string(LOOT_KEY, "")
		loot = {}
	end
	local next_item = table.remove(loot, 1)
	if #loot > 0 then
		meta:set_string(LOOT_KEY, core.serialize(loot))
		meta:mark_as_private(LOOT_KEY)
	else
		meta:set_string(LOOT_KEY, "")
	end
	return next_item, loot[1]
end


local tpl = {
	drawtype = "allfaces_optional",
	paramtype2 = "facedir",
	paramtype = "light",
	description = S("Vault"),
	_tt_help = S("Ejects loot when opened with the key"),
	_doc_items_longdesc = S("A vault ejects loot when opened with the right key. It can only be opened once by each player."),
	_doc_items_usagehelp = S("A vault ejects loot when opened with the right key. It can only be opened once by each player."),
	groups = {pickaxey=1, material_stone=1, deco_block=1, vault = 1, not_in_creative_inventory = 1, unmovable_by_piston = 1, features_cannot_replace = 1, },
	is_ground_content = false,
	drop = "",
	_mcl_hardness = 50,
	_mcl_blast_resitance = 50,
}

core.register_entity("mcl_vaults:item_entity", {
	initial_properties = {
		physical = false,
		visual = "wielditem",
		visual_size = {x=0.25, y=0.25},
		collisionbox = {0,0,0,0,0,0},
		pointable = true,
		static_save = false,
	},
	_mcl_pistons_unmovable = true,
	_deactivate = function(self, node)
		node.name = self._vault_name
		core.swap_node(self._pos, node)
		self.object:remove()
		core.get_node_timer(self._pos):start(1)
	end,
	_display_item = function(self, item_name)
		self.object:set_properties({
			wield_item = item_name,
		})
	end,
	on_step = function(self, dtime)
		self._timer = (self._timer or 0) - dtime
		if self._timer < 0 then
			local node = core.get_node(self._pos)
			if node.name == self._vault_on_name then
				if get_eligible_player_near(self._pos, 5) then
					-- active vault and eligible player still there -> show next item
					-- intentionally use larger distance to prevent activate/deactivate race
					self._timer = SHOWITEM_INTERVAL
					local item = mcl_loot.get_multi_loot(self._loot, self._pr)[1]:get_name()
					self:_display_item(item)
					-- TODO: manage particles
				else
					-- no player near or player can't open -> deactivate
					self:_deactivate(node)
				end
			elseif node.name == self._vault_ejecting_name then
				self._timer = EJECTITEM_INTERVAL
				local loot, preview = get_next_loot(self._pos)
				if loot then
					core.add_item(vector.offset(self._pos, 0, 0.8, 0), loot)
					-- TODO: create particles
				end
				if preview then
					self:_display_item(ItemStack(preview):get_name())
				else
					-- no more loot -> deactivate
					self:_deactivate(node)
				end
			else
				-- vault node changed -> remove entity
				self.object:remove()
			end
		end
	end,
	on_activate = function(self)
		self._pos = self.object:get_pos()
		local def = get_vault_def(self._pos)
		if def then
			self._vault_name = "mcl_vaults:" .. def.name
			self._vault_on_name = self._vault_name .. "_on"
			self._vault_ejecting_name = self._vault_name .. "_ejecting"
			self._loot = def.loot
			self._pr = PcgRandom(os.time())
			self._timer = 0
			self.object:set_armor_groups({ immortal = 1 })
		else
			self.object:remove()
			return
		end
	end,
})

local function activate_item_entity(pos)
	local entity

	local count = 0
	for o in core.objects_inside_radius(pos, 0.1) do
		local lua_entity = o:get_luaentity()
		if lua_entity.name == "mcl_vaults:item_entity" then
			count = count + 1
			if count == 1 then
				entity = o
				lua_entity._timer = 0 -- activate
			else
				-- remove any superfluous entity
				core.log("warning", "[mcl_vaults] more than one item entity found at " .. core.pos_to_string(pos, 0))
				o:remove()
			end
		end
	end

	return entity or core.add_entity(pos, "mcl_vaults:item_entity")
end

-- Activate node at position `pos`.
-- Creates an entity inside the vault that displays potential loot.
function mcl_vaults.activate(pos, player)
	local def, node = get_vault_def(pos)
	if def and node.name == "mcl_vaults:"..def.name and can_open(pos, player) then
		node.name = node.name.."_on"
		core.swap_node(pos, node)
		activate_item_entity(pos)
		return true
	end
	return false
end

-- Register new type of vault.
--
-- The `def` needs to define the loot, a key item that unlocks the loot and the
-- properties of the inactive, active, and ejecting variant.
--
-- The code currently assumes that `#mcl_loot.get_multi_loot(loot, pr) > 0`,
-- i.e. that at least some loot components have `stacks_min > 0`.
function mcl_vaults.register_vault(name, def)
	assert(type(name) == "string", "[mcl_vaults] trying to register vault without a valid (string) name")
	assert(def.loot, "[mcl_vaults] vault "..tostring(name).." does not define a loot table.")
	assert(def.keyitem or type(def.key) == "table", "[mcl_vaults] vault "..tostring(name).." does not define a key item.")
	def.name = name
	mcl_vaults.registered_vaults[name] = def

	local keyitem = def.keyitem or ("mcl_vaults:"..def.key.name)
	if not def.keyitem then
		core.register_craftitem(keyitem, def.key)
	end

	core.register_node(":mcl_vaults:"..name, table.merge(tpl, {
		_mcl_vault_name = name,
		groups = table.merge(tpl.groups, { not_in_creative_inventory = 0 }),
		on_rightclick = function(pos, _, clicker)
			-- just in case that auto activation somehow didn't work
			mcl_vaults.activate(pos, clicker)
		end,
		on_construct = function(pos)
			core.get_node_timer(pos):start(1)
		end,
		on_timer = function(pos)
			local player = get_eligible_player_near(pos, 3)
			return not player or not mcl_vaults.activate(pos, player)
		end,
	}, def.node_off))

	core.register_node(":mcl_vaults:"..name.."_ejecting", table.merge(tpl, {
		_mcl_vault_name = name,
		groups = table.merge(tpl.groups, { vault = 3 }),
	}, def.node_ejecting))

	core.register_node(":mcl_vaults:"..name.."_on", table.merge(tpl, {
		_mcl_vault_name = name,
		groups = table.merge(tpl.groups, { vault = 2 }),
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			-- generate loot and store it in private node metadata
			-- do this before actually opening the vault to prevent
			-- it from getting lost in a badly timed server crash
			generate_loot(pos, node)
			if itemstack:get_name() == keyitem and try_open(pos, clicker) then
				node.name = "mcl_vaults:"..name.."_ejecting"
				core.swap_node(pos, node)
				if not core.is_creative_enabled(clicker:get_player_name()) then
					itemstack:take_item()
				end
				-- the item entity handles ejecting the loot and
				-- finally deactivating the vault; it is
				-- recreated on server restart
				activate_item_entity(pos)
				return itemstack
			end
		end
	}, def.node_on))

	core.register_lbm({
		name = "mcl_vaults:" .. name .. "_item_entity",
		label = "Activate vault item entity",
		nodenames = {
			"mcl_vaults:" .. name .. "_on",
			"mcl_vaults:" .. name .. "_ejecting",
		},
		run_at_every_load = true,
		action = activate_item_entity,
	})

	core.register_lbm({
		name = "mcl_vaults:" .. name .. "_node_timer",
		label = "Activate vault node timer",
		nodenames = {
			"mcl_vaults:" .. name,
		},
		run_at_every_load = true,
		action = function(pos)
			-- don't bother with checking whether it's already running
			core.get_node_timer(pos):start(1)
		end,
	})
end
