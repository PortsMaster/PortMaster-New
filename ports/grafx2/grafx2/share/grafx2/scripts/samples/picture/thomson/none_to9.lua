-- ostro_mo5.lua : converts a color image into a
-- TO9 image (320x200x16 with color clashes)
-- using Ostromoukhov's error diffusion algorithm.
--
-- Version: 02-jan-2017
--
-- Copyright 2016-2017 by Samuel Devulder
--
-- This program is free software; you can redistribute
-- it and/or modify it under the terms of the GNU
-- General Public License as published by the Free
-- Software Foundation; version 2 of the License.
-- See <http://www.gnu.org/licenses/>

run('lib/thomson.lua')
thomson.optiMAP = false

run('lib/ostromoukhov.lua')
run('lib/color_reduction.lua')

local dith=OstroDither:new()
local tmp=dith.setLevelsFromPalette
dith.setLevelsFromPalette = function(self)
	tmp(self)
	self.attenuation=0
end
dith:dither40cols(function(w,h,getLinearPixel)
	local c16 = true
	for y=0,h-1 do
		for x=0,w-1 do
			if getbackuppixel(x,y)>15 then c16 = false end
		end
	end

	local pal
	if c16 then
		pal = {}
		for i=0,15 do
			local r,g,b=getbackupcolor(i)
			r = thomson.levels.pc2to[r]
			g = thomson.levels.pc2to[g]
			b = thomson.levels.pc2to[b]
			pal[i+1] = r+g*16+b*256-273
		end
	else
		pal=ColorReducer:new():analyzeWithDither(w,h,
			getLinearPixel,
			function(y)
				thomson.info("Building palette...",math.floor(y*100/h),"%")
			end):buildPalette(16)
	end
	thomson.palette(0, pal)

	return pal
end)
