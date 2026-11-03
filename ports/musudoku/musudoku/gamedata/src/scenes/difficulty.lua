local ui = require("src.ui")
local theme = require("src.theme")
local sound = require("src.sound")

local Difficulty = {}
Difficulty.__index = Difficulty

local LEVELS = {
    { key = "easy", name = "Easy", about = "Lots of starting numbers. Scanning rows and boxes is enough." },
    { key = "medium", name = "Medium", about = "Fewer clues. Some cells only have one number left." },
    { key = "hard", name = "Hard", about = "Needs notes and tricks like pointing pairs." },
    { key = "expert", name = "Expert", about = "Few clues. Needs X-Wings, Swordfish or XY-Wings." },
    { key = "master", name = "Master", about = "The fewest clues. Needs logic beyond those, like chains." },
}

function Difficulty.new(app)
    local self = setmetatable({ app = app, t = 0 }, Difficulty)
    self.sel = 2
    for k, level in ipairs(LEVELS) do
        if level.key == (app.lastDifficulty or (app.game and app.game.difficulty)) then self.sel = k end
    end
    return self
end

function Difficulty:update(dt)
    self.t = self.t + dt
end

function Difficulty:action(a)
    local app = self.app
    if a == "up" then
        self.sel = (self.sel - 2) % #LEVELS + 1
        sound.play("menu")
    elseif a == "down" then
        self.sel = self.sel % #LEVELS + 1
        sound.play("menu")
    elseif a == "b" then
        sound.play("close")
        app.pop()
    elseif a == "a" or a == "start" then
        local key = LEVELS[self.sel].key
        sound.play("open")
        if app.hasGame() then
            app.push("confirm", {
                title = "Start a new puzzle?",
                body = "The puzzle in progress will be replaced.",
                yes = "New puzzle",
                onYes = function() app.newPuzzle(key) end,
            })
        else
            app.newPuzzle(key)
        end
    end
end

function Difficulty:draw()
    theme.set("text")
    ui.text("New puzzle", 64, 40, 36, "bold")

    local stats = self.app.stats
    local x, w, h, y0 = 64, 592, 64, 96
    for k, level in ipairs(LEVELS) do
        local y = y0 + (k - 1) * (h + 6)
        local selected = (k == self.sel)
        if selected then
            theme.set("panel")
            ui.rect("fill", x - 16, y, w + 32, h, 10)
            theme.set("accent")
            ui.rect("fill", x - 16, y + 12, 5, h - 24, 2)
        end
        theme.set(selected and "text" or "muted")
        ui.centered(level.name, x, y + 22, 24, "bold", "left")
        theme.set("muted")
        ui.centered(level.about, x, y + 46, 15, "regular", "left")

        local entry = stats[level.key]
        local right
        if entry and entry.best > 0 then
            right = "Best " .. ui.formatTime(entry.best)
        elseif entry and entry.solved > 0 then
            right = entry.solved .. " solved"
        end
        if right then
            theme.set(selected and "text" or "muted")
            ui.centered(right, x + w, y + 22, 18, "regular", "right")
        end
    end

    ui.hints({ { "B", "Back" }, { "A", "Start" } }, 696, 452, "right")
end

return Difficulty
