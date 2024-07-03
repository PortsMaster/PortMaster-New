-- color_reduction.lua : support for reducing the
-- colors for a thomson image.
--
-- Inspire by Xiaolin Wu v2 (Xiaolin Wu 1992).
-- Greedy orthogonal bipartition of RGB space for
-- variance minimization aided by inclusion-exclusion
-- tricks. (Author's description)
-- http://www.ece.mcmaster.ca/%7Exwu/cq.c
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
run('bayer.lua')
run('thomson.lua')
run('convex_hull.lua')

if not ColorReducer then

-- clamp a value in the 0-255 range
local function clamp(v)
	v=math.floor(v+.5)
	return v<0 and 0 or v>255 and 255 or v
end

local Voxel = {}

function Voxel:new()
	local o = {m2 = 0, wt=0, mr=0, mg=0, mb=0}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Voxel:rgb()
	local n=self.wt; n=n>0 and n or 1
	return clamp(self.mr/n),
	       clamp(self.mg/n),
		   clamp(self.mb/n)
end

function Voxel:toThomson()
	local r,g,b=self:rgb()
	return thomson.levels.linear2to[r]-1,
		   thomson.levels.linear2to[g]-1,
		   thomson.levels.linear2to[b]-1
end

function Voxel:toPal()
	local r,g,b=self:toThomson()
	return r+g*16+b*256
end

function Voxel:tostring()
	local n=self.wt
	local r,g,b=self:rgb()
	return "(n="..math.floor(n*10)/10 .." r=" .. r.. " g="..g .. " b=" .. b.. " rgb=".. table.concat({self:toThomson()},',').. ")"
end

function Voxel:addColor(color)
	local r,g,b=color:toRGB()
	self.wt = self.wt + 1
	self.mr = self.mr + r
	self.mg = self.mg + g
	self.mb = self.mb + b
	self.m2 = self.m2 + r*r + g*g + b*b
	return self
end

function Voxel:add(other,k)
	k=k or 1
	self.wt = self.wt + other.wt*k
	self.mr = self.mr + other.mr*k
	self.mg = self.mg + other.mg*k
	self.mb = self.mb + other.mb*k
	self.m2 = self.m2 + other.m2*k
	return self
end

function Voxel:mul(k)
	return self:add(self,k-1)
end

function Voxel:module2()
	return self.mr*self.mr + self.mg*self.mg + self.mb*self.mb
end

ColorReducer = {}

function ColorReducer:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function ColorReducer:v(r,g,b)
	local i=(r*17+g)*17+b
	if not self[i] then self[i]=Voxel:new() end
	return self[i]
end

function ColorReducer:add(linearColor)
	local r,g,b=linearColor:toRGB()

	r,g,b=thomson.levels.linear2to[clamp(r)],
	      thomson.levels.linear2to[clamp(g)],
	      thomson.levels.linear2to[clamp(b)]
	self:v(r,g,b):addColor(linearColor)
	-- if r==1 and g==1 and b==1 then messagebox(self:v(r,g,b).wt) end
end

function ColorReducer:M3d()
	-- convert histogram into moments so that we can
    -- rapidly calculate the sums of the above quantities
    -- over any desired box.
	for r=1,16 do
		local area={}
		for i=0,16 do area[i]=Voxel:new() end
		for g=1,16 do
			local line=Voxel:new()
			for b=1,16 do
				local v = self:v(r,g,b)
				-- v:mul(0):add(self:v(r-1,g,b)):add(area[b]:add(line:add(v))
				line:add(v)
				area[b]:add(line)
				v:mul(0):add(self:v(r-1,g,b)):add(area[b])
			end
		end
	end
end

function ColorReducer:Vol(cube)
	-- Compute sum over a box of all statistics
	return Voxel:new()
	       :add(self:v(cube.r1,cube.g1,cube.b1), 1)
		   :add(self:v(cube.r1,cube.g1,cube.b0),-1)
		   :add(self:v(cube.r1,cube.g0,cube.b1),-1)
		   :add(self:v(cube.r1,cube.g0,cube.b0), 1)
		   :add(self:v(cube.r0,cube.g1,cube.b1),-1)
		   :add(self:v(cube.r0,cube.g1,cube.b0), 1)
		   :add(self:v(cube.r0,cube.g0,cube.b1), 1)
		   :add(self:v(cube.r0,cube.g0,cube.b0),-1)
end

-- The next two routines allow a slightly more efficient
-- calculation of Vol() for a proposed subbox of a given
-- box.  The sum of Top() and Bottom() is the Vol() of a
-- subbox split in the given direction and with the specified
-- new upper bound.

function ColorReducer:Bottom(cube,dir)
	-- Compute part of Vol(cube, mmt) that doesn't
	-- depend on r1, g1, or b1 (depending on dir)
	local v=Voxel:new()
	if dir=="RED" then
		v:add(self:v(cube.r0,cube.g1,cube.b1),-1)
		 :add(self:v(cube.r0,cube.g1,cube.b0), 1)
		 :add(self:v(cube.r0,cube.g0,cube.b1), 1)
		 :add(self:v(cube.r0,cube.g0,cube.b0),-1)
	elseif dir=="GREEN" then
		v:add(self:v(cube.r1,cube.g0,cube.b1),-1)
		 :add(self:v(cube.r1,cube.g0,cube.b0), 1)
		 :add(self:v(cube.r0,cube.g0,cube.b1), 1)
		 :add(self:v(cube.r0,cube.g0,cube.b0),-1)
	elseif dir=="BLUE" then
		v:add(self:v(cube.r1,cube.g1,cube.b0),-1)
		 :add(self:v(cube.r1,cube.g0,cube.b0), 1)
		 :add(self:v(cube.r0,cube.g1,cube.b0), 1)
		 :add(self:v(cube.r0,cube.g0,cube.b0),-1)
	end
	return v
end

function ColorReducer:Top(cube,dir,pos)
	-- Compute remainder of Vol(cube, mmt), substituting
    -- pos for r1, g1, or b1 (depending on dir)
	local v=Voxel:new()
	if dir=="RED" then
		v:add(self:v(pos,cube.g1,cube.b1), 1)
		 :add(self:v(pos,cube.g1,cube.b0),-1)
		 :add(self:v(pos,cube.g0,cube.b1),-1)
		 :add(self:v(pos,cube.g0,cube.b0), 1)
	elseif dir=="GREEN" then
		v:add(self:v(cube.r1,pos,cube.b1), 1)
		 :add(self:v(cube.r1,pos,cube.b0),-1)
		 :add(self:v(cube.r0,pos,cube.b1),-1)
		 :add(self:v(cube.r0,pos,cube.b0), 1)
	elseif dir=="BLUE" then
		v:add(self:v(cube.r1,cube.g1,pos), 1)
		 :add(self:v(cube.r1,cube.g0,pos),-1)
		 :add(self:v(cube.r0,cube.g1,pos),-1)
		 :add(self:v(cube.r0,cube.g0,pos), 1)
	end
	return v
end

function ColorReducer:Var(cube)
	-- Compute the weighted variance of a box
	-- NB: as with the raw statistics, this is really the variance * size
	local v = self:Vol(cube)
	return v.m2 - v:module2()/v.wt
end

-- We want to minimize the sum of the variances of two subboxes.
-- The sum(c^2) terms can be ignored since their sum over both subboxes
-- is the same (the sum for the whole box) no matter where we split.
-- The remaining terms have a minus sign in the variance formula,
-- so we drop the minus sign and MAXIMIZE the sum of the two terms.

function ColorReducer:Maximize(cube,dir,first,last,cut,whole)
	local base = self:Bottom(cube,dir)
	local max = 0
	cut[dir] = -1
	for i=first,last-1 do
		local half = Voxel:new():add(base):add(self:Top(cube,dir,i))
		-- now half is sum over lower half of box, if split at i
		if half.wt>0 then -- subbox could be empty of pixels!
			local temp = half:module2()/half.wt
			half:mul(-1):add(whole)
			if half.wt>0 then
				temp = temp + half:module2()/half.wt
				if temp>max then max=temp; cut[dir] = i end
			end
		end
	end
	return max
end

function ColorReducer:Cut(set1,set2)
	local whole = self:Vol(set1)
	local cut = {}
	local maxr = self:Maximize(set1,"RED",  set1.r0+1,set1.r1, cut, whole)
	local maxg = self:Maximize(set1,"GREEN",set1.g0+1,set1.g1, cut, whole)
	local maxb = self:Maximize(set1,"BLUE", set1.b0+1,set1.b1, cut, whole)
	local dir  = "BLUE"
	if maxr>=maxg and maxr>=maxb then
		dir = "RED"
		if cut.RED<0 then return false end -- can't split the box
	elseif maxg>=maxr and maxg>=maxb then
		dir = "GREEN"
	end

	set2.r1=set1.r1
	set2.g1=set1.g1
	set2.b1=set1.b1
	if dir=="RED" then
		set1.r1 = cut[dir]
		set2.r0 = cut[dir]
		set2.g0 = set1.g0
		set2.b0 = set1.b0
	elseif dir=="GREEN" then
		set1.g1 = cut[dir]
		set2.g0 = cut[dir]
		set2.r0 = set1.r0
		set2.b0 = set1.b0
	else
		set1.b1 = cut[dir]
		set2.b0 = cut[dir]
		set2.r0 = set1.r0
		set2.g0 = set1.g0
	end
	local function vol(box)
		local function q(a,b) return (a-b)*(a-b) end
		return q(box.r1,box.r0) + q(box.g1,box.g0) + q(box.b1,box.b0)
	end
	set1.vol = vol(set1)
	set2.vol = vol(set2)
	return true
end

function ColorReducer:boostBorderColors()
	-- Idea: consider the convex hull of all the colors.
	-- These color can be mixed to produce any other used
	-- color, so they are kind of really important.
	-- Unfortunately most color-reduction algorithm do not
	-- retain these color ue to averaging property. The idea
	-- here is not artifically increase their count so that
	-- the averaging goes into these colors.

	-- do return self end -- for testing

	local hull=ConvexHull:new(function(v)
		return {v:rgb()}
	end)

	-- collect set of points
	local pts,tot={},0
	for i=0,17*17*17-1 do
		local v = self[i]
		if v then
			pts[v] = true
			tot=tot+v.wt
		end
	end

	-- build convex hull of colors.
	for v in pairs(pts) do
		hull:addPoint(v)
	end

	-- collect points near the hull
	local bdr, hsz, hnb, max = {},0,0,0
	for v in pairs(pts) do
		if hull:distToHull(v)>-.1 then
			bdr[v] = true
			hnb = hnb+1
			hsz = hsz+v.wt
			max = math.max(max,v.wt)
		end
	end

	if tot>hsz then
		-- heuristic formula to boost colors of the hull
		-- not too little, not to much. It might be tuned
		-- over time, but this version gives satisfying
		-- result (.51 is important)
		for v in pairs(bdr) do
			v:mul(math.min(max,tot-hsz,v.wt*(1+.51*max*hnb/hsz))/v.wt)
		end
	end

	return self
end

function ColorReducer:buildPalette(max, forceBlack)
	if self.palette then return self.palette end

	forceBlack=forceBlack or true

	self:M3d()
	local function c(r0,g0,b0,r1,g1,b1)
		return {r0=r0,r1=r1,g0=g0,g1=g1,b0=b0,b1=b1}
	end
	local cube = {c(0,0,0,16,16,16)}
	local n,i = 1,2
	local vv   = {}
	while i<=max do
		cube[i] = c(0,0,0,1,1,1)
		if forceBlack and i==max then
			local ko = true;
			for j=1,max-1 do
				if self:Vol(cube[j]):toPal()==0 then
					ko = false
					break
				end
			end
			if ko then break end -- forcingly add black
		end
		if self:Cut(cube[n], cube[i]) then
			vv[n] = cube[n].vol>1 and self:Var(cube[n]) or 0
			vv[i] = cube[i].vol>1 and self:Var(cube[i]) or 0
		else
			vv[n] = 0
			cube[i] = nil
			i=i-1
		end
		n = 1; local temp = vv[n]
		for k=2,i do if vv[k]>temp then temp=vv[k]; n=k; end end
		if temp<=0 then break end -- not enough color
		i = i+1
	end

	-- helper to sort the palette
	local pal = {}
	for _,c in ipairs(cube) do
		local r,g,b=self:Vol(c):toThomson()
		table.insert(pal, {r=r+1,g=g+1,b=b+1})
	end
	-- messagebox(#pal)

	-- sort the palette in a nice color distribution
	local function cmp(a,b)
		local t=thomson.levels.pc
		a = Color:new(t[a.r],t[a.g],t[a.b])
		b = Color:new(t[b.r],t[b.g],t[b.b])
		local ah,as,av=a:HSV()
		local bh,bs,bv=b:HSV()
		as,bs=a:intensity()/255,b:intensity()/255
		-- function lum(a) return ((.241*a.r + .691*a.g + .068*a.b)/255)^.5 end
		-- as,bs=lum(a),lum(b)
		local sat,int=32,256
		local function quant(ah,as,av)
			return math.floor(ah*8),
			       math.floor(as*sat),
				   math.floor(av*int+.5)
		end
		ah,as,av=quant(ah,as,av)
		bh,bs,bv=quant(bh,bs,bv)
		-- if true then return ah<bh end
		-- if true then return av<bv or av==bv and as<bs end
		-- if true then return as<bs or as==bs and av<bv end
		if ah%2==1 then as,av=sat-as,int-av end
		if bh%2==1 then bs,bv=sat-bs,int-bv end
		return ah<bh or (ah==bh and (as<bs or (as==bs and av<bv)))
	end
	table.sort(pal, cmp)

	-- add black if color count is not reached
	while #pal<max do table.insert(pal,{r=1,g=1,b=1}) end

	-- linear palette
	local linear = {}
	for i=1,#pal do
		linear[i] = Color:new(thomson.levels.linear[pal[i].r],
							  thomson.levels.linear[pal[i].g],
							  thomson.levels.linear[pal[i].b])
	end
	self.linear = linear

	-- thomson palette
	local palette = {}
	for i=1,#pal do
		palette[i] = pal[i].r+pal[i].g*16+pal[i].b*256-273
	end
	self.palette = palette

	return palette
end

function ColorReducer:getLinearColors()
	return self.linear
end

function ColorReducer:getColor(linearColor)
	local M=64
	local m=(M-1)/255
	local function f(x)
		return math.floor(.5+(x<0 and 0 or x>255 and 255 or x)*m)
	end
	local k=f(linearPixel.r)+M*(f(linearPixel.g)+M*f(linearPixel.b))
	local c=self[k]
	if c==nil then
		local dm=1e30
		for i,palette in ipairs(self.linear) do
			local d = palette:dist2(linearColor)
			if d<dm then dm,c=d,i end
		end
		self[k] = c-1
	end
	return c
end

function ColorReducer:analyze(w,h,getLinearPixel,info)
	if not info then info=function(y) thomson.info() end end
	for y=0,h-1 do
		info(y)
		for x=0,w-1 do
			self:add(getLinearPixel(x,y))
		end
	end
	return self
end

-- fixes the issue ith low-level of intensity
function ColorReducer:analyzeWithDither(w,h,getLinearPixel,info)
	-- do return self:analyze(w,h,getLinearPixel,info) end
	local mat=bayer.make(4)
	local mx,my=#mat,#mat[1]
	local function dith(x,y)
		local function dith(v,t)
			local L=thomson.levels.linear
			local i=14
			local a,b=L[i+1],L[i+2]
			if v>=b then return v end
			while v<a do a,b,i=L[i],a,i-1 end
			return (v-a)/(b-a)>=t and b or a
		end
		local t = mat[1+(x%mx)][1+(y%my)]
		local p=getLinearPixel(x,y)
		p.r = dith(p.r, t)
		p.g = dith(p.g, t)
		p.b = dith(p.b, t)
		return p
	end
	return self:analyze(w,h, function(x,y)
		return
			   dith(x,y)
		       -- :mul(4):add(getLinearPixel(x,y)):div(5)
			   -- :add(getLinearPixel(x-1,y))
			   -- :add(getLinearPixel(x+1,y))
			   -- :div(3)
	end, info)
end

--[[
function ColorReducer:analyzeBuildWithDither(w,h,max,getLinearPixel,info)
	if not info then info=function(y) wait(0) end end

	local dith = ColorReducer:new()
	dith:analyze(w,h,getLinearPixel,function(y) info(y/2) end)


	local ostro = OstroDither:new(dith:buildPalette(max),
	                              thomson.levels.linear, .9)
	ostro:dither(w,h,
		function(x,y,xs,err)
			local p = getLinearPixel(x,y)
			self:add(err[x]:clone():add(p))
			self:add(p)
			return p
		end,
		function(x,y,c)
			-- self:add(ostro:_linearPalette(c+1))
		end,true,
		function(y) info((h+y)/2) end
	)

	return self:buildPalette(max)
end
--]]

end -- ColorReduction
