local object = object:extend()
object.layer = 100

local SPEED = 2
local CIRCLE_SIZE = 120
local SIZE = 156

local DELAY = 0.05

function object:create()
    if game.player then
        self.x = game.player.position.x + 2
        self.y = game.player.position.y + 2
    else
        self.x = camera.x + 32
        self.y = camera.y + 32
    end

    self.canvas = love.graphics.newCanvas(SIZE, SIZE)
    self.circleSize = 0
    self.delay = DELAY

    self:updateCanvas()
    game.splash = self

    self.stopped = game.hideSplash
end

function object:update(dt)
    if self.stopped then
        return
    end

    if game.player then
        self.x = game.player.position.x + 2
        self.y = game.player.position.y + 2
    else
        self.x = camera.x + 32
       
        self.y = camera.y + 32
    end
    if self.delay > 0 then
        self.delay = self.delay - dt
        return
    end

    self.circleSize = math.lerp(self.circleSize, CIRCLE_SIZE, SPEED * dt)

    if self.circleSize > CIRCLE_SIZE - 3 then
        self:destroy()
    end

    self:updateCanvas()
    
end

function object:updateCanvas()
    graphics.setCanvas(self.canvas)
    graphics.clear(0, 0, 0, 1)
    graphics.setColor(0, 0, 0, 1)
    graphics.rectangle("fill", 0, 0, SIZE, SIZE)
    graphics.setBlendMode("replace")
    graphics.setColor(0,0,0,0)
    
    if self.circleSize > 5 then
        if game.subpixel then
            graphics.circle("fill", SIZE / 2, SIZE / 2, self.circleSize)
        else
            graphics.circle("fill", math.round(SIZE / 2), math.round(SIZE / 2), math.round(self.circleSize))
        end
    end

    graphics.setBlendMode("alpha")
    graphics.setCanvas()
end

function object:draw()
    if self.stopped then
        return
    end

    if self.delay > 0 then
        color.black:set()
        graphics.rectangle("fill", 0, 0, game.level.data.width, game.level.data.height)
    end

    color.reset(1)
    if game.subpixel then
        graphics.draw(self.canvas, self.x - SIZE / 2, self.y - SIZE / 2)
    else
        graphics.draw(self.canvas, math.round(self.x - SIZE / 2), math.round(self.y - SIZE / 2))
    end
end

return object