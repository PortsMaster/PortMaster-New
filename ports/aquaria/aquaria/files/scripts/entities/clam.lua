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

v.sleepLoc = 0
v.held = 0
v.held2 = 0
v.seen = false

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Clam")	
	entity_setAllDamageTargets(me, false)
	
	--entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_IDLE)
	
	entity_setActivation(me, AT_CLICK, 128, 512)
	
	v.sleepLoc = entity_getBoneByName(me, "SleepLoc")
	bone_alpha(v.sleepLoc)
	
	loadSound("clam-open")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if not v.seen and entity_isEntityInRange(me, v.n, 700) then
		if chance(50) then
			emote(EMOTE_NAIJAGIGGLE)
		else
			emote(EMOTE_NAIJAWOW)
		end
		v.seen = true
	end
	if isForm(FORM_BEAST) then
		entity_setActivationType(me, AT_CLICK)
	else
		entity_setActivationType(me, AT_NONE)
	end
	
	--[[
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	entity_updateMovement(me, dt)
	]]--
	
	if v.held ~= 0 then
		entity_setPosition(v.held, bone_getWorldPosition(v.sleepLoc))
		entity_rotate(v.held, bone_getWorldRotation(v.sleepLoc))
		entity_clearVel(v.held)
	end
	
	if v.held2 ~= 0 then
		local bx, by = bone_getWorldPosition(v.sleepLoc)
		entity_setPosition(v.held2, bx-20, by-20)
		entity_rotate(v.held2, bone_getWorldRotation(v.sleepLoc))
		entity_clearVel(v.held2)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_CLOSE) then
		entity_animate(me, "close")
	elseif entity_isState(me, STATE_OPEN) then
		playSfx("clam-open")
		entity_setStateTime(me, entity_animate(me, "open"))
	end
end

function exitState(me)
	if entity_isState(me, STATE_OPEN) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
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
	-- sleep
	
	v.n = getNaija()
	local l = 0
	if hasLi() then
		l = getLi()
	end
	
	esetv(v.n, EV_LOOKAT, 0)
	
	local saveCombat = getFlag(FLAG_LICOMBAT)
	if l ~= 0 then
		fade2(1, 0.5, 1, 1, 1)
		watch(0.5)
		
		setFlag(FLAG_LICOMBAT, 0)
		
		entity_setState(l, STATE_PUPPET)
		
		entity_setPosition(l, entity_x(v.n), entity_y(v.n))
		
		fade2(0, 0.5, 1, 1, 1)
	end
		
		
	
	entity_idle(v.n)
	if entity_isfh(me) and entity_isfh(v.n) then
		entity_fh(v.n)
	elseif not entity_isfh(me) and not entity_isfh(v.n) then
		entity_fh(v.n)
	end
	entity_clearVel(v.n)
	watch(0.1)
	local x, y = bone_getWorldPosition(v.sleepLoc)
	entity_setPosition(v.n, x, y, 1)
	watch(1)
	
	if l ~= 0 then
		entity_clearVel(l)
		entity_setPosition(l, x, y, 1)
	end
	
	v.held = v.n
	entity_clearVel(v.n)
	--entity_rotate(held, bone_getWorldRotation(v.sleepLoc), 1)
	emote(EMOTE_NAIJASIGH)
	entity_animate(v.n, "sleep", -1, LAYER_OVERRIDE)
	watch(1)
	
	if l ~= 0 then
		if entity_fh(v.n) and entity_fh(l) then
			entity_fh(l)
		elseif entity_fh(v.n) and not entity_fh(l) then
			entity_fh(l)
		end
		
		entity_clearVel(l)
		v.held2 = l
		--entity_rotate(l, bone_getWorldRotation(v.sleepLoc), 1)
		entity_animate(l, "sleep", -1)
		watch(1)
	end
	
	entity_setState(me, STATE_CLOSE)
	watch(1.5)
	musicVolume(0.25, 1)
	fade(1, 1)
	watch(1)
	local nd = entity_getNearestNode(me, "CLAMCAM")
	if nd ~= 0 then
		cam_toNode(nd)
	end
	watch(1)
	fade(0.5, 1)
	watch(1)
	--entity_heal(v.n, 20)
	-- do sleep wait for input thing
	while (not isLeftMouse()) and (not isRightMouse()) do		
		watch(FRAME_TIME)
		entity_heal(v.n, FRAME_TIME)
	end
	
	musicVolume(1, 1)
	fade(0, 2)
	entity_setState(me, STATE_OPEN)
	watch(0.5)
	cam_toEntity(v.n)
	entity_idle(v.n)
	entity_animate(v.n, "slowWakeUp")
	while entity_isAnimating(v.n) do
		watch(FRAME_TIME)
	end	
	local nx, ny = entity_getNormal(me)
	nx,ny = vector_setLength(nx, ny, 200)
	entity_idle(v.n)
	entity_addVel(v.n, nx, ny)
	entity_rotateToVel(v.n)
	entity_animate(v.n, "burst")
	
	if l ~= 0 then
		entity_setState(l, STATE_IDLE)
		setFlag(FLAG_LICOMBAT, saveCombat)
	end
	
	esetv(v.n, EV_LOOKAT, 1)
	entity_setInternalOffset(l, 0, 0, 0.5)
	
	
	--entity_animate(v.n, "wakeUp")
	--watch(1)
	v.held = 0
	v.held2 = 0
	
end
