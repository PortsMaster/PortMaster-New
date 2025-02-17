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


--function bASDFASDF () ()A {}}A SDFASJDF end end end

v.n = 0
v.mia = 0
v.baby = 0

v.done = false

function init(me)
	v.n = getNaija()
	v.mia = getEntity("MiaGhost")
	v.baby = getEntity("NaijaChildGhost")
	
	entity_fh(v.mia)
	entity_alpha(v.mia, 0)
	entity_alpha(v.baby, 0)
	
	fade2(0, 1)
end

function update(me, dt)
	if not v.done and isFlag(FLAG_SECRET03, 0) then 
		if node_isEntityIn(me, v.n) then
			v.done = true
			
			setFlag(FLAG_SECRET03, 1)
			
			foundLostMemory()
			
			changeForm(FORM_NORMAL)
			
			entity_idle(v.n)
			
			cam_toEntity(v.mia)
			
			setSceneColor(0.5, 0.5, 1, 2)
			watch(2)
			fade2(1, 2, 1, 1, 1)
			watch(2)
			loadMap("Secret03", "INSIDE")
		end
	end
	
end
