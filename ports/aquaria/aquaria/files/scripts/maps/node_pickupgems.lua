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


v.n = 0
v.done = false

function init(me)
	v.n = getNaija()
end

function update(me, dt)
	if not v.done and node_isEntityIn(me, v.n) then
		pickupGem("IceCave")
		pickupGem("SunkenCity")
		pickupGem("SongCave")
		pickupGem("EnergyCave")
		pickupGem("HomeCave")
		pickupGem("IceCave")
		pickupGem("Cathedral")
		pickupGem("SpriteCave")
		pickupGem("ForestBoss")
		pickupGem("LiCave")
		pickupGem("SunTemple")
		pickupGem("Turtle")
		pickupGem("Whale")
		pickupGem("PieceRed")
		pickupGem("PieceTeal")
		pickupGem("PieceGreen")
		pickupGem("PyramidPurple")
		pickupGem("Statue")
		pickupGem("PyramidYellow")
		v.done = true
	end
end

