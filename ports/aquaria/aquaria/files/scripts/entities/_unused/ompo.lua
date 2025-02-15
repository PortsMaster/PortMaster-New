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

local STATE_RUNOFF			= 1000

v.n = 0

v.following = false
v.seen = false
v.spinning = false
v.followMia = false
v.fade = false

v.singTimer = 0

v.rot = 0

v.glowBody = 0
v.body = 0

v.runNode = 0

local function normalSegs(me)
	bone_setSegs(entity_getBoneByIdx(me, 0), 2, 8, 0.7, 0.7, -0.02, 0, 6, 1)
end

local function singSegs(me)
	bone_setSegs(entity_getBoneByIdx(me, 0), 2, 8, 0.7, 0.7, 0.02, 0, 6, 1)
end

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "Ompo")
	
	entity_setEntityLayer(me, 1)
	
	--entity_generateCollisionMask(me)	
	
	entity_scale(me, 0.7, 0.7)
	entity_setState(me, STATE_IDLE)
	
	
	normalSegs(me)
	
	
	v.glowBody = entity_getBoneByIdx(me,2)
	v.body = entity_getBoneByIdx(me, 0)
	
	entity_alpha(me, 1)
	bone_alpha(v.glowBody, 0)
	bone_setBlendType(v.glowBody, BLEND_ADD)
	
	entity_scale(me, 0.6, 0.6)
	
	
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	v.runNode = getNode("OMPORUNOFF")
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		if not v.following then
			entity_doCollisionAvoidance(me, dt, 2, 1)
			
			if v.following then 
				entity_moveTowardsTarget(me, dt, 800)
			else
				if entity_isEntityInRange(me, v.n, 512) then
					v.following = true
					entity_moveTowardsTarget(me, dt, 800)
					if isFlag(FLAG_OMPO, 2) then
						setFlag(FLAG_OMPO, 3)
						playSfx("Ompo")
						emote(EMOTE_NAIJALAUGH)
					end
				end
			end
			entity_flipToVel(me)
		
			entity_updateMovement(me, dt)
		else
			local tar
			if v.followMia then
				tar = getEntity("13_MainArea")
				esetv(me, EV_LOOKAT, 0)
			else
				tar = entity_getNearestEntity(me, "13_MainArea", 1024)
				if tar == 0 then
					tar = v.n
				end
			end
			v.rot = v.rot + dt*0.2
			if avatar_isSinging() then
				v.rot = v.rot + dt*0.2
			end
			if v.rot > 1 then
				v.rot = v.rot - 1
			end
			local dist = 100
			if tar == v.n then
				if avatar_isSinging() then
					dist = 150
				end
			else
				if v.fade then
					dist = 32
				else
					dist = 200
				end
			end
			local t = 0
			local x = 0
			local y = 0
			if avatar_isRolling() then
				dist = 90
				t = v.rot * 6.28
			else
				t = v.rot * 6.28
			end
			

			
			if not entity_isEntityInRange(me, tar, 2024) then
				entity_setPosition(me, entity_x(tar)+x, entity_y(tar)+y)
			end
			
			local a = t
			x = x + math.sin(a)*dist
			y = y + math.cos(a)*dist
			
			if tar ~= v.n then
				if v.fade then
					entity_setPosition(me, entity_x(tar)+x, entity_y(tar)+y, 0.2)
				else
					entity_setPosition(me, entity_x(tar)+x, entity_y(tar)+y, 2)
				end
			elseif avatar_isSinging() then
				entity_setPosition(me, entity_x(tar)+x, entity_y(tar)+y, 0.2)
			else
				entity_setPosition(me, entity_x(tar)+x, entity_y(tar)+y, 0.6)
			end
			
			if tar == v.n then
				if not avatar_isSinging() then
					entity_flipToEntity(me, v.n)
				end
				
				if avatar_isSinging() then
					v.singTimer = v.singTimer + dt
					if v.singTimer > 4 then
						v.singTimer = 0 - math.random(4)
						if chance(50) then
							emote(EMOTE_NAIJAGIGGLE)
						end
						if chance(75) then
							playSfx("Ompo")
						end
						entity_rotate(me, 0)
						entity_rotate(me, -360, 1, 0, 0, 1)
					end
				else
					v.singTimer = v.singTimer - dt *2
					if v.singTimer < 0 then
						v.singTimer = 0
					end
				end
			else
				entity_flipToEntity(me, tar)
			end
		end

	end
	
	entity_handleShotCollisions(me)

	if isFlag(FLAG_OMPO, 0) and not v.seen and entity_isEntityInRange(me, v.n, 300) then
		playSfx("Ompo")
		emote(EMOTE_NAIJAGIGGLE)
		v.seen = true
	end
	
	if v.runNode ~= 0 and node_isEntityIn(v.runNode, me) then
		entity_setState(me, STATE_OFF)
	end
end

v.cut = false

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_OFF) then
		--- flee
		if v.cut then return end
		v.cut = true
		debugLog("setting off")
		v.following = false
		local crack = getNode("CRACK")
		entity_idle(v.n)
		if entity_isfh(v.n) then entity_fh(v.n) end
		musicVolume(0.5, 1)
		watch(1)
		playSfx("Ompo")
		
		entity_offset(me, 0, -40, 0.2, 7, 1)
		watch(0.4)
		emote(EMOTE_NAIJAUGH)
		watch(0.6)
		watch(1)
		
		cam_toEntity(me)
		entity_setPosition(me, node_x(crack), node_y(crack, 3), 1, 0, 1)
		while entity_isInterpolating(me) do
			watch(FRAME_TIME)
		end
		
		entity_alpha(me, 0, 0.5)
		watch(0.5)
		cam_toEntity(v.n)
		watch(1)
		emote(EMOTE_NAIJASADSIGH)
		setFlag(FLAG_OMPO, 4)
		entity_delete(me)
		v.cut = false
		watch(1)
		musicVolume(1, 1)
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

function msg(me, msg)
	if msg=="fmia" then
		v.followMia = true
		
		esetv(me, EV_LOOKAT, 0)
	elseif msg=="fade" then
		setFlag(FLAG_OMPO, 2)
		entity_delete(me, 2)
		v.fade = true
	end
end


function songNote(me, note)
	local r,g,b = getNoteColor(note)
	--[[
	r = 0.5 + r*0.5
	g = 0.5 + g*0.5
	b = 0.5 + b*0.5
	entity_color(me, r, g, b, 0.1)
	]]--
	bone_setColor(v.glowBody, r, g, b, 0.2)
	bone_alpha(v.glowBody, 0.5)
	
	bone_scale(v.glowBody, 2, 2)
	bone_scale(v.glowBody, 5, 5, 0.5, -1, 1)
	--bone_scale(v.glowBody, 
	--[[
	if not v.spinning then
		v.spinning = true
		entity_rotate(me, 360+entity_getRotation(me), 1, -1)
	end
	]]--
	--bone_setBlendType(entity_getBoneByIdx(me,1), BLEND_ADD)
end

function songNoteDone(me, note)
	--bone_setColor(v.glowBody, 1, 1, 1, 1)
	bone_alpha(v.glowBody, 0, 4)
	--[[
	if v.spinning then
		v.spinning = false
		entity_rotate(me, 0, 1, 0, 0, 1)
	end
	]]--
end

function song(me, song)
end

function activate(me)
end

