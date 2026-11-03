local ui = require("src.ui")
local theme = require("src.theme")
local sound = require("src.sound")

local About = {}
About.__index = About

-- { what, who and license }
local CREDITS = {
    { "Font", "Atkinson Hyperlegible by the Braille Institute, SIL Open Font License" },
    { "Game engine", "LÖVE 11.5, zlib license" },
    { "muOS runtime", "By saitamasahil, MIT license" },
    { "Dancing Links", "Donald Knuth's Algorithm X" },
    { "Theme colors", "Solarized by Ethan Schoonover, Nord by Arctic Ice Studio, Gruvbox by Pavel Pertsev" },
}

function About.new(app)
    return setmetatable({ app = app, t = 0 }, About)
end

function About:update(dt)
    self.t = self.t + dt
end

function About:action(a)
    if a == "b" or a == "start" then
        sound.play("close")
        self.app.pop()
    end
end

function About:draw()
    local x, w = 64, 592
    theme.set("text")
    ui.text("About", x, 40, 36, "bold")

    ui.text("muSudoku " .. self.app.version, x, 102, 22, "bold")
    theme.set("mark")
    ui.text("Created by amiralul", x, 132, 20, "bold")

    theme.set("muted")
    ui.text("Credits", x, 186, 16, "bold")
    local y, dx = 214, 200
    for _, c in ipairs(CREDITS) do
        theme.set("text")
        ui.text(c[1], x, y, 17, "regular")
        theme.set("muted")
        ui.text(c[2], x + dx, y, 17, "regular", "left", w - dx)
        y = y + ui.wrapHeight(c[2], 17, "regular", w - dx) + 10
    end

    theme.set("muted")
    ui.text("Made for muOS (MustardOS). Game code: MIT license.", x, y + 8, 16, "regular", "left", w)

    ui.hints({ { "B", "Back" } }, 696, 452, "right")
end

return About
