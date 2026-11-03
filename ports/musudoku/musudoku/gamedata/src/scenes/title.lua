local ui = require("src.ui")
local theme = require("src.theme")
local sound = require("src.sound")
local daily = require("src.daily")

local Title = {}
Title.__index = Title

local DIFFICULTY_NAMES = { easy = "Easy", medium = "Medium", hard = "Hard", expert = "Expert", master = "Master" }

-- The box on the left plays one short demo: givens appear, then the cursor
-- fills the remaining cells, the way a player would.
local BOX = { 5, 2, 8, 6, 1, 4, 3, 7, 9 }
local GIVEN = { true, false, true, false, true, false, true, false, true }
local FILL_ORDER = { 2, 6, 4, 8 }

local BOX_X, BOX_Y, CELL = 64, 128, 72

function Title.new(app)
    local self = setmetatable({ app = app, t = 0, sel = 1 }, Title)
    self:build()
    return self
end

function Title:build()
    local app = self.app
    self.items = {}
    if app.hasGame() then
        local g = app.game
        local where = g.pack and (g.pack.name .. " " .. ui.number(g.pack.index)) or DIFFICULTY_NAMES[g.difficulty]
        if g.daily then where = "Daily puzzle" end
        self.items[#self.items + 1] = {
            label = "Continue",
            detail = where .. ", " .. ui.formatTime(g.elapsed),
            run = function() app.setScene("play") end,
        }
    end
    self.items[#self.items + 1] = { label = "New puzzle", run = function() app.push("difficulty") end }
    self.items[#self.items + 1] = { label = "Daily puzzle", detail = self:dailyDetail(), run = app.openDaily }
    self.items[#self.items + 1] = { label = "Puzzle packs", run = function() app.push("packs") end }
    self.items[#self.items + 1] = { label = "Statistics", run = function() app.push("stats") end }
    self.items[#self.items + 1] = { label = "Settings", run = function() app.push("settings") end }
    self.items[#self.items + 1] = { label = "About", run = function() app.push("about") end }
    self.items[#self.items + 1] = { label = "Quit", run = function() app.quit() end }
    self.sel = math.min(self.sel, #self.items)
end

function Title:dailyDetail()
    local app = self.app
    local today = daily.today()
    if not today then return "Set the date first" end
    local streak = daily.streak(app.daily.days, today.key)
    local suffix = streak > 1 and (", " .. streak .. "-day streak") or ""
    if app.daily.days[today.key] then return "Solved" .. suffix end
    if app.game and app.game.daily == today.key and not app.game.solved then return "In progress" .. suffix end
    return DIFFICULTY_NAMES[today.difficulty] .. suffix
end

function Title:resume()
    self:build()
end

function Title:update(dt)
    self.t = self.t + dt
end

function Title:busy()
    return self.t < 2.4 -- the box demo plays once
end

function Title:action(a)
    if a == "up" then
        self.sel = (self.sel - 2) % #self.items + 1
        sound.play("menu")
    elseif a == "down" then
        self.sel = self.sel % #self.items + 1
        sound.play("menu")
    elseif a == "a" or a == "start" then
        sound.play("open")
        self.items[self.sel].run()
    end
end

-- When each box cell appears, and where the demo cursor is.
local function demoState(t)
    local appear = {}
    local k = 0
    for i = 1, 9 do
        if GIVEN[i] then
            appear[i] = 0.15 + k * 0.06
            k = k + 1
        end
    end
    local cursor, cursorT = 5, 0
    for n, i in ipairs(FILL_ORDER) do
        local at = 0.75 + (n - 1) * 0.32
        appear[i] = at + 0.12
        if t >= at then cursor, cursorT = i, at end
    end
    return appear, cursor, cursorT
end

function Title:drawBox()
    local t = self.t
    local appear, cursor = demoState(t)
    local size = CELL * 3

    theme.set("board")
    ui.rect("fill", BOX_X, BOX_Y, size, size, 10)

    -- cursor cell
    local cc = cursor - 1
    local cx, cy = BOX_X + (cc % 3) * CELL, BOX_Y + math.floor(cc / 3) * CELL
    theme.set("peer")
    ui.rect("fill", cx, cy, CELL, CELL, 0)

    theme.set("line")
    love.graphics.setLineWidth(1.5)
    for k = 1, 2 do
        love.graphics.line(BOX_X + k * CELL, BOX_Y, BOX_X + k * CELL, BOX_Y + size)
        love.graphics.line(BOX_X, BOX_Y + k * CELL, BOX_X + size, BOX_Y + k * CELL)
    end

    for i = 1, 9 do
        local at = appear[i]
        if t >= at then
            local p = ui.ease((t - at) / 0.25)
            local x = BOX_X + ((i - 1) % 3) * CELL + CELL / 2
            local y = BOX_Y + math.floor((i - 1) / 3) * CELL + CELL / 2
            theme.set(GIVEN[i] and "given" or "user", p)
            love.graphics.push()
            love.graphics.translate(x, y)
            local sc = GIVEN[i] and 1 or (1 + 0.25 * (1 - p))
            love.graphics.scale(sc)
            ui.centered(tostring(BOX[i]), 0, 0, 44, "bold", "center")
            love.graphics.pop()
        end
    end

    theme.set("boxLine")
    love.graphics.setLineWidth(3)
    ui.rect("line", BOX_X, BOX_Y, size, size, 10)

    theme.set("mark")
    love.graphics.setLineWidth(3)
    ui.rect("line", cx + 3, cy + 3, CELL - 6, CELL - 6, 6)
end

function Title:draw()
    self:drawBox()

    local x = 352
    theme.set("text")
    ui.text("muSudoku", x - 3, 84, 64, "bold")

    local y, step = 182, 36
    if #self.items <= 7 then y, step = 190, 40 end
    for k, item in ipairs(self.items) do
        local selected = (k == self.sel)
        local cy = y + (k - 1) * step
        if selected then
            theme.set("accent")
            ui.rect("fill", x - 18, cy - 6, 8, 12, 2)
        end
        theme.set(selected and "text" or "muted")
        local w = ui.centered(item.label, x, cy, 26, selected and "bold" or "regular", "left")
        if item.detail then
            theme.set("muted")
            ui.centered(item.detail, x + w + 14, cy + 1, 16, "regular", "left")
        end
    end

    theme.set("muted")
    ui.centered("Version " .. self.app.version, 24, 452, 13, "regular", "left")
    ui.hints({ { "A", "Select" } }, 696, 452, "right")
end

return Title
