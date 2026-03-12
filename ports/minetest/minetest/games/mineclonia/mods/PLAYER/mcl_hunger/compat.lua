-- backwards compatibility for callers of the old and deprecated API.
function mcl_hunger.register_food(name, hunger_change, replace_with_item, poisontime, poison, exhaust, poisonchance, sound)
	core.log("error", "mcl_hunger.register_food() is removed and no longer used.")
end
