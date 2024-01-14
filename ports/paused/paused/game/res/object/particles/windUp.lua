-- extending the object class
local object = object:extend()

object.layer = -1

-- create is called once the object is just created in the room
function object:create(x, y)
    self.time = math.randomFloat(0.15, 0.45)
    self.position = vector(x + math.random(-2, 2) , y + math.random(-1, 1))
    self.size = math.random(1, 4)
    self.pixelTime = self.time / self.size
    self.timer = self.pixelTime
    self.pixels = {{x, y, self.time}}
    self.currentPixel = 1
end

-- update is called once every frame
function object:update(dt)
    self.timer = self.timer - dt
    if self.timer < 0 and self.currentPixel < self.size then
        table.insert(self.pixels, {self.pixels[self.currentPixel][1] + (self.currentPixel == 3 and (math.random() > 0.5 and 1 or -1) or 0), self.pixels[self.currentPixel][2] - 1, self.time})
        self.currentPixel = self.currentPixel + 1
        self.timer = self.pixelTime
    end

    for id, pixel in pairs(self.pixels) do
        pixel[3] = pixel[3] - dt
        if pixel[3] < 0 then
            self.pixels[id] = nil
        end
    end

    -- destroy the object if not pixel is present
    for key, value in pairs(self.pixels) do
        return
    end
    self:destroy()
end

-- draw is called once every draw frame
function object:draw()
    color.dark_grey:set()
    for key, pixel in pairs(self.pixels) do
        graphics.rectangle('fill', pixel[1], pixel[2], 1, 1)
    end
end

return object