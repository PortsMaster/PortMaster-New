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

v.file = ""

v.entToSpawn = ""
v.ingToSpawn = ""
v.amount = 0

v.breakSound = ""

v.spawnTimes = 1

v.sfxVol = 1

function v.commonInit(me, fle, cr, h, num, snd, ignoreSets, stimes, svol)
	if svol and svol ~= 0 then
		v.sfxVol = svol
	end
	
	setupEntity(me)
	v.breakSound = snd
	
	entity_setTexture(me, fle)
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setCollideRadius(me, cr)
	entity_setHealth(me, h)
	
	entity_setDeathScene(me, true)
	entity_setDeathSound(me, "")
	
	v.file = fle
	v.numSpawn = num
	
	entity_setEatType(me, EAT_NONE)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setUpdateCull(me, 3000)
	
	if not ignoreSets then
		local n1 = getNearestNodeByType(entity_x(me), entity_y(me), PATH_SETING)
		if n1 ~= 0 and node_isEntityIn(n1, me) then
			v.ingToSpawn = node_getContent(n1)
			v.amount = node_getAmount(n1)	if v.amount == 0 then v.amount = 1 end
		else
			local n2 = getNearestNodeByType(entity_x(me), entity_y(me), PATH_SETENT)
			if n2 ~= 0 and node_isEntityIn(n2, me) then
				v.entToSpawn = node_getContent(n2)
				v.amount = node_getAmount(n2)	if v.amount == 0 then v.amount = 1 end
			end
		end
	end
	
	esetv(me, EV_TYPEID, EVT_CONTAINER)
	
	v.spawnTimes = stimes
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_handleShotCollisions(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	elseif entity_isState(me, STATE_DEAD) then
		if v.ingToSpawn ~= "" or v.entToSpawn ~= "" then
			playSfx("secret", 0, 0.7)
		end
	elseif entity_isState(me, STATE_DEATHSCENE) then
		spawnParticleEffect("SmallBubbleExplosion", entity_getPosition(me))
		for i=1,v.spawnTimes do
			for i=1,v.numSpawn do
				debugLog("Spawning")
				local e = createEntity("BrokenPiece", "", entity_x(me), entity_y(me))
				local str = string.format("%s-000%d", v.file, i)
				--debugLog(str)
				entity_setTexture(e, str)
			end
		end
		entity_setStateTime(me, 0.1)
		if v.ingToSpawn ~= "" then
			for i=1,v.amount do
				spawnIngredient(v.ingToSpawn, entity_x(me), entity_y(me))
			end
		elseif v.entToSpawn ~= "" then
			
			for i=1,v.amount do
				createEntity(v.entToSpawn, "", entity_x(me), entity_y(me))
			end
		end
		entity_alpha(me, 0, 0.1)
		entity_setStateTime(me, 0.1)
		playSfx(v.breakSound, 0, v.sfxVol)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

