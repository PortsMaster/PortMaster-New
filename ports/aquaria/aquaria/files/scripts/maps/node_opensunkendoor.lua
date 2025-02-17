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

v.door = 0
v.linode = 0
v.doflip = false

function init(me)
	v.door = node_getNearestEntity(me, "sunkendoor")
	
	if hasLi() then
		node_setCursorActivation(me, true)
	end
	
	loadSound("sunkendoor-unlock")
	loadSound("sunkendoor-open")
	
	v.linode = getNode("liopendoor")
end

function update(me, dt)
	if v.doflip then
		local li = getLi()
		if entity_isfh(li) then entity_fh(li) end
		--bone_setAnimated(entity_getBoneByName(li, "head"), ANIM_ALL)
	end
end

function activate(me)
	local li = getLi()
	local n = getNaija()
	
	v.doflip = true
	
	local fadet = 0.5
	
	local wrench = entity_getBoneByName(li, "wrench")
	
	entity_setState(li, STATE_OPEN)
	
	
	
	if entity_isfh(n) then entity_fh(n) end
	
	overrideZoom(1.2, 1)
	
	fade2(1, fadet) watch(fadet)
	
	
	entity_setPosition(li, node_x(v.linode), node_y(v.linode))
	
	cam_toEntity(li)
	
	entity_setPosition(n, node_x(v.linode)+64, node_y(v.linode)-15)
	bone_setVisible(wrench, 1)
	entity_animate(li, "work", 0, 4)
	
	if entity_isfh(li) then entity_fh(li) end
	
	fade2(0, fadet) watch(fadet)
	
	watch(3)
	
	--- click
	playSfx("sunkendoor-unlock")
	
	entity_msg(li, "expression", EXPRESSION_SURPRISE)
	
	watch(0.8)
	
	entity_msg(li, "expression", EXPRESSION_HAPPY)
	
	playSfx("sunkendoor-open")
	entity_setState(v.door, STATE_OPEN)
	
	overrideZoom(0.7, 4)
	
	watch(1.8)
	entity_animate(li, "idle", -1)
	bone_scale(wrench, 0, 0, 1)
	
	voiceOnce("Naija_SunkenCityOpened")
	
	entity_setState(li, STATE_IDLE)
	cam_toEntity(n)
	
	node_setCursorActivation(me, false)
	v.doflip = false
	
	overrideZoom(0)
end

