-- bayer4_mo5.lua : converts an image into TO7/70-MO5
-- mode for thomson machines (MO6,TO8,TO9,TO9+)
-- using special bayer matrix that fits well with
-- color clashes.
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

-- get screen size
local screen_w, screen_h = getpicturesize()

run("lib/thomson.lua")
run("lib/color.lua")
run("lib/bayer.lua")

-- Converts thomson coordinates (0-319,0-199) into screen coordinates
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

-- return the pixel @(x,y) in normalized linear space (0-1)
-- corresonding to the thomson screen (x in 0-319, y in 0-199)
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
	p:div((y2-y1)*(x2-x1)*Color.ONE)

	return p
end

local dither = bayer.norm(bayer.double(bayer.double({{1,2},{3,4}})))
local dx,dy=#dither,#dither[1]

-- get thomson palette pixel (linear, 0-1 range)
local linearPalette = {}
function linearPalette.get(i)
	local p = linearPalette[i]
	if not p then
		local pal = thomson.palette(i-1)
		local b=math.floor(pal/256)
		local g=math.floor(pal/16)%16
		local r=pal%16
		p = Color:new(thomson.levels.linear[r+1],
					  thomson.levels.linear[g+1],
					  thomson.levels.linear[b+1]):div(Color.ONE)
		linearPalette[i] = p
	end
	return p:clone()
end

-- distance between two colors
local distance = {}
function distance.between(c1,c2)
	local k = c1..','..c2
	local d = distance[k]
	if false and not d then
		d = linearPalette.get(c1):euclid_dist2(linearPalette.get(c2))
		distance[k] = d
	end
	if not d then
		local x = linearPalette.get(c1):sub(linearPalette.get(c2))
		local c,c1,c2,c3=1.8,8,11,8
		local f = function(c,x) return math.abs(x)*c end
		d = f(c1,x.r)^c + f(c2,x.g)^c + f(c3,x.b)^c
		distance[k] = d
	end
	return d
end

-- compute a set of best couples for a given histogram
local best_couple = {n=0}
function best_couple.get(h)
	local k = (((h[1]or 0)*8+(h[2]or 0))*8+(h[3]or 0))*8+(h[4]or 0)
	.. ',' .. (((h[5]or 0)*8+(h[6]or 0))*8+(h[7]or 0))*8+(h[8]or 0)
	local best_found = best_couple[k]
	if not best_found then
		local dm=1000000
		for i=1,15 do
			for j=i+1,16 do
				local d=0
				for p,n in pairs(h) do
					local d1,d2=distance.between(p,i),distance.between(p,j)
					d = d + n*(d1<d2 and d1 or d2)
					if d>dm then break; end
				end
				if d< dm then dm,best_found=d,{} end
				if d<=dm then table.insert(best_found, {c1=i,c2=j}) end
			end
		end

		if best_couple.n>10000 then
			-- keep memory usage low
			best_couple = {n=0, get=best_couple.get}
		end
		best_couple[k] = best_found
		best_couple.n  = best_couple.n+1
	end
	return best_found
end

-- TO7/70 MO5 mode
thomson.setMO5()

-- convert picture
local err1,err2 = {},{}
local coefs = {0,0.6,0}
for x=-1,320 do
	err1[x] = Color:new(0,0,0)
	err2[x] = Color:new(0,0,0)
end
for y = 0,199 do
	err1,err2 = err2,err1
	for x=-1,320 do err2[x]:mul(0) end

	for x = 0,319,8 do
		local h,q = {},{} -- histo, expected color
		for z=x,x+7 do
			local d=dither[1+(y%dx)][1+(z%dx)]
			local p=getLinearPixel(z,y):add(err1[z])
			local c=((p.r>d) and 1 or 0) +
			        ((p.g>d) and 2 or 0) +
					((p.b>d) and 4 or 0) + 1 -- theorical color

			table.insert(q,c)
			h[c] = (h[c] or 0)+1
		end

		local c1,c2
		for c,_ in pairs(h) do
			if c1==nil then c1=c
			elseif c2==nil then c2=c
			else c1=nil; break; end
		end
		if c1~=nil then
			c2 = c2 or c1
		else
			-- get best possible couples of colors
			local best_found = best_couple.get(h)
			if #best_found==1 then
				c1,c2 = best_found[1].c1,best_found[1].c2
			else
				-- keep the best of the best depending on max solvable color clashes
				function clamp(v) return v<0 and -v or v>1 and v-1 or 0 end
				local dm=10000000
				for _,couple in ipairs(best_found) do
					local d=0
					for k=1,8 do
						local q=q[k]
						local p=distance.between(q,couple.c1)<distance.between(q,couple.c2) and couple.c1 or couple.c2
						-- error between expected and best
						local e=linearPalette.get(q):sub(linearPalette.get(p)):mul(coefs[1])
						local z=getLinearPixel(x+k-1,y+1):add(e)
						d = d + clamp(z.r) + clamp(z.g) + clamp(z.b)
					end
					if d<=dm then dm,c1,c2=d,couple.c1,couple.c2 end
				end
			end
		end

		-- thomson.pset(x,y,c1-1)
		-- thomson.pset(x,y,-c2)

		for k=0,7 do
			local z=x+k
			local q=q[k+1]
			local p=distance.between(q,c1)<distance.between(q,c2) and c1 or c2
			local d=linearPalette.get(q):sub(linearPalette.get(p))
			err2[z]:add(d:mul(coefs[1]))

			thomson.pset(z,y,p==c1 and c1-1 or -c2)
		end
	end
	thomson.info("Converting...",math.floor(y/2),"%")
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
	local ok = not exist(fullname)
	if not ok then
		selectbox("Ovr " .. mapname .. "?", "Yes", function() ok = true; end, "No", function() ok = false; end)
	end
	if ok then thomson.savep(fullname) end
end
