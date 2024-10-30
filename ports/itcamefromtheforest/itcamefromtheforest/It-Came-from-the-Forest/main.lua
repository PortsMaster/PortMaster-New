class = require "libs/middleclass"
inspect = require "libs/inspect"
lume = require "libs/lume"
json = require "libs/json"
bresenham = require 'libs/bresenham'

Grid = require ("libs/jumper.grid")
Pathfinder = require ("libs/jumper.pathfinder")

require "globals"
require "util"

Game = require "game"

screen = {width = 640, height = 360}

local game = Game:new()

function love.load(arg)

	game:init()
	
end

function love.update(dt)
	collectgarbage("collect")
	game:update(dt)
	
end

function love.keypressed(key)

	game:handleInput(key)
	
	settings.debug = love.keyboard.isDown("rctrl")
	
end

function love.keyreleased(key)

	settings.debug = love.keyboard.isDown("rctrl")
	
end


function love.mousepressed(x, y, button, istouch)
	game:handleMousePressed(x, y, button, istouch)
end

function love.draw(dt)
	
	love.graphics.push()
	love.graphics.scale(love.graphics.getWidth() / screen.width)
	love.graphics.draw(game.canvas)
	love.graphics.pop()
	
end
