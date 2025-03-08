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
v.t = 0
v.b = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "gateway")	
	entity_setAllDamageTargets(me, false)
	
	entity_setEntityLayer(me, -2)

	
	
	for i=0,4 do
		bone_setSegs(entity_getBoneByIdx(me, i), 2, 8, 0.8, 0.8, -0.018, 0, 6, 1)
	end
	
	v.b = entity_getNearestNode(me, "gatewayblock")
	if v.b ~= 0 and node_isEntityIn(v.b, me) then
	else
		v.b = 0
	end
	
	entity_setHealth(me, 2)
	
	entity_scale(me, 1.5, 1.5)
	
	entity_generateCollisionMask(me)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setDamageTarget(me, DT_AVATAR_DUALFORMNAIJA, true)
	
	entity_setDeathScene(me, true)
	
	entity_setUpdateCull(me, 3000)
	
	entity_setCullRadius(me, 1024)
	
	entity_setDropChance(me, 100, 2)
	
	loadSound("gateway-die")
	
	entity_setDeathSound(me, "")
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	--entity_updateMovement(me, dt)
	
	entity_handleShotCollisionsSkeletal(me)
	
	if v.b ~= 0 then
		if node_isEntityIn(v.b, v.n) then
			local xd = entity_x(v.n) - node_x(v.b)
			local yd = 0
			vector_setLength(xd, yd, 1000)
			entity_addVel(v.n, xd, yd)
			entity_touchAvatarDamage(me, 0, 1, 0, 1)
			avatar_fallOffWall()
		end
	end
		
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		entity_clearVel(v.n)
		if entity_x(v.n) > entity_x(me) then
			entity_addVel(v.n, 500, 0)
		else
			entity_addVel(v.n, -500, 0)
		end
		entity_touchAvatarDamage(me, 0, 1, 0, 1)
		avatar_fallOffWall()
	end
	
	
	v.t = v.t + dt
	if v.t > 4 then
		local toomany = 4
		local c = 0
		local e = getFirstEntity()
		while e~=0 do
			if entity_isEntityInRange(me, e, 1500) then
				if eisv(e, EV_TYPEID, EVT_GATEWAYMUTANT) then
					c = c + 1
					if c >= toomany then
						break
					end
				end
			end
			e = getNextEntity()
		end
		if c < toomany then
			local e = createEntity("final-mutant", "", entity_x(me), entity_y(me))
			spawnParticleEffect("tinyredexplode", entity_x(e), entity_y(e))
			entity_alpha(e, 0)
			entity_alpha(e, 1, 0.5)
		end
		v.t = 0
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_setStateTime(me, 99)
		
		playSfx("gateway-die")
		
		spawnParticleEffect("gateway-die", entity_x(me), entity_y(me))
		entity_idle(v.n)
		entity_flipToEntity(v.n, me)
		cam_toEntity(me)
		shakeCamera(4, 4)
		entity_offset(me, 5, 0, 0.1, -1)
		entity_setColor(me, 1, 0.2, 0.2, 5)
		for i=0,4 do
			bone_setSegs(entity_getBoneByIdx(me, i), 2, 8, 1, 1, -0.1, 0, 6, 0)
		end
		watch(2)
		cam_toEntity(v.n)
		entity_setStateTime(me, 0)
		
		spawnParticleEffect("gateway-die", entity_x(me), entity_y(me))
		
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_DUALFORMNAIJA then
		return true
	end
	
	playNoEffect()
	return false
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

