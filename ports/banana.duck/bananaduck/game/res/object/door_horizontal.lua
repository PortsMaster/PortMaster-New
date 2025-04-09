local object = object:extend()
object.tag = "door"


local OPEN_DELAY = 0.2
local OPEN_SPEED = 10

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    self.sprite = sprite("objects/door-horizontal.png")
    self.lock   = sprite("objects/lock.png")

    self.xScale = ldtkEntity.width / 8
    self.sprite:setScale(self.xScale, 1)

    self.isOpen = ldtkEntity.props.isOpen
    self.openTimer = OPEN_DELAY
    self.openSize = 0
    self.width = ldtkEntity.width

    self.key = nil
    self.keyNeeded = ldtkEntity.props.keyNeeded

    game.world:add(self, self.position.x, self.position.y, self.width, 8)
    game.shadows:add(self)

    self.canvas = love.graphics.newCanvas(self.width, 8)
    self:updateCanvas()

    for _, event in ipairs(ldtkEntity.props.open) do
        game.level:listenToEvent(self, event, function ()
            self:open()
            self.openTimer = 0
        end)
    end

    for _, event in ipairs(ldtkEntity.props.close) do
        game.level:listenToEvent(self, event, function ()
            self:close()
        end)
    end

    for _, event in ipairs(ldtkEntity.props.toggle) do
        game.level:listenToEvent(self, event, function ()
            if self.isOpen then
                self:close()
            else
                self:open()
                self.openTimer = 0
            end
        end)
    end
end

function object:update(dt)
    if game.paused then
        return
    end
    
    if self.isOpen then
        if self.openTimer <= 0 then
            self.tag = ""
            if self.key then 
                self.key:destroy()
                self.key = nil
            end
            self.openSize = math.lerp(self.openSize, self.xScale * 8 - 4, OPEN_SPEED * dt)
        else
            self.openTimer = self.openTimer - dt
        end
    else
        self.tag = "door"
        self.openSize = math.lerp(self.openSize, 0, OPEN_SPEED * dt)
        if self.openSize < 1 then
            self.openSize = 0
            self.openTimer = OPEN_DELAY
        end
    end

    -- Canvas is updated outside of the draw function to avoid some bugs
    self:updateCanvas()

    
end

function object:open(key)
    self.key = key

    if not self.isOpen then
        self.isOpen = true
        --check if inside view
        if self.position.x < camera.x - 8 or self.position.x > camera.x + camera.baseWidth + 8 then
            return
        end

        if self.position.y < camera.y - 8 or self.position.y > camera.y + camera.baseHeight + 8 then
            return
        end

        game.playSound("door-open.wav")
    end
end

function object:close()
    
    if self.isOpen then
        self.isOpen = false
        --check if inside view
        if self.position.x < camera.x - 8 or self.position.x > camera.x + camera.baseWidth + 8 then
            return
        end

        if self.position.y < camera.y - 8 or self.position.y > camera.y + camera.baseHeight + 8 then
            return
        end

        game.playSound("door-close.wav")
    end
end

function object:draw()
    graphics.setColor(1, 1, 1, 1)
    if game.subpixel then
        love.graphics.draw(self.canvas, self.position.x, self.position.y)
    else
        love.graphics.draw(self.canvas, math.round(self.position.x), math.round(self.position.y))
    end
end

function object:updateCanvas()
    graphics.setCanvas(self.canvas)
    graphics.clear()
    
    graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(0, 0)
    
    if game.subpixel then
        self.lock:draw(self.xScale * 4 - 4, 0)
        if self.openSize > 2 then
            graphics.setBlendMode("replace")
            graphics.setColor(1, 0, 0, 0)
            graphics.rectangle("fill", (1 - self.openSize / self.width) * self.width / 2, 0, self.openSize, 8)
            graphics.setBlendMode("alpha")
            graphics.setColor(0, 0, 0, 1)
            graphics.rectangle("fill", (1 - self.openSize / self.width) * self.width / 2, 0, 1, 8)
            graphics.rectangle("fill", (1 - self.openSize / self.width) * self.width / 2 + self.openSize - 1, 0, 1, 8)
        end
        
    else
        self.lock:draw(math.round(self.xScale * 4 - 4), 0)
        if self.openSize > 2 then
            graphics.setBlendMode("replace")
            graphics.setColor(1, 0, 0, 0)
            graphics.rectangle("fill", math.round((1 - math.round(self.openSize) / self.width) * self.width / 2), 0,  math.round(self.openSize), 8)
            graphics.setBlendMode("alpha")
            graphics.setColor(0, 0, 0, 1)
            graphics.rectangle("fill", math.round((1 - math.round(self.openSize) / self.width) * self.width / 2), 0, 1, 8)
            graphics.rectangle("fill", math.round((1 - math.round(self.openSize) / self.width) * self.width / 2 + math.round(self.openSize) - 1), 0, 1, 8)
        end
    end
    
    graphics.setCanvas()
end

function object:remove()
    game.world:remove(self)
    game.shadows:remove(self)
end

return object