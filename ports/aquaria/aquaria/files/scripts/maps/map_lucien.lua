-- Copyright (C) 2007, 2010 - Bit-Blot
--
-- This file is part of Aquaria.
--
-- Aquaria is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.doScene = true
v.debugEnd = false

function init()
	fade2(0, 1, 1, 1, 1)
	
	loadSound("mother")
	loadSound("proploop")
	loadSound("airship-engineloop")
	loadSound("airship-boost")
	loadSound("airship-onboard")
	
	if v.doScene then
	
		local ship = getEntity("airship")
		
		local start = getNode("naijastart")
		local l1 = getNode("l1")
		local lu = getEntity("lucien")
		entity_setPosition(getNaija(), node_x(start), node_y(start))
		
		local camDummy = createEntity("Empty")
		
		overrideZoom(1.2)
		
		entity_animate(lu, "crystal", -1)
		
		cam_toNode(l1)
		watch(1)
		
		entity_animate(lu, "crystal", -1)
	
		playMusicOnce("lucien")
		
		watch(4)
		
		overrideZoom(0.9, 10)
		
		fade(0, 3)
		watch(3)
		
		spawnParticleEffect("spiritbeacon", node_x(l1), node_y(l1))
		
		playSfx("spirit-beacon")
		watch(0.5)
		entity_animate(lu, "idle", -1)
		playSfx("spirit-return")
		watch(0.5)
		playSfx("mother")
		--centerText("...mother...")
		
		watch(2)
		fade(1, 3)
		watch(3)
		
		--centerText("")
		
		cam_toNode(getNode("ship"))
		watch(2)
		overrideZoom(0.9)
		overrideZoom(0.6, 10)
		
		local sfx = playSfx("proploop", 0, 0.1)
		
		fade(0, 3)
		watch(3)
		watch(3)
		fade(1, 3)
		watch(3)
		fadeSfx(sfx, 3)
		
		
		cam_toNode(getNode("l2"))
		watch(1)
		
		overrideZoom(1.0, 10)
		
		fade(0, 3)
		watch(3)
		watch(3)
		fade(1, 3)
		watch(3)
		
		watch(4)
		
		cam_toEntity(ship)
		-- get out of water
		watch(2)
		playSfx("splash-outof")
		watch(1)
		
		playSfx("airship-onboard")
		watch(2.2)
		
		local engineLoop = playSfx("airship-engineloop", 0, 0.4)
		
		
		entity_fh(lu)
		entity_animate(lu, "fly", -1)
		
		entity_msg(ship, "attach", lu)
		
		watch(1)
		
		playMusicOnce("flyaway")
		
		overrideZoom(0.55)
		
		overrideZoom(0.3, 30)
		
		local flyNode = getNode("fly")
		entity_setPosition(ship, node_x(flyNode), node_y(flyNode), 30, 0, 0, 1) 
		
		sfx = playSfx("proploop", 0, 0.2)
		
		playSfx("airship-boost")
		
		local node = getNode("airshipboost")
		spawnParticleEffect("tinyredexplode", node_x(node), node_y(node))
		
		fade(0, 3)
		watch(3)
		
		watch(6)
		
		fadeSfx(sfx, 20)
		fadeSfx(engineLoop, 20)
		watch(4)
		
		centerText("To Be Continued...")
		
		watch(4)
		

		fade(1, 4)
		watch(4)
		
		fade2(1, 1, 0, 0, 0)
		
		watch(4)
		
		if v.debugEnd then
			fade(0, 1)
			cam_toEntity(getNaija())
		else
			setFlag(FLAG_SKIPSECRETCHECK, 1)
			loadMap("thirteenlair")
		end
	end
end

