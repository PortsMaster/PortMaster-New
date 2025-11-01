local Object = require("./classic")

Animation = Object.extend(Object)

TILE_SIZE = 8

function Animation.new(self, stages, initial_step, width, height)
    love.graphics.setDefaultFilter("nearest")
    self.spritesheets = {}
    self.width = width or TILE_SIZE
    self.height = height or TILE_SIZE
    for _, stage in pairs(stages) do
        -- TODO: optimization , dont load filename multiple times
        table.insert(self.spritesheets, love.graphics.newImage(stage.filename))
    end
    
    -- TODO: handle errors
    self.quads = {}
    self.step = initial_step or 1 
    self.stage = 1
    self.has_looped = false

    for stage, spritesheet in pairs(self.spritesheets) do
        for x = 0, spritesheet:getWidth() - self.width, self.width do
            self.quads[stage] = self.quads[stage] or {}
            table.insert(
                self.quads[stage],
                love.graphics.newQuad(x, 0, self.width, self.height, spritesheet:getDimensions())
            )
        end
    end

    self.frames_per_frame = {}
    for i, stage in pairs(stages) do
        self.frames_per_frame[i] = math.floor((stage.duration or 100) / #self.quads[self.stage])
    end
end

function Animation:draw(x, y, dir_x, dir_y, alpha, s, color_str)
    if color_str then
        local r, g, b, a = lume.color(color_str)
        love.graphics.setColor(r, g, b, alpha or 1)
    else
        love.graphics.setColor(1, 1, 1, alpha)
    end
    s = s or 1
    dir_x = dir_x or 1
    dir_y = dir_y or 1
    local dx = 0
    local dy = 0
    if(dir_x == -1) then
        dx = self.width*s
    end
    if(dir_y == -1) then
        dy = self.height*s
    end
    local frame = math.floor(self.step / (self.frames_per_frame[self.stage] + 1)) + 1
    love.graphics.draw(
        self.spritesheets[self.stage], self.quads[self.stage][frame],
        math.floor(x + dx), math.floor(y + dy), 0, s*dir_x, s*dir_y 
    )
    love.graphics.setColor(1, 1, 1)
end

function Animation:advance_step()
    self.step = self.step + 1
    if(self.step == (#self.quads[self.stage]*self.frames_per_frame[self.stage])) then
        self.has_looped = true
    end
    if(self.step > #self.quads[self.stage]*self.frames_per_frame[self.stage]) then
        if(#self.spritesheets > 1) then
            self:advance_stage()
        else
            self.has_looped = false
            self.step = 1
        end
    end
end

function Animation:advance_stage()
    self.step = 1
    self.stage = self.stage + 1
    self.has_looped = false
    if(self.stage > #self.spritesheets) then
        self.stage = 1
    end
end

function Animation:reset()
    self.step = 1
    self.stage = 1
    self.has_looped = false
end
