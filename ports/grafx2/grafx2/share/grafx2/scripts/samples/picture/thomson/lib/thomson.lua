-- thomson.lua : lots of utility for handling
-- thomson screen.
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

if not thomson then

run("color.lua") -- optionnal

thomson = {optiMAP=true}

-- RAM banks
thomson.ramA = {}
thomson.ramB = {}

function thomson.clear()
	for i=1,8000 do
		thomson.ramA[i] = 0
		thomson.ramB[i] = 0
	end
end

-- color levels
thomson.levels = {
	-- in pc-space (0-255):
	pc = {0,100,127,142,163,179,191,203,215,223,231,239,
		  243,247,251,255},
	-- in linear space (0-255):
	linear = {},
	-- maps pc-levels (0-255) to thomson levels (1-16)
	pc2to={},
	-- maps linear-levels (0-255) to thomson levels (1-16)
	linear2to={}
};

-- pc space to linear space
local function toLinear(val)
	-- use the version from Color library
	if not Color then
		val = val/255
		if val<=0.081 then
			val = val/4.5;
		else
			val = ((val+0.099)/1.099)^2.2;
		end
		val = val*255
		return val;
	else
		return Color:new(val,0,0):toLinear().r
	end
end

for i=1,16 do
	thomson.levels.linear[i] = toLinear(thomson.levels.pc[i])
end
for i=0,255 do
	local r,cm,dm;
	r,cm,dm = toLinear(i),0,1e30
	for c,v in ipairs(thomson.levels.linear) do
		local d = math.abs(v-r);
		if d<dm then cm,dm = c,d; end
	end
	thomson.levels.pc2to[i] = cm;
	r,cm,dm = i,0,1e30
	for c,v in ipairs(thomson.levels.linear) do
		local d = math.abs(v-r);
		if d<dm then cm,dm = c,d; end
	end
	thomson.levels.linear2to[i] = cm;
end

-- palette stuff
function thomson.palette(i, pal)
	-- returns palette #i if pal is missing (nil)
	-- if pal is a number, sets palette #i
	-- if pal is an array, sets the palette #i, #i+1, ...
	if type(pal)=='table' then
		for j,v in ipairs(pal) do
			thomson.palette(i+j-1,v)
		end
	elseif pal and i>=0 and i<thomson._palette.max then
		thomson._palette[i+1] = pal
	elseif not pal and i>=0 and i<thomson._palette.max then
		return thomson._palette[i+1]
	end
end;
thomson._palette = {offset = 0, max=16}
thomson.default_palette = {0,15,240,255,3840,3855,4080,4095,
						   1911,826,931,938,2611,2618,3815,123}

-- border color
function thomson.border(c)
	if c then
		thomson._border = c;
	else
		return thomson._border
	end
end
thomson.border(0)

-- helper to appen tables to tables
function thomson._append(result, ...)
	for _,tab in ipairs({...}) do
		for _,v in ipairs(tab) do
			table.insert(result,v)
		end
	end
end

-- RLE compression of data into result
function thomson._compress(result,data)
	local partial,p,pmax={},1,#data
	local function addCarToPartial(car)
		partial[2] = partial[2]+1
		partial[2+partial[2]] = car
	end
	while p<=pmax do
		local num,car = 1,data[p]
		while num<255 and p<pmax and data[p+1]==car do
			num,p = num+1,p+1
		end
		local default=true
		if partial[1] then
			-- 01 aa 01 bb ==> 00 02 aa bb
			if default and num==1 and partial[1]==1 then
				partial = {0,2,partial[2],car}
				default = false
			end
			-- 00 n xx xx xx 01 bb ==> 00 n+1 xx xx xx bb
			if default and num==1 and partial[1]==0 and partial[2]<255 then
				addCarToPartial(car)
				default = false
			end
			-- 00 n xx xx xx 02 bb ==> 00 n+2 xx xx xx bb bb (pas utile mais sert quand combiné à la regle ci-dessus)
			if default and num==2 and partial[1]==0 and partial[2]<254 then
				addCarToPartial(car)
				addCarToPartial(car)
				default = false
			end
		end
		if default then
			thomson._append(result, partial)
			partial = {num,car}
		end
		p=p+1
	end
	thomson._append(result, partial)
	return result
end

-- save a map file corresponging to the current file
-- if a map file already exist, a confirmation is
-- prompted to the user
local function save_current_file()
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

-- saves the thomson screen into a MAP file
function thomson.savep(name)
	if not name then return save_current_file()	end

	wait(0) -- allow for key handling
	local data = thomson._get_map_data()
	local tmp = {0, math.floor(#data/256), #data%256,0,0}
	thomson._append(tmp,data,{255,0,0,0,0})
	local function save(name, buf)
		local out = io.open(name,"wb")
		out:write(buf)
		out:close()
	end
	save(name, string.char(unpack(tmp)))

	-- save raw data as well ?
	local moved, key, mx, my, mb = waitinput(0.01)
	if key==4123 then -- shift-ESC ==> save raw files as well
		save(name .. ".rama", string.char(unpack(thomson.ramA)))
		save(name .. ".ramb", string.char(unpack(thomson.ramB)))
		local pal = ""
		for i=0,15 do
			local val = thomson.palette(i)
			pal=pal..string.char(math.floor(val/256),val%256)
		end
		save(name .. ".pal", pal)
		messagebox('Saved MAP + RAMA/RAMB/PAL files.')
	end
end
waitbreak(0.01)

function thomson.info(...)
	local txt = ""
	for _,t in ipairs({...}) do txt = txt .. t end
	statusmessage(txt);
	if waitbreak(0)==1 then
		local ok=false
		selectbox("Abort ?", "Yes", function() ok = true end, "No", function() ok = false end)
		if ok then error('Operation aborted') end
	end
end

-- copy ramA/B onto GrafX2 screen
function thomson.updatescreen()
	-- back out
	for i=0,255 do
		setcolor(i,0,0,0)
	end
	-- refresh screen content
	clearpicture(thomson._palette.offset + thomson.border())
	for y=0,thomson.h-1 do
		for x=0,thomson.w-1 do
			local p = thomson.point(x,y)
			if p<0 then p=-p-1 end
			thomson._putpixel(x,y,thomson._palette.offset + p)
		end
	end
	-- refresh palette
	for i=1,thomson._palette.max do
		local v=thomson._palette[i]
		local r=v % 16
		local g=math.floor(v/16)  % 16
		local b=math.floor(v/256) % 16
		setcolor(i+thomson._palette.offset-1,
				 thomson.levels.pc[r+1],
				 thomson.levels.pc[g+1],
				 thomson.levels.pc[b+1])
	end
	updatescreen()
end

-- bitmap 16 mode
function thomson.setBM16()
	-- put a pixel onto real screen
	function thomson._putpixel(x,y,c)
		putpicturepixel(x*2+0,y,c)
		putpicturepixel(x*2+1,y,c)
	end
	-- put a pixel in thomson screen
	function thomson.pset(x,y,c)
		local bank = x%4<2 and thomson.ramA or thomson.ramB
		local offs = math.floor(x/4)+y*40+1
		if x%2==0 then
			bank[offs] = (bank[offs]%16)+c*16
		else
			bank[offs] = math.floor(bank[offs]/16)*16+c
		end
		-- c=c+thomson._palette.offset
		-- putpicturepixel(x*2+0,y,c)
		-- putpicturepixel(x*2+1,y,c)
	end
	-- get thomson pixel at (x,y)
	function thomson.point(x,y)
		local bank = x%4<2 and thomson.ramA or thomson.ramB
		local offs = math.floor(x/4)+y*40+1
		if x%2==0 then
			return math.floor(bank[offs]/16)
		else
			return bank[offs]%16
		end
	end
	-- return internal MAP file
	function thomson._get_map_data()
		local tmp = {}
		for x=1,40 do
			for y=x,x+7960,40 do
				table.insert(tmp, thomson.ramA[y])
			end
			for y=x,x+7960,40 do
				table.insert(tmp, thomson.ramB[y])
			end
			wait(0) -- allow for key handling
		end
		local pal = {}
		for i=1,16 do
			pal[2*i-1] = math.floor(thomson._palette[i]/256)
			pal[2*i+0] =            thomson._palette[i]%256
		end
		-- build data
		local data={
			-- BM16
			0x40,
			-- ncols-1
			79,
			-- nlines-1
			24
		};
		thomson._compress(data, tmp)
		thomson._append(data,{0,0})
		-- padd to word
		if #data%2==1 then table.insert(data,0); end
		-- tosnap
		thomson._append(data,{0,128,0,thomson.border(),0,3})
		thomson._append(data, pal)
		thomson._append(data,{0xa5,0x5a})
		return data
	end

	thomson.w = 160
	thomson.h = 200
	thomson.palette(0,thomson.default_palette)
	thomson.border(0)
	thomson.clear()
end

-- mode MO5
function thomson.setMO5()
	-- put a pixel onto real screen
	thomson._putpixel = putpicturepixel
	-- helpers
	local function bittst(val,mask)
		-- return bit32.btest(val,mask)
		return (val % (2*mask))>=mask;
	end
	local function bitset(val,mask)
		-- return bit32.bor(val, mask)
		return bittst(val,mask) and val or (val+mask)
	end
	local function bitclr(val,mask)
		-- return bit32.band(val,255-mask)
		return bittst(val,mask) and (val-mask) or val
	end
	-- put a pixel in thomson screen
	function thomson.pset(x,y,c)
		local offs = math.floor(x/8)+y*40+1
		local mask = 2^(7-(x%8))
		if c>=0 then
			thomson.ramB[offs] = (thomson.ramB[offs]%16)+c*16
			thomson.ramA[offs] = bitset(thomson.ramA[offs],mask)
		else
			c=-c-1
			thomson.ramB[offs] = math.floor(thomson.ramB[offs]/16)*16+c
			thomson.ramA[offs] = bitclr(thomson.ramA[offs],mask)
		end
	end
	-- get thomson pixel at (x,y)
	function thomson.point(x,y)
		local offs = math.floor(x/8)+y*40+1
		local mask = 2^(7-(x%8))
		if bittst(thomson.ramA[offs],mask) then
			return math.floor(thomson.ramB[offs]/16)
		else
			return -(thomson.ramB[offs]%16)-1
		end
	end
	-- convert color from MO5 to TO7 (MAP requires TO7 encoding)
	local function mo5to7(val)
		-- MO5: DCBA 4321
		--      __
		-- TO7: 4DCB A321
		local t=((val%16)>=8) and 0 or 128
		val = math.floor(val/16)*8 + (val%8)
		val = (val>=64 and val-64 or val+64) + t
		return val
	end
	-- return internal MAP file
	function thomson._get_map_data()
		-- create columnwise data
		local tmpA,tmpB={},{};
		for x=1,40 do
			for y=x,x+7960,40 do
				table.insert(tmpA, thomson.ramA[y])
				table.insert(tmpB, thomson.ramB[y])
			end
			wait(0) -- allow for key handling
		end
		if thomson.optiMAP then
			-- optimize
			for i=2,8000 do
				local c1,c2 = math.floor(tmpB[i-0]/16),tmpB[i-0]%16
				local d1,d2 = math.floor(tmpB[i-1]/16),tmpB[i-1]%16

				if tmpA[i-1]==255-tmpA[i] or c1==d2 and c2==c1 then
					tmpA[i] = 255-tmpA[i]
					tmpB[i] = c2*16+c1
				elseif tmpA[i]==255 and c1==d1 or tmpA[i]==0 and c2==d2 then
					tmpB[i] = tmpB[i-1]
				end
			end
		else
			for i=1,8000 do
				local c1,c2 = math.floor(tmpB[i]/16),tmpB[i]%16

				if tmpA[i]==255 or c1<c2 then
					tmpA[i] = 255-tmpA[i]
					tmpB[i] = c2*16+c1
				end
			end
		end
		-- convert into to7 encoding
		for i=1,#tmpB do tmpB[i] = mo5to7(tmpB[i]); end
		-- build data
		local data={
			-- BM40
			0x00,
			-- ncols-1
			39,
			-- nlines-1
			24
		};
		thomson._compress(data, tmpA); tmpA=nil;
		thomson._append(data,{0,0})
		thomson._compress(data, tmpB); tmpB=nil;
		thomson._append(data,{0,0})
		-- padd to word (for compatibility with basic)
		if #data%2==1 then table.insert(data,0); end

		-- tosnap
		local orig_palette = true
		for i=0,15 do
			if thomson.default_palette[i+1]~=thomson.palette(i) then
				orig_palette = false
				break
			end
		end
		if not orig_palette then
			local pal = {}
			for i=0,15 do
				local v = thomson.palette(i)
				pal[2*i+1] = math.floor(v/256)
				pal[2*i+2] =            v%256
			end
			thomson._append(data,{0,0,0,thomson.border(),0,0})
			thomson._append(data, pal)
			thomson._append(data,{0xa5,0x5a})
		end

		return data
	end

	thomson.w = 320
	thomson.h = 200
	thomson.palette(0,thomson.default_palette)
	thomson.border(0)
	thomson.clear()
end

end -- thomson
