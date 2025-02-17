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

v.naijain = false
v.n = 0

function init(me)
	v.n = getNaija()
end

function update(me)
	if node_isEntityIn(me, v.n) and not v.naijain then
		overrideZoom(0.5, 1)
		v.naijain = true
	elseif not node_isEntityIn(me, v.n) and v.naijain then
		v.naijain = false
		overrideZoom(0, 1)
	end
end
