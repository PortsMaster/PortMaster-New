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

--SCRIPT_OFF

v.n = 0
v.mbDown = false
v.labelTimer = 0

function init(me)
	--stopAllVoice()
	resetContinuity()
	setOverrideMusic("")
	
	v.n = getNaija()
	
	entity_alpha(v.n, 0.2)
	
	entity_heal(v.n, 999)
	cam_toNode(me)
	cam_setPosition(node_x(me), node_y(me))
	entity_setInvincible(v.n, true)
	entity_setState(v.n, STATE_TITLE)
	
	--entity_stopAllAnimations(v.n)
	entity_animate(v.n, "frozen", -1, 4)
	--c = createEntity("Crotoid", "", 400, 300)

	setMousePos(400, 550)
	
	disableInput()
	toggleCursor(true, 0.1)
	overrideZoom(1.0)
	
	--toggleBlackBars(true)
	
	resetTimer()
	
	playMusicStraight("Title")
	
	
	avatar_toggleCape(false)
	
	setMousePos(400, 550)
	
	fade(1, 0)
	fade(0, 1)
	fade2(0, 2, 1, 1, 1)
	
	setVersionLabelText()
	toggleVersionLabel(1)
	
	v.labelTimer = 0
end

function update(me, dt)
	v.labelTimer = v.labelTimer + dt
	if v.labelTimer > 0.5 then
		setVersionLabelText()
	end
	cam_setPosition(node_x(me), node_y(me))
	if isInputEnabled() then
		debugLog("calling disable input")
		disableInput()
		toggleCursor(true, 0.1)
	end

	local scale = 800.0/1024.0 + 0.01
	
	overrideZoom(scale, 2)
	
	entity_setPosition(v.n, node_getPosition(getNode("NAIJA")))
	
	if (isLeftMouse() or isRightMouse()) and not v.mbDown then
		v.mbDown = true
	elseif (not isLeftMouse() and not isRightMouse()) and v.mbDown then
		v.mbDown = false
		local node = getNodeToActivate()
		setNodeToActivate(0)
		if node ~= 0 then
			node_activate(node, 0)
		end
	end
end
