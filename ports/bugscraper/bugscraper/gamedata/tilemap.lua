local Class = require "class"
local Tiles = require "data.tiles"
local images = require

local TileMap = Class:inherit()

function TileMap:init(w,h)
	self.map = {}
	self.width = w
	self.height = h
	self.tile_size = 16

	for ix = 0, w-1 do
		self.map[ix] = {}
		for iy = 0, h-1 do
			self.map[ix][iy] = Tiles:new_tile(0, ix, iy, self.tile_size)
		end
	end
end

function TileMap:update(dt)
	self:for_all_tiles(function(tile)
		tile:update(dt)
	end)
end

function TileMap:draw()
	self:for_all_tiles(function(tile)
		tile:draw()
	end)
end


function TileMap:for_all_tiles(func)
	for ix=0,self.width-1 do
		for iy=0,self.height-1 do
			func(self.map[ix][iy], ix, iy)
		end
	end
end

function TileMap:reset()
	self:for_all_tiles(function(tile, ix, iy)
		self:set_tile(ix, iy, 0)
	end)
end

function TileMap:get_tile(x,y)
	if not self:is_valid_tile(x,y) then   return   end
	return self.map[x][y]
end

function TileMap:set_tile(x,y,n)
	-- Assertions
	if not self:is_valid_tile(x,y) then   return   end
	-- Remove collisions
	if self.map[x][y].is_solid then   self:set_collision(x, y, false)   end
	
	-- Create tile class
	local tile = Tiles:new_tile(n, x, y, self.tile_size)
	self.map[x][y] = tile
	if tile.is_solid then   self:set_collision(x,y,true)   end
end

function TileMap:set_collision(x,y, val)
	if not self:is_valid_tile(x,y) then   return   end

	local tile = self:get_tile(x, y)
	-- Return is the tile is already at the wanted state
	if val == tile.is_solid then    return    end		

	if val then
		collision:add(tile, tile.x, tile.y, tile.w, tile.w)
	else
		collision:remove(tile)	
	end
end

function TileMap:is_valid_tile(x,y)
	return 0 <= x and x < self.width and 0 <= y and y < self.height
end

return TileMap