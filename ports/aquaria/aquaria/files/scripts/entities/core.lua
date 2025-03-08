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

v.node = 0

v.dir = 0
v.dirTimer = 0

v.bone_body = 0
v.bone_eye1 = 0
v.bone_eye2 = 0
v.bone_eye3 = 0
v.bone_eye4 = 0
v.bone_tentacles = 0

local function doEye(bone)
	bone_scale(bone, 0.6, 0.6, 0)
	bone_scale(bone, 1.2, 1.2, 4 + math.random(6))
end

local function updateEye(bone)
	local x,y = bone_getScale(bone)
	if x > 1.1 then
		local sx,sy = bone_getWorldPosition(bone)
		createEntity("Moneye", "", sx, sy)
		spawnParticleEffect("TinyGreenExplode", sx, sy)
		doEye(bone)
	end
end

local function clearBarriers()
	if v.node ~= 0 then
		-- do magic
		node_setElementsInLayerActive(v.node, 2, false)
		reconstructGrid()
	end
end

function init(me)
	if entity_isFlag(me, 1) then
		return
	end

	setupBasicEntity(
	me,
	"",								-- texture
	64,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	135,							-- collideRadius
	STATE_IDLE,						-- initState
	0,								-- sprite width
	0,								-- sprite height
	0,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000
	)
	
	entity_initSkeletal(me, "Core")	
	entity_animate(me, "idle")
	
	v.bone_body = entity_getBoneByName(me, "Body")
	v.bone_eye1 = entity_getBoneByName(me, "Eye1")
	v.bone_eye2 = entity_getBoneByName(me, "Eye2")
	v.bone_eye3 = entity_getBoneByName(me, "Eye3")
	v.bone_eye4 = entity_getBoneByName(me, "Eye4")
	v.bone_tentacles = entity_getBoneByName(me, "Tentacles")
	
	doEye(v.bone_eye1)
	doEye(v.bone_eye2)
	doEye(v.bone_eye3)
	doEye(v.bone_eye4)
	
	bone_setSegs(v.bone_body, 2, 8, 0.5, 0.1, -0.018, 0, 2, 1)
	bone_setSegs(v.bone_tentacles, 2, 8, 0.5, 0.1, -0.018, 0, 3, 0.5)
	
	
	entity_setMaxSpeed(me, 100)
	
	--entity_setCullRadius(me, 1024)
end

function postInit(me)
	v.node = entity_getNearestNode(me, "CORERANGE")
	
	if entity_isFlag(me, 1) then
		clearBarriers()
		entity_delete(me)
	end
end

function update(me, dt)
	entity_handleShotCollisions(me)
	
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0, 1000)
	
	if v.dir == 0 then
		entity_addVel(me, -100*dt, 0)
	else
		entity_addVel(me, 100*dt, 0)
	end
	
	v.dirTimer = v.dirTimer - dt
	if v.dirTimer < 0 then
		v.dirTimer = math.random(2)+1
		if v.dir == 0 then
			v.dir = 1
		else
			v.dir = 0
		end
	end
	
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	
	updateEye(v.bone_eye1)
	updateEye(v.bone_eye2)
	updateEye(v.bone_eye3)
	updateEye(v.bone_eye4)
end

function enterState(me, state)
	if entity_isState(me, STATE_DEAD) then
		clearBarriers()
		entity_setFlag(me, 1)
	end
end

function damage(me)
	return true
end
