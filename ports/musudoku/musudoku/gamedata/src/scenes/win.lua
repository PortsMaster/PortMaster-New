local ui = require("src.ui")
local theme = require("src.theme")
local sound = require("src.sound")
local daily = require("src.daily")

local Win = { overlay = true }
Win.__index = Win

local DIFFICULTY_NAMES = { easy = "Easy", medium = "Medium", hard = "Hard", expert = "Expert", master = "Master" }

function Win.new(app, info)
    return setmetatable({ app = app, t = 0, info = info or {} }, Win)
end

function Win:update(dt)
    self.t = self.t + dt
end

function Win:busy()
    return self.t < 0.35
end

function Win:action(a)
    if self.t < 0.3 then return end
    local app = self.app
    if a == "a" and app.game.daily then
        sound.play("close")
        app.game = nil
        app.setScene("title")
    elseif a == "a" then
        sound.play("open")
        local g = app.game
        if g.pack then
            local file = app.packFileFor(g)
            if file then
                app.setScene("pack", file, true)
            else
                app.setScene("title")
            end
        else
            app.newPuzzle(g.difficulty)
        end
    elseif a == "b" or a == "start" then
        sound.play("close")
        app.game = nil
        app.setScene("title")
    end
end

function Win:draw()
    local p = ui.ease(self.t / 0.22)
    local g = self.app.game
    local heading = DIFFICULTY_NAMES[g.difficulty] .. " puzzle"
    if g.pack then heading = g.pack.name .. ", puzzle " .. ui.number(g.pack.index) end
    if g.daily then heading = "Daily puzzle, " .. daily.label(g.daily) end

    local stats = self.app.stats[g.difficulty]
    if g.pack or g.daily then stats = nil end
    local lines = {}
    if g.daily then
        local today = daily.today()
        local days = self.app.daily.days
        local streak = daily.streak(days, today and today.key or g.daily)
        if streak > 1 then
            local best = streak >= daily.bestStreak(days)
            lines[#lines + 1] = { streak .. "-day streak" .. (best and ", your best" or ""), best }
        else
            lines[#lines + 1] = { "Come back tomorrow for the next one.", false }
        end
    elseif g.pack then
        local packs = require("src.packs")
        local entry = self.app.packProgress[g.pack.file]
        local solved = entry and packs.solvedCount(entry) or 0
        lines[#lines + 1] = { ui.number(solved) .. " of " .. ui.number(g.pack.count) .. " solved in this pack", false }
        if self.info.newBest then lines[#lines + 1] = { "Best time in this pack", true } end
    elseif self.info.newBest then
        lines[#lines + 1] = { "New best time", true }
    elseif stats and stats.best > 0 then
        lines[#lines + 1] = { "Best time " .. ui.formatTime(stats.best), false }
    end
    if stats and stats.streak > 1 then
        local best = stats.streak >= stats.bestStreak
        lines[#lines + 1] = { stats.streak .. " solved in a row" .. (best and ", your best" or ""), best }
    end
    local parts = {}
    if self.app.settings.mistakes then
        parts[#parts + 1] = g.mistakes == 1 and "1 mistake" or (g.mistakes .. " mistakes")
    end
    if g.hints > 0 or self.app.settings.hints ~= "off" then
        parts[#parts + 1] = g.hints == 1 and "1 hint" or (g.hints .. " hints")
    end
    if #parts > 0 then
        local text = table.concat(parts, ", ")
        lines[#lines + 1] = { text:sub(1, 1):upper() .. text:sub(2), false }
    end
    if g.hints > 0 and not g.pack and not g.daily then
        lines[#lines + 1] = { "Solves with hints don't count toward best times.", false, 14 }
    end

    -- the card grows with its lines
    local w, linesH = 380, 0
    for _, line in ipairs(lines) do linesH = linesH + (line[3] and 22 or 28) end
    local h = math.max(262, 126 + linesH + 52)
    local x, y = ui.card(w, h, p)

    theme.set("muted", p)
    ui.text(heading, x + 32, y + 26, 18, "regular", "left", w - 64)
    theme.set("text", p)
    ui.text("Solved", x + 32, y + 48, 38, "bold")
    theme.set("mark", p)
    ui.centered(ui.formatTime(g.elapsed), x + w - 32, y + 72, 38, "bold", "right")

    local ly = y + 126
    for _, line in ipairs(lines) do
        theme.set(line[2] and "mark" or "text", p)
        ui.text(line[1], x + 32, ly, line[3] or 18, line[2] and "bold" or "regular")
        ly = ly + (line[3] and 22 or 28)
    end

    local buttons = { { "B", "Title" }, { "A", g.pack and "Next puzzle" or "New puzzle" } }
    if g.daily then buttons = { { "A", "Title" } } end
    ui.hints(buttons, x + w - 24, y + h - 26, "right", p)
end

return Win
