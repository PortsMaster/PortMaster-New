-- ostromoukhov.lua : Color dithering using variable
-- coefficients.
--
-- https://liris.cnrs.fr/victor.ostromoukhov/publications/pdf/SIGGRAPH01_varcoeffED.pdf
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

run('color.lua')
run('thomson.lua')

if not OstroDither then

OstroDither = {}

local function default_levels()
	return {r={0,Color.ONE},g={0,Color.ONE},b={0,Color.ONE}}
end

function OstroDither:new(palette,attenuation,levels)
	local o = {
		attenuation = attenuation or .9, -- works better than 1
		palette = palette or thomson.default_palette,
		levels = levels or default_levels(),
		clash_size = 8 -- for color clash
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function OstroDither:setLevelsFromPalette()
	local rLevels = {[1]=true,[16]=true}
	local gLevels = {[1]=true,[16]=true}
	local bLevels = {[1]=true,[16]=true}
	local default_palette = true
	for i,pal in ipairs(self.palette) do
		local r,g,b=pal%16,math.floor(pal/16)%16,math.floor(pal/256)
		rLevels[1+r] = true
		gLevels[1+g] = true
		bLevels[1+b] = true
		if pal~=thomson.default_palette[i] then
			default_palette = false
		end
	end
	local levels = {r={},g={},b={}}
	for i,v in ipairs(thomson.levels.linear) do
		if false then
			if rLevels[i] and gLevels[i] and bLevels[i] then
				table.insert(levels.r, v)
				table.insert(levels.g, v)
				table.insert(levels.b, v)
			end
		else
			if rLevels[i] then table.insert(levels.r, v) end
			if gLevels[i] then table.insert(levels.g, v) end
			if bLevels[i] then table.insert(levels.b, v) end
		end
	end
	self.levels = levels
	if default_palette then
		self.attenuation = .98
		self.levels = default_levels()
	else
		self.attenuation = .9
		self.levels = levels
	end
end

function OstroDither:_coefs(linearLevel,rgb)
	if self._ostro==nil then
		-- original coefs, about to be adapted to the levels
		local t={
			13,     0,     5,
			13,     0,     5,
			21,     0,    10,
			 7,     0,     4,
			 8,     0,     5,
			47,     3,    28,
			23,     3,    13,
			15,     3,     8,
			22,     6,    11,
			43,    15,    20,
			 7,     3,     3,
		   501,   224,   211,
		   249,   116,   103,
		   165,    80,    67,
		   123,    62,    49,
		   489,   256,   191,
			81,    44,    31,
		   483,   272,   181,
			60,    35,    22,
			53,    32,    19,
		   237,   148,    83,
		   471,   304,   161,
			 3,     2,     1,
		   459,   304,   161,
			38,    25,    14,
		   453,   296,   175,
		   225,   146,    91,
		   149,    96,    63,
		   111,    71,    49,
			63,    40,    29,
			73,    46,    35,
		   435,   272,   217,
		   108,    67,    56,
			13,     8,     7,
		   213,   130,   119,
		   423,   256,   245,
			 5,     3,     3,
		   281,   173,   162,
		   141,    89,    78,
		   283,   183,   150,
			71,    47,    36,
		   285,   193,   138,
			13,     9,     6,
			41,    29,    18,
			36,    26,    15,
		   289,   213,   114,
		   145,   109,    54,
		   291,   223,   102,
			73,    57,    24,
		   293,   233,    90,
			21,    17,     6,
		   295,   243,    78,
			37,    31,     9,
			27,    23,     6,
		   149,   129,    30,
		   299,   263,    54,
			75,    67,    12,
			43,    39,     6,
		   151,   139,    18,
		   303,   283,    30,
			38,    36,     3,
		   305,   293,    18,
		   153,   149,     6,
		   307,   303,     6,
			 1,     1,     0,
		   101,   105,     2,
			49,    53,     2,
			95,   107,     6,
			23,    27,     2,
			89,   109,    10,
			43,    55,     6,
			83,   111,    14,
			 5,     7,     1,
		   172,   181,    37,
			97,    76,    22,
			72,    41,    17,
		   119,    47,    29,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			65,    18,    17,
			95,    29,    26,
		   185,    62,    53,
			30,    11,     9,
			35,    14,    11,
			85,    37,    28,
			55,    26,    19,
			80,    41,    29,
		   155,    86,    59,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
		   305,   176,   119,
		   155,    86,    59,
		   105,    56,    39,
			80,    41,    29,
			65,    32,    23,
			55,    26,    19,
		   335,   152,   113,
			85,    37,    28,
		   115,    48,    37,
			35,    14,    11,
		   355,   136,   109,
			30,    11,     9,
		   365,   128,   107,
		   185,    62,    53,
			25,     8,     7,
			95,    29,    26,
		   385,   112,   103,
			65,    18,    17,
		   395,   104,   101,
			 4,     1,     1,
			 4,     1,     1,
		   395,   104,   101,
			65,    18,    17,
		   385,   112,   103,
			95,    29,    26,
			25,     8,     7,
		   185,    62,    53,
		   365,   128,   107,
			30,    11,     9,
		   355,   136,   109,
			35,    14,    11,
		   115,    48,    37,
			85,    37,    28,
		   335,   152,   113,
			55,    26,    19,
			65,    32,    23,
			80,    41,    29,
		   105,    56,    39,
		   155,    86,    59,
		   305,   176,   119,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
			 5,     3,     2,
		   155,    86,    59,
			80,    41,    29,
			55,    26,    19,
			85,    37,    28,
			35,    14,    11,
			30,    11,     9,
		   185,    62,    53,
			95,    29,    26,
			65,    18,    17,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
			 4,     1,     1,
		   119,    47,    29,
			72,    41,    17,
			97,    76,    22,
		   172,   181,    37,
			 5,     7,     1,
			83,   111,    14,
			43,    55,     6,
			89,   109,    10,
			23,    27,     2,
			95,   107,     6,
			49,    53,     2,
		   101,   105,     2,
			 1,     1,     0,
		   307,   303,     6,
		   153,   149,     6,
		   305,   293,    18,
			38,    36,     3,
		   303,   283,    30,
		   151,   139,    18,
			43,    39,     6,
			75,    67,    12,
		   299,   263,    54,
		   149,   129,    30,
			27,    23,     6,
			37,    31,     9,
		   295,   243,    78,
			21,    17,     6,
		   293,   233,    90,
			73,    57,    24,
		   291,   223,   102,
		   145,   109,    54,
		   289,   213,   114,
			36,    26,    15,
			41,    29,    18,
			13,     9,     6,
		   285,   193,   138,
			71,    47,    36,
		   283,   183,   150,
		   141,    89,    78,
		   281,   173,   162,
			 5,     3,     3,
		   423,   256,   245,
		   213,   130,   119,
			13,     8,     7,
		   108,    67,    56,
		   435,   272,   217,
			73,    46,    35,
			63,    40,    29,
		   111,    71,    49,
		   149,    96,    63,
		   225,   146,    91,
		   453,   296,   175,
			38,    25,    14,
		   459,   304,   161,
			 3,     2,     1,
		   471,   304,   161,
		   237,   148,    83,
			53,    32,    19,
			60,    35,    22,
		   483,   272,   181,
			81,    44,    31,
		   489,   256,   191,
		   123,    62,    49,
		   165,    80,    67,
		   249,   116,   103,
		   501,   224,   211,
			 7,     3,     3,
			43,    15,    20,
			22,     6,    11,
			15,     3,     8,
			23,     3,    13,
			47,     3,    28,
			 8,     0,     5,
			 7,     0,     4,
			21,     0,    10,
			13,     0,     5,
			13,     0,     5}
		local function process(tab)
			local tab2={}
			local function add(i)
				i=3*math.floor(i+.5)
				local c0,c1,c2=t[i+1],t[i+2],t[i+3]
				local norm=self.attenuation/(c0+c1+c2)
				table.insert(tab2,c0*norm)
				table.insert(tab2,c1*norm)
				table.insert(tab2,c2*norm)
			end
			local function level(i)
				return tab[i]*255/Color.ONE
			end
			local a,b,j=level(1),level(2),3
			for i=0,255 do
				if i>b then a,b,j=b,level(j),j+1; end
				add(255*(i-a)/(b-a))
			end
			return tab2
		end
		self._ostro = {r=process(self.levels.r),
		               g=process(self.levels.g),
					   b=process(self.levels.b)}
	end
	local i = math.floor(linearLevel[rgb]*255/Color.ONE+.5)
	i = 3*(i<0 and 0 or i>255 and 255 or i)
	return self._ostro[rgb][i+1],self._ostro[rgb][i+2],self._ostro[rgb][i+3]
end

function OstroDither:_linearPalette(colorIndex)
	if self._linear==nil then
		self._linear = {}
		local t=thomson.levels.linear
		for i,pal in ipairs(self.palette) do
			local r,g,b=pal%16,math.floor(pal/16)%16,math.floor(pal/256)
			self._linear[i] = Color:new(t[1+r],t[1+g],t[1+b])
		end
	end
	return self._linear[colorIndex]
end

function OstroDither:getColorIndex(linearPixel)
	local k=linearPixel:hash(64)
	local c=self[k]
	if c==nil then
		local dm=1e30
		for i=1,#self.palette do
			local d = self:_linearPalette(i):dist2(linearPixel)
			if d<dm then dm,c=d,i end
		end
		self[k] = c
	end
	return c
end

function OstroDither:_diffuse(linearColor,err, err0,err1,err2)
	local c=self:getColorIndex(err:add(linearColor))
	local M = Color.ONE

	err:sub(self:_linearPalette(c))
	local function d(rgb)
		local e = err[rgb]
		function f(a,c)
			a=a+c*e
			return a<-M and -M or
			       a> M and  M or a
		end
		local c0,c1,c2=self:_coefs(linearColor,rgb)
		if err0 and c0>0 then err0[rgb] = f(err0[rgb],c0) end
		if err1 and c1>0 then err1[rgb] = f(err1[rgb],c1) end
		if err2 and c2>0 then err2[rgb] = f(err2[rgb],c2) end
	end
	d("r"); d("g"); d("b")

	return c
end

function OstroDither:dither(screen_w,screen_h,getLinearPixel,pset,serpentine,info)
	if not info then info = function(y) thomson.info() end end
	if not serpentine then serpentine = true end

	local err1,err2 = {},{}
	for x=-1,screen_w do
		err1[x] = Color:new(0,0,0)
		err2[x] = Color:new(0,0,0)
	end

	for y=0,screen_h-1 do
		-- permute error buffers
		err1,err2 = err2,err1
		-- clear current-row's buffer
		for i=-1,screen_w do err2[i]:mul(0) end

		local x0,x1,xs=0,screen_w-1,1
		if serpentine and y%2==1 then x0,x1,xs=x1,x0,-xs end

		for x=x0,x1,xs do
			local p = getLinearPixel(x,y,xs,err1)
			local c = self:_diffuse(p,err1[x],err1[x+xs],
			                          err2[x-xs],err2[x])
			pset(x,y,c-1)
		end
		info(y)
	end
end

function OstroDither:ccAcceptCouple(c1,c2)
	return c1~=c2
end

function OstroDither:ccDither(screen_w,screen_h,getLinearPixel,pset,serpentine,info) -- dither with color clash
	local c1,c2
	self.getColorIndex = function(self,p)
		return p:dist2(self:_linearPalette(c1))<p:dist2(self:_linearPalette(c2)) and c1 or c2
	end

	local function _pset(x,y,c)
		pset(x,y,c==c1-1 and c or -c2)
	end

	local findC1C2 = function(x,y,xs,err1)
		-- collect the data we are working on
		local gpl = {
			clone = function(self)
				local r={}
				for i,v in ipairs(self) do
					r[i] = {pix=v.pix:clone(),
					        err=v.err:clone()}
				end
				return r
			end,
			fill = function(self,dither)
				for i=x,x+(dither.clash_size-1)*xs,xs do
					table.insert(self,
					            {pix=getLinearPixel(i,y),
								 err=err1[i]})
				end
				table.insert(self, {pix=Color:new(),
				                    err=Color:new()})
			end
		}
		gpl:fill(self)

		local histo = {
			fill = function(self,dither)
				local t=gpl:clone()
				for i=1,#dither.palette do self[i] = {n=0,c=i} end
				local back = dither.getColorIndex
				dither.getColorIndex = OstroDither.getColorIndex
				for i=1,dither.clash_size do
					local c = dither:_diffuse(t[i].pix,t[i].err,
					                          t[i+1].err)
					self[c].n = self[c].n+1
				end
				dither.getColorIndex = back
				table.sort(self, function(a,b)
				           return a.n>b.n or a.n==b.n and a.c<b.c end)
		 	end,
			get = function(self,i,...)
				if i then
					return self[i].c,self:get(...)
				end
			end,
			num = function(self,i,...)
				if i then
					return self[i].n,self:num(...)
				end
			end,
			sum = function(self,i,...)
				return i and self[i].n+self:sum(...) or 0
			end
		}
		histo:fill(self)

		c1,c2=histo:get(1,2)

		if not self:ccAcceptCouple(c1,c2) or histo:sum(1,2)<=self.clash_size-2 then
			info(y)
			local dm=1e30
			local function eval()
				if self:ccAcceptCouple(c1,c2) then
					local d,t = 0,gpl:clone()
					for i=1,self.clash_size do
						local err=t[i].err
						self:_diffuse(t[i].pix,err,t[i+1].err)
						d = d + err.r^2 + err.g^2 + err.b^2
						if d>dm then break end
					end
					return d
				else
					return dm
				end
			end
			dm=eval()

			if histo:num(1)>=self.clash_size/2+1 then
				local z=c2
				for i=1,#self.palette do c2=i
					local d=eval()
					if d<dm then dm,z=d,i end
				end
				c2=z
			else
				local a,b=c1,c2
				for i=1,#self.palette-1 do     c1=i
					for j=1+i,#self.palette do c2=j
						local d=eval()
						if d<dm then dm,a,b=d,i,j end
					end
				end
				c1,c2=a,b
			end
		end
	end

	local function _getLinearPixel(x,y,xs,err1)
		if x%self.clash_size==(xs>0 and 0 or self.clash_size-1) then
			findC1C2(x,y,xs,err1)
		end
		return getLinearPixel(x,y)
	end

	self:dither(screen_w,screen_h,_getLinearPixel,_pset,serpentine,info)
end

function OstroDither:dither40cols(getpalette,serpentine)
	-- get screen size
	local screen_w, screen_h = getpicturesize()

	-- Converts thomson coordinates (0-159,0-199) into screen coordinates
	local function thom2screen(x,y)
		local i,j;
		if screen_w/screen_h < 1.6 then
			i = x*screen_h/200
			j = y*screen_h/200
		else
			i = x*screen_w/320
			j = y*screen_w/320
		end
		return math.floor(i), math.floor(j)
	end

	-- return the Color @(x,y) in linear space (0-255)
	-- corresonding to the thomson screen (x in 0-319,
	-- y in 0-199)
	local function getLinearPixel(x,y)
		local with_cache = true
		if not self._getLinearPixel then self._getLinearPixel = {} end
		local k=x+y*thomson.w
		local p = self._getLinearPixel[k]
		if not p then
			local x1,y1 = thom2screen(x,y)
			local x2,y2 = thom2screen(x+1,y+1)
			if x2==x1 then x2=x1+1 end
			if y2==y1 then y2=y1+1 end

			p = Color:new(0,0,0);
			for j=y1,y2-1 do
				for i=x1,x2-1 do
					p:add(getLinearPictureColor(i,j))
				end
			end
			p:div((y2-y1)*(x2-x1)) --:floor()

			if with_cache then self._getLinearPixel[k]=p end
		end

		return with_cache and p:clone() or p
	end

	-- MO5 mode
	thomson.setMO5()
	self.palette = getpalette(thomson.w,thomson.h,getLinearPixel)

	-- compute levels from palette
	self:setLevelsFromPalette()

	-- convert picture
	self:ccDither(thomson.w,thomson.h,
				  getLinearPixel, thomson.pset,
				  serpentine or true, function(y)
					thomson.info("Converting...",
						math.floor(y*100/thomson.h),"%")
				  end,true)

	-- refresh screen
	setpicturesize(thomson.w,thomson.h)
	thomson.updatescreen()
	thomson.savep()
	finalizepicture()
end

end -- OstroDither
