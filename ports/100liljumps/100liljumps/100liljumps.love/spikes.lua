require("./utils");
require("./math");
require("./tile_map")
local Object = require("./classic")

Spikes = Object.extend(Object)

local Orientation = {
    ["HORIZONTAL"] = 0,
    ["VERTICAL"] = 1,
}

local PADDING = 1

function Spikes.new(self, pos, orientation) --rect?
    self.pos = pos -- top_left
    self.orientation = orientation or 0

    -- NOTE: maybe use smaller hitboxes than visual info
    -- NOTE: maybe use orientation to use different heights
    -- NOTE: maybe get dimensions from hitbox?
    self.width  = TILE_SIZE/2 - 2*PADDING
    self.height = TILE_SIZE/2 - 2*PADDING
    self.hitbox = Rectangle(
        V2(pos.x + PADDING, pos.y + PADDING),
        V2(pos.x + self.width, pos.y + self.height)
    )
end

function Spikes:draw()
    -- Draw hitbox
    if false then
        love.graphics.setColor(1, 0, 0, 0.6)
        love.graphics.rectangle(
            "fill",
            self.hitbox.top_left.x, self.hitbox.top_left.y,
            self.width, self.height
        )
    end
    -- Draw shape
end
