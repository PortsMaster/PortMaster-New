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

-- moves around
-- follows dropped flowers

v.n = 0
v.singDelay = 60
v.goBackTimer = 0
v.miny = 0
v.lx = 0
v.ly = 0
v.node = 0

v.seen = false
v.done = false

function init(me)
	setupEntity(me)
	entity_initSkeletal(me, "CC_GF")
		
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 0.6, 0.6)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	v.miny = entity_y(me)-300
	
	--node = getNode("CCWANTGF")
	--cc = createEntity("CC_WantGF", "", node_x(node), node_y(node))

--[[	
	if isFlag(FLAG_SUNKENCITY_PUZZLE, 3) or isFlag(FLAG_SUNKENCITY_PUZZLE, 4) then
		local n2 = getNode("GFREST")
		local x = node_x(n2)
		local y = node_y(n2)
		entity_setPosition(me, x, y)
		v.done = true
		v.node = getNode("CATGETBEAT")
		cat = createEntity("CC_Cat", "", node_x(v.node), node_y(v.node))
	end
	]]--
end

function update(me, dt)
	if getFlag(FLAG_SUNKENCITY_PUZZLE) <= SUNKENCITY_GF then
		if entity_isState(me, STATE_IDLE) and not v.done then
			if v.goBackTimer > 0 then
				v.goBackTimer = v.goBackTimer - dt
				if v.goBackTimer < 0 then
					entity_setPosition(me, v.lx, v.ly, math.abs(entity_x(me)-v.lx)*0.003, 0, 0)
				end
			end
		end
	end
	if entity_isState(me, STATE_IDLE) and not v.seen then
		if getFlag(FLAG_SUNKENCITY_PUZZLE) <= SUNKENCITY_GF then
			if entity_isEntityInRange(me, getNaija(), 512) then
				v.seen = true
				entity_idle(getNaija())
				
				cam_toEntity(me)
				overrideZoom(1.2,4)
				watch(3)
				fade2(1, 1, 1, 1, 1)
				watch(0.5)
				playSfx("naijagasp", 0, 0.5)
				watch(0.5)
				
				cam_toEntity(getNaija())
				overrideZoom(0.7, 1)
				watch(0.5)
				fade2(0, 0.5, 1, 1, 1)
				overrideZoom(0)
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DONE) then
		--entity_animate(me, "idle", -1)
		--debugLog("CC_GF in NON IDLE STATE")
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

function sporesDropped(me, x, y, t)
	if t ~= 0 then return end
	if not entity_isState(me, STATE_IDLE) then
		return
	end
	if not v.done then
		if entity_isPositionInRange(me, x, y, 700) then
			if v.lx == 0 and v.ly == 0 then
				v.lx,v.ly = entity_getPosition(me)
			end
			if not isObstructed(x, y-80) then
				if y > v.miny then
					entity_setPosition(me, x, y-128, math.abs(entity_x(me)-x)*0.005, 0, 0)
				else
					entity_setPosition(me, x, entity_y(me), math.abs(entity_x(me)-x)*0.005, 0, 0)
				end
				v.goBackTimer = 4
				if x >= entity_x(me) then
					if not entity_isfh(me) then	entity_fh(me) end
				else
					if entity_isfh(me) then	entity_fh(me) end
				end
				entity_animate(me, "float", -1)
			end
		end
	end
end

function activate(me)
end

