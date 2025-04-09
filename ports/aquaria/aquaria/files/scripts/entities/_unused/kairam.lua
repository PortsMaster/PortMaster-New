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
	entity_initSkeletal("Mer", "Kairam")
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
	if getFlag("Q1")==0 then
		onceConversation("Q1-intro")
		conversation("Q1-reminder")
		setStringFlag("Hint", "Hint_Q1")
	else
		if onceConversation("Q1-done") then
			setStringFlag("Hint", "")
		end
		if getFlag("Q2")==0 then
			onceConversation("Q2-intro")
			conversation("Q2-reminder")	
			setStringFlag("Hint", "Hint_Q2")
		else
			if onceConversation("Q2-done") then
				setStringFlag("Hint", "")
			end
			conversation("Kairam_TalkToEfendu")
		end
	end
end

function update(dt)
end

function enterState()
end

function exitState()
end


