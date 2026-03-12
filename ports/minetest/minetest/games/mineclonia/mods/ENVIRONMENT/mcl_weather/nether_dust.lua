mcl_weather.nether_dust = {}
mcl_weather.nether_dust.particlespawners = {}

local PARTICLES_COUNT_NETHER_DUST = 150

local S = core.get_translator("mcl_weather")

local psdef= {
	amount = PARTICLES_COUNT_NETHER_DUST,
	time = 0,
	minpos = vector.new(-15,-15,-15),
	maxpos =vector.new(15,15,15),
	minvel = vector.new(-0.3,-0.15,-1),
	maxvel = vector.new(0.3,0.15,0.3),
	minacc = vector.new(-1,-0.4,-1),
	maxacc = vector.new(1,0.4,1),
	minexptime = 1,
	maxexptime = 10,
	minsize = 0.2,
	maxsize = 0.7,
	collisiondetection = false,
	collision_removal = false,
	object_collision = false,
	vertical = false
}

mcl_weather.nether_dust.add_particlespawners = function(player)
	if not mcl_player.get_player_setting(player, "mcl_weather:nether_dust", true) then
		return
	end

	local name=player:get_player_name()
	mcl_weather.nether_dust.particlespawners[name]={}
	psdef.playername = name
	psdef.attached = player
	psdef.glow = math.random(0,core.LIGHT_MAX)
	for i=1,3 do
		psdef.texture="mcl_particles_nether_dust"..i..".png"
		mcl_weather.nether_dust.particlespawners[name][i]=core.add_particlespawner(psdef)
	end
end

mcl_weather.nether_dust.delete_particlespawners = function(player)
	local name=player:get_player_name()
	if mcl_weather.nether_dust.particlespawners[name] then
		for i=1,3 do
			core.delete_particlespawner(mcl_weather.nether_dust.particlespawners[name][i])
		end
		mcl_weather.nether_dust.particlespawners[name]=nil
	end
end

local function update_player_particles(player)
	if not (mcl_worlds.has_dust(player:get_pos()) and mcl_player.get_player_setting(player, "mcl_weather:nether_dust", true)) then
		mcl_weather.nether_dust.delete_particlespawners(player)
	elseif not mcl_weather.nether_dust.particlespawners[player:get_player_name()] then
		mcl_weather.nether_dust.add_particlespawners(player)
	end
end

mcl_worlds.register_on_dimension_change(update_player_particles)
core.register_on_joinplayer(update_player_particles)

core.register_on_leaveplayer(function(player)
	mcl_weather.nether_dust.delete_particlespawners(player)
end)

mcl_player.register_player_setting("mcl_weather:nether_dust", {
        type = "boolean",
	section = "Graphics",
	short_desc = S("Enable dust particles in the nether"),
	ui_default = true,
	on_change = update_player_particles,
})
