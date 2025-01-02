local Grid = Basic:extend("Grid")

function Grid:new(x, y, rows, cols, cellSize, color1, color2)
	Grid.super.new(self)

	self.x = x or 0
	self.y = y or 0
	self.rows = rows or 2
	self.cols = cols or 2
	self.cellSize = cellSize or 20
	self.grid = {}
	self.color1 = color1 or {0.5, 0.5, 0.5}
	self.color2 = color2 or Color.WHITE
	self.scrollFactor = {x = 1, y = 1}
	self.width = self.cellSize * self.cols
	self.height = self.cellSize * self.rows

	for i = 1, rows do
		self.grid[i] = {}
		for j = 1, cols do self.grid[i][j] = (i + j) % 2 == 0 and 1 or 2 end
	end
end

function Grid:__render(camera)
	local r, g, b, a = love.graphics.getColor()

	local x, y = self.x, self.y

	x, y = x - (camera.scroll.x * self.scrollFactor.x),
		y - (camera.scroll.y * self.scrollFactor.y)

	for i = 1, self.rows do
		for j = 1, self.cols do
			local gridx = (j - 1) * self.cellSize + x
			local gridy = (i - 1) * self.cellSize + y
			local color = (self.grid[i][j] == 1) and self.color1 or self.color2

			love.graphics.setColor(color)
			love.graphics.rectangle("fill", gridx, gridy, self.cellSize,
				self.cellSize)
		end
	end

	love.graphics.setColor(r, g, b, a)
end

return Grid
