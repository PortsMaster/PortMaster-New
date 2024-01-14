local object = object:extend()

object.persistent = true
object.layer = 10000
object.target = ''

function object:create(target, time, startDelay, switchDelay)
    global.splash = self
    object.target = target
    self.time = time / 2
    self.timer = -self.time
    self.changed = false
    self.startDelay = startDelay or 0
    self.switchDelay = switchDelay or 0
end

function object:update(dt)
    if self.startDelay > 0 then
        self.startDelay = self.startDelay - dt
        return
    end

    self.timer = self.timer + dt
    if self.timer > 0 then
        if self.switchDelay > 0 then
            self.timer = 0
            self.switchDelay = self.switchDelay - dt
            return
        end
        if not self.changed and global.splash == self then
            self.changed = true
            room.goTo(object.target)
        end
    end

    if self.timer > self.time then
        self:destroy()
    end
end

function object:draw()
    color.black:set()
    local progress = self.timer / self.time -- [-1, 1]
    -- splash rectangle from left to right and forward

    graphics.rectangle("fill", progress * (camera.baseWidth), -25, camera.baseWidth, camera.baseHeight + 50)

    -- if progress < 0 then
    --     graphics.polygon("fill", 0, 0, (progress + 1) * camera.baseWidth * 2, 0, 0, (progress + 1) * camera.baseWidth * 2)
    -- else
    --     graphics.polygon("fill", camera.baseWidth, camera.baseHeight, camera.baseHeight - (1 - progress) * camera.baseWidth * 2, camera.baseHeight, camera.baseHeight, camera.baseHeight - (1 - progress) * camera.baseWidth * 2)
    -- end
    
end

return object