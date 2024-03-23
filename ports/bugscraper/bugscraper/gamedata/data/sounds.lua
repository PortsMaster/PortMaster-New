require "util"

local function new_source(path, type, args)
	local source = love.audio.newSource("sfx/"..path, type)
	if not args then  return source  end
	
	if args.looping then
		source:setLooping(true)
	end
	return source
end

local sounds = {}

--music_level_1 = new_source("music/level_1.mp3", "stream", {looping = true})
local sfxnames = {
	"jump", "jump1.wav",
	"shot1", "shot1.wav", -- these are pico 8 sfx from birds with guns
	"shot2", "shot2.wav",
	"shot3", "shot3.wav",
	"gunshot1", "gunshot1.wav",
	"gunshot_machinegun", "gunshot_machinegun.wav",
	"gunshot_shotgun", "gunshot_shotgun.wav",
	"gunshot_ring_1", "gunshot_ring_1.wav",
	"gunshot_ring_2", "gunshot_ring_2.wav",
	"gunshot_ring_3", "gunshot_ring_3.wav",
	"pop_ring", "pop_ring.wav",
	
	"hurt",  "hurt.wav",
	"land",  "land.wav",
	"item_collect", "item_collect.wav",

	"menu_hover_old", "menu_hover.wav",
	"menu_hover",     "menu_hover_5.ogg",
	"menu_select_old", "menu_select.wav",
	"menu_select",     "menu_select_2.ogg",
	
	"wall_slide", "wall_slide.wav",
	"game_over_1", "game_over_1.wav",
	"game_over_2", "game_over_2.wav",
	
	"explosion", "explosion.wav",
	
	"sliding_wall_metal", "sliding_wall_metal.wav",
	
	"footstep00", "footstep00.wav", -- CC0 https://kenney.nl/
	"footstep01", "footstep01.wav",
	"footstep02", "footstep02.wav",
	"footstep03", "footstep03.wav",
	"footstep04", "footstep04.wav",
	"footstep05", "footstep05.wav",
	"footstep06", "footstep06.wav",
	"footstep07", "footstep07.wav",
	"footstep08", "footstep08.wav",
	"footstep09", "footstep09.wav",
	
	"metalfootstep_00", "footstep/metalfootstep_000.ogg", -- CC0 https://kenney.nl/
	"metalfootstep_01", "footstep/metalfootstep_001.ogg",
	"metalfootstep_02", "footstep/metalfootstep_002.ogg",
	"metalfootstep_03", "footstep/metalfootstep_003.ogg",
	"metalfootstep_04", "footstep/metalfootstep_004.ogg",
	
	"impactglass_heavy_000", "impactglass_heavy_000.ogg", -- CC0 https://kenney.nl/
	"impactglass_heavy_001", "impactglass_heavy_001.ogg",
	"impactglass_heavy_002", "impactglass_heavy_002.ogg",
	"impactglass_heavy_003", "impactglass_heavy_003.ogg",
	"impactglass_heavy_004", "impactglass_heavy_004.ogg",
	
	"impactglass_light_000", "impactglass_light_000.ogg",
	"impactglass_light_001", "impactglass_light_001.ogg",
	"impactglass_light_002", "impactglass_light_002.ogg",
	"impactglass_light_003", "impactglass_light_003.ogg",
	"impactglass_light_004", "impactglass_light_004.ogg",
	
	"glass_fracture", "glass_fracture.wav", -- CC BY https://freesound.org/people/cmusounddesign/sounds/85168/
	"glass_break", "glass_break.wav", 
	-- CC0  window shatter https://freesound.org/people/avrahamy/sounds/141563/
	-- + combined & deeper CCBY   glass shatter https://freesound.org/people/cmusounddesign/sounds/85168/
	-- + combined & fade out CCBY sprinkle texture https://freesound.org/people/el-bee/sounds/636238/
	
	"button_press", "button_press.wav",
	-- CCBY RICHERlandTV Buzz https://freesound.org/people/RICHERlandTV/sounds/216090/
	-- CCBY keypress slowed down https://freesound.org/people/MattRuthSound/sounds/561661/
	-- CC0 Impact Sound https://kenney.nl/
	
	"cloth1", "cloth1.wav", -- CC0 Kenney
	"cloth2", "cloth2.wav",
	"cloth3", "cloth3.wav",
	"cloth_drop", "cloth_drop.wav", -- CC0 Kenney + CC0 https://freesound.org/people/RossBell/sounds/389442/
	
	"larva_damage1", "larva_damage1.wav",
	"larva_damage2", "larva_damage2.wav",
	"larva_damage3", "larva_damage3.wav",
	"larva_death", "larva_death.wav",
	
	"fly_buzz", "fly_buzz.wav",
	
	"elevator_bg", "elevator_bg.wav",
	"elev_door_open", "elev_door_open.wav",
	"elev_door_close", "elev_door_close.wav",
	"elev_burning", "elev_burning.wav",
	"elev_ding", "elev_ding.wav",
	
	"gravel_footstep_1", "gravel_footstep_1.wav",
	"gravel_footstep_2", "gravel_footstep_2.wav",
	"gravel_footstep_3", "gravel_footstep_3.wav",
	"gravel_footstep_4", "gravel_footstep_4.wav",
	"gravel_footstep_5", "gravel_footstep_5.wav",
	"gravel_footstep_6", "gravel_footstep_6.wav",
	
	"elev_crash", "elev_crash.wav",
	"elev_siren", "elev_siren.wav",
	"mushroom_ant_pop", "mushroom_ant_pop.wav",
	
	"enemy_damage", "enemy_damage.wav",
	"enemy_death_1", "enemy_death_1.wav",
	"enemy_death_2", "enemy_death_2.wav",
	"enemy_stomp_2", "enemy_stomp_2.wav",
	"enemy_stomp_3", "enemy_stomp_3.wav",
	
	"snail_shell_crack", "snail_shell_crack.wav",
	"triple_pop", "triple_pop.wav",

	"crush_bug_1", "crush_bug_1.wav",
	"crush_bug_2", "crush_bug_2.wav",
	"crush_bug_3", "crush_bug_3.wav",
	"crush_bug_4", "crush_bug_4.wav",

	"jump_short", "jump_short.wav"
}

for i=1, #sfxnames, 2 do    sounds[sfxnames[i]] = new_source(sfxnames[i+1], "static")    end

sounds.shot1:setVolume(0.9)
sounds.shot2:setPitch(0.8)

sounds.menu_hover:setPitch(1.23)
sounds.menu_hover:setVolume(0.5)
sounds.menu_select:setPitch(0.7)

sounds.sliding_wall_metal:setLooping(true)
sounds.sliding_wall_metal:setVolume(0.1)
sounds.elevator_bg:setVolume(0.5)
sounds.elevator_bg:setLooping(true)
sounds.elev_door_open:setVolume(0.3)
sounds.elev_door_close:setVolume(0.3)

sounds.elev_burning:setLooping(true)

sounds.fly_buzz:setLooping(true)

for i=0,9 do
	sounds["footstep0"..tostring(i)]:setVolume(0.2)
end

sounds.music_galaxy_trip = new_source("music/music_galaxy_trip.wav", "static", {looping = true})

-- Static sounds are sounds that are played without the use of the audio:play function
-- local static_sfx_names = {
-- 	"music1",
-- 	"elevator_bg",
-- 	"elev_door_open",
-- 	"elev_door_close",
-- 	"elev_burning",
-- 	"elev_siren",
-- 	"sliding_wall_metal",
-- 	"fly_buzz"
-- }
-- local static_sounds = {}
-- for _,v in pairs(static_sfx_names) do
-- 	table.insert(static_sounds, sounds[v])
-- end

-- All sources are tables to support multiple sounds playing at once without using Source:clone()
for k, snd in pairs(sounds) do
	sounds[k] = {
		snd,
		pitch = snd:getPitch(),
		volume = snd:getVolume(),
		is_looping = snd:isLooping(),
	}
end

return sounds