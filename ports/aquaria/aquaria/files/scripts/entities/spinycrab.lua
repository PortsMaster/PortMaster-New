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
v.glow = 0
v.eyes = 0
v.maxRun = 1
v.runTimer = v.maxRun
v.moving = 0
v.upRate = 1


local STATE_RUNAWAY = 1001

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "SpinyCrab")	
	entity_setAllDamageTargets(me, true)
	
	--entity_generateCollisionMask(me)
	entity_setCollideRadius(me, 50)
	
	v.glow = createQuad("Naija/LightFormGlow", 13)
	v.eyes = entity_getBoneByName(me, "Eyes")
	--[[
	quad_alpha(v.glow, 0.8)
	quad_alpha(v.glow, 1, 1, -1, 1, 1)
	]]--
	quad_scale(v.glow, 0.6, 0.3)
	--quad_scale(v.glow, 2, 1, 1, -1, 1, 1)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setBeautyFlip(me, false)
	
	entity_clampToSurface(me)
	entity_rotateToSurfaceNormal(me, 0.1)
	entity_flipHorizontal(me)
	entity_setUpdateCull(me, 3000)
	entity_setDeathParticleEffect(me, "TinyBlueExplode")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	dt = dt * v.upRate
	-- ugly slow hack
	entity_updateSkeletal(me, dt*0.5)
	entity_handleShotCollisions(me)
	--bone = entity_collideSkeletalVsCircle(me, v.n)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 800) then
		avatar_fallOffWall()
	end
	--entity_updateMovement(me, dt)
	
	if entity_isState(me, STATE_IDLE) then
		if entity_isEntityInRange(me, v.n, 500) then
			v.runTimer = v.runTimer - dt
			if v.runTimer <= 0 then
				v.runTimer = v.maxRun
				entity_setState(me, STATE_RUNAWAY, 8)
			end
		end
	elseif entity_isState(me, STATE_RUNAWAY) then		
		entity_rotateToSurfaceNormal(me)
		entity_moveAlongSurface(me, dt, 600*v.moving, 6, 10)
	end
	quad_setPosition(v.glow, bone_getWorldPosition(v.eyes))
	quad_rotate(v.glow, bone_getWorldRotation(v.eyes))
end

function lightFlare(me)
	if entity_isEntityInRange(me, v.n, 600) then
		v.upRate = 1.5
		entity_setState(me, STATE_RUNAWAY, 4)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
		if v.glow ~= 0 then
			quad_alpha(v.glow, 1, 0.5)
		end
		if v.eyes ~= 0 then
			bone_alpha(v.eyes, 1, 0.5)
		end
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_RUNAWAY) then
		if v.upRate == 1.0 then
			entity_switchSurfaceDirection(me)
			entity_flipHorizontal(me)
			entity_clampToSurface(me)
		end
		
		quad_alpha(v.glow, 0, 3)
		bone_alpha(v.eyes, 0, 3)
		entity_animate(me, "runAway", -1)
	elseif entity_isState(me, STATE_DEAD) then
		quad_delete(v.glow)
		v.glow = 0
	end
end

function exitState(me)
	if entity_isState(me, STATE_RUNAWAY) then
		v.upRate = 1
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_ENEMY_TRAP or damageType == DT_AVATAR_VINE then
		return true
	end
	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_RUNAWAY) and ((key > 2 and key < 5) or (key == 1)) then
		v.moving = 1
	else
		v.moving = 0.6
	end
	if entity_isState(me, STATE_RUNAWAY) and (key == 3) then
		entity_sound(me, "Scuttle", math.random(200)+900)
	end
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

function dieNormal(me)
	if chance(60) then
		spawnIngredient("SpiderEgg", entity_x(me), entity_y(me))
	end
end



