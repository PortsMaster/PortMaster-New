--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes
mobs_mc = {}

local offsets = {}
for x=-2, 2 do
	for z=-2, 2 do
		table.insert(offsets, {x=x, y=0, z=z})
	end
end

mobs_mc.water_level = tonumber(core.settings:get("water_level")) or 0
mobs_mc.is_mob_griefing_enabled = function(mob_name)
	for _, mob in pairs((core.settings:get("mobs_griefing_disable_individual") or ""):split(",")) do
		mob = mob:trim()
		if mob == mob_name then
			return false
		end
	end
	return core.settings:get_bool("mobs_griefing", true)
end

-- Load mobs in the right order.
local path = core.get_modpath(core.get_current_modname())
local files = {
	"spawning.lua",
	"axolotl.lua",
	"bat.lua",
	"blaze.lua",
	"chicken.lua",
	"cod.lua",
	"cow+mooshroom.lua",
	"creeper.lua",
	"dolphin.lua",
	"ender_dragon.lua",
	"enderman.lua",
	"endermite.lua",
	"ghast.lua",
	"guardian.lua",
	"guardian_elder.lua",
	"hoglin+zoglin.lua",
	"horse.lua",
	"illager_common.lua",
	"iron_golem.lua",
	"llama.lua",
	"ocelot.lua",
	"parrot.lua",
	"pig.lua",
	"pillager.lua",
	"polar_bear.lua",
	"pufferfish.lua",
	"rabbit.lua",
	"ravager.lua",
	"salmon.lua",
	"sheep.lua",
	"shulker.lua",
	"silverfish.lua",
	"skeleton+stray.lua",
	"skeleton_wither.lua",
	"slime+magma_cube.lua",
	"snowman.lua",
	"spider.lua",
	"squid+glow_squid.lua",
	"strider.lua",
	"tropical_fish.lua",
	"vex.lua",
	"villager_evoker.lua",
	"villager_illusioner.lua",
	"villager.lua",
	"villager_vindicator.lua",
	"wandering_trader.lua",
	"witch.lua",
	"wither.lua",
	"wolf.lua",
	"zombie.lua",
	"drowned.lua",
	"villager_zombie.lua",
	"zombiepig.lua",
	"piglin.lua",
}
for _, file in pairs (files) do
	dofile (path .. "/" .. file)
end
