-- ostro_zx.lua : converts a color image into a
-- ZX image (8+8 fixed colors with color clash)
-- using Ostromoukhov's error diffusion algorithm.
--
-- Version: 03/21/2017
--
-- Copyright 2016-2017 by Samuel Devulder
--
-- This program is free software; you can redistribute
-- it and/or modify it under the terms of the GNU
-- General Public License as published by the Free
-- Software Foundation; version 2 of the License.
-- See <http://www.gnu.org/licenses/>

run('lib/ostro_other.lua')

OtherDither:new{width=256,height=192,clash_size=8}:dither()
