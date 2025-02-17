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

-- generic collectible costume

dofile("scripts/include/collectibletemplate.lua")

v.on = false
v.cname = ""

function v.commonInit2(me, gfx, flag, costumeName)
	v.commonInit(me, gfx, flag, true)
	v.cname = costumeName
	entity_setEntityLayer(me, -1)
	
	-- cached now
	loadSound("ChangeClothes1")
	loadSound("ChangeClothes2")
end

function update(me, dt)
	v.commonUpdate(me, dt)

	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		if getCostume() == v.cname then
			if v.on then
				entity_alpha(me, 0.5)
				v.on = false
			end
		else
			if not v.on then
				entity_alpha(me, 1)
				v.on = true
			end
		end
	end
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		entity_setActivation(me, AT_CLICK, 32, 700)
	end
end

function activate(me)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		-- go to changing area
		
		if not isForm(FORM_NORMAL) then
			changeForm(FORM_NORMAL)
		end
		local node = getNode("CHANGE")
		avatar_fallOffWall()
		watch(0.5)
		entity_swimToNode(getNaija(), node)
		entity_watchForPath(getNaija())
		entity_idle(getNaija())
		entity_setColor(getNaija(), 0.01, 0.01, 0.01, 1)
		watch(0.5)
		
		entity_animate(getNaija(), "changeCostume")
		watch(1)
		playSfx("ChangeClothes1")
		watch(1)
		playSfx("ChangeClothes2")
		watch(1.2)
		
		watch(0.6)
		playSfx("ChangeClothes1")
		if getCostume() == v.cname then
			setCostume("")
		else
			setCostume(v.cname)
		end	
		while entity_isAnimating(getNaija()) do
			watch(FRAME_TIME)
		end
		
		watch(0.5)
		-- change	

		--watch(0.5)
		entity_setColor(getNaija(), 1, 1, 1, 0.5)
		entity_swimToNode(getNaija(), getNode("CHANGEEXIT"))
		entity_watchForPath(getNaija())	
		if chance(50) then
			emote(EMOTE_NAIJAGIGGLE)
		end
	end
end

function exitState(me, state)
	v.commonExitState(me, state)
end
