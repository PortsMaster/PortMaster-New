require("./utils");
require("./math");
require("./animation")
require("./audio")
local Object = require("./classic")

Fact = Object.extend(Object)

Fact.facts = {
    ["test_1"] = "The desert rain frog is a plump species with bulging eyes, a short snout, short limbs, spade-like feet, and webbed toes. On the underside, it has a transparent area of skin through which its internal organs can be seen. It has a stout body, with small legs, which makes it unable to hop or leap – instead, it walks around on the sand. The male's croaking is also distinctly high-pitched."
}

-- TODO: maybe use trigger
function Fact.new(self, pos, key, tile_map)
    self.pos = pos -- top_left
    self.key = key
    self.tile_map = tile_map

    self.reading_fact = false
end

function Fact:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + TILE_SIZE, self.pos.y + TILE_SIZE)
    )
end

function Fact:update()
    if(self.reading_fact) then
        UI.set_info_text(self:get_text())
    end
end

function Fact:draw()
    -- Draw hitbox
    if false then
        love.graphics.setColor(1, 0, 0, 0.6)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle(
            "line",
            self:hitbox().top_left.x, self:hitbox().top_left.y,
            TILE_SIZE, TILE_SIZE
        )
    end
end

function Fact:released_trigger()
    self.reading_fact = false
end

function Fact:triggered_by_player()
    self.reading_fact = true
end

function Fact:get_text()
    return Fact.facts[self.key]
end
