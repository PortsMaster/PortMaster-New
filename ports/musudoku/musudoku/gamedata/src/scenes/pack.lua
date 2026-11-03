local ui = require("src.ui")
local theme = require("src.theme")
local sound = require("src.sound")
local packs = require("src.packs")
local input = require("src.input")

-- One puzzle pack: reads (indexes) the file, then offers next, random or a
-- chosen puzzle number. With autoNext it starts the next unsolved puzzle
-- as soon as the file is read (used by "Next puzzle" on the win screen).
local Pack = {}
Pack.__index = Pack

local FRAME_BUDGET = 0.012

function Pack.new(app, file, autoNext)
    local self = setmetatable({ app = app, t = 0, file = file, autoNext = autoNext, sel = 1, fraction = 0 }, Pack)
    local cached = app.packCache[file.path]
    if cached and cached.size == file.size then
        self.index = cached
    else
        local frameStart = 0
        self.co = coroutine.create(function()
            return packs.scan(file.path, function(fraction)
                self.fraction = fraction
                if love.timer.getTime() - frameStart > FRAME_BUDGET then coroutine.yield() end
            end)
        end)
        self.beginFrame = function() frameStart = love.timer.getTime() end
    end
    if self.index then self:ready() end
    return self
end

function Pack:progress()
    return packs.entry(self.app.packProgress, self.file.file)
end

function Pack:ready()
    local app, p = self.app, self:progress()
    app.packCache[self.file.path] = self.index
    if p.count ~= self.index.count or p.size ~= self.file.size then
        if p.size ~= self.file.size then
            packs.reset(p) -- the file changed: start over
        end
        p.count, p.size = self.index.count, self.file.size
        app.savePackProgress()
    end
    self.choice = math.max(1, math.min(self.index.count, (packs.nextUnsolved(p, self.index.count) or 1)))
    if self.autoNext then
        self.autoNext = false
        self.pendingStart = true -- started from update(), never mid-construction
    end
end

function Pack:back()
    sound.play("close")
    if #self.app.stack > 1 then self.app.pop() else self.app.setScene("title") end
end

-- Try to start a puzzle; skip forward past broken ones for next/random.
function Pack:start(mode)
    local app, p, count = self.app, self:progress(), self.index.count
    local n
    if mode == "choose" then n = self.choice
    elseif mode == "random" then n = packs.randomUnsolved(p, count)
    else n = packs.nextUnsolved(p, count) end
    if not n then
        self.message = "Every puzzle in this pack is solved."
        return
    end
    for _ = 1, 50 do
        local ok, err = app.startPackPuzzle(self.file, self.index, n)
        if ok then return end
        if mode == "choose" then
            self.message = err
            sound.play("blocked")
            return
        end
        self.message = err
        n = (mode == "random") and packs.randomUnsolved(p, count) or packs.nextUnsolved(p, count, n)
        if not n then return end
    end
end

function Pack:update(dt)
    self.t = self.t + dt
    if self.pendingStart then
        self.pendingStart = false
        self:start("next")
        return
    end
    if self.co then
        self.beginFrame()
        local ok, result, err = coroutine.resume(self.co)
        if not ok then error(result) end
        if coroutine.status(self.co) == "dead" then
            self.co = nil
            if result then
                self.index = result
                self:ready()
            else
                self.failed = err or "Couldn't read this file."
            end
        end
    end
end

function Pack:busy()
    return self.co ~= nil or self.pendingStart == true
end

function Pack:action(a)
    if a == "b" or a == "start" then
        self:back()
        return
    end
    if not self.index or self.index.count == 0 then return end
    local count = self.index.count
    if a == "up" then
        self.sel = (self.sel - 2) % 3 + 1
        sound.play("menu")
    elseif a == "down" then
        self.sel = self.sel % 3 + 1
        sound.play("menu")
    elseif self.sel == 3 and (a == "left" or a == "right" or a == "l2" or a == "r2") then
        local step = (a == "left" and -1) or (a == "right" and 1) or (a == "l2" and -100) or 100
        self.choice = (self.choice - 1 + step) % count + 1
        sound.play("move")
    elseif a == "a" then
        sound.play("open")
        self.message = nil
        self:start(({ "next", "random", "choose" })[self.sel])
    end
end

function Pack:draw()
    local x, w = 64, 592
    theme.set("text")
    ui.text(self.file.name, x, 40, 36, "bold", "left", w)

    if self.failed then
        theme.set("muted")
        ui.text(self.failed, x, 110, 18, "regular", "left", w)
        ui.hints({ { "B", "Back" } }, 696, 452, "right")
        return
    end

    if not self.index then
        theme.set("muted")
        ui.text("Reading puzzles", x, 112, 18, "regular")
        theme.set("panel")
        ui.rect("fill", x, 146, w, 8, 4)
        theme.set("accent")
        ui.rect("fill", x, 146, math.max(8, w * self.fraction), 8, 4)
        ui.hints({ { "B", "Back" } }, 696, 452, "right")
        return
    end

    local count, p = self.index.count, self:progress()
    if count == 0 then
        theme.set("muted")
        ui.text("No puzzles found in this file. Each puzzle needs 81 characters on one line, or 9 lines of 9.", x, 110, 18, "regular", "left", w)
        ui.hints({ { "B", "Back" } }, 696, 452, "right")
        return
    end

    local solved = packs.solvedCount(p)
    theme.set("muted")
    ui.text(ui.number(count) .. (count == 1 and " puzzle, " or " puzzles, ") .. ui.number(solved) .. " solved", x, 98, 18, "regular")
    if p.timed > 0 then
        local parts = {}
        if p.best > 0 then parts[#parts + 1] = "Best " .. ui.formatTime(p.best) end
        parts[#parts + 1] = "Average " .. ui.formatTime(p.total / p.timed)
        if p.perfect > 0 then parts[#parts + 1] = ui.number(p.perfect) .. " perfect" end
        ui.text(table.concat(parts, ", "), x, 98, 18, "regular", "right", w)
    end
    theme.set("panel")
    ui.rect("fill", x, 128, w, 6, 3)
    if solved > 0 then
        theme.set("accent")
        ui.rect("fill", x, 128, math.max(6, w * solved / count), 6, 3)
    end
    if self.index.truncated then
        theme.set("muted")
        ui.text("Only the first " .. ui.number(packs.MAX_PUZZLES) .. " puzzles in this file are used.", x, 142, 14, "regular")
    end

    local nextN = packs.nextUnsolved(p, count)
    local items = {
        { "Next unsolved", nextN and ("Puzzle " .. ui.number(nextN)) or "All solved" },
        { "Random unsolved", nil },
        { "Choose a puzzle", nil },
    }
    local y0 = 182
    for k, item in ipairs(items) do
        local cy = y0 + (k - 1) * 56
        local selected = (k == self.sel)
        if selected then
            theme.set("panel")
            ui.rect("fill", x - 16, cy - 23, w + 32, 46, 10)
            theme.set("accent")
            ui.rect("fill", x - 16, cy - 10, 5, 20, 2)
        end
        theme.set(selected and "text" or "muted")
        ui.centered(item[1], x, cy, 22, selected and "bold" or "regular", "left")
        if k == 3 then
            local label = ui.number(self.choice)
            if p.solved[self.choice] then label = label .. ", solved" end
            theme.set(selected and "mark" or "text")
            local vw = ui.centered(label, x + w - 22, cy, 20, "bold", "right")
            if selected then
                theme.set("muted")
                ui.centered("<", x + w - 22 - vw - 16, cy, 18, "bold", "center")
                ui.centered(">", x + w - 6, cy, 18, "bold", "center")
            end
        elseif item[2] then
            theme.set("muted")
            ui.centered(item[2], x + w, cy, 17, "regular", "right")
        end
    end

    if self.message then
        theme.set("error")
        ui.text(self.message, x, 352, 16, "regular", "left", w)
    elseif self.sel == 3 then
        theme.set("muted")
        ui.text("Left and right change the number by 1, " .. input.label("l2") .. " and "
            .. input.label("r2") .. " by 100.", x, 352, 16, "regular", "left", w)
    end

    ui.hints({ { "B", "Back" }, { "A", "Play" } }, 696, 452, "right")
end

return Pack
