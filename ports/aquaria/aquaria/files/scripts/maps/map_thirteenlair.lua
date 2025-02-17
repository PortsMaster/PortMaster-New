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

local function foundSecrets()
	--return true
	if not isFlag(FLAG_SKIPSECRETCHECK, 0) then
		return false
	else
		return (isFlag(FLAG_SECRET01, 1) and isFlag(FLAG_SECRET02, 1) and isFlag(FLAG_SECRET03, 1))
	end
end

function init()

	setInvincible(false)
	entity_setInvincible(getNaija(), false)

	--return
	
	
	setOverrideMusic("")
	
	local n = getNaija()
	local mia = 0
	local thir = 0
	
	stopMusic()
	
	if foundSecrets() then
		local li = getLi()
		if li ~= 0 then
			entity_delete(li)
		end
		setLi(0)
		setFlag(FLAG_LI, 0)
		
		entity_heal(n, 100)
		
		
		
		overrideZoom(1)
		
		local bg = getEntity("falsebg")
		
		n = getNaija()
		
		local nd = getNode("START")
		entity_setPosition(n, node_x(nd), node_y(nd))
		
		
		entity_animate(n, "sitback", -1)
	
		watch(0.3)
		
		fade2(0, 1, 1, 1, 1)
		fade(0, 1)
		
		watch(5)
		
		entity_setState(bg, STATE_CLOSE)
		
		watch(0.4)
		playSfx("naijagasp")
		entity_idle(n)
		
		watch(0.6)
		
		
		
		watch(3)
		
		overrideZoom(0)
	else
	
		stopMusic()
		
		overrideZoom(0.5)
		
		watch(4)
		
		setCameraLerpDelay(0.0001)
		
		cam_toNode(getNode("theend"))
		
		playMusicOnce("prelude")
		
		watch(10)
		
		fade2(0,4)
		fadeIn(4)
		
		overrideZoom(0.9, 20)
		
		watch(4)
		
		watch(4)
		
		
		while not isLeftMouse() and not isRightMouse() do
			watch(FRAME_TIME)
		end
		
		
		
		fadeOutMusic(5)
		fade2(1, 5)
		watch(5)
		
		stopAllSfx()
		
		watch(3)
		
		setCameraLerpDelay(0)
		
		
		if isFlag(FLAG_SKIPSECRETCHECK, 0) then
			voice("naija_endingpart2")
			watchForVoice()
		end
		
		watch(4)
		goToTitle()
	end
end

