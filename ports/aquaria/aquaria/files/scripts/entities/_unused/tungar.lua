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

-- tungar 

function init()
	setupConversationEntity("Tungar")
	-- click/range, cursorRadius, playerRange
	entity_setActivation(1, 80, 256)
	if isMapName("HereticCave") then
		if isMapName("HereticCave1")<=1 then
		else
			entity_delete()
		end
	end
end

function update(dt)
end

function enterState()
end

function exitState()
end

function activate()
	if isMapName("HereticCave") then
		if getFlag("HereticCave1")==1 then
			entity_debugText("gibbles!")
			simpleConversation("HereticCave_TungarReminder")
		elseif getFlag("HereticCave1")==0 then
			simpleConversation("HereticCave_Intro")
			incrFlag("HereticCave1")
		end
	end
end

