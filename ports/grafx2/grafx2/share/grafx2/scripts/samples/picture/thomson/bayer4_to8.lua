-- bayer4_to8.lua : converts an image into BM16
-- mode for thomson machines (MO6,TO8,TO9,TO9+)
-- using bayer matrix and a special palette.
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

-- This is my first code in lua, so excuse any bad
-- coding practice.

-- use a zig zag. If false (recommended value), this gives
-- a raster look and feel
local with_zig_zag = with_zig_zag or false

-- debug: displays histograms
local debug = false

-- enhance luminosity since our mode divide it by two
local enhance_lum = enhance_lum or true

-- use fixed levels (default=false, give better result)
local fixed_levels = fixed_levels or false

-- use void-and-cluster 8x8 matrix (default=false)
local use_vac = use_vac or false

-- get screen size
local screen_w, screen_h = getpicturesize()

run("lib/thomson.lua")
run("lib/color.lua")
run("lib/bayer.lua")

-- Converts thomson coordinates (0-159,0-99) into screen coordinates
local function thom2screen(x,y)
	local i,j;
	if screen_w/screen_h < 1.6 then
		i = x*screen_h/100
		j = y*screen_h/100
	else
		i = x*screen_w/160
		j = y*screen_w/160
	end
	return math.floor(i), math.floor(j)
end

-- return the pixel @(x,y) in linear space corresonding to the thomson screen (x in 0-159, y in 0-99)
local function getLinearPixel(x,y)
	local x1,y1 = thom2screen(x,y)
	local x2,y2 = thom2screen(x+1,y+1)
	if x2==x1 then x2=x1+1 end
	if y2==y1 then y2=y1+1 end

	local p,i,j = Color:new(0,0,0);
	for i=x1,x2-1 do
		for j=y1,y2-1 do
			p:add(getLinearPictureColor(i,j))
		end
	end

	return p:div((y2-y1)*(x2-x1)):floor()
end

--[[ make a bayer matrix
function bayer(matrix)
	local m,n=#matrix,#matrix[1]
	local r,i,j = {}
	for j=1,m*2 do
		local t = {}
		for i=1,n*2 do t[i]=0; end
		r[j] = t;
	end

	-- 0 3
	-- 2 1
	for j=1,m do
		for i=1,n do
			local v = 4*matrix[j][i]
			r[m*0+j][n*0+i] = v-3
			r[m*1+j][n*1+i] = v-2
			r[m*1+j][n*0+i] = v-1
			r[m*0+j][n*1+i] = v-0
		end
	end

	return r;
end
--]]

-- dither matrix
local dither = bayer.make(4)

if use_vac then
	-- vac8: looks like FS
	dither = bayer.norm{
		{35,57,19,55,7,51,4,21},
		{29,6,41,27,37,17,59,45},
		{61,15,53,12,62,25,33,9},
		{23,39,31,49,2,47,13,43},
		{3,52,8,22,36,58,20,56},
		{38,18,60,46,30,5,42,28},
		{63,26,34,11,64,16,54,10},
		{14,48,1,44,24,40,32,50}
	}
end

-- get color statistics
local stat = {};
function stat:clear()
	self.r = {}
	self.g = {}
	self.b = {}
	for i=1,16 do self.r[i] = 0; self.g[i] = 0; self.b[i] = 0; end
end
function stat:update(px)
	local pc2to = thomson.levels.pc2to
	local r,g,b=pc2to[px.r], pc2to[px.g], pc2to[px.b];
	self.r[r] = self.r[r] + 1;
	self.g[g] = self.g[g] + 1;
	self.b[b] = self.b[b] + 1;
end
function stat:coversThr(perc)
	local function f(stat)
		local t=-stat[1]
		for i,n in ipairs(stat) do t=t+n end
		local thr = t*perc; t=-stat[1]
		for i,n in ipairs(stat) do
			t=t+n
			if t>=thr then return i end
		end
		return 0
	end
	return f(self.r),f(self.g),f(self.b)
end
stat:clear();
for y = 0,99 do
	for x = 0,159 do
		stat:update(getLinearPixel(x,y))
	end
	thomson.info("Collecting stats...",y,"%")
end

-- enhance luminosity since our mode divide it by two
local gain = 1
if enhance_lum then
	-- findout level that covers 98% of all non-black pixels
	local max = math.max(stat:coversThr(.98))

	gain = math.min(2,255/thomson.levels.linear[max])

	if gain>1 then
		-- redo stat with enhanced levels
		-- messagebox('gain '..gain..' '..table.concat({stat:coversThr(.98)},','))
		stat:clear();
		for y = 0,99 do
			for x = 0,159 do
				stat:update(getLinearPixel(x,y):mul(gain):floor())
			end
			thomson.info("Enhancing levels..",y,"%")
		end
	end
end

-- find regularly spaced levels in thomson space
local levels = {}
function levels.compute(name, stat, num)
	local tot, max = -stat[1],0;
	for _,t in ipairs(stat) do
		max = math.max(t,max)
		tot = tot + t
	end
	local acc,full=-stat[1],0
	for i,t in ipairs(stat) do
		acc = acc + t
		if acc>tot*.98 then
			full=thomson.levels.linear[i]
			break
		end
	end
	-- sanity
	if fixed_levels or full==0 then full=255 end
	local res = {1}; num = num-1
	for i=1,num do
		local p = math.floor(full*i/num)
		local q = thomson.levels.linear2to[p]
		if q==res[i] and q<16 then q=q+1 end
		if not fixed_levels and i<num then
			if q>res[i]+1 and stat[q-1]>stat[q] then q=q-1 end
			if q>res[i]+1 and stat[q-1]>stat[q] then q=q-1 end
			-- 3 corrections? no need...
			-- if q>res[i]+1 and stat[q-1]>stat[q] then q=q-1 end
		end
		res[1+i] = q
	end

	-- debug
	if debug then
		local txt = ""
		for _,i in ipairs(res) do
			txt = txt .. i .. " "
		end
		for i,t in ipairs(stat) do
			txt = txt .. "\n" .. string.format("%s%2d:%3d%% ", name, i, math.floor(100*t/(tot+stat[1]))) .. string.rep('X', math.floor(23*t/max))
		end
		messagebox(txt)
	end

	return res
end
function levels.computeAll(stat)
	levels.grn = levels.compute("GRN",stat.g,5)
	levels.red = levels.compute("RED",stat.r,4)
	levels.blu = levels.compute("BLU",stat.b,3)
end
levels.computeAll(stat)

-- put a pixel at (x,y) with dithering
local function pset(x,y,px)
	local thr = dither[1+(y % #dither)][1+(x % #dither[1])]
	local function dither(val,thr,lvls)
		local i=#lvls
		local a,b = thomson.levels.linear[lvls[i]],1e30
		while i>1 and val<a do
			i=i-1;
			a,b=thomson.levels.linear[lvls[i]],a;
		end
		return i + ((val-a)>=thr*(b-a) and 0 or -1)
	end

	local r = dither(px.r, thr, levels.red);
	local g = dither(px.g, thr, levels.grn);
	local b = dither(px.b, thr, levels.blu);

	local i = r + b*4
	local j = g==0 and 0 or (11 + g)

	if with_zig_zag and x%2==1 then
		thomson.pset(x,y*2+0,j)
		thomson.pset(x,y*2+1,i)
	else
		thomson.pset(x,y*2+0,i)
		thomson.pset(x,y*2+1,j)
	end
end

-- BM16 mode
thomson.setBM16()

-- define palette
for i=0,15 do
	local r,g,b=0,0,0
	if i<12 then
		-- r = bit32.band(i,3)
		-- b = bit32.rshift(i,2)
		b = math.floor(i/4)
		r = i-4*b
	else
		g = i-11
	end
	r,g,b=levels.red[r+1],levels.grn[g+1],levels.blu[b+1]
	thomson.palette(i,b*256+g*16+r-273)
end

-- convert picture
for y = 0,99 do
	for x = 0,159 do
		pset(x,y, getLinearPixel(x,y):mul(gain):floor())
	end
	thomson.info("Converting...",y,"%")
end

-- refresh screen
setpicturesize(320,200)
thomson.updatescreen()
finalizepicture()

-- save picture
do
	local function exist(file)
		local f=io.open(file,'rb')
		if not f then return false else io.close(f); return true; end
	end
	local name,path = getfilename()
	local mapname = string.gsub(name,"%.%w*$","") .. ".map"
	local fullname = path .. '/' .. mapname
	-- fullname = 'D:/tmp/toto.map'
	local ok = not exist(fullname)
	if not ok then
		selectbox("Ovr " .. mapname .. "?", "Yes", function() ok = true; end, "No", function() ok = false; end)
	end
	if ok then thomson.savep(fullname) end
end
