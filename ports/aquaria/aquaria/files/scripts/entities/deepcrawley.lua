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

-- ================================================================================================
-- D E E P   C R A W L E Y
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.size = 0
v.t = 0.5
v.size0 = 1.5
v.maxHits = 16

v.n = 0
v.mld = 0.2
v.ld = v.mld
v.note = -1
v.excited = 0
v.glow = 0

v.width = 128
v.dir = -1

local STATE_ROTATE = 1000
local STATE_WALK = 1001
local STATE_MOVEAWAY = 1002

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	v.maxSpeed = 321 + math.random(32)

	setupEntity(me)
	entity_setEntityLayer(me, -2)
	entity_setEntityType(me, ET_ENEMY)
	entity_setTexture(me, "deepcrawley")
	--entity_setAllDamageTargets(me, false)
	
	--entity_generateCollisionMask(me)
	
	entity_setState(me, STATE_IDLE)
	entity_addRandomVel(me, 500)

	esetv(me, EV_TYPEID, EVT_GLOBEJELLY)
	
	entity_setHealth(me, 3)
	entity_setDropChance(me, 20, 1)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	entity_setUpdateCull(me, 4000)

	-- SLIGHT SCALE AND COLOUR VARIATION
	local sz = 0.8 + (math.random(400) * 0.001)
	entity_scale(me, sz, sz)
	local cl = 1.0 - (math.random(2345) * 0.0001)
	entity_color(me, cl, cl, cl)
	v.width = v.width * sz
	entity_setCollideRadius(me, v.width)

	entity_scale(me, v.size0, v.size0)

	v.glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(v.glow, 4, 4)
end

function postInit(me)
	v.n = getNaija()

	entity_setMaxSpeed(me, v.maxSpeed)
	entity_rotate(me, randAngle360())
	entity_addRandomVel(me, 123)
	
	if chance(50) then v.dir = 1 end
end

function update(me, dt)
	v.ld = v.ld - dt
	if v.ld < 0 then
		v.ld = v.mld
		local l = createQuad("Naija/LightFormGlow", 13)
		local r = 1
		local g = 1
		local b = 1
		if v.note ~= -1 then
			r, g, b = getNoteColor(v.note)
			r = r*0.5 + 0.5
			g = g*0.5 + 0.5
			b = b*0.5 + 0.5
		end
		quad_setPosition(l, entity_getPosition(me))
		quad_scale(l, 4.0, 4.0)
		quad_alpha(l, 0.1)
		quad_alpha(l, 0.7, 0.5)
		quad_color(l, r, g, b)		
		quad_delete(l, 2)
		quad_color(v.glow, r, g, b, 0.5)
	end

	entity_clearTargetPoints(me)
	
	-- ROTATE GENTLY
	local rotSpeed = (entity_getVelLen(me)/300) + 1
	if entity_velx(me) < 0 then v.dir = -1
	else v.dir = 1 end
	entity_rotateTo(me, entity_getRotation(me) + (rotSpeed * v.dir))
	
	-- AVOIDANCE
	if entity_getBoneLockEntity(v.n) ~= me then entity_doEntityAvoidance(me, dt, entity_getCollideRadius(me)*2.1, 1.23) end
	entity_doCollisionAvoidance(me, dt, ((entity_getCollideRadius(me)*0.01)*7)+1, 0.421)
	-- MOVEMENT
	if entity_getVelLen(me) > 64 then entity_doFriction(me, dt, 42) end
	entity_updateMovement(me, dt)

	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 400) then
		entity_moveTowardsTarget(me, 1, -500)
	end

	quad_setPosition(v.glow, entity_getPosition(me))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_ROTATE) then
		entity_animate(me, "walk", -1)
	elseif entity_isState(me, STATE_WALK) then
		entity_animate(me, "walk", -1)		
	end
		
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if not entity_isInvincible(me) and (damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_SHOCK or damageType == DT_AVATAR_LIZAP) then
		entity_heal(me, 999)
		
		v.size = v.size + dmg
		v.maxSpeed = v.maxSpeed + dmg * 10
		if v.size >= v.maxHits then
			entity_setState(me, STATE_DEAD)
		end	
		--entity_setCollideRadius(me, getRadius(me))
		entity_setCollideRadius(me, entity_getCollideRadius(me)-(v.size*0.5))
		
		local sz = v.size0 * (1 - v.size/v.maxHits)
		entity_scale(me, sz, sz, 0.5)
	end
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
	--debugLog("HIT")
end

function songNote(me, note)
	v.note = note
end

function songNoteDone(me, note)
	v.note = -1
end

function song(me, song)
end

function activate(me)
end

