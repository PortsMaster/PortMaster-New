local mob_class = mcl_mobs.mob_class

local function player_near(pos)
	for _,o in pairs(minetest.get_objects_inside_radius(pos,2)) do
		if o:is_player() then return true end
	end
end

local function get_armor_texture(armor_name)
	if armor_name == "" then
		return ""
	end
	if armor_name=="blank.png" then
		return "blank.png"
	end
	local seperator = string.find(armor_name, ":")
	return "mcl_armor_"..string.sub(armor_name, seperator+1, -1)..".png^"
end

function mob_class:set_armor_texture()
	if self.armor_list then
		local chestplate=minetest.registered_items[self.armor_list.chestplate] or {name=""}
		local boots=minetest.registered_items[self.armor_list.boots] or {name=""}
		local leggings=minetest.registered_items[self.armor_list.leggings] or {name=""}
		local helmet=minetest.registered_items[self.armor_list.helmet] or {name=""}

		if helmet.name=="" and chestplate.name=="" and leggings.name=="" and boots.name=="" then
			helmet={name="blank.png"}
		end
		local texture = get_armor_texture(chestplate.name)..get_armor_texture(helmet.name)..get_armor_texture(boots.name)..get_armor_texture(leggings.name)
		if string.sub(texture, -1,-1) == "^" then
			texture=string.sub(texture,1,-2)
		end
		if self.base_texture[self.wears_armor] then
			self.base_texture[self.wears_armor]=texture
		end
		self:set_properties({textures=self.base_texture})

		local armor_
		if type(self.armor) == "table" then
			armor_ = table.copy(self.armor)
			armor_.immortal = 1
		else
			armor_ = {immortal=1, fleshy = self.armor}
		end

		for _,item in pairs(self.armor_list) do
			if not item then return end
			if type(minetest.get_item_group(item, "mcl_armor_points")) == "number" then
				armor_.fleshy=armor_.fleshy-(minetest.get_item_group(item, "mcl_armor_points")*3.5)
			end
		end
		self.object:set_armor_groups(armor_)
	end
end

function mob_class:check_item_pickup()
	if self.pick_up and #self.pick_up > 0 or self.wears_armor then
		local p = self.object:get_pos()
		if not p then return end
		for _,o in pairs(minetest.get_objects_inside_radius(p,2)) do
			local l=o:get_luaentity()
			if l and l.name == "__builtin:item" then
				if not player_near(p) and l.itemstring:find("mcl_armor") and self.wears_armor then
					local armor_type
					if l.itemstring:find("chestplate") then
						armor_type = "chestplate"
					elseif l.itemstring:find("boots") then
						armor_type = "boots"
					elseif l.itemstring:find("leggings") then
						armor_type = "leggings"
					elseif l.itemstring:find("helmet") then
						armor_type = "helmet"
					end
					if not armor_type then
						return
					end
					if not self.armor_list then
						self.armor_list={helmet="",chestplate="",boots="",leggings=""}
					elseif self.armor_list[armor_type] and self.armor_list[armor_type] ~= "" then
						return
					end
					self.armor_list[armor_type]=ItemStack(l.itemstring):get_name()
					o:remove()
				end
				if self.pick_up then
					for k,v in pairs(self.pick_up) do
						if not player_near(p) and self.on_pick_up and ItemStack(l.itemstring):get_name() == v then
							local r =  self.on_pick_up(self,l)
							if  r and r.is_empty and not r:is_empty() then
								l.itemstring = r:to_string()
							elseif r and r.is_empty and r:is_empty() then
								o:remove()
							end
						end
					end
				end
			end
		end
	end
end
