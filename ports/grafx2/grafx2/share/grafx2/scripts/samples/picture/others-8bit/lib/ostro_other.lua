-- ostro_zx.lua : converts a color image into a
-- ZX-like image (8+8 fixed colors with color clash)
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

run('../../thomson/lib/ostromoukhov.lua')

-- get screen size
local screen_w, screen_h = getpicturesize()

OtherDither = {}
function OtherDither:new(a)
	local o = { -- default ZX values
		-- width of the screen
		width=a and a.width or 256,
		-- height of the screen
		height=a and a.height or 192,
		-- size of Nx1 clash size
		clash_size=a and a.clash_size or 8,
		-- normalize the picture levels (like in imagemagick)
		normalize=a and a.normalize or 0.005,
		-- put a pixel
		pset=a and a.pset or function(self,x,y,c)
			if c<0 then c=-c-1 end
			self.screen[x+y*self.width] = c
		end,
		-- init gfx data
		setGfx=a and a.setGfx or function(self)
			self.screen={}
		end,
		-- update gfx to screen
		updatescreen=a and a.updatescreen or function(self)
			for i=0,255 do setcolor(i,0,0,0) end
			for y=0,self.height-1 do
				for x=0,self.width-1 do
					putpicturepixel(x,y,self.screen[x+y*self.width] or 0)
				end
			end
			-- refresh palette
			for i,v in ipairs(self.pal) do
				local r=v % 16
				local g=math.floor(v/16)  % 16
				local b=math.floor(v/256) % 16
				setcolor(i+thomson._palette.offset-1,
						 thomson.levels.pc[r+1],
						 thomson.levels.pc[g+1],
						 thomson.levels.pc[b+1])
			end
			updatescreen()
		end,
		-- palette with thomson ordering (to use thomson's
		-- lib support)
		pal= a and a.pal or {
			0x000,0xF00,0x00F,0xF0F,0x0F0,0xFF0,0x0FF,0xFFF,
			0x000,0x200,0x002,0x202,0x020,0x220,0x022,0x222
		}
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Converts ZX coordinates (0-255,0-191) into screen coordinates
function OtherDither:to_screen(x,y)
	local i,j;
	if screen_w/screen_h < self.width/self.height then
		i = x*screen_h/self.height
		j = y*screen_h/self.height
	else
		i = x*screen_w/self.width
		j = y*screen_w/self.width
	end
	return math.floor(i), math.floor(j)
end

-- return the Color @(x,y) in linear space (0-255)
-- corresonding to the other platform screen
OtherDither._getLinearPixel = {} -- cache
function OtherDither:getLinearPixel(x,y)
	local k=x+y*self.width
	local p = self._getLinearPixel and self._getLinearPixel[k]
	if not p then
		local x1,y1 = self:to_screen(x,y)
		local x2,y2 = self:to_screen(x+1,y+1)
		if x2==x1 then x2=x1+1 end
		if y2==y1 then y2=y1+1 end

		p = Color:new(0,0,0)
		for j=y1,y2-1 do
			for i=x1,x2-1 do
				p:add(getLinearPictureColor(i,j))
			end
		end
		p:div((y2-y1)*(x2-x1)) --:floor()

		if self._getLinearPixel then
			self._getLinearPixel[k]=p
		end
	end

	return self._getLinearPixel and p:clone() or p
end

function OtherDither:ccAcceptCouple(c1,c2)
	-- bright colors can't mix with dimmed ones
	return c1~=c2 and ((c1<=8 and c2<=8) or (c1>8 and c2>8))
end

function OtherDither:dither()
	local NORMALIZE=Color.NORMALIZE
	Color.NORMALIZE=self.normalize

	local dither=OstroDither:new(self.pal)
	dither.ccAcceptCouple = function(dither,c1,c2) return self:ccAcceptCouple(c1,c2) end
	dither.clash_size = self.clash_size
	dither.attenuation = .9

	self:setGfx()
	dither:ccDither(self.width,self.height,
				  function(x,y) return self:getLinearPixel(x,y) end,
				  function(x,y,c) self:pset(x,y,c) end,
				  true,
				  function(y)
					thomson.info("Converting...",
							math.floor(y*100/self.height),"%")
				  end,true)
	-- refresh screen
	setpicturesize(self.width,self.height)
	self:updatescreen()
	finalizepicture()
	Color.NORMALIZE=NORMALIZE
end
