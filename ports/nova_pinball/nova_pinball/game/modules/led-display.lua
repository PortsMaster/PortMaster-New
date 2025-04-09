local led = {}
led.queue = {}
led.position = {x=0, y=0}
led.size = {w=400, h=200}
led.current = nil
led.WaitTime = 1.5

-- Add a new message to display.
-- Options is a comma seperated string of:
--      "priority": queues at the top, displays next
--      "sticky": shows until a priority message is added.
--      "long": display longer than the default.
function led:add(message, options)
    options = options or ""
    local m = {
        priority=options:match("priority") and true or false,
        message=message,
        sticky=options:match("sticky") and true or false,
        timer=0,
        position={x=0, y=self.size.h},
        direction="up",
        long=options:match("long") and true or false
        }
    -- Avoid duplicating current message
    if (self.current and self.current.message == message) then return end
    -- Unsticky current
    if (self.current and self.current.sticky and m.priority) then
        self.current.sticky = false
    end
    -- Insert priority messages to the top
    if (m.priority) then
        --self.current.timer = 0
        table.insert(self.queue, 1, m)
    else
        table.insert(self.queue, m)
    end
    
end

function led:clear()
    self.queue = {}
end

function led:update(dt)
    -- Get the next message
    if (not self.current and #self.queue > 0) then self.current = table.remove(self.queue, 1) end
    -- Update message scroll
    if (self.current and self.current.direction == "up") then
        self.current.position.y = self.current.position.y - (dt*150)
        if (self.current.position.y <= 0) then
            self.current.direction = "wait"
            self.current.timer = self.WaitTime * (self.current.long and 3 or 1)
        end
    end
    if (self.current and self.current.direction == "down") then
        self.current.position.y = self.current.position.y + (dt*150)
        if (self.current.position.y >= self.size.h) then
            self.current.direction = "destroy"
        end
    end
    if (self.current and self.current.direction == "wait" and not self.current.sticky) then
        self.current.timer = self.current.timer - dt
        if (self.current.timer <= 0) then
            self.current.direction = "down"
        end
    end
    if (self.current and self.current.direction == "destroy") then
        self.current = nil
    end
end

function led:draw()
    if (self.current) then
        love.graphics.printf(self.current.message,
            0, self.position.y + self.current.position.y,
            scrWidth, "center")
        --printShadowText(
            --self.current.message,
            --self.position.y + self.current.position.y,
            --{200, 200, 255, 255}
            --)
    end
end

return led
