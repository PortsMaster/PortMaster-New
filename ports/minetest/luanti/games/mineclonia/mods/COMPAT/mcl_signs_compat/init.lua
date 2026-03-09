
--these are the "rotation strings" of the old sign rotation scheme
local rotkeys = {
	"22_5",
	"45",
	"67_5"
}
--this is a translation table for the old sign rotation scheme to degrotate
--the first level is the itemstring part and the second level represents
--the facedir param2 (+1) mapped to the degrotate param2
local nidp2_degrotate = {
	["22_5"] = {
		225,
		165,
		105,
		45,
	},
	["45"] = {
		210,
		150,
		90,
		30,
	},
	["67_5"] = {
		195,
		135,
		75,
		15,
	}
}
local mcl2standingsigns = {}
mcl2standingsigns["mcl_signs:standing_sign"] = "mcl_signs:standing_sign_oak"
mcl2standingsigns["mcl_signs:standing_sign_acaciawood"] = "mcl_signs:standing_sign_acacia"
mcl2standingsigns["mcl_signs:standing_sign_junglewood"] = "mcl_signs:standing_sign_jungle"
mcl2standingsigns["mcl_signs:standing_sign_birchwood"] = "mcl_signs:standing_sign_birch"
mcl2standingsigns["mcl_signs:standing_sign_darkwood"] = "mcl_signs:standing_sign_dark_oak"
mcl2standingsigns["mcl_signs:standing_sign_sprucewood"] = "mcl_signs:standing_sign_spruce"
mcl2standingsigns["mcl_signs:standing_sign_mangrove_wood"] = "mcl_signs:standing_sign_mangrove"
mcl2standingsigns["mcl_signs:standing_sign_crimson_hyphae_wood"] = "mcl_signs:standing_sign_crimson"
mcl2standingsigns["mcl_signs:standing_sign_warped_hyphae_wood"] = "mcl_signs:standing_sign_warped"
mcl2standingsigns["mcl_signs:standing_sign_cherrywood"] = "mcl_signs:standing_sign_cherry_blossom"

local mcl2rotsigns = {}

for _,v in pairs(rotkeys) do
	mcl2rotsigns["mcl_signs:standing_sign"..v] = "mcl_signs:standing_sign_oak"
	mcl2rotsigns["mcl_signs:standing_sign"..v.."_acaciawood"] = "mcl_signs:standing_sign_acacia"
	mcl2rotsigns["mcl_signs:standing_sign"..v.."_junglewood"] = "mcl_signs:standing_sign_jungle"
	mcl2rotsigns["mcl_signs:standing_sign"..v.."_birchwood"] = "mcl_signs:standing_sign_birch"
	mcl2rotsigns["mcl_signs:standing_sign"..v.."_darkwood"] = "mcl_signs:standing_sign_dark_oak"
	mcl2rotsigns["mcl_signs:standing_sign"..v.."_sprucewood"] = "mcl_signs:standing_sign_spruce"
	mcl2rotsigns["mcl_signs:standing_sign"..v.."_mangrove_wood"] = "mcl_signs:standing_sign_mangrove"
	mcl2rotsigns["mcl_signs:standing_sign"..v.."_crimson_hyphae_wood"] = "mcl_signs:standing_sign_crimson"
	mcl2rotsigns["mcl_signs:standing_sign"..v.."_warped_hyphae_wood"] = "mcl_signs:standing_sign_warped"
	mcl2rotsigns["mcl_signs:standing_sign"..v.."_cherrywood"] = "mcl_signs:standing_sign_cherry_blossom"
end

function mcl_signs.upgrade_sign_meta(pos)
		local m = core.get_meta(pos)
		local col = m:get_string("mcl_signs:text_color")
		local glo = m:get_string("mcl_signs:glowing_sign")
		if col ~= "" then
			m:set_string("color",col)
			m:set_string("mcl_signs:text_color","")
		end
		if glo == "true" then
			m:set_string("glow",glo)
		end
		if glo ~= "" then
			m:set_string("mcl_signs:glowing_sign","")
		end
		mcl_signs.get_text_entity (pos, true) -- the 2nd "true" arg means deleting the entity for respawn
end

function mcl_signs.upgrade_sign_rot(pos,node)
	local numsign = false

	for _,v in pairs(rotkeys) do
		if mcl2rotsigns[node.name] then
			node.name = mcl2rotsigns[node.name]
			node.param2 = nidp2_degrotate[v][node.param2 + 1]
			numsign = true
		elseif node.name:find(v) then
			node.name = node.name:gsub(v,"")
			node.param2 = nidp2_degrotate[v][node.param2 + 1]
			numsign = true
		end
	end

	if not numsign then
		if mcl2standingsigns[node.name] then
			node.name = mcl2standingsigns[node.name]
		end
		local def = core.registered_nodes[node.name]
		if def and def._mcl_sign_type == "standing" then
			if node.param2 == 1 or node.param2 == 121 then
				node.param2 = 180
			elseif node.param2 == 2 or node.param2 == 122 then
				node.param2 = 120
			elseif node.param2 == 3 or node.param2 == 123 then
				node.param2 = 60
			end
		end
	end
	core.swap_node(pos,node)
	mcl_signs.upgrade_sign_meta(pos)
	mcl_signs.update_sign(pos)
end

core.register_lbm({
	nodenames = {"group:sign"},
	name = ":mcl_signs:update_old_signs",
	label = "Update old signs",
	run_at_every_load = false,
	action = mcl_signs.upgrade_sign_rot,
})

for k,_ in pairs(mcl2rotsigns) do table.insert(mcl_signs.old_rotnames, k) end
for k,_ in pairs(mcl2standingsigns) do table.insert(mcl_signs.old_rotnames, k) end
core.register_lbm({
	nodenames = mcl_signs.old_rotnames,
	name = ":mcl_signs:update_old_rotated_standing",
	label = "Update old standing rotated signs",
	run_at_every_load = true, --these nodes are supposed to completely be replaced
	action = mcl_signs.upgrade_sign_rot
})
