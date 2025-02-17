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
v.warpBone = 0
v.coreRots = 0
v.open = false
v.doorsDown = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "CathedralDoor")	
	entity_setAllDamageTargets(me, false)
	
	entity_generateCollisionMask(me)

	v.warpBone = entity_getBoneByName(me, "WarpBone")	
	bone_alpha(v.warpBone, 0)
	
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 2, 2)
	
	entity_setCullRadius(me, 1024)
end

function msg(me, msg)
	if msg == "DoorDownPre" or msg=="DoorDown" then
		
		v.doorsDown = v.doorsDown + 1
		if v.doorsDown >= 3 then
			v.open = true
			voiceOnce("Naija_MithalasDarkness")
		end
		if v.doorsDown >= 1 and v.doorsDown <= 3 then
			local tbone = entity_getBoneByIdx(me, v.doorsDown)
			if msg=="DoorDown" then
				--setCameraLerpDelay(0.5)				
				entity_setInvincible(v.n, true)
				cam_toEntity(me)
				watch(1)
				clearShots()
				bone_alpha(tbone, 0, 1)
				playSfx("UberVineShrink")
				watch(1)
				bone_alpha(tbone, 0)
				watch(0.5)
				setCameraLerpDelay(0)
				cam_toEntity(v.n)
				clearShots()
				entity_setInvincible(v.n, false)
			else
				for i=1,v.doorsDown do
					local tbone = entity_getBoneByIdx(me, i)
					bone_alpha(tbone, 0)
				end
			end
		end
	end
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		local nx,ny = entity_getPosition(v.n)
		local cx,cy = entity_getPosition(me)
		local x = nx-cx
		local y = 0
		x,y = vector_setLength(x,y,2000)
		entity_addVel(v.n, x, y)
	end
	if v.open then
		local bx,by = bone_getWorldPosition(v.warpBone)
		if entity_isPositionInRange(v.n, bx, by, 200) then
			warpNaijaToSceneNode("Cathedral03", "DOORENTER")
		end
	end
	
	entity_updateMovement(me, dt)
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
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

