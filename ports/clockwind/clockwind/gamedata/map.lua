--Tile Map
local Map = class("Map")

function Map:initialize(w, h, tileset)
	self.w = w
	self.h = h
	self.background = false

	--create tile matrix
	if w and h then
		self:create(w, h)
	end
end

function Map:update(dt)
end

function Map:drawTile(tilei, timeperiod, x, y)
	local animid = self:getTileProp(tilei, "anim") --animation id (if any)
	if animid then
		local anim = tilesanim[animid]
		love.graphics.draw(anim.img, anim.q[timeperiod][anim.frame], (x-1)*TILE, (y-1)*TILE)
	else
		love.graphics.draw(tilesimg[timeperiod], tileq[timeperiod][tilei][1], (x-1)*TILE, (y-1)*TILE)
	end
end

function Map:draw(front, timeperiod, transition, from) --front?, time period, transition alpha
	local front = (front == "front")
	love.graphics.setColor(1,1,1)
	for x = math.max(1, math.ceil(camera.x/TILE)), math.ceil((camera.x+camera.w)/TILE) do
		for y = math.max(1, math.ceil(camera.y/TILE)), math.ceil((camera.y+camera.h)/TILE) do
			local tilei, forei, obji, text
			if self:inside(x, y) then
				tilei = self:get(x, y, 1)
				forei = self:get(x, y, 2)
				obji = self:get(x, y, 3)
				text = self:get(x, y, 4)
				if tilei > 0 and ((not self:getTileProp(tilei, "foreground")) and (not front)) or (self:getTileProp(tilei, "foreground") and front) then
					love.graphics.setColor(1,1,1)
					if transition then
						self:drawTile(tilei, from, x, y)
						love.graphics.setColor(1,1,1,1-transition)
					end
					self:drawTile(tilei, timeperiod, x, y)
				end

				if forei > 0 and ((not self:getTileProp(forei, "foreground")) and (not front)) or (self:getTileProp(forei, "foreground") and front) then
					love.graphics.setColor(1,1,1)
					if transition then
						self:drawTile(forei, from, x, y)
						love.graphics.setColor(1,1,1,1-transition)
					end
					self:drawTile(forei, timeperiod, x, y)
				end

				if not front then
					if leveledit and obji > 0 then
						love.graphics.setColor(1,1,1,.5)
						love.graphics.draw(objtilesimg, objtileq[obji], (x-1)*TILE, (y-1)*TILE)
					end
				end

				if front then
					if leveledit and text and #text > 0 then
						love.graphics.setColor(1,1,1,1)
						love.graphics.setFont(tinyfont)
						love.graphics.print(text, (x-1)*TILE, (y-1)*TILE)
					end
				end
			end
		end
	end
end

function Map:create(w, h)
	local w, h = w or self.w, h or self.h
	self.map = {}
	for x = 1, w do
		self.map[x] = {}
		for y = 1, h do
			self.map[x][y] = {}
			self.map[x][y][1] = 0 --tile
			self.map[x][y][2] = 0 --tile foreground
			self.map[x][y][3] = 0 --object
			self.map[x][y][4] = "" --object parameters
		end
	end
	self.w = w
	self.h = h
end

function Map:setWidth()

end

function Map:setHeight()

end

function Map:resize(x1, y1, x2, y2) --()
	--
end

function Map:expand(d) --increase width/height
	if d == "left" then
		self:expand("right")
		for x = self.w, 1, -1 do
			for y = 1, self.h do
				if x == 1 then
					self.map[x][y] = {0, 0, 0, ""}
				else
					self.map[x][y] = self.map[x-1][y]
				end
			end
		end
		for x = 1, self.w do
			for y = 1, self.h do
				local tilei = self.map[x][y][1]
				local forei = self.map[x][y][2]
				local obji = self.map[x][y][3]
				local text = self.map[x][y][4]

				self:set(x, y, tilei, 1)
				self:set(x, y, forei, 2)
				self:set(x, y, obji, 3)
				self:set(x, y, text, 4)
			end
		end
	elseif d == "right" then
		self.map[self.w+1] = {}
		for y = 1, self.h do
			table.insert(self.map[self.w+1], {0, 0, 0, ""})
		end
		self.w = self.w + 1
	elseif d == "up" then
		self:expand("down")
		for x = 1, self.w do
			for y = self.h, 1, -1 do
				if y == 1 then
					self.map[x][y] = {0, 0, 0, ""}
				else
					self.map[x][y] = self.map[x][y-1]
				end
			end
		end
		for x = 1, self.w do
			for y = 1, self.h do
				local tilei = self.map[x][y][1]
				local forei = self.map[x][y][2]
				local obji = self.map[x][y][3]
				local text = self.map[x][y][4]

				self:set(x, y, tilei, 1)
				self:set(x, y, forei, 2)
				self:set(x, y, obji, 3)
				self:set(x, y, text, 4)
			end
		end
	elseif d == "down" then
		for x = 1, self.w+1 do
			if not self.map[x] then
				self.map[x] = {}
			end
			table.insert(self.map[x], {0, 0, 0, ""})
		end
		self.h = self.h + 1
	end
	self.changed = true
end

function Map:reduce(d) --decrease width/height
	if d == "left" then
		for x = 1, self.w do
			for y = 1, self.h do
				if x == self.w then
					self.map[x][y] = nil
				else
					self.map[x][y] = self.map[x+1][y]
				end
			end
		end
		self.map[self.w] = nil
		self.w = self.w - 1
	elseif d == "right" then
		for y = 1, self.h do
			table.remove(self, self.w)
		end
		self.w = self.w - 1
	elseif d == "up" then
		for x = 1, self.w do
			for y = 1, self.h do
				if y == self.h then
					--self[x][y] = nil
				else
					self.map[x][y] = self.map[x][y+1]
				end
			end
			self.map[x][self.h] = nil
		end
		self.h = self.h - 1
	elseif d == "down" then
		for x = 1, self.w do
			table.remove(self.map[x], self.h)
		end
		self.h = self.h - 1
	end
	self.changed = true
end

function Map:inside(x, y)
	return (x > 0 and y > 0 and x <= self.w and y <= self.h)
end

function Map:set(x, y, t, i) --x, y, tile id, section
	if self.map[x] and self.map[x][y] then
		self.map[x][y][i or 1] = t or 0

		if i == 1 then
			self:updateTile(x, y)
		end
		return true
	else
		return false
	end
end

function Map:get(x, y, i)
	if self.map[x] and self.map[x][y] and self.map[x][y][i or 1] then
		return self.map[x][y][i or 1]
	else
		return false
	end
end

function Map:getData(x, y)
	if self.map[x] and self.map[x][y] then
		return self.map[x][y]
	else
		return false
	end
end

function Map:getCollision(x, y)
	local tilei = self:get(x, y, 1)
	return self:getTileProp(tilei, "collision")
end

function Map:getProp(x, y, prop) --gets property from coordinate, including foreground layer
	local tilei = self:get(x, y, 1)
	local forei = self:get(x, y, 2)
	return self:getTileProp(tilei, prop) or self:getTileProp(forei, prop)
end

function Map:getTileProp(i, prop, tp)
	local tilei = i
	if tilei and tileq[tp or timeperiod][tilei] then
		return tileq[tp or timeperiod][tilei].t[tilepropst[prop]]
	else
		return false
	end
end

function Map:updateTile(x, y)
	--tile object
	local tilei = self:get(x, y, 1)
	local forei = self:get(x, y, 2)
	local obji = self:get(x, y, 3)
	local text = self:get(x, y, 4)

	obj["tile"][x .. "|" .. y] = nil
	if tilei > 0 and self:getTileProp(tilei, "collision") then --check for collision
		obj["tile"][x .. "|" .. y] = Tile:new(x, y)
	end
end

function Map:save(level)
	level = level or 1

	local s = ""

	--map info
	s = s .. map.w .. "|"
	s = s .. map.h .. "|"
	--tiles
	for x = 1, self.w do
		for y = 1, self.h do
			for i = 1, #self.map[x][y] do
				s = s .. self.map[x][y][i] .. "`"
			end
			s = s:sub(1, -2)
			s = s .. "~"
		end
	end
	--extra data
	s = s .. "|" .. tostring(map.background) .. "|"


	s = s:sub(1, -2)
	love.filesystem.createDirectory("levels")
	return love.filesystem.write("levels/" .. level, s)
end

function Map:load(level)
	level = level or 1

	if not love.filesystem.exists("levels/" .. level) then
		return false
	end

	local s = love.filesystem.read("levels/" .. level)
	local s1 = s:split("|")

	obj["tile"] = {}

	--map info
	self.w = tonumber(s1[1])
	self.h = tonumber(s1[2])
	self:create(self.w, self.h)
	--tiles
	local s2 = s1[3]:split("~")
	for x = 1, self.w do
		self.map[x] = {}
		for y = 1, self.h do
			local s3 = s2[(x-1)*(self.h)+y]:split("`")
			self.map[x][y] = {tonumber(s3[1]) or 0, tonumber(s3[2]) or 0, tonumber(s3[3]) or 0, s3[4] or false}
			self:updateTile(x, y)
		end
	end
	--extra data
	if s1[4] ~= "false" then
		self.background = s1[4]
	end

	return true
end

return Map
