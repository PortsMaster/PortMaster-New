require("./utils")
require("./math")
require("./lume")
require("./snail")
local Object = require("./classic")

Spawner = Object.extend(Object)

function Spawner.new(self, pos, direction, waiting_time, tile_map, initial_time)
    self.pos = pos
    self.direction = direction or 1

    self.waiting_time = waiting_time or 1
    self.time_since_spawn = initial_time or 0

    self.tile_map = tile_map
end

function Spawner:update(dt)
    self.time_since_spawn = self.time_since_spawn + dt
    if self.time_since_spawn >= self.waiting_time then
        self.time_since_spawn = self.time_since_spawn - self.waiting_time

        local new_snail = Snail(V2(self.pos.x, self.pos.y), self.direction)
        local MAX_SNAIL_COUNT = 30
        local current_snail_count = #tile_map.snails
        if(current_snail_count < MAX_SNAIL_COUNT) then
            self.tile_map:add_snail(new_snail)
        end
    end
end

function Spawner:draw()
    if false then
        love.graphics.setColor(0.1, 0.8, 0.1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", self.pos.x, self.pos.y, TILE_SIZE, TILE_SIZE)
    end
end
