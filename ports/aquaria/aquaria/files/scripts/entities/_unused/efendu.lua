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

-- kairam

function init()
	setupConversationEntity("")
	entity_initSkeletal("Mer", "Efendu")
	entity_animate("idle", -1)
	entity_setActivation(AT_CLICK, 80, 256)
		
	if isMapName("MithalasCastle") then
		if getFlag("NOFLAG")==0 then			
		else
			entity_delete()
		end
	end
	entity_scale(0.65, 0.65)
end

function activate()
	if getFlag("Q3")==0 then
		if onceConversation("Q3-intro") then
			setFlag("GardenActive", 1)
		end
		conversation("Q3-reminder")
		setStringFlag("Hint", "Hint_Q3")
	elseif getFlag("Q4")==1 then
		onceConversation("Q4-done")
		setStringFlag("Hint", "")
	elseif getFlag("Q3")==1 then
		if not(onceConversation("Q3-done")) then
			onceConversation("Q4-intro")
			conversation("Q4-reminder")
			setStringFlag("Hint", "Hint_Q4")
		else
			setStringFlag("Hint", "")
		end
	end
end

function update(dt)
end

function enterState()
end

function exitState()
end


