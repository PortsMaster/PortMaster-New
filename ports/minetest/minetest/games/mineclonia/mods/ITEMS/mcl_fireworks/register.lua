local S = minetest.get_translator(minetest.get_current_modname())

local tt_help = S("Flight Duration:")
local description = S("Firework Rocket")

local function register_rocket(n, duration, force)
	minetest.register_craftitem("mcl_fireworks:rocket_" .. n, {
		description = description,
		_tt_help = tt_help .. " " .. duration,
		inventory_image = "mcl_fireworks_rocket.png",
		on_use = function(itemstack, user, pointed_thing)
			local elytra = mcl_player.players[user].elytra
			if elytra.active and elytra.rocketing <= 0 then
				elytra.rocketing = duration
				if not minetest.is_creative_enabled(user:get_player_name()) then
					itemstack:take_item()
				end
				minetest.sound_play("mcl_fireworks_rocket", {pos = user:get_pos()})
			end
			return itemstack
		end,
	})
end

minetest.register_alias("mcl_bows:rocket", "mcl_fireworks:rocket_2")

register_rocket(1, 2.2, 10)
register_rocket(2, 4.5, 20)
register_rocket(3, 6, 30)
