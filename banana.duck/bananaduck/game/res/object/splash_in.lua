local object = object:extend()
object.layer = 100

local SPEED = 9
local CIRCLE_SIZE = 80
local SIZE = 156
local DELAY = 0.05

function object:create(x, y, targetRoom)
    self.x = x
    self.y = y
    self.canvas = love.graphics.newCanvas(SIZE, SIZE)
    self.circleSize = CIRCLE_SIZE

    game.splash = self
    self.stopped = game.hideSplash
    self.targetRoom = targetRoom
    self.delay = DELAY
    self.changed = false
end

function object:update(dt)
    if self.stopped then
        return
    end
    
    self.circleSize = math.lerp(self.circleSize, 0, SPEED * dt)

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
    if self.circleSize < 3 then
        if self.delay > 0 then
            self.delay = self.delay - dt
        else
            if not self.changed then
                if game.playing then
                    gamedata.set("deaths", game.stats.deaths, "stats.sav")
                    gamedata.set("time", game.stats.time, "stats.sav")
                    gamedata.set("jumps", game.stats.jumps, "stats.sav")
                    if game.crown and game.won then
                        gamedata.set("crown_" .. game.crown, true, "game.sav")
                    end
                end
                self.changed = true

                ldtk:level(self.targetRoom)
            end
        end
    end
end

function object:draw()
    if self.stopped then
        return
    end

    color.reset(1)
    if game.subpixel then
        graphics.draw(self.canvas, self.x - SIZE / 2, self.y - SIZE / 2)
    else
        graphics.draw(self.canvas, math.round(self.x - SIZE / 2), math.round(self.y - SIZE / 2))
    end
end

return object