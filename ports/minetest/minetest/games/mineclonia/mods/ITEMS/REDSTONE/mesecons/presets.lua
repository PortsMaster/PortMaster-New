mesecon.rules = {}
mesecon.state = {}

mesecon.rules.default =
{{x=0,  y=0,  z=-1},
 {x=1,  y=0,  z=0},
 {x=-1, y=0,  z=0},
 {x=0,  y=0,  z=1},
 {x=0,  y=1,  z=0},
 {x=0,  y=-1, z=0},

 {x=1,  y=1,  z=0},
 {x=1,  y=-1, z=0},
 {x=-1, y=1,  z=0},
 {x=-1, y=-1, z=0},
 {x=0,  y=1,  z=1},
 {x=0,  y=-1, z=1},
 {x=0,  y=1,  z=-1},
 {x=0,  y=-1, z=-1}}

mesecon.rules.alldirs =
{{x= 1, y= 0,  z= 0},
 {x=-1, y= 0,  z= 0},
 {x= 0, y= 1,  z= 0},
 {x= 0, y=-1,  z= 0},
 {x= 0, y= 0,  z= 1},
 {x= 0, y= 0,  z=-1}}

mesecon.rules.pplate =
{{x = 1,  y = 0, z = 0},
 {x =-1,  y = 0, z = 0},
 {x = 0,  y = 1, z = 0},
 {x = 0,  y =-1, z = 0, spread = true},
 {x = 0,  y = 0, z = 1},
 {x = 0,  y = 0, z =-1}}

mesecon.rules.buttonlike =
{{x = 0,  y = 0, z =-1},
 {x = 0,  y = 0, z = 1},
 {x = 0,  y =-1, z = 0},
 {x = 0,  y = 1, z = 0},
 {x =-1,  y = 0, z = 0},
 {x = 1,  y = 0, z = 0, spread = true}}

mesecon.rules.floor =
{{x = 1,  y = 0, z = 0},
 {x =-1,  y = 0, z = 0},
 {x = 0,  y = 1, z = 0},
 {x = 0,  y =-1, z = 0, spread = true},
 {x = 0,  y = 0, z = 1},
 {x = 0,  y = 0, z =-1}}

mesecon.rules.flat =
{{x = 1, y = 0, z = 0},
 {x =-1, y = 0, z = 0},
 {x = 0, y = 0, z = 1},
 {x = 0, y = 0, z =-1}}



-- NOT IN ORIGNAL MESECONS
mesecon.rules.mcl_alldirs_spread =
{{x= 1, y= 0,  z= 0, spread = true},
 {x=-1, y= 0,  z= 0, spread = true},
 {x= 0, y= 1,  z= 0, spread = true},
 {x= 0, y=-1,  z= 0, spread = true},
 {x= 0, y= 0,  z= 1, spread = true},
 {x= 0, y= 0,  z=-1, spread = true}}

-- END OF UNOFFICIAL RULES

local rules_buttonlike = {
	xp = mesecon.rules.buttonlike,
	xn = mesecon.rotate_rules_right(mesecon.rotate_rules_right(mesecon.rules.buttonlike)),
	yp = mesecon.rotate_rules_down(mesecon.rules.buttonlike),
	yn = mesecon.rotate_rules_up(mesecon.rules.buttonlike),
	zp = mesecon.rotate_rules_right(mesecon.rules.buttonlike),
	zn = mesecon.rotate_rules_left(mesecon.rules.buttonlike),
}

local rules_wallmounted = {
	xp = mesecon.rotate_rules_down(mesecon.rules.floor),
	xn = mesecon.rotate_rules_up(mesecon.rules.floor),
	yp = mesecon.rotate_rules_up(mesecon.rotate_rules_up(mesecon.rules.floor)),
	yn = mesecon.rules.floor,
	zp = mesecon.rotate_rules_left(mesecon.rotate_rules_up(mesecon.rules.floor)),
	zn = mesecon.rotate_rules_right(mesecon.rotate_rules_up(mesecon.rules.floor)),
}

local function rules_from_dir(ruleset, dir)
	if dir.x ==  1 then return ruleset.xp end
	if dir.y ==  1 then return ruleset.yp end
	if dir.z ==  1 then return ruleset.zp end
	if dir.x == -1 then return ruleset.xn end
	if dir.y == -1 then return ruleset.yn end
	if dir.z == -1 then return ruleset.zn end
end

function mesecon.rules.buttonlike_get(node)
	local dir = minetest.facedir_to_dir(node.param2)
	return rules_from_dir(rules_buttonlike, dir)
end

function mesecon.rules.wallmounted_get(node)
	local dir = minetest.wallmounted_to_dir(node.param2)
	return rules_from_dir(rules_wallmounted, dir)
end

mesecon.state.on = "on"
mesecon.state.off = "off"
