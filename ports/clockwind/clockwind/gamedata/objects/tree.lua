Tree = class("Tree")

function Tree:initialize(x, y)
	self.x = x
	self.y = y-TILE
	self.w = 8
	self.h = TREE_startlength

	self.category = 4
	self.mask = {false, true, true, true, false}

	self.active = false
	self.static = true

	self.sx = 0
	self.sy = 0

	self.born = timep
	self.grabbable = true

	self.length = TREE_startlength

	self.branches = {} --make like a tree
	for i = 1, 3 do
		local x = self.x+self.w
		local dir = "right"
		if math.floor(i/2) == i/2 then
			x = self.x-32
			dir = "left"
		end
		local object = Branch:new(x, self.y+self.h-30*i, i, dir)
		object.active = false
		self.branches[i] = object
		table.insert(obj["branch"], object)
	end
end

function Tree:update(dt)
	if timetraveling then
		self.length = TREE_startlength+((TREE_length-TREE_startlength)*(((timep-1)-(self.born-1))/(TIMEPERIODS-1)))
		self.length = math.max(TREE_startlength, self.length)

		self.y = self.y + self.h - self.length
		self.h = self.length

		--grow branches
		for i = 1, 3 do
			if self.branches[i].y > self.y+5 then
				self.branches[i].active = true
			else
				self.branches[i].active = false
			end
		end

		--seed form
		if self.length <= TREE_startlength then
			self.grabbable = true
		else
			self.grabbable = false
		end
	end
end

function Tree:draw()
	love.graphics.setColor(1,1,1,1)
	if self.length <= TREE_startlength then --pullable seed
		love.graphics.draw(seedimg, seedq[1][2], math.floor(self.x+self.w/2-8), self.y+self.h-16)
	else
		love.graphics.setScissor(math.floor(self.x+self.w/2-10-camera.x), math.floor(self.y-camera.y), 20, math.ceil(self.h))
		for i = 1, math.ceil(self.length) do
			love.graphics.draw(treeimg, treeq.trunk, math.floor(self.x+self.w/2-10), self.y+self.h-20*i)
		end
		love.graphics.setScissor()
		love.graphics.draw(treeimg, treeq.top, math.floor(self.x+self.w/2-10), self.y-20)
	end
end

function Tree:collide(side, a, b)

end

function Tree:grab()
	local seed = Seed:new(self.x, self.y, 1)
	seed:grab()
	table.insert(obj["seed"], seed)
	
	--delete branches
	for i = 1, 3 do
		self.branches[i].delete = true
	end
	self.delete = true
	return true, seed
end

--Branch platforms
Branch = class("Branch")

function Branch:initialize(x, y, i, dir)
	self.x = x
	self.y = y
	self.w = 32
	self.h = 10
	self.i = i or 1

	self.category = 5
	self.mask = {false, true, true, true, false}

	self.active = true
	self.static = true

	self.sx = 0
	self.sy = 0

	self.dir = dir
end

function Branch:update(dt)
end

function Branch:draw()
	if self.active then
		love.graphics.setColor(1,1,1,1)
		if self.dir == "right" then
			love.graphics.draw(treeimg, treeq.branchright, math.floor(self.x-1), math.floor(self.y-10))
		else
			love.graphics.draw(treeimg, treeq.branchleft, math.floor(self.x-8), math.floor(self.y-10))
		end
	end
end

function Branch:collide(side, a, b)

end