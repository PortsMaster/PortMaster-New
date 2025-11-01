require("./math");

local Object = require("./classic")

Mirror = Object.extend(Object)

function Mirror.new(self, pos, width, height, direction)
    self.pos = pos
    self.width = width
    self.height = height
    self.direction = direction or 1
end

function Mirror:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + self.width, self.pos.y + self.height)
    )
end

function Mirror:draw()
    -- Draw hitbox
    if false then
        love.graphics.setColor(0, 1, 0, 0.2)
        love.graphics.rectangle(
            "fill",
            self.pos.x, self.pos.y,
            self.width, self.height
        )
    end
end