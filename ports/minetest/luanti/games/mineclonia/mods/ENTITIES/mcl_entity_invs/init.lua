mcl_entity_invs = {}

local function check_distance(inv,player,count)
	for o in core.objects_inside_radius(player:get_pos(), 5) do
		local l = o:get_luaentity()
		if l and l._inv_id and inv:get_location().name == l._inv_id then return count end
	end
	return 0
end

local function save_on_action(inv)
	local l = inv:get_location()
	local ent = mcl_entity_invs.get_entity_by_invname(l.name)
	if ent then
		mcl_entity_invs.save_inv(ent)
	end
end

local inv_callbacks = {
	allow_take = function(inv, _, _, stack, player)
		return check_distance(inv,player,stack:get_count())
	end,
	allow_move = function(inv, _, _, _, _, count, player)
		return check_distance(inv,player,count)
	end,
	allow_put = function(inv, _, _, stack, player)
		return check_distance(inv,player,stack:get_count())
	end,
	on_put = save_on_action,
	on_take = save_on_action,
	on_move = save_on_action,
}

function mcl_entity_invs.get_entity_by_invname(name)
	for _, ent in pairs(core.luaentities) do
		if name and name == ent._inv_id then return ent end
	end
end

function mcl_entity_invs.load_inv(ent,size)
	if not ent._inv_id then return end
	local inv = core.get_inventory({type="detached", name=ent._inv_id})
	if not inv then
		inv =  core.create_detached_inventory(ent._inv_id, inv_callbacks)
		inv:set_size("main", size)
		if ent._items then
			inv:set_list("main",ent._items)
		end
	end
	ent._inv = inv
	return inv
end

function mcl_entity_invs.save_inv(ent)
	if ent._inv then
		ent._items = {}
		local list = ent._inv  and ent._inv:get_list("main")
		if list then
			for i,it in ipairs(list) do
				ent._items[i] = it:to_string()
			end
		end
	end
end

local function load_default_formspec (ent, text)
	text = text or ""

	local invent_size = ent._inv_size
	local div_by_two = invent_size % 2 == 0
	local div_by_three =  invent_size % 3 == 0

	local rows
	if invent_size > 18 or (div_by_three == true and invent_size > 8) then
		rows = 3
	elseif (div_by_two == true and invent_size > 3) or invent_size > 9 then
		rows = 2
	else
		rows = 1
	end

	local cols = (math.ceil(ent._inv_size/rows))
	local spacing = (9 - cols) / 2

	local formspec = "size[9,8.75]"
			.. "label[0,0;" .. core.formspec_escape(
			core.colorize("#313131", ent._inv_title .. " ".. text)) .. "]"
			.. "list[detached:"..ent._inv_id..";main;"..spacing..",0.5;"..cols..","..rows..";]"
			.. mcl_formspec.get_itemslot_bg(spacing,0.5,cols,rows)
			.. "label[0,4.0;" .. core.formspec_escape(
			core.colorize("#313131", "Inventory")) .. "]"
			.. "list[current_player;main;0,4.5;9,3;9]"
			.. mcl_formspec.get_itemslot_bg(0,4.5,9,3)
			.. "list[current_player;main;0,7.74;9,1;]"
			.. mcl_formspec.get_itemslot_bg(0,7.74,9,1)
			.. "listring[detached:"..ent._inv_id..";main]"
			.. "listring[current_player;main]"
	return formspec
end


function mcl_entity_invs.show_inv_form(ent,player,text)
	if not ent._inv_id then return end
	ent._inv = mcl_entity_invs.load_inv(ent,ent._inv_size)
	ent._inv_open = true
	if ent.is_mob then
		ent:stay()
	end
	local playername = player:get_player_name()

	core.show_formspec(playername, ent._inv_id, load_default_formspec (ent, text))
end

local function drop_inv(ent)
	if not ent._items then return end
	local pos = ent.object:get_pos()
	for _, it in pairs(ent._items) do
		local p = vector.add(pos,vector.new(math.random() - 0.5, math.random()-0.5, math.random()-0.5))
		core.add_item(p,it)
	end
	ent._items = nil
end

local function on_remove(self,killer,oldf)
	mcl_entity_invs.save_inv(self)
	drop_inv(self)
	if oldf then return oldf(self,killer) end
end

function mcl_entity_invs.register_inv(entity_name,show_name,size,no_on_righclick,no_sneak)
	assert(core.registered_entities[entity_name],"mcl_entity_invs.register_inv called with invalid entity: "..tostring(entity_name))
	core.registered_entities[entity_name]._inv_size = size
	core.registered_entities[entity_name]._inv_title = show_name

	local old_oa = core.registered_entities[entity_name].on_activate
	core.registered_entities[entity_name].on_activate  = function(self,staticdata,dtime_s)
		local r
		if old_oa then r=old_oa(self,staticdata,dtime_s) end
		local d = core.deserialize(staticdata)
		if type(d) == "table" and d._inv_id then
			self._inv_id = d._inv_id
			self._items = d._items
			self._inv_size = d._inv_size
			self._inv_open = nil
			self._inv = mcl_entity_invs.load_inv(self, self._inv_size or 27)
		else
			self._inv_id="entity_inv_"..core.sha1(core.get_gametime()..core.pos_to_string(self.object:get_pos())..tostring(math.random()))
			--gametime and position for collision safety and math.random salt to protect against position brute-force
		end
		return r
	end
	if not no_on_righclick then
		local old_rc = core.registered_entities[entity_name].on_rightclick
		core.registered_entities[entity_name].on_rightclick = function(self,clicker)
			if no_sneak or clicker:get_player_control().sneak  then
				if self._on_show_entity_inv then
					self:_on_show_entity_inv (clicker)
				end
				mcl_entity_invs.show_inv_form(self,clicker,"")
				if not no_sneak then return end
			end
			if old_rc then return old_rc(self,clicker) end
		end
	end

	local old_gsd = core.registered_entities[entity_name].get_staticdata
	core.registered_entities[entity_name].get_staticdata  = function(self)
		local old_sd = old_gsd and old_gsd(self)
		local d = old_sd and core.deserialize(old_sd) or {}
		assert(type(d) == "table","mcl_entity_invs currently only works with entities that return a (serialized) table in get_staticdata. "..tostring(self.name).." returned: "..tostring(old_sd))
		d._inv_id = self._inv_id
		d._inv_size = self._inv_size
		d._items = {}
		if self._items then
			for i,it in ipairs(self._items) do
				d._items[i] = it
			end
		end
		return core.serialize(d)
	end

	local old_ode = core.registered_entities[entity_name].on_deactivate
	core.registered_entities[entity_name].on_deactivate = function(self,removal)
		mcl_entity_invs.save_inv(self)
		if removal then
			on_remove(self)
		end
		core.remove_detached_inventory(self._inv_id)
		if old_ode then return old_ode(self,removal) end
	end
end
