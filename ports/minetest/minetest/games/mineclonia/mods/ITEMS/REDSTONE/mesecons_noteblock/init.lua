local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mesecons_noteblock:noteblock", {
	description = S("Note Block"),
	_tt_help = S("Plays a musical note when powered by redstone power"),
	_doc_items_longdesc = S("A note block is a musical block which plays one of many musical notes and different intruments when it is punched or supplied with redstone power."),
	_doc_items_usagehelp = S("Use the note block to choose the next musical note (there are 25 semitones, or 2 octaves). The intrument played depends on the material of the block below the note block:").."\n\n"..

S("• Glass: Sticks").."\n"..
S("• Wood: Bass guitar").."\n"..
S("• Stone: Bass drum").."\n"..
S("• Sand or gravel: Snare drum").."\n"..
S("• Block of Gold: Bell").."\n"..
S("• Clay: Flute").."\n"..
S("• Packed Ice: Chime").."\n"..
S("• Wool: Guitar").."\n"..
S("• Bone Block: Xylophne").."\n"..
S("• Block of Iron: Iron xylophne").."\n"..
S("• Soul Sand: Cow bell").."\n"..
S("• Pumpkin: Didgeridoo").."\n"..
S("• Block of Emerald: Square wave").."\n"..
S("• Hay Bale: Banjo").."\n"..
S("• Glowstone: Electric piano").."\n"..
S("• Anything else: Piano").."\n\n"..

S("The note block will only play a note when it is below air, otherwise, it stays silent."),
	tiles = {"mesecons_noteblock.png"},
	groups = {handy=1,axey=1, material_wood=1, flammable=-1},
	is_ground_content = false,
	place_param2 = 0,
	on_rightclick = function(pos, node, clicker) -- change sound when rightclicked
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return
		end
		node.param2 = (node.param2+1)%25
		mesecon.noteblock_play(pos, node.param2)
		minetest.set_node(pos, node)
	end,
	on_punch = function(pos, node) -- play current sound when punched
		mesecon.noteblock_play(pos, node.param2)
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	mesecons = {effector = { -- play sound when activated
		action_on = function(pos, node)
			mesecon.noteblock_play(pos, node.param2)
		end,
		rules = mesecon.rules.alldirs,
	}},
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
})

minetest.register_craft({
	output = "mesecons_noteblock:noteblock",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "mesecons:redstone", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mesecons_noteblock:noteblock",
	burntime = 15
})

local soundnames_piano = {
	[0] = "mesecons_noteblock_c",
	"mesecons_noteblock_csharp",
	"mesecons_noteblock_d",
	"mesecons_noteblock_dsharp",
	"mesecons_noteblock_e",
	"mesecons_noteblock_f",
	"mesecons_noteblock_fsharp",
	"mesecons_noteblock_g",
	"mesecons_noteblock_gsharp",
	"mesecons_noteblock_a",
	"mesecons_noteblock_asharp",
	"mesecons_noteblock_b",

	"mesecons_noteblock_c2",
	"mesecons_noteblock_csharp2",
	"mesecons_noteblock_d2",
	"mesecons_noteblock_dsharp2",
	"mesecons_noteblock_e2",
	"mesecons_noteblock_f2",
	"mesecons_noteblock_fsharp2",
	"mesecons_noteblock_g2",
	"mesecons_noteblock_gsharp2",
	"mesecons_noteblock_a2",
	"mesecons_noteblock_asharp2",
	"mesecons_noteblock_b2",

	-- TODO: Add dedicated sound file?
	"mesecons_noteblock_b2",
}

local function param2_to_note_color(param2)
	local r, g, b
	if param2 < 8 then -- 0..7
		-- More red, less green
		r = param2 / 8 * 255
		g = (8-param2) / 8 * 255
		b = 0
	elseif param2 < 16 then -- 0..15
		-- More blue, less red
		r = (8-(param2 - 8)) / 8 * 255
		g = 0
		b = (param2 - 8) / 8 * 255
	else -- 16..24
		-- More green, less blue
		r = 0
		g = (param2 - 16) / 9 * 255
		b = (9-(param2 - 16)) / 9 * 255
	end
	r = math.floor(r)
	g = math.floor(g)
	b = math.floor(b)
	local color = 0x10000 * r + 0x100 * g + b
	-- Convert to ColorString
	return string.format("#%06X", color)
end

local function param2_to_pitch(param2)
    return 2^((param2-12)/12)
end

function mesecon.noteblock_play(pos, param2)
	local block_above_name = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
	if block_above_name ~= "air" then
		-- Don't play sound if no air is above
		return
	end

	local block_below_name = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
	local pitched = false
	local soundname, pitch
	if block_below_name == "mcl_core:goldblock" then
		soundname="mesecons_noteblock_bell"
	elseif block_below_name == "mcl_core:clay" then
		soundname="mesecons_noteblock_flute"
	elseif block_below_name == "mcl_core:packed_ice" then
		soundname="mesecons_noteblock_chime"
	elseif block_below_name == "mcl_core:bone_block" then
		soundname="mesecons_noteblock_xylophone_wood"
	elseif block_below_name == "mcl_core:ironblock" then
		soundname="mesecons_noteblock_xylophone_metal"
	elseif block_below_name == "mcl_nether:soul_sand" then
		soundname="mesecons_noteblock_cowbell"
	elseif block_below_name == "mcl_core:emeraldblock" then
		soundname="mesecons_noteblock_squarewave"
	elseif block_below_name == "mcl_farming:hay_block" then
		soundname="mesecons_noteblock_banjo"
	elseif block_below_name == "mcl_nether:glowstone" then
		soundname="mesecons_noteblock_piano_digital"
	elseif minetest.get_item_group(block_below_name, "wool") ~= 0 then
		soundname="mesecons_noteblock_guitar"
	elseif minetest.get_item_group(block_below_name, "pumpkin") ~= 0 then
		soundname="mesecons_noteblock_didgeridoo"
	elseif minetest.get_item_group(block_below_name, "material_glass") ~= 0 then
		soundname="mesecons_noteblock_hit"
	elseif minetest.get_item_group(block_below_name, "material_wood") ~= 0 then
		soundname="mesecons_noteblock_bass_guitar"
	elseif minetest.get_item_group(block_below_name, "material_sand") ~= 0 then
		soundname="mesecons_noteblock_snare"
	elseif minetest.get_item_group(block_below_name, "material_stone") ~= 0 then
		soundname="mesecons_noteblock_bass_drum"
	else
		-- Default: One of 25 piano notes
		soundname = soundnames_piano[param2]
		-- Workaround: Final sound gets automatic higher pitch instead
		if param2 == 24 then
			pitch = 2^(1/12)
		end
		pitched = true
	end
	if not pitched then
		pitch = param2_to_pitch(param2)
	end

	local note_color = param2_to_note_color(param2)

	minetest.add_particle({
		texture = "mcl_particles_note.png^[colorize:"..note_color..":92",
		pos = { x = pos.x, y = pos.y + 0.35, z = pos.z },
		velocity = { x = 0, y = 2, z = 0 },
		acceleration = { x = 0, y = -2, z = 0 },
		expirationtime = 1.0,
		collisiondetection = false,
		size = 3,
	})
	minetest.sound_play(soundname,
	{pos = pos, gain = 1.0, max_hear_distance = 48, pitch = pitch})
end
