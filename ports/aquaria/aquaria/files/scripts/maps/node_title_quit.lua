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

function init(me)
	node_setCursorActivation(me, true)
	node_setCatchActions(me, true)
end

function action(me, action, state)
	if isNestedMain() then return end
	if getNodeToActivate() == me and state == 1 then
		if action == ACTION_MENULEFT then
			debugLog("L!")
			local node = getNode("TITLE_CONTINUE")
			setNodeToActivate(node)
			setMousePos(toWindowFromWorld(node_x(node), node_y(node)-20))
			return false
		end
	end
	return true
end

function activate(me)
	if isNestedMain() then return end

	playSfx("TitleAction")
	spawnParticleEffect("TitleEffect1", node_x(me), node_y(me))
	watch(0.5)
	
	local doQuit = false
	
	if confirm("", "exit") then
		doQuit = true
	end
	
	if getInputMode() ~= INPUT_MOUSE then
		setMousePos(toWindowFromWorld(node_x(me), node_y(me)))
	end
	
	setNodeToActivate(0)
	
	if doQuit then
		fadeOutMusic(2)
		toggleVersionLabel(false)
		toggleCursor(false)
		fade(1, 3, 0, 0, 0)
		watch(3)
		watch(0.5)
		quit()
	end
end

function update(me, dt)
end
