require "util"
local Class = require "class"
local Gun = require "gun"
local images = require "data.images"
local E = require "data.enemies"

print(table_to_str)

local waves = {

{ -- 1
	min = 4,
	max = 6,
	enemies = {
		{E.Larva, 1},
		{E.Fly, 1},

		-- {E.Larva, 4},
		-- {E.Fly, 3},
		-- {E.SpikedFly, 3},
		-- {E.SnailShelled, 3},
		-- {E.Slug, 2},
		-- {E.Grasshopper, 1},
		-- {E.MushroomAnt, 10},
	},
},

{ -- 2
	-- Slug intro
	min = 6,
	max = 8,
	enemies = {
		{E.Larva, 2},
		{E.Fly, 2},
		{E.Slug, 5},
	},
},

{ -- 3
	-- Grasshopper intro
	min = 4,
	max = 6,
	enemies = {
		{E.Slug, 2},
		{E.Grasshopper, 4},
	},
},


{ -- 4
	-- 
	min = 6,
	max = 8,
	enemies = {
		{E.Larva, 2},
		{E.Fly, 2},
		{E.Slug, 5},
		{E.Grasshopper, 1},
	},
},


{ -- 5
	-- Spider intro
	min = 4,
	max = 6,
	enemies = {
		{E.Larva, 2},
		{E.Spider, 4},
	},
},


{ -- 6
	-- 
	min = 6,
	max = 8,
	enemies = {
		{E.Larva, 3},
		{E.Slug, 2},
		{E.Fly, 3},
		{E.Spider, 4},
	},
},

{ -- 7
	min = 3,
	max = 5,
	enemies = {
		-- Shelled Snail intro
		{E.SnailShelled, 3},
		{E.Fly, 1},
	},
},

{ -- 8
	min = 6,
	max = 8,
	enemies = {
		-- 
		{E.Fly, 4},
		{E.Larva, 4},
		{E.SnailShelled, 3},
		{E.Spider, 3},
	},
},

{ -- 9
	-- SpikedFly intro
	min = 5,
	max = 7,
	enemies = {
		{E.Larva, 1},
		{E.Fly, 2},
		{E.SpikedFly, 4},
	},
},

{ -- 10
	-- Mushroom Ant intro
	min = 3,
	max = 4,
	enemies = {
		{E.MushroomAnt, 3},
	},
},


{ -- 11
	min = 6,
	max = 8,
	enemies = {
		{E.MushroomAnt, 3},
		{E.Fly, 1},
		{E.SpikedFly, 1},
		{E.Spider, 2},
	},
},

{ -- 12
	-- ALL
	min = 6,
	max = 8,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.SpikedFly, 1},
		{E.Grasshopper, 1},
		{E.MushroomAnt, 1},
		{E.Spider, 1},
	},
},

-- unpack(duplicate_table({
	-- ALL BUT HARDER
	-- 13, 14, 15
{
	min = 8,
	max = 10,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.SpikedFly, 1},
		-- {E.Grasshopper, 1},
		-- {E.MushroomAnt, 1},
		-- {E.Spider, 1},
	},
},{
	min = 10,
	max = 12,
	enemies = {
		-- {E.Larva, 4},
		-- {E.Fly, 3},
		-- {E.SnailShelled, 3},
		-- {E.Slug, 2},
		{E.SpikedFly, 1},
		{E.Grasshopper, 1},
		{E.MushroomAnt, 1},
		{E.Spider, 1},
	},
},{
	min = 12,
	max = 16,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.SpikedFly, 1},
		{E.Grasshopper, 1},
		{E.MushroomAnt, 1},
		{E.Spider, 1},
	},
},
-- }, 4)),

-- Last wave
{ -- 16
	min = 1,
	max = 1,
	enemies = {
		{E.ButtonGlass, 1}
	}
}

}

return waves