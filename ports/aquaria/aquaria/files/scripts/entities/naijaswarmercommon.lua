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

v.minCap = 400
v.maxCap = 700
v.cap = v.minCap

v.body = 0
v.glow = 0

v.singingDelay = 0

v.curNote = 0

v.singing = false

function v.commonInit(me, tex)	
	v.add = math.random(50)

	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "minnow")
	
	--entity_setTexture(me, "title/minnow")
	entity_setAllDamageTargets(me, false)

	v.body = entity_getBoneByName(me, "Body")
	v.glow = entity_getBoneByName(me, "Glow")
	
	if tex ~= "" then
		bone_setTexture(v.body, tex)
	end
	
	if chance(50) then
		entity_setEntityLayer(me, 0)
	else
		entity_setEntityLayer(me, 1)
	end
	
	--entity_setEntityLayer(me, -1)
	
	--entity_alpha(me, 0.5)
	
	bone_alpha(v.body, 0.5)
	
	entity_setState(me, STATE_IDLE)
	esetv(me, EV_LOOKAT, 0)
	
	bone_setBlendType(v.glow, BLEND_ADD)
	
	bone_alpha(v.glow, 0)
	bone_scale(v.glow, 2, 2)
	bone_scale(v.glow, 4, 4, 1, -1, 1)
	
	entity_addRandomVel(me, 600)
	
	esetv(me, EV_LOOKAT, 0)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)	
	v.cap = v.cap - dt*400
	if v.cap < v.minCap then
		v.cap = v.minCap
	end
	local add = v.add
	if v.singing and avatar_isBursting() then
		v.cap = v.maxCap
		add = 600
	end
	--entity_doCollisionAvoidance(me, dt, 4, 0.5)
	
	
	entity_doCollisionAvoidance(me, dt, 5, 0.5)
	
	--local x, y = getMouseWorldPos()
	
	if v.singing then
		local x, y = entity_getPosition(v.n)
		
		entity_moveTowards(me, x, y, dt, 300+add)
		
		entity_doEntityAvoidance(me, dt, 32, 0.5)
		
		if v.singingDelay > 0 then
			v.singingDelay = v.singingDelay - dt
			if v.singingDelay < 0 then
				v.singing = false
			end
		end
	else
		local ent = entity_getNearestEntity(me, entity_getName(me), 256)
		if ent ~= 0 then
			local x, y = entity_getPosition(ent)
			entity_moveTowards(me, x, y, dt, 800+add)
		end
		entity_doEntityAvoidance(me, dt, 40, 0.5)
		--entity_doEntityAvoidance(me, dt, 32, 
	end
	
	local vx = entity_velx(me)
	local vy = entity_vely(me)
	
	vx, vy = vector_cap(vx, vy, v.cap)
	entity_clearVel(me)
	entity_addVel(me, vx, vy)
	
	entity_setPosition(me, entity_x(me) + entity_velx(me)*dt, entity_y(me)+entity_vely(me)*dt)

	--entity_updateMovement(me, dt)
	entity_rotateToVel(me)
	
	local len = vector_getLength(vx, vy)
	addInfluence(entity_x(me), entity_y(me), 16, len)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
	v.curNote = note 
	v.singing = true
	
	v.singingDelay = 0
	
	local r, g, b = getNoteColor(note)
	bone_alpha(v.glow, 0.5, 1)
	bone_setColor(v.glow, r, g, b, 1)
end

function songNoteDone(me, note)
	if note == v.curNote then
		v.singingDelay = 3
		
		bone_alpha(v.glow, 0, 4)
		bone_setColor(v.glow, 1, 1, 1, 4)
	end
end

function song(me, song)
end

function activate(me)
end

