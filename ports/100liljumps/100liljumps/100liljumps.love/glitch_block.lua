require("./utils")
require("./math")
require("./animation")
require("./lume")
require("./audio")
local Object = require("./classic")

GlitchBlock = Object.extend(Object)
GlitchBlock.spritesheet = love.graphics.newImage("tile_sets/glitch.png")
GlitchBlock.quads = {}

GlitchBlock.MIN_UPDATE_TIME = 0.2
GlitchBlock.MAX_UPDATE_TIME = 0.5

local TILE_SIZE = 8
for y = 0, GlitchBlock.spritesheet:getHeight() - TILE_SIZE, TILE_SIZE do
    table.insert(GlitchBlock.quads, {})
    for x = 0, GlitchBlock.spritesheet:getWidth() - TILE_SIZE, TILE_SIZE do
        local y_index = math.floor(y / TILE_SIZE) + 1
        table.insert(GlitchBlock.quads[y_index], love.graphics.newQuad(x, y, TILE_SIZE, TILE_SIZE, GlitchBlock.spritesheet:getDimensions()))
    end
end

function GlitchBlock.new(self, pos, level)
    self.pos = V2(pos.x, pos.y)
    self.level = level

    self.x_index = math.floor(math.random(1, 16))
    self.y_index = math.floor(math.random(1, 16))

    self.target_update_time = lume.random(GlitchBlock.MIN_UPDATE_TIME, GlitchBlock.MAX_UPDATE_TIME)
    self.time = lume.random(0, self.target_update_time)
end

function GlitchBlock:update(dt)
    if game_state.config_effects_disabled then
        return
    end

    self.time = self.time + dt
    if(self.time > self.target_update_time) then
        self.time = 0
        self.x_index = math.floor(math.random(1, 16))
        self.y_index = math.floor(math.random(1, 16))
    end
end

function GlitchBlock:draw()
    -- hitbox
    if false then
        love.graphics.setColor(0.5, 0, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", self.pos.x, self.pos.y, TILE_SIZE, TILE_SIZE)
    end

    local level_matches = self.level and game_state:computah_broken_stage() >= self.level
    local should_show = level_matches or game_state.jump_counter_broken
    if(should_show) then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(GlitchBlock.spritesheet, GlitchBlock.quads[self.y_index][self.x_index], self.pos.x, self.pos.y)
    end
end
