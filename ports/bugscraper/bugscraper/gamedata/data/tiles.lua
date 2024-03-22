require "util"
local Class = require "class"
local Tile = require "tile"
local images = require "data.images"

local Tiles = Class:inherit()

local function make_tile(init)
	local tile = Tile:inherit()
	tile.init = init
	return tile
end

function Tiles:init()
	self.tiles = {}
	
	-- Air
	self.tiles[0] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = 0
		
		self.name = "air"
		self.spr = nil
	end)

	-- Metal
	self.tiles[1] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = 1
		self.name = "metal"
		self.spr = images.metal
		
		self.is_solid = true
	end)

	-- Rubble
	self.tiles[2] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = 2
		self.name = "rubble"
		self.spr = images.empty
		
		self.is_solid = true
		self.is_not_slidable = true
	end)

	-- -- Grass
	-- self.tiles[2] = make_tile(function(self, x, y, w)
	-- 	self:init_tile(x, y, w)
	-- 	self.id = 2
	-- 	self.name = "grass"
	-- 	self.spr = images.grass
		
	-- 	self.is_solid = true
	-- end)

	-- -- Dirt
	-- self.tiles[3] = make_tile(function(self, x, y, w)
	-- 	self:init_tile(x, y, w)
	-- 	self.id = 3

	-- 	self.name = "dirt"
	-- 	self.spr = images.dirt
	-- 	self.is_solid = true
	-- end)

	-- Chain
	self.tiles[4] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = 4

		self.name = "chain"
		self.spr = images.chain
		self.is_solid = false
	end)

	-- self.tiles[5] = make_tile(function(self, x, y, w)
	-- 	self:init_tile(x, y, w)
	-- 	self.id = 5
		
	-- 	self.name = "bg_plate"
	-- 	self.spr = images.bg_plate
	-- 	self.is_solid = false
	-- end)
end

function Tiles:new_tile(n, x, y, w, ...)
	local tile_class = self.tiles[n]
	local tile = tile_class:new(x, y, w, ...)

	-- Init collision box
	if tile.is_solid then
		collision:add(tile, tile.x, tile.y, tile.w, tile.w)
	end

	return tile
end

return Tiles:new()