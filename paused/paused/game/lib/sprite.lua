-- THIS IS A VERY OLD LIBRARY, I MAY HAVE TO UPDATE IT LATER...
-- (I hope so)

local Sprite = class:extend()

local args
function Sprite:new(...)
    args = {...}
    self.path = args
    self.frames = {}
    self.frame = 1
    self.speed = 0.1
    self.animated = true
    self.countOfFrames = #args
    self.color = color(255, 255, 255)
    
    if type(args[self.countOfFrames]) == 'number' then
        self.speed = args[self.countOfFrames]
        args[self.countOfFrames] = nil
        self.countOfFrames = self.countOfFrames - 1
    end

    for index, value in ipairs(args) do
        self.frames[index] = resource.image(value)
    end

    if self.countOfFrames == 1 then
        self.animated = false
        self.path = args[1]
    end

    self.image = self.frames[self.frame]
    self.timer = math.abs(self.speed)
    self:_super()
end

function Sprite:_super()
    self.rotation = 0
    self.originX,   self.originY   = 0, 0
    self.scaleX,    self.scaleY    = 1, 1
    self.shearingX, self.shearingY = 0, 0
    self.imageWidth  = self.image:getWidth()
    self.imageHeight = self.image:getHeight()
    self.alpha = 1
end

function Sprite:setOrigin(x, y)
    self.originX = x
    self.originY = y
    return self
end

function Sprite:setRotation(rotation)
    self.rotation = rotation
    return self
end

function Sprite:setScale(sx, sy)
    self.scaleX = sx
    self.scaleY = sy
    return self
end

function Sprite:setShearing(sx, sy)
    self.shearingX = sx
    self.shearingY = sy
    return self
end

function Sprite:setAlpha(alpha)
    self.alpha = alpha
    return self
end

local spd
function Sprite:setSpeed(speed)
    self.speed = speed
    spd = math.abs(speed)
    if self.timer > spd then
        self.timer = spd
    end
    return self
end



function Sprite:getOrigin()
    return self.originX, self.originY
end

function Sprite:getScale()
    return self.scaleX, self.scaleY
end

function Sprite:getRotation()
    return self.rotation
end

function Sprite:getShearing()
    return self.shearingX, self.shearingY
end

function Sprite:getAlpha()
    return self.alpha
end

function Sprite:getSpeed()
    return self.speed
end

function Sprite:isAnimated()
    return self.animated
end


function Sprite:setFrame(frame)
    if frame > self.countOfFrames then
        self:animationFinished()
        frame = 1
    elseif frame < 1 then
        frame = self.countOfFrames
    end
    self.frame = frame
    self.image = self.frames[self.frame]
end

function Sprite:goToFrame(frame)
    self.frame = frame
    self.image = self.frames[self.frame]
    self.timer = math.abs(self.speed)
end

function Sprite:update(dt)
    self.color.alpha = self.alpha
    if self.animated then
        self.timer = self.timer - math.abs(dt)
        if self.timer <= 0 then
            if self.speed > 0 then
                if self.speed * (dt > 0 and 1 or -1) > 0 then
                    self:setFrame(self.frame + 1)
                else
                    self:setFrame(self.frame - 1)
                end
                self.timer = self.timer + math.abs(self.speed)
            else
                self.timer = 0
            end
        end
    end
end



local oldColor = {1, 1, 1, 1}
function Sprite:draw(x, y, rotation)
    oldColor[1], oldColor[2], oldColor[3] = love.graphics.getColor()
    self.color:set()
    
    love.graphics.draw(self.image, x, y, rotation or self.rotation, self.scaleX, self.scaleY, self.originX, self.originY, self.shearingX, self.shearingY)
end


function Sprite:animationFinished()
    
end

return Sprite