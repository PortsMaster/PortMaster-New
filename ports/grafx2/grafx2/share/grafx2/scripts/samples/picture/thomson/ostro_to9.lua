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

run('lib/ostromoukhov.lua')
run('lib/color_reduction.lua')

OstroDither:new():dither40cols(function(w,h,getLinearPixel)
	local c16 = h==200 and w==320
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
			end):boostBorderColors():buildPalette(16)
	end

	thomson.palette(0, pal)

	return pal
end)
