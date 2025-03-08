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
v.bulb = 0
v.base = 0
v.glow = 0

v.entToSpawn = ""
v.ingToSpawn = ""
v.amount = 0

v.myNote = 0

v.singingNote = false
v.singTimer = 0

v.back = false

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "singbulb")	
	
	v.bulb = entity_getBoneByName(me, "bulb")
	v.base = entity_getBoneByName(me, "base")
	v.glow = entity_getBoneByName(me, "glow")
	
	entity_animate(me, "idle", -1)
	
	if entity_isFlag(me, 1) then
		entity_setState(me, STATE_OPENED)
	else
		entity_setState(me, STATE_CLOSED)
	end
	
	-- should not be necessarry anymore
	--[[
	local nodey = entity_getNearestNode(me, "layerback")
	if nodey ~= 0 and node_isEntityIn(nodey, me) then
		entity_setEntityLayer(me, -1)
		v.back = true
	end
	]]--
	
	local n1 = getNearestNodeByType(entity_x(me), entity_y(me), PATH_SETING)
	if n1 ~= 0 and node_isEntityIn(n1, me) then
		v.ingToSpawn = node_getContent(n1)
		v.amount = node_getAmount(n1)	if v.amount == 0 then v.amount = 1 end
	else
		local n2 = getNearestNodeByType(entity_x(me), entity_y(me), PATH_SETENT)
		if n2 ~= 0 and node_isEntityIn(n2, me) then
			v.entToSpawn = node_getContent(n2)
			v.amount = node_getAmount(n2)	if v.amount == 0 then v.amount = 1 end
		end
	end
	
	v.myNote = getRandNote()
	
	entity_setCanLeaveWater(me, true)
	
	entity_setCullRadius(me, 512)
	
	
	-- note: LAYER OVERRIDE
	entity_setEntityLayer(me, -100)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	local r, g, b = getNoteColor(v.myNote)
	bone_setColor(v.bulb, r, g, b)
	bone_setColor(v.glow, r, g, b)
	
	bone_setBlendType(v.glow, BLEND_ADD)
	bone_alpha(v.glow, 0.4)
	
	bone_scale(v.glow, 12, 12, 1, -1, 1)
	
	if mapNameContains("veil") then
		bone_setTexture(v.base, "singbulb/base-0002")
	elseif mapNameContains("mithalas") or mapNameContains("cathedral") or mapNameContains("final") then
		bone_setTexture(v.base, "singbulb/base-0003")
	elseif mapNameContains("icecave") or mapNameContains("frozenveil") or mapNameContains("bubble") then
		bone_setTexture(v.base, "singbulb/base-0004")
	elseif mapNameContains("abyss") then
		bone_setTexture(v.base, "singbulb/base-0005")
	end
end

function update(me, dt)
	if entity_isState(me, STATE_CLOSED) then
		if v.singingNote then
			v.singTimer = v.singTimer + dt
			if v.singTimer > 2 then
				v.singingNote = false
				v.singTimer = 0
				bone_scale(v.bulb, 1, 1, 1)
				entity_setState(me, STATE_OPEN)
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	elseif entity_isState(me, STATE_CLOSED) then
	elseif entity_isState(me, STATE_OPENED) then
		bone_alpha(v.bulb, 0)
	elseif entity_isState(me, STATE_OPEN) then
		bone_alpha(v.bulb, 0)
		entity_setStateTime(me, 1)
		
		entity_setFlag(me, 1)
		
		local bx, by = bone_getWorldPosition(v.bulb)
		
		if v.ingToSpawn ~= "" or v.entToSpawn ~= "" then
			playSfx("secret")
		end
		if v.ingToSpawn ~= "" then
			for i=1,v.amount do
				local ing = spawnIngredient(v.ingToSpawn, bx, by, 1, (i==1))
				--[[
				if i==1 then
					entity_clearVel(ing)
					x,y = entity_getNormal(me)
					x,y = vector_setLength(x, y, 250)
					entity_addVel(ing, x, y)
				end
				]]--
			end
		elseif v.entToSpawn ~= "" then
			for i=1,v.amount do
				createEntity(v.entToSpawn, "", bx, by)
			end
		end
	end
end

function exitState(me)
	if entity_isState(me, STATE_OPEN) then
		entity_setState(me, STATE_OPENED)
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
	if entity_isEntityInRange(me, v.n, 800) then
		if entity_isState(me, STATE_CLOSED) then
			if v.myNote == note then
			
				if v.back then
					local e = getFirstEntity()
					while e ~= 0 do
						if eisv(e, EV_TYPEID, EVT_ROCK) or eisv(e, EV_TYPEID, EVT_CONTAINER) then
							if entity_isEntityInRange(me, e, 64) then
								return
							end
						end
						e = getNextEntity()
					end
				end
				v.singingNote = true
				v.singTimer = 0
				bone_scale(v.bulb, 1, 1)
				bone_scale(v.bulb, 0.7, 1, 0.1, -1, 1)
			end
		end
	end
end

function songNoteDone(me, note)
	v.singingNote = false
	v.singTimer = 0
	bone_scale(v.bulb, 1, 1, 1)
end

function song(me, song)
end

function activate(me)
end

