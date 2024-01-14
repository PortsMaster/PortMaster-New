-- extending the object class
local object = object:extend()

object.layer = 0

-- create is called once the object is just created in the room
function object:create(x, y, text_table, startDelay, room)
    self.text_table = text_table
    self.number_of_strings = #text_table
    self.current = 0
    self.text = ''
    self.timer = startDelay
    self.room = room
    self.x = x
    self.y = y
    self.changed = false
end

-- update is called once every frame
function object:update(dt)
    if self.timer < 0 then
        self.current = self.current + 1
        if self.current <= self.number_of_strings then
            self.text = self.text .. self.text_table[self.current][1]
            self.timer = self.text_table[self.current][2]
        else
            if not self.changed then
                objects.splash(self.room, 0.3)
            end
            self.changed = true
        end
    else
        self.timer = self.timer - dt
    end
end

-- draw is called once every draw frame
function object:draw()
    color.white:set()
    graphics.print(self.text, self.x, self.y)
end

return object