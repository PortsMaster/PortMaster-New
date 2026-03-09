-- Liquids: Water and lava

local S = core.get_translator(core.get_current_modname())

--local WATER_ALPHA = 179
local WATER_VISC = 1
local LAVA_VISC = 7
local LIGHT_LAVA = core.LIGHT_MAX

core.register_node("mcl_core:water_flowing", {
	description = S("Flowing Water"),
	_doc_items_create_entry = false,
	wield_image = "default_water_flowing_animated.png^[verticalframe:64:0",
	drawtype = "flowingliquid",
	tiles = {"default_water_flowing_animated.png^[verticalframe:64:0"},
	special_tiles = {
		{
			name = "default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
		{
			name = "default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
	},
	sounds = mcl_sounds.node_sound_water_defaults(),
	is_ground_content = false,
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mcl_core:water_flowing",
	liquid_alternative_source = "mcl_core:water_source",
	liquid_viscosity = WATER_VISC,
	liquid_range = 7,
	waving = 3,
	post_effect_color = {a=60, r=0x03, g=0x3C, b=0x5C},
	groups = { liquid_flowing=1, water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1, freezes=1, melt_around=1, dig_by_piston=1, unsticky = 1},
	_pathfinding_class = "WATER",
	_on_bottle_place = mcl_core.get_bottle_place_on_water("mcl_potions:water"),
	_mcl_blast_resistance = 100,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

core.register_node("mcl_core:water_source", {
	description = S("Water Source"),
	_doc_items_entry_name = S("Water"),
	_doc_items_longdesc =
S("Water is abundant in oceans and also appears in a few springs in the ground. You can swim easily in water, but you need to catch your breath from time to time.").."\n\n"..
S("Water interacts with lava in various ways:").."\n"..
S("• When water is directly above or horizontally next to a lava source, the lava turns into obsidian.").."\n"..
S("• When flowing water touches flowing lava either from above or horizontally, the lava turns into cobblestone.").."\n"..
S("• When water is directly below lava, the water turns into stone."),
	_doc_items_hidden = false,
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{name="default_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name = "default_water_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
			backface_culling = false,
		}
	},
	sounds = mcl_sounds.node_sound_water_defaults(),
	is_ground_content = false,
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "source",
	liquid_alternative_flowing = "mcl_core:water_flowing",
	liquid_alternative_source = "mcl_core:water_source",
	liquid_viscosity = WATER_VISC,
	liquid_range = 7,
	post_effect_color = {a=60, r=0x03, g=0x3C, b=0x5C},
	groups = { liquid_source=1, water=3, liquid=3, puts_out_fire=1, freezes=1, not_in_creative_inventory=1, dig_by_piston=1, unsticky = 1},
	_pathfinding_class = "WATER",
	_on_bottle_place = mcl_core.get_bottle_place_on_water("mcl_potions:water"),
	_mcl_blast_resistance = 100,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
	after_destruct = core.check_for_falling,
})

core.register_node("mcl_core:lava_flowing", {
	description = S("Flowing Lava"),
	_doc_items_create_entry = false,
	wield_image = "default_lava_flowing_animated.png^[verticalframe:64:0",
	drawtype = "flowingliquid",
	tiles = {"default_lava_flowing_animated.png^[verticalframe:64:0"},
	special_tiles = {
		{
			name = "default_lava_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=6.6}
		},
		{
			name = "default_lava_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=6.6}
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source = LIGHT_LAVA,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_lava_defaults(),
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	--[[ Drowning in Minecraft deals 2 damage per second.
	In Minetest, drowning damage is dealt every 2 seconds so this
	translates to 4 drowning damage ]]
	drowning = 0,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mcl_core:lava_flowing",
	liquid_alternative_source = "mcl_core:lava_source",
	liquid_viscosity = LAVA_VISC,
	liquid_renewable = false,
	liquid_range = 3,
	damage_per_second = 4*2,
	post_effect_color = {a=245, r=208, g=73, b=10},
	groups = { liquid_flowing=1, lava=3, liquid=2, destroys_items=1, not_in_creative_inventory=1, dig_by_piston=1, set_on_fire=15, unsticky = 1},
	_pathfinding_class = "LAVA",
	_mcl_blast_resistance = 100,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

local fire_text
local fire_enabled = core.settings:get_bool("enable_fire", true)
if fire_enabled then
	fire_text = S("A lava source sets fire to a couple of air blocks above when they're next to a flammable block.")
else
	fire_text = ""
end

core.register_node("mcl_core:lava_source", {
	description = S("Lava Source"),
	_doc_items_entry_name = "Lava",
	_doc_items_longdesc =
S("Lava is hot and rather dangerous. Don't touch it, it will hurt you a lot and it is hard to get out.").."\n"..
fire_text.."\n\n"..
S("Lava interacts with water various ways:").."\n"..
S("• When a lava source is directly below or horizontally next to water, the lava turns into obsidian.").."\n"..
S("• When flowing water touches flowing lava either from above or horizontally, the lava turns into cobblestone.").."\n"..
S("• When lava is directly above water, the water turns into stone."),
	drawtype = "liquid",
	tiles = {
		{name="default_lava_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}
	},
	special_tiles = {
		-- New-style lava source material (mostly unused)
		{
			name="default_lava_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0},
			backface_culling = false,
		}
	},
	paramtype = "light",
	light_source = LIGHT_LAVA,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_lava_defaults(),
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 0,
	liquidtype = "source",
	liquid_alternative_flowing = "mcl_core:lava_flowing",
	liquid_alternative_source = "mcl_core:lava_source",
	liquid_viscosity = LAVA_VISC,
	liquid_renewable = false,
	liquid_range = 3,
	damage_per_second = 4*2,
	post_effect_color = {a=245, r=208, g=73, b=10},
	groups = { liquid_source=1, lava=3, lava_source=1, liquid=2, destroys_items=1, not_in_creative_inventory=1, dig_by_piston=1, set_on_fire=15, fire_damage=1, unsticky = 1},
	_pathfinding_class = "LAVA",
	_mcl_blast_resistance = 100,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
	after_destruct = core.check_for_falling,
})

local function emit_lava_particle(pos)
	local node = core.get_node(pos)
	if core.get_item_group(node.name, "lava_source") == 0 then
		return
	end
	local ppos = vector.add(pos, { x = math.random(-7, 7)/16, y = 0.45, z = math.random(-7, 7)/16})
	--local spos = vector.add(ppos, { x = 0, y = -0.2, z = 0 })
	local vel = { x = math.random(-3, 3)/10, y = math.random(4, 7), z = math.random(-3, 3)/10 }
	local acc = { x = 0, y = -9.81, z = 0 }
	-- Lava droplet
	core.add_particle({
		pos = ppos,
		velocity = vel,
		acceleration = acc,
		expirationtime = 2.5,
		collisiondetection = true,
		collision_removal = true,
		size = math.random(20, 30)/10,
		texture = "mcl_particles_lava.png",
		glow = LIGHT_LAVA,
	})
end

if core.settings:get("mcl_node_particles") == "full" then
	core.register_abm({
		label = "Lava particles",
		nodenames = {"group:lava_source"},
		interval = 8.0,
		chance = 20,
		action = function(pos)
			local apos = {x=pos.x, y=pos.y+1, z=pos.z}
			local anode = core.get_node(apos)
			-- Only emit partiles when directly below lava
			if anode.name ~= "air" then
				return
			end

			core.after(math.random(0, 800)*0.01, emit_lava_particle, pos)
		end,
	})
end


mcl_liquids.register_liquid({
	name_flowing = "mcl_core:water_flowing",
	name_source = "mcl_core:water_source",

	tick_duration = 1.0 / 4.0,
	range_spread = 7,
	renewable = true,
})


mcl_liquids.register_liquid({
	name_flowing = "mcl_core:lava_flowing",
	name_source  = "mcl_core:lava_source",

	tick_duration = 3.0/2.0,
	range_spread = 3,
	renewable = false,
})

