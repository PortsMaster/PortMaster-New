-- ostro_zx.lua : converts a color image into a
-- Oric image (8+8 fixed colors with color clash)
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

OtherDither:new{
	width=240,
	height=200,
	clash_size=6,
	pal={0x000,0x00F,0x0F0,0x0FF,0xF00,0xF0F,0xFF0,0xFFF},
	pset=function(self,x,y,c)
		if x<6 then c=0    end
		if c<0 then c=-c-1 end
		self.screen[x+y*self.width] = c
	end
}:dither()
