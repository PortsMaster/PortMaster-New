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
v.attackDelay = 0
v.attacked = 0
v.aggro = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Swordfish")
	
	entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_IDLE)
	
	entity_setCanLeaveWater(me, true)
	
	entity_setCollideRadius(me, 128)
	entity_setUpdateCull(me, 4000)
	entity_setDeathParticleEffect(me, "TinyBlueExplode")
	
	entity_setCullRadius(me, 256)
	
	entity_setHealth(me, 12)
	
	loadSound("swordfish-attack")
	loadSound("swordfish-die")
	
	entity_setDeathSound(me, "swordfish-die")
end

function postInit(me)
	v.n = getNaija()
	---entity_setTarget(me, v.n)
end

v.t = 0
local function rotflip(me)
	
	entity_flipToVel(me)
	if entity_isfh(me) then
		entity_rotateToVel(me, v.t, -90)
	else
		entity_rotateToVel(me, v.t, 90)
	end
	
end

function update(me, dt)

	if not isForm(FORM_FISH) then
		v.aggro = 1
	end

	if v.attacked > 0 then
		v.attacked = v.attacked - dt
		if v.attacked < 0 then
			v.attacked = 0
		end
	end
	
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		entity_damage(v.n, me, 1)
		local x, y = entity_getVectorToEntity(me, v.n)
		entity_addVel(v.n, x*500, y*500)
	end
	if entity_isState(me, STATE_ATTACK) then
		if entity_isEntityInRange(me, v.n, 800) then
			entity_moveTowardsTarget(me, dt, 800)
		end
	end
	if entity_isState(me, STATE_CHARGE1) then
		
	end
	if entity_isState(me, STATE_IDLE) then
		if entity_hasTarget(me) then
			entity_moveTowardsTarget(me, dt, 100)
			if entity_isUnderWater(me) then
				if v.attacked > 0 or entity_isEntityInRange(me, v.n, 512) then
					v.attackDelay = v.attackDelay - dt
					if v.attackDelay <= 0
					and v.aggro == 1 then
						--[[
						entity_moveTowardsTarget(me, 1, 1000)
						entity_flipToEntity(me, v.n)
						rotflip(me)
						entity_clearVel(me)
						]]--
						entity_moveTowardsTarget(me, 1, -100)
						
						entity_setState(me, STATE_CHARGE1)
						--[[
						x, y = entity_getNormal(me)
						sw = x
						x = -y
						y = sw
						len = -1000
						x = x * len
						y = y * len
						if entity_collideCircleVsLine(v.n, entity_x(me), entity_y(me), entity_x(me)+x, entity_y(me)+y, 128) then
							entity_setState(me, STATE_CHARGE1)
						end
						]]--
					end
				end
			end
			entity_doCollisionAvoidance(me, dt, 8, 0.1)
			entity_doCollisionAvoidance(me, dt, 4, 0.5)
			entity_doEntityAvoidance(me, dt, 32, 0.2)
			--entity_doSpellAvoidance(me, dt, 256, 0.2)
			--entity_doSpellAvoidance(me, dt, 128, 0.8)
			entity_findTarget(me, 2500)
		else
			entity_findTarget(me, 1000)
		end
	end
	if not entity_isState(me, STATE_CHARGE1) then
		rotflip(me)
	end
	if entity_isState(me, STATE_CHARGE1) then
		local vx = entity_velx(me)
		local vy = entity_vely(me)
		entity_clearVel(me)
		entity_moveTowardsTarget(me, 1, 1000)
		rotflip(me)
		entity_clearVel(me)
		entity_addVel(me, vx, vy)
	end
	--entity_flipToVel(me)
	entity_updateMovement(me, dt)
	if entity_checkSplash(me) then
		if not entity_isUnderWater(me) then
			entity_setMaxSpeedLerp(me, 4)
			
			if entity_velx(me) < 0 then
				entity_addVel(me, -300, -500)
			else
				entity_addVel(me, 300, -500)
			end
			entity_setWeight(me, 650)
		else
			--entity_setCanLeaveWater(me, false)
			entity_setWeight(me, 0)
		end
	end	
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_CHARGE1) then
		entity_sound(me, "swordfish-attack")
		entity_moveTowardsTarget(me, 1, -1000)
		--entity_flipToEntity(me, v.n)
		entity_setMaxSpeedLerp(me, 0.75)
		entity_setMaxSpeedLerp(me, 0.5, 0.2)
		entity_setStateTime(me, entity_animate(me, "attackPrep"))
		entity_doGlint(me, "Glint", BLEND_ADD)
		--entity_fv(me)
	elseif entity_isState(me, STATE_ATTACK) then
		--entity_fv(me)
		entity_setMaxSpeedLerp(me, 4)
		entity_setStateTime(me, entity_animate(me, "attack"))
		local x, y = entity_getNormal(me)
		local sw = x
		x = -y
		y = sw
		local spd = 3000
		entity_moveTowardsTarget(me, 1, spd)
		rotflip(me)
	end
end

function exitState(me)
	if entity_isState(me, STATE_CHARGE1) then
		entity_setState(me, STATE_ATTACK)
	elseif entity_isState(me, STATE_ATTACK) then
		v.attackDelay = math.random(3)+2
		entity_setState(me, STATE_IDLE)
		entity_setMaxSpeedLerp(me, 1, 1)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	v.attackDelay = v.attackDelay - dmg * 2
	
	v.attacked = 1
	v.aggro = 1
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

function dieNormal(me)
	if chance(50) then
		spawnIngredient("SwordfishSteak", entity_x(me), entity_y(me))
	else
		spawnIngredient("FishMeat", entity_x(me), entity_y(me))
	end
end

