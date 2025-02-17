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

-- === SAVE POINT ===
function init(me)
	setupConversationEntity(me, "save-point", "save-point")
	entity_setActivation(me, AT_CLICK, 80, 256)
end

function activate(me)
	pause()
	if isMapName("VedhaCave") then
		savePoint(me)
		if getStory()>=1 and getFlag("usedMemoryCrystal")==0 then
			setFlag("usedMemoryCrystal", 1)
		end
	elseif isMapName("MemoryCave") then
		if getFlag("MemoryCaveSavePointScene")==3 then
			savePoint(me)
		elseif getFlag("MemoryCaveSavePointScene")==2 then
			-- naija activating memory crystal while trapped / escaping memory cave
			-- should do nothing (or offer a hint?)
		elseif getFlag("MemoryCaveSavePointScene")==1 then
			simpleConversation("MemoryCave_ghost")
			--learnSpell(2)
			--entityFollowEntity("Drask", "Naija")
			entity_followEntity(getEntity("Drask"), getEntity("Naija"))
			-- setEntityScript("Drask", "");
			setFlag("Drask1", 2)
			setFlag("VedhaCave1", 8)
			setFlag("MemoryCaveSavePointScene", 2)
		elseif getFlag("MemoryCaveSavePointScene")==0 then
			savePoint(me)
		end
	else
		savePoint(me);
	end
	unpause()
end

function update(me, dt)
end

function enterState(me)
end

function exitState(me)
end
