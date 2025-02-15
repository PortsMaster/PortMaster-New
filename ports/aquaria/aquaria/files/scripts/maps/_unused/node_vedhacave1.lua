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


vedha 	= 0
drask	= 0
sharan 	= 0
teira 	= 0

drask_route = 0

function init(me)
	if getStory() <= 10 then
		vedha = createEntity("Vedha")
		entity_warpToNode(vedha, getNode("LOBBY"))
		
		--[[
		drask = createEntity("ChildDrask")
		entity_warpToNode(drask, getNode("DRASK1"))
		
		teira = createEntity("ChildTeira")
		entity_warpToNode(teira, getNode("TEIRA1"))
		
		sharan = createEntity("ChildSharan")
		entity_warpToNode(sharan, getNode("SHARAN1"))
		]]--
	end
end
	
function activate(me)
end

function update(me, dt)
end