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

-- forest ghost

function init()
	setupConversationEntity("Vedha")
	entity_setActivation(0, 80, 256)
		
	if isMapName("ForestEast") then
		if getFlag("MajaiHide")==0 then
			
		else
			forceBreakElement(13305, 10400, 1)
			forceBreakElement(13305, 10400, 1)
			forceBreakElement(13305, 10400, 1)

			entity_delete()
		end
	end
end

function activate()
	setFlag("MajaiHide", 1)
	msg1("Majai: I'm a rockbusters!")
	forceBreakElement(13305, 10400)
	wait(1)
	forceBreakElement(13305, 10400)
	wait(1)
	forceBreakElement(13305, 10400)
	wait(1)
	msg1("Maija: Byez!")
	entity_delete()
end

function update(dt)
end

function enterState()
end

function exitState()
end


