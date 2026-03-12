local S = core.get_translator(core.get_current_modname())

local description = S("Firework Rocket")

local function use_rocket(itemstack, user, duration)
	if mcl_serverplayer.is_csm_capable (user) then
		if mcl_serverplayer.use_rocket (user, duration) then
			if not core.is_creative_enabled (user:get_player_name()) then
				itemstack:take_item()
			end
			core.sound_play("mcl_fireworks_rocket", {pos = user:get_pos()})
		end
		return itemstack
	end
	local elytra = mcl_player.players[user].elytra
	if elytra.active then
		elytra.rocketing = duration
		if not core.is_creative_enabled(user:get_player_name()) then
			itemstack:take_item()
		end
		core.sound_play("mcl_fireworks_rocket", {pos = user:get_pos()})
	elseif core.get_item_group(user:get_inventory():get_stack("armor", 3):get_name(), "elytra") ~= 0 then
		mcl_title.set(user, "actionbar", { text = S("Elytra not deployed. Jump while falling down to deploy."), color = "white", stay = 60 })
	else
		mcl_title.set(user, "actionbar", { text = S("Elytra not equipped."), color = "white", stay = 60 })
	end
	return itemstack
end


local function register_rocket(n, duration, force)
	core.register_craftitem("mcl_fireworks:rocket_" .. n, {
		description = description,
		_tt_help = S("Flight Duration: @1s", string.format("%.1f", duration)),
		inventory_image = "mcl_fireworks_rocket.png",
		on_use = function(itemstack, user, pointed_thing)
			return use_rocket(itemstack, user, duration)
		end,
		on_secondary_use = function(itemstack, user, pointed_thing)
			return use_rocket(itemstack, user, duration)
		end,
	})
end

core.register_alias("mcl_bows:rocket", "mcl_fireworks:rocket_2")

register_rocket(1, 2.2, 10)
register_rocket(2, 4.5, 20)
register_rocket(3, 6, 30)
