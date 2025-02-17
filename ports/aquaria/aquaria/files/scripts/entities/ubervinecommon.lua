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

-- SPORE SEED

v.growEmitter = 0
v.done = false
v.lifeTime = 0
v.n = 0
v.limited = false

function v.commonInit(me, lim)
	setupEntity(me)
	entity_initSkeletal(me, "UberVine")
	entity_setEntityLayer(me, -1)
	
	entity_setCollideRadius(me, 0)
	entity_setState(me, STATE_IDLE)
	--entity_setInternalOffset(me, 0, -256)
	entity_setInternalOffset(me, 0, -200)
	
	entity_setDamageTarget(me, DT_AVATAR_VINE, false)
	
	v.lifeTime = 15
	
	entity_alpha(me, 0)
	entity_alpha(me, 1, 0.3)
	
	entity_scale(me, 1, 0)
	entity_scale(me, 1, 1, 0.2)
	
	--[[
	entity_scale(me, 1, 0.9)
	entity_scale(me, 1, 1, 0.5, 0, 0, 1)
	]]--
	
	entity_clampToSurface(me)
	entity_animate(me, "idle", 0, 0, 0)
	
	entity_setCullRadius(me, 1024)
	
	entity_generateCollisionMask(me)
	entity_setHealth(me, 8)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_BITE, false)
	entity_setDamageTarget(me, DT_AVATAR_PETBITE, false)
	
	entity_sound(me, "UberVineGrow")
	
	v.limited = lim
end

function postInit(me)
	v.n = getNaija()
	entity_clampToSurface(me)
	entity_rotateToSurfaceNormal(me)
	
	if v.limited then
		entity_ensureLimit(me, 3, STATE_DONE)
	end
end

function songNote(me, note)
end

function shotHitEntity(me, ent, shot)
	--debugLog("shot hit entity!")
	local sx, sy = entity_getScale(me)
	local sx2, sy2 = bone_getScale(entity_getBoneByIdx(me, 0))
	local len = 400*sy*sy2
	local x1, y1 = entity_getPosition(me)
	local fx, fy = entity_getNormal(me)
	local x2 = x1 + fx*len
	local y2 = y1 + fy*len
	
	local doFall = false
	if entity_getEntityType(ent) ~= ET_NEUTRAL and ent ~= me and entity_isDamageTarget(ent, DT_AVATAR_VINE) and eisv(ent, EV_VINEPUSH, 1) then
		local doIt = true
		local dmg = 1
		if entity_getEntityType(ent) == ET_AVATAR then
			if isForm(FORM_NATURE) then
				dmg = 0
				if avatar_isLockable() then
					return
				end
			end
			doFall = true
		end
		if doIt then
			--[[
			if entity_collideCircleVsLine(ent, x1,y1,x2,y2,32) then	
				if doFall then
					avatar_fallOffWall()
				end
				
				local cx, cy = getLastCollidePosition()
				local dx = entity_x(ent) - cx
				local dy = entity_y(ent) - cy
				if dx ~= 0 or dy ~= 0 then
					dx, dy = vector_setLength(dx, dy, 500)
					--entity_push(ent, dx, dy, 0.1)
					entity_addVel(ent, dx, dy)
				end
			end
			]]--
			local dx = 0
			local dy = 0
			if entity_isAnimating(me) then
				dx = entity_x(ent) - entity_x(me)
				dy = entity_y(ent) - entity_y(me)
				
				if doFall then
					avatar_fallOffWall()
				end
			else
				local cx, cy = shot_getPosition(shot)
				dx = entity_x(ent) - cx
				dy = entity_y(ent) - cy
			end
			
			if dx ~= 0 or dy ~= 0 then
				--debugLog("push!")
				dx, dy = vector_setLength(dx, dy, 2000)
				entity_addVel(ent, dx, dy)
				--entity_warpLastPosition(ent)
				--entity_push(ent, dx, dy, 5000, 1)
			end
		end
	end
end

v.spawnDelay = 0

local function spawnShots(me)
	if v.spawnDelay == 0 then
		local sx, sy = entity_getScale(me)
		local sx2, sy2 = bone_getScale(entity_getBoneByIdx(me, 0))
		local len = 400*sy*sy2
		local x1, y1 = entity_getPosition(me)
		local fx, fy = entity_getNormal(me)
		local x2 = x1 + fx*len
		local y2 = y1 + fy*len
		
		local bit = len/4
		local totlen = 0
		while totlen < len do
			local px = x1 + fx*totlen
			local py = y1 + fy*totlen
			
			local s = createShot("Vine", me, 0, px, py)
			
			totlen = totlen + bit
		end
		
		v.spawnDelay = 0.5
	end
end

function update(me, dt)
	if not entity_isAnimating(me) and v.limited and isFlag(FLAG_NAIJA_FIRSTVINE, 0) and entity_isEntityInRange(me, v.n, 600) then
		emote(EMOTE_NAIJALAUGH)
		setFlag(FLAG_NAIJA_FIRSTVINE, 1)
	end
	if v.spawnDelay > 0 then
		v.spawnDelay = v.spawnDelay - dt
		if v.spawnDelay < 0 then
			v.spawnDelay = 0
		end
	end
	if v.done and not entity_isAnimating(me) then
		entity_scale(me, 1, 0, 0.2)
		entity_delete(me, 0.2)
		
	end
	if not v.done then
		entity_handleShotCollisionsSkeletal(me)
		v.lifeTime = v.lifeTime - dt
		if v.lifeTime < 0 then
			--entity_delete(me, 0.2)
			entity_animate(me, "shrink")
			v.done = true
			entity_sound(me, "UberVineShrink")
		end
		
		spawnShots(me)
		
		--if isForm(FORM_NATURE) then
		local bone = entity_collideSkeletalVsCircle(me, v.n)
		
		--[[
		if bone ~= 0 then
			debugLog(string.format("collided with bone named [%s] idx[%d]", bone_getName(bone), bone_getIndex(bone)))
		end
		]]--
		if isForm(FORM_NATURE) and avatar_isLockable() and bone ~= 0 and bone_getIndex(bone) == 0 and entity_setBoneLock(v.n, me, bone) then
		else
			---entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0, 1000)
			if bone ~= 0 then
				if entity_isAnimating(me) then
					entity_moveTowards(v.n, entity_x(me), entity_y(me), 1, -1000)
					avatar_fallOffWall()
				else
					local bx, by = bone_getWorldPosition(bone)
					entity_moveTowards(v.n, bx, by, 1, -1000)
					
					if not isForm(FORM_NATURE) then
						entity_damage(v.n, me, 0.25, DT_AVATAR_VINE)
					end
				end
				--entity_doCollisionAvoidance(v.n, 1, 5, 1)
			--[[
				local cx, cy = getLastCollidePosition()
				local dx = entity_x(v.n) - cx
				local dy = entity_y(v.n) - cy
				if dx ~= 0 or dy ~= 0 then
					dx, dy = vector_setLength(dx, dy, 500)
					--entity_push(ent, dx, dy, 0.1)
					entity_addVel(v.n, dx, dy)
				end
				]]--
			end
		end

		--[[
		if true then
			local sx, sy = entity_getScale(me)
			local sx2, sy2 = bone_getScale(entity_getBoneByIdx(me, 0))
			local len = 400*sy*sy2
			local x1, y1 = entity_getPosition(me)
			local fx, fy = entity_getNormal(me)
			local x2 = x1 + fx*len
			local y2 = y1 + fy*len
			
			local doFall = false
			local ent = getFirstEntity()
			while ent~=0 do
				if entity_getEntityType(ent) ~= ET_NEUTRAL and ent ~= me and entity_isDamageTarget(ent, DT_AVATAR_VINE) then
					local doIt = true
					local dmg = 1
					if entity_getEntityType(ent) == ET_AVATAR then
						if isForm(FORM_NATURE) then
							dmg = 0
							if avatar_isBursting() then
								doIt = false
							end
						end
						doFall = true
					end
					if doIt then
						if entity_collideCircleVsLine(ent, x1,y1,x2,y2,32) then	
							if doFall then
								avatar_fallOffWall()
							end
							if dmg ~= 0 then
								entity_damage(ent, me, dmg, DT_AVATAR_VINE)
							end
							
							local cx, cy = getLastCollidePosition()
							local dx = entity_x(ent) - cx
							local dy = entity_y(ent) - cy
							if dx ~= 0 or dy ~= 0 then
								dx, dy = vector_setLength(dx, dy, 500)
								--entity_push(ent, dx, dy, 0.1)
								entity_addVel(ent, dx, dy)
							end
						end
					end
				end
				
				ent = getNextEntity()
			end
		end
		]]--
		--[[
		if not entity_isNearObstruction(me, 3) then		
			v.done = true
		end
		]]--
	end
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_DONE) then
		debugLog("VINE DONE")
		v.done = true
		entity_scale(me, 1, 0, 0.2)
		entity_delete(me, 0.2)
		entity_sound(me, "UberVineShrink")
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function exitState(me)
end
