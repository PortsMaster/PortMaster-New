lightning = {
	auto = true,
	effect_range = 500,
}
setmetatable(lightning, { __index = mcl_lightning })

core.register_alias("lightning:dying_flame", "mcl_fire:fire")
