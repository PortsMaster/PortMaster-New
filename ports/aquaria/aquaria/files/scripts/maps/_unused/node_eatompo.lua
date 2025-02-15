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

v.n = 0
v.boss = 0
v.ompo = 0
v.start = 0
v.goto = 0
v.eatPos = 0

function init(me)
	v.start = getNode("OMPOSTART")
	v.goto = getNode("OMPOGOTO")
	v.boss = getEntity("EnergyBoss")
	v.eatPos = getNode("EATPOS")
	v.n = getNaija()
	if isFlag(FLAG_OMPO, 4) then
		entity_alpha(v.boss, 0)
	end
end

v.c = false
function update(me)
	if v.c then return end
	
	if node_isEntityIn(me, v.n) and isFlag(FLAG_OMPO, 4) and isFlag(FLAG_ENERGYBOSSDEAD, 0) then
		v.c = true
		
		
		entity_idle(v.n)
		if entity_isfh(v.n) then entity_fh(v.n) end
		musicVolume(0.5, 1)
		watch(1)
		
		
		
		v.ompo = createEntity("Ompo", "", node_x(v.start), node_y(v.start))
		entity_alpha(v.ompo, 0)
		entity_alpha(v.ompo, 1, 1)
		entity_setState(v.ompo, STATE_INTRO)
		entity_flipToEntity(v.ompo, v.n)
		
		playSfx("Ompo")
		watch(0.5)
		
		--cam_toEntity(v.ompo)
		
		entity_setPosition(v.ompo, node_x(v.goto), node_y(v.goto), 3, 0, 0, 1)
		--entity_setEntityLayer(v.ompo, 0)
		watch(3)
		
		musicVolume(0, 5)
		watch(1)
		
		-- do animation stuff
		
		
		
		entity_alpha(v.boss, 1, 0.1)
		entity_setPosition(v.boss, node_x(v.eatPos), node_y(v.eatPos))
		
		--
		entity_setState(v.boss, STATE_APPEAR)
		
		watch(1.3)
		
		emote(EMOTE_NAIJAUGH)
		
		setGameSpeed(0.5)
		
		watch(0.5)
		
		setGameSpeed(1)
		
		entity_alpha(v.ompo, 0)
		entity_setPosition(v.ompo, 0, 0)
		
		-- now,  set the bone on
		local boneOmpo = entity_getBoneByName(v.boss, "Ompo")
		
		bone_setVisible(boneOmpo, true)
		bone_scale(boneOmpo, 0.4, 0.4)
		
		watch(0.1)
		
		playSfx("Bite")
		
		cam_toEntity(v.boss)
	
		--[[
		watch(0.5)
		local ct = 0
		while entity_isAnimating(boss) do
			watch(0.2)
			--playSfx("Bite")
			
			ct = ct + 1
			if ct >= 2 then
				
				break
			end
		end
		
		watch(2)
		playSfx("Gulp")
		]]--
		
		while entity_isAnimating(v.boss) do
			watch(FRAME_TIME)
		end
		
		bone_scale(boneOmpo, 0, 0, 0.5)
		--watch(0.5)
		
		
		cam_toEntity(v.boss)
		
		entity_setState(v.boss, STATE_INTRO)
		
		watch(1.5)
		
		playMusic("BigBoss")
		
		cam_toEntity(v.n)
		
		setFlag(FLAG_OMPO, 5)
		
		v.c = false
	end
end
