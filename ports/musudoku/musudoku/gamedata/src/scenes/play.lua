local bit = require("bit")
local ui = require("src.ui")
local theme = require("src.theme")
local sound = require("src.sound")
local sudoku = require("src.sudoku")
local hints = require("src.hints")
local input = require("src.input")

local band = bit.band
local DIGIT_BIT, ROW, COL, BOX, UNITS = sudoku.DIGIT_BIT, sudoku.ROW, sudoku.COL, sudoku.BOX, sudoku.UNITS

local Play = {}
Play.__index = Play

-- Layout (720x480 design canvas)
local BX, BY, CS = 15, 15, 50  -- board origin and cell size (see Play:layout)
local BS = CS * 9              -- board size
local PX, PW = 488, 217        -- side panel
local PAD_BTN, PAD_GAP, PAD_INSET = 56, 6, 8
local PAD_W = PAD_INSET * 2 + PAD_BTN * 3 + PAD_GAP * 2
local PAD_H = PAD_W

local FLASH_TIME = 0.7   -- one cell's flash
local RING_TIME = 0.65   -- glow pulse around a completed area
local GLOW_PERIOD = 1.6  -- one breath of the cursor glow while picking in the panel
local GLOW_FPS = 20      -- the glow is redrawn this often, not every frame
local LIFT = 0.16        -- how far digits bounce during a flash
local WIN_CARD_AT = 1.7  -- seconds after solving before the result card
local CONFETTI = { "accent", "user", "given", "boxLine", "note" }
local DIFFICULTY_LABELS = { -- side panel header, longest first
    easy = { "EASY" }, medium = { "MEDIUM", "MED" }, hard = { "HARD" }, expert = { "EXPERT" },
    master = { "MASTER" },
}
local HEAD_LABEL, HEAD_CLOCK, HEAD_GAP = 24, 40, 10 -- header sizes and spacing

function Play.new(app)
    local self = setmetatable({ app = app, t = 0 }, Play)
    self.game = app.game
    local cx, cy = self:cellPos(self.game.cursor)
    self.vx, self.vy = cx, cy
    self.flash = {}
    self.rings = {}
    self.particles = {}
    self.tileFlash = {}
    self.pad = nil
    self.shake = 0
    self.pop = nil
    self.winT = nil
    return self
end

function Play:cellPos(i)
    return BX + COL[i] * CS, BY + ROW[i] * CS
end

-- Distraction-free mode hides the side panel and centers the board. An open
-- explained hint brings the panel back, since the hint card lives there.
function Play:panelShown()
    return not self.app.settings.boardOnly or self.hint ~= nil
end

-- With Settings → Number pad → Side panel, and the panel showing, the panel's
-- number tiles are the pad: the D-pad walks them and A enters the chosen one.
-- Otherwise the pad pops up next to the cell.
function Play:padInPanel()
    return self.app.settings.pad == "panel" and self:panelShown()
end

-- While the number is picked in the side panel, the cursor's cell waits for
-- it and glows, breathing slowly, so it's clear the board expects an entry
-- from the right. Returns 0 when not picking there, else 0.4 to 1.
function Play:cursorGlow()
    if not (self.pad and self:padInPanel()) then return 0 end
    return 0.7 + 0.3 * math.cos(2 * math.pi * (self.t - self.pad.t) / GLOW_PERIOD)
end

function Play:layout()
    local bx = self:panelShown() and 15 or (ui.W - BS) / 2
    if bx ~= BX then
        self.vx = self.vx + bx - BX -- the cursor moves with the board
        BX = bx
    end
end

function Play:resume()
    self.hidden = false
end

-- Feedback --------------------------------------------------------------------

function Play:rippleFrom(i, cells, base)
    local r0, c0 = ROW[i], COL[i]
    for _, j in ipairs(cells) do
        local d = math.abs(ROW[j] - r0) + math.abs(COL[j] - c0)
        local start = self.t + (base or 0) + d * 0.035
        if not self.flash[j] or self.flash[j] < start then self.flash[j] = start end
    end
end

function Play:react(res, i)
    local app = self.app
    if not res then return end
    if res.blocked then
        self.shake = 0.25
        sound.play("blocked")
        return
    end
    if res.changed or res.hinted then app.markDirty() end

    if res.placed then
        self.pop = { i = i, t = self.t }
        if res.wrong and app.settings.mistakes then
            sound.play("wrong")
        elseif res.hinted then
            sound.play("hint")
        else
            sound.play("place")
        end
    elseif res.cleared or res.erased then
        sound.play("erase")
    elseif res.noted then
        sound.play("note")
    elseif res.filled then
        sound.play("hint")
    end

    if res.placed and not res.solved then
        local strict = app.settings.mistakes
        if not (strict and res.wrong) then self:celebrate(i, strict) end
    end

    if res.solved then self:startWin(i) end
end

local function unitRect(u)
    if u <= 9 then return BX, BY + (u - 1) * CS, BS, CS end
    if u <= 18 then return BX + (u - 10) * CS, BY, CS, BS end
    local b = u - 19
    return BX + (b % 3) * 3 * CS, BY + math.floor(b / 3) * 3 * CS, 3 * CS, 3 * CS
end

function Play:ring(x, y, w, h, delay, strength)
    self.rings[#self.rings + 1] = {
        x = x, y = y, w = w, h = h,
        start = self.t + (delay or 0), strength = strength or 1,
    }
end

-- Rows, columns and boxes completed by placing a number in cell i, and all
-- nine of that number, each get a ripple, bouncing digits and a glow.
function Play:celebrate(i, strict)
    local g = self.game
    local cells, seen = {}, {}
    local function add(j)
        if not seen[j] then
            seen[j] = true
            cells[#cells + 1] = j
        end
    end

    local units = g:completedUnits(i, strict)
    for _, u in ipairs(units) do
        for _, j in ipairs(UNITS[u]) do add(j) end
        local x, y, w, h = unitRect(u)
        self:ring(x, y, w, h)
    end

    local d = g.values[i]
    local digitDone = d ~= 0 and g:digitComplete(d, strict)
    if digitDone then
        for j = 1, 81 do
            if g.values[j] == d then add(j) end
        end
        self.tileFlash[d] = self.t
    end

    if #cells == 0 then return end
    self:rippleFrom(i, cells)
    local count = #units + (digitDone and 1 or 0)
    sound.play(count >= 2 and "unitBig" or "unit")
end

function Play:spawnConfetti()
    local rand = love.math.random
    for k = 1, 130 do
        local w = 6 + rand() * 6
        local side = (k % 2 == 0) and 1 or -1 -- two fountains, from the lower corners
        self.particles[#self.particles + 1] = {
            x = BX + BS / 2 + side * (BS / 2 - 20) + (rand() - 0.5) * 40,
            y = BY + BS - 10,
            vx = -side * (90 + rand() * 300),
            vy = -480 - rand() * 380,
            rot = rand() * math.pi,
            vr = (rand() - 0.5) * 14,
            w = w, h = w * (0.45 + rand() * 0.5),
            color = CONFETTI[rand(#CONFETTI)],
            born = self.t, life = 1.1 + rand() * 0.5,
        }
    end
end

function Play:startWin(i)
    self.pad = nil
    self.winT = 0
    local all = {}
    for j = 1, 81 do all[j] = j end
    self:rippleFrom(i, all, 0.1)
    self:ring(BX, BY, BS, BS, 0.15, 1.6)
    self:ring(BX, BY, BS, BS, 0.5, 2.4)
    self.confettiAt = self.t + 0.3
    sound.play("win")
    self.newBest = self.app.recordSolve()
end

-- Actions -------------------------------------------------------------------

function Play:move(dr, dc)
    local g = self.game
    local r, c = ROW[g.cursor], COL[g.cursor]
    r, c = (r + dr) % 9, (c + dc) % 9
    g.cursor = r * 9 + c + 1
    sound.play("move")
end

-- L1 / R1: jump to the previous / next empty cell.
function Play:jumpEmpty(dir)
    local g = self.game
    local i = g:nextEmpty(g.cursor, dir)
    if not i then
        self:react({ blocked = true })
        return
    end
    g.cursor = i
    sound.play("move")
end

-- Number-first input: A puts the chosen number (the game's lastDigit) in the
-- cursor's cell, and L1 / R1 choose the number.
function Play:numberFirst()
    return self.app.settings.input == "number"
end

-- L1 / R1 in number-first input: the previous / next number that isn't
-- already on the board nine times.
function Play:cycleDigit(dir, silent)
    local g = self.game
    g.lastDigit = g:nextNeededDigit(g.lastDigit, dir)
    self.app.markDirty()
    if not silent then sound.play("move") end
end

-- A in number-first input. On a given or hinted cell it picks up that number
-- instead, since nothing can go there.
function Play:stamp()
    local g = self.game
    local i = g.cursor
    if g.fixed[i] then
        if g.lastDigit ~= g.values[i] then
            g.lastDigit = g.values[i]
            self.app.markDirty()
            sound.play("note")
        else
            self:react({ blocked = true })
        end
        return
    end
    local res = self:applyDigit(g.lastDigit)
    -- all nine placed: move on to the next number still needed
    if res.placed and not res.solved and g:digitCounts()[g.lastDigit] >= 9 then
        self:cycleDigit(1, true)
    end
end

function Play:applyDigit(d)
    local g, app = self.game, self.app
    local i = g.cursor
    local res
    if g.mode == "pen" then
        res = g:enter(i, d, app.settings)
    else
        res = g:toggleNote(i, d)
    end
    self:react(res, i)
    return res
end

function Play:openPad()
    local g = self.game
    if g.fixed[g.cursor] then
        self:react({ blocked = true })
        return
    end
    local v = g.values[g.cursor]
    self.pad = { sel = (v ~= 0) and v or g.lastDigit, t = self.t }
    sound.play("open")
end

function Play:closePad(silent)
    self.pad = nil
    if not silent then sound.play("close") end
end

function Play:toggleMode()
    local g = self.game
    g.mode = (g.mode == "pen") and "pencil" or "pen"
    self.modeT = self.t
    sound.play("note")
    self.app.markDirty()
end

function Play:history(which)
    local g = self.game
    local cell = (which == "undo") and g:undo() or g:redo()
    if cell then
        g.cursor = cell
        sound.play("erase")
        self.app.markDirty()
    else
        self:react({ blocked = true })
    end
end

-- Explained hints ---------------------------------------------------------------

function Play:openHint()
    local g = self.game
    local steps = hints.build(g.values, g.solution, g.fixed, g.cursor)
    if #steps == 0 then
        self:react({ blocked = true })
        return
    end
    g:countHint()
    self.app.markDirty()
    self.hint = { steps = steps, index = 1 }
    self:focusHint()
    sound.play("hint")
end

function Play:hintStep()
    return self.hint and self.hint.steps[self.hint.index]
end

function Play:focusHint()
    local step = self:hintStep()
    if step and step.target then
        self.game.cursor = step.target
        self.vx, self.vy = self:cellPos(step.target)
    end
end

function Play:closeHint(silent)
    self.hint = nil
    if not silent then sound.play("close") end
end

function Play:hintActionLabel(step)
    if step.action == "erase" then return "Erase it" end
    if step.action == "place" then return "Place " .. step.digit end
    for _, r in ipairs(step.removals or {}) do
        if self.game:hasNote(r[1], r[2]) then return "Remove from notes" end
    end
    return "Next"
end

function Play:hintAction(a)
    local h, g = self.hint, self.game
    local step = h.steps[h.index]
    if a == "b" then
        self:closeHint()
    elseif a == "y" or a == "right" or a == "r2" then
        if h.index < #h.steps then
            h.index = h.index + 1
            self:focusHint()
            sound.play("menu")
        else
            self:react({ blocked = true })
        end
    elseif a == "l2" or a == "left" then
        if h.index > 1 then
            h.index = h.index - 1
            self:focusHint()
            sound.play("menu")
        end
    elseif a == "a" then
        if step.action == "erase" then
            self:closeHint(true)
            self:react(g:erase(step.target), step.target)
        elseif step.action == "remove" then
            local res = g:removeNotes(step.removals)
            if res.changed then
                self.app.markDirty()
                sound.play("note")
            else
                sound.play("menu")
            end
            h.index = math.min(#h.steps, h.index + 1)
            self:focusHint()
        else
            self:closeHint(true)
            local res = g:hint(step.target, { free = true })
            self:react(res, step.target)
        end
    end
end

function Play:pause()
    self.pad = nil
    self.hint = nil
    self.hidden = true
    sound.play("open")
    self.app.saveGame()
    self.app.push("pause")
end

function Play:action(a)
    if self.winT then return end
    local g = self.game

    if a == "start" or a == "menu" then
        self:pause()
        return
    end

    if self.hint then
        self:hintAction(a)
        return
    end

    local digit = a:match("^digit(%d)$")

    if self.pad then
        local pad = self.pad
        if a == "up" or a == "down" or a == "left" or a == "right" then
            local r, c = math.floor((pad.sel - 1) / 3), (pad.sel - 1) % 3
            if a == "up" then r = (r - 1) % 3
            elseif a == "down" then r = (r + 1) % 3
            elseif a == "left" then c = (c - 1) % 3
            else c = (c + 1) % 3 end
            pad.sel = r * 3 + c + 1
            sound.play("move")
        elseif a == "a" or digit then
            local d = digit and tonumber(digit) or pad.sel
            pad.sel = d
            local res = self:applyDigit(d)
            if g.mode == "pen" and not res.blocked then self:closePad(true) end
        elseif a == "b" then
            self:closePad()
        elseif a == "x" then
            self:toggleMode()
        elseif a == "y" or a == "erase" then
            self:react(g:erase(g.cursor), g.cursor)
            self:closePad(true)
        elseif a == "l2" then
            self:history("undo")
        elseif a == "r2" then
            self:history("redo")
        elseif a == "l1" or a == "r1" then
            -- the pad stays open and follows the cursor, so in pencil mode
            -- you can note one cell after another
            self:jumpEmpty(a == "l1" and -1 or 1)
        end
        return
    end

    if a == "up" then self:move(-1, 0)
    elseif a == "down" then self:move(1, 0)
    elseif a == "left" then self:move(0, -1)
    elseif a == "right" then self:move(0, 1)
    elseif a == "a" then
        if self:numberFirst() then self:stamp() else self:openPad() end
    elseif a == "b" or a == "erase" then
        local res = g:erase(g.cursor)
        if not res.empty then self:react(res, g.cursor) end
    elseif a == "x" then self:toggleMode()
    elseif a == "y" then
        local mode = self.app.settings.hints
        if mode == "off" then
            return
        elseif mode == "explained" then
            self:openHint()
        else
            local res = g:hint(g.cursor)
            if res.cell then g.cursor = res.cell end
            self:react(res, res.cell or g.cursor)
        end
    elseif a == "l2" then self:history("undo")
    elseif a == "r2" then self:history("redo")
    elseif a == "l1" or a == "r1" then
        local dir = (a == "l1") and -1 or 1
        if self:numberFirst() then self:cycleDigit(dir) else self:jumpEmpty(dir) end
    elseif a == "select" then self:react(g:toggleNotes(), g.cursor)
    elseif digit then self:applyDigit(tonumber(digit))
    end
end

-- Update ----------------------------------------------------------------------

function Play:update(dt)
    self.t = self.t + dt
    self:layout()
    local g = self.game
    if not g.solved and self.app.focused then
        g.elapsed = g.elapsed + dt
    end

    local tx, ty = self:cellPos(g.cursor)
    local k = 1 - math.exp(-dt * 28)
    self.vx = self.vx + (tx - self.vx) * k
    self.vy = self.vy + (ty - self.vy) * k
    if math.abs(tx - self.vx) > CS * 3 or math.abs(ty - self.vy) > CS * 3 then
        self.vx, self.vy = tx, ty -- wrapping around the edge: jump, don't fly across
    end
    if math.abs(tx - self.vx) < 0.25 and math.abs(ty - self.vy) < 0.25 then
        self.vx, self.vy = tx, ty -- settle exactly, so the scene can go idle
    end

    if self.shake > 0 then self.shake = math.max(0, self.shake - dt) end

    -- a slow breath needs few frames: ask for GLOW_FPS rather than being
    -- busy() at the full frame rate
    if self:cursorGlow() > 0 then
        local step = math.floor(self.t * GLOW_FPS)
        if step ~= self.glowStep then
            self.glowStep = step
            self.app.requestRedraw()
        end
    end

    for i, start in pairs(self.flash) do
        if self.t > start + FLASH_TIME then self.flash[i] = nil end
    end
    for k = #self.rings, 1, -1 do
        if self.t > self.rings[k].start + RING_TIME then table.remove(self.rings, k) end
    end
    for d, start in pairs(self.tileFlash) do
        if self.t > start + 0.8 then self.tileFlash[d] = nil end
    end
    if self.confettiAt and self.t >= self.confettiAt then
        self.confettiAt = nil
        self:spawnConfetti()
    end
    for k = #self.particles, 1, -1 do
        local p = self.particles[k]
        p.vy = p.vy + 980 * dt
        p.x, p.y = p.x + p.vx * dt, p.y + p.vy * dt
        p.rot = p.rot + p.vr * dt
        if self.t > p.born + p.life or p.y > ui.H + 20 then table.remove(self.particles, k) end
    end

    -- the clock only changes once a second, so that's all it needs to draw
    local second = math.floor(g.elapsed)
    if second ~= self.lastSecond then
        self.lastSecond = second
        if self.app.settings.timer and self:panelShown() then self.app.requestRedraw() end
    end

    if self.winT then
        self.winT = self.winT + dt
        if self.winT > WIN_CARD_AT and not self.winShown then
            self.winShown = true
            self.particles = {}
            self.app.push("win", { newBest = self.newBest })
        end
    end
end

-- True while something on screen is moving and needs continuous frames.
function Play:busy()
    local tx, ty = self:cellPos(self.game.cursor)
    if tx ~= self.vx or ty ~= self.vy then return true end
    if next(self.flash) ~= nil or self.shake > 0 then return true end
    if #self.rings > 0 or #self.particles > 0 or self.confettiAt then return true end
    if next(self.tileFlash) ~= nil then return true end
    if self.pop and self.t - self.pop.t < 0.2 then return true end
    if self.modeT and self.t - self.modeT < 0.2 then return true end
    if self.pad and not self:padInPanel() and self.t - self.pad.t < 0.15 then return true end
    if self.winT and not self.winShown then return true end
    return false
end

-- Drawing: board --------------------------------------------------------------

-- Notes sit in a 3x3 grid inside the cell. The Large notes setting makes the
-- digits bigger in the same places (spreading them wider would put the corner
-- ones under the cursor); drawBoard sets it each frame.
local largeNotes = false

local function notePos(x, y, d)
    local r, c = math.floor((d - 1) / 3), (d - 1) % 3
    return x + 9 + c * 16, y + 9 + r * 16
end

-- Note digit size: plain notes, or bold ones (matching, hint marks, preview).
local function noteSize(bold)
    if largeNotes then return bold and 18 or 17 end
    return bold and 14 or 13
end

function Play:drawBoard()
    local g, settings = self.game, self.app.settings
    largeNotes = settings.largeNotes
    local hidden = self.hidden
    local cur = g.cursor
    local cr, cc, cb = ROW[cur], COL[cur], BOX[cur]

    local match = 0
    if self.pad then
        match = self.pad.sel
    elseif self:numberFirst() then
        match = g.lastDigit
    elseif settings.matching then
        match = g.values[cur]
    end

    theme.frame(BX, BY, BS, BS)
    theme.set("board")
    ui.rect("fill", BX, BY, BS, BS, 8)

    love.graphics.stencil(function() ui.rect("fill", BX, BY, BS, BS, 8) end, "replace", 1)
    love.graphics.setStencilTest("greater", 0)

    local hint = self:hintStep()
    if hint then match = 0 end

    if not hidden then
        for i = 1, 81 do
            local x, y = self:cellPos(i)
            local v = g.values[i]
            if hint then
                if hint.mistake and i == hint.target then
                    theme.set("error", 0.3)
                    ui.rect("fill", x, y, CS, CS)
                elseif hint.focusCells[i] or i == hint.target then
                    theme.set("same")
                    ui.rect("fill", x, y, CS, CS)
                elseif hint.unitCells[i] then
                    theme.set("peer")
                    ui.rect("fill", x, y, CS, CS)
                end
            elseif match ~= 0 and v == match and settings.matching then
                theme.set("same")
                ui.rect("fill", x, y, CS, CS)
            elseif ROW[i] == cr or COL[i] == cc or BOX[i] == cb then
                theme.set("peer")
                ui.rect("fill", x, y, CS, CS)
            end
            local f = self.flash[i]
            if f and self.t >= f then
                local p = (self.t - f) / FLASH_TIME
                if p <= 1 then
                    theme.set("accent", math.sin(math.pi * p) * 0.6)
                    ui.rect("fill", x, y, CS, CS)
                end
            end
        end
    end
    theme.texture(BX, BY, BS, BS) -- under the lines and digits, so they stay crisp
    love.graphics.setStencilTest()

    -- grid lines
    theme.set("line")
    love.graphics.setLineWidth(1)
    for k = 1, 8 do
        if k % 3 ~= 0 then
            love.graphics.line(BX + k * CS, BY, BX + k * CS, BY + BS)
            love.graphics.line(BX, BY + k * CS, BX + BS, BY + k * CS)
        end
    end
    theme.set("boxLine")
    love.graphics.setLineWidth(2.5)
    for k = 3, 6, 3 do
        love.graphics.line(BX + k * CS, BY, BX + k * CS, BY + BS)
        love.graphics.line(BX, BY + k * CS, BX + BS, BY + k * CS)
    end
    love.graphics.setLineWidth(3)
    ui.rect("line", BX, BY, BS, BS, 8)

    if hidden then return end

    -- hint marks grouped by cell: marksByCell[i][d] = "focus" | "removed"
    local marksByCell = {}
    if hint then
        for _, m in ipairs(hint.marks) do
            marksByCell[m[1]] = marksByCell[m[1]] or {}
            marksByCell[m[1]][m[2]] = m[3]
        end
    end

    -- digits and notes
    for i = 1, 81 do
        local x, y = self:cellPos(i)
        local v = g.values[i]
        if v ~= 0 then
            local slot = "user"
            if g.fixed[i] then slot = "given"
            elseif settings.mistakes and v ~= g.solution[i] then slot = "error" end
            theme.set(slot)
            local scale = 1
            if self.pop and self.pop.i == i then
                local p = (self.t - self.pop.t) / 0.18
                if p < 1 then scale = 1 + 0.3 * (1 - ui.ease(p)) end
            end
            local f = self.flash[i]
            if f and self.t >= f then
                local p = (self.t - f) / FLASH_TIME
                if p <= 1 then scale = scale * (1 + LIFT * math.sin(math.pi * p)) end
            end
            if scale ~= 1 then
                love.graphics.push()
                love.graphics.translate(x + CS / 2, y + CS / 2)
                love.graphics.scale(scale)
                ui.centered(tostring(v), 0, 0, 32, "regular", "center")
                love.graphics.pop()
            else
                ui.centered(tostring(v), x + CS / 2, y + CS / 2, 32, "regular", "center")
            end
        else
            local notes = g.notes[i]
            local marked = hint and marksByCell[i]
            if marked then
                for d, style in pairs(marked) do
                    local nx, ny = notePos(x, y, d)
                    if style == "removed" then
                        theme.set("error")
                        ui.centered(tostring(d), nx, ny, noteSize(true), "bold", "center")
                        local k = largeNotes and 7.5 or 6
                        love.graphics.setLineWidth(largeNotes and 2 or 1.5)
                        love.graphics.line(nx - k, ny + k, nx + k, ny - k)
                    else
                        theme.set("mark")
                        ui.centered(tostring(d), nx, ny, noteSize(true), "bold", "center")
                    end
                end
            end
            if hint and hint.action == "place" and i == hint.target then
                theme.set("mark", 0.55)
                ui.centered(tostring(hint.digit), x + CS / 2, y + CS / 2, 32, "regular", "center")
                notes = 0
            end
            if notes ~= 0 then
                for d = 1, 9 do
                    if band(notes, DIGIT_BIT[d]) ~= 0 and not (marked and marked[d]) then
                        local nx, ny = notePos(x, y, d)
                        if d == match and settings.matching then
                            theme.set("mark")
                            ui.centered(tostring(d), nx, ny, noteSize(true), "bold", "center")
                        else
                            theme.set("note")
                            ui.centered(tostring(d), nx, ny, noteSize(false), "regular", "center")
                        end
                    end
                end
            end
        end
    end

    if hint then
        theme.set("mark", 0.9)
        love.graphics.setLineWidth(2)
        for i in pairs(hint.blockers) do
            local x, y = self:cellPos(i)
            love.graphics.circle("line", x + CS / 2, y + CS / 2, CS / 2 - 6)
        end
        if hint.target then
            local x, y = self:cellPos(hint.target)
            theme.set(hint.mistake and "error" or "mark")
            love.graphics.setLineWidth(3)
            ui.rect("line", x + 3, y + 3, CS - 6, CS - 6, 6)
        end
    end

    -- glow pulses around completed rows, columns, boxes and the board
    for _, r in ipairs(self.rings) do
        local p = (self.t - r.start) / RING_TIME
        if p >= 0 and p <= 1 then
            local grow = 1 + 8 * ui.ease(p) * r.strength
            local fade = (1 - p) ^ 2
            for k = 0, 2 do
                local spread = grow + k * 3
                theme.set("accent", fade * (0.9 - k * 0.3))
                love.graphics.setLineWidth(3 - k)
                ui.rect("line", r.x - spread, r.y - spread, r.w + spread * 2, r.h + spread * 2, 6 + spread)
            end
        end
    end

    -- number-first input: a faint preview of what A would put in the cell
    if self:numberFirst() and not self.winT and not hint and not g.fixed[cur] and g.values[cur] == 0 then
        local x, y = self:cellPos(cur)
        local d = g.lastDigit
        if g.mode == "pen" and g.notes[cur] == 0 then
            theme.set("mark", 0.35)
            ui.centered(tostring(d), x + CS / 2, y + CS / 2, 32, "regular", "center")
        elseif g.mode == "pencil" and band(g.notes[cur], DIGIT_BIT[d]) == 0 then
            local nx, ny = notePos(x, y, d)
            theme.set("mark", 0.5)
            ui.centered(tostring(d), nx, ny, noteSize(true), "bold", "center")
        end
    end

    -- cursor
    if not self.winT and not hint then
        local dx = 0
        if self.shake > 0 then dx = math.sin(self.shake * 70) * 4 * (self.shake / 0.25) end
        local x, y, s = self.vx + 3 + dx, self.vy + 3, CS - 6
        -- picking in the side panel: a soft halo, fading outwards. It stays
        -- outside the outline, clear of the corner notes, and has no fill
        -- (accent over the darker boards turns muddy).
        local glow = self:cursorGlow()
        if glow > 0 then
            love.graphics.setLineWidth(2.5)
            for k = 1, 3 do
                local spread = k * 2.5
                theme.set("accent", glow * (0.8 - k * 0.2))
                ui.rect("line", x - spread, y - spread, s + spread * 2, s + spread * 2, 6 + spread)
            end
        end
        theme.set("mark")
        love.graphics.setLineWidth(3)
        ui.rect("line", x, y, s, s, 6)
    end
end

-- Drawing: number pad ---------------------------------------------------------

function Play:padRect()
    local i = self.game.cursor
    local r, c = ROW[i], COL[i]
    local x
    if c <= 4 then
        x = BX + (c + 1) * CS + 6
    else
        x = BX + c * CS - PAD_W - 6
    end
    local y = BY + r * CS + CS / 2 - PAD_H / 2
    y = math.max(8, math.min(ui.H - 8 - PAD_H, y))
    return x, y
end

function Play:drawPad()
    local pad = self.pad
    if not pad then return end
    local g = self.game
    local x, y = self:padRect()
    local p = ui.ease((self.t - pad.t) / 0.12)
    local counts = g:digitCounts()
    local pencil = g.mode == "pencil"
    local cell = g.cursor
    local notes = g.notes[cell]

    -- The pad grows from its center as it opens. Shapes are scaled, but the
    -- digits are only moved, never scaled, so ui.centered can keep them on
    -- whole screen pixels and they stay sharp.
    local grow = 0.92 + 0.08 * p
    local function at(lx, ly)
        return x + PAD_W / 2 + (lx - PAD_W / 2) * grow, y + PAD_H / 2 + (ly - PAD_H / 2) * grow
    end
    local function box(mode, lx, ly, w, h, r)
        local bx, by = at(lx, ly)
        ui.rect(mode, bx, by, w * grow, h * grow, r * grow)
    end

    theme.set("scrim", 0.35 * p)
    box("fill", 2, 4, PAD_W, PAD_H, 12)
    theme.set("bg", p)
    box("fill", 0, 0, PAD_W, PAD_H, 12)
    local px, py = at(0, 0)
    theme.texture(px, py, PAD_W * grow, PAD_H * grow, p, 12 * grow)
    theme.set("boxLine", p)
    love.graphics.setLineWidth(2)
    box("line", 0, 0, PAD_W, PAD_H, 12)

    for d = 1, 9 do
        local r, c = math.floor((d - 1) / 3), (d - 1) % 3
        local bx = PAD_INSET + c * (PAD_BTN + PAD_GAP)
        local by = PAD_INSET + r * (PAD_BTN + PAD_GAP)
        local selected = (d == pad.sel)
        local noted = pencil and band(notes, DIGIT_BIT[d]) ~= 0
        local done = counts[d] >= 9

        if selected then theme.set("accent", p)
        elseif noted then theme.set("same", p)
        else theme.set("panel", p) end
        box("fill", bx, by, PAD_BTN, PAD_BTN, 8)

        if not selected and not pencil and g.values[cell] == d then
            theme.set("mark", p)
            love.graphics.setLineWidth(2)
            box("line", bx + 1, by + 1, PAD_BTN - 2, PAD_BTN - 2, 8)
        end

        local alpha = p * ((done and not selected) and 0.4 or 1)
        theme.set(selected and "accentText" or "text", alpha)
        if pencil then
            -- show the digit where its note would sit in the cell
            local nx, ny = at(bx + 13 + c * 15, by + 13 + r * 15)
            if not selected and not noted then theme.set("note", alpha) end
            ui.centered(tostring(d), nx, ny, 20, "bold", "center")
        else
            local tx, ty = at(bx + PAD_BTN / 2, by + PAD_BTN / 2)
            ui.centered(tostring(d), tx, ty, 32, "regular", "center") -- like the board's digits
        end
    end
end

-- Drawing: side panel ---------------------------------------------------------

-- The side panel clock: 134 -> "02:14", an hour or more -> "1:02:14".
local function clock(seconds)
    seconds = math.floor(seconds)
    if seconds >= 3600 then return ui.formatTime(seconds) end
    return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

-- Difficulty (left) and clock (right) share the top row, on one baseline. The
-- first label that fits is used (MEDIUM, then MED); only if none fits does the
-- row shrink.
function Play:drawHeader(x, base)
    local g = self.game
    local prefix = g.pack and ("#" .. ui.number(g.pack.index) .. " ") or ""
    local time = self.app.settings.timer and clock(g.elapsed)
    -- measured with its widest digits, so the label doesn't change as it ticks
    local clockW = time and HEAD_GAP + ui.width((time:gsub("%d", "0")), HEAD_CLOCK, "bold") or 0
    local names = DIFFICULTY_LABELS[g.difficulty] or { "" }
    if g.daily then names = { "DAILY " .. names[1], "DAILY" } end
    local label, rowW
    for _, name in ipairs(names) do
        label = prefix .. name
        rowW = ui.width(label, HEAD_LABEL, "bold") + clockW
        if rowW <= PW then break end
    end
    local k = math.min(1, (PW - 2) / rowW)
    theme.set("muted")
    ui.onBaseline(label, x, base, HEAD_LABEL * k, "bold", "left")
    if time then
        theme.set("text")
        ui.onBaseline(time, x + PW, base, HEAD_CLOCK * k, "bold", "right")
    end
end

function Play:drawPanel()
    local g, settings = self.game, self.app.settings
    local x = PX

    self:drawHeader(x, 46)
    local y = 58

    -- progress through the board
    local filled = g:filledCount()
    theme.set("panel")
    ui.rect("fill", x, y, PW, 6, 3)
    theme.set("accent")
    ui.rect("fill", x, y, math.max(6, PW * filled / 81), 6, 3)
    y = y + 24

    local function counter(label, value, cx)
        theme.set("muted")
        local w = ui.centered(label, cx, y, 19, "regular", "left")
        theme.set("text")
        ui.centered(tostring(value), cx + w + 6, y, 19, "bold", "left")
    end
    -- the hint count shows if hints are on, or were used earlier in this puzzle
    local showHints = settings.hints ~= "off" or g.hints > 0
    if settings.mistakes then
        counter("Mistakes", g.mistakes, x)
        if showHints then counter("Hints", g.hints, x + 124) end
    elseif showHints then
        counter("Hints", g.hints, x)
    end
    y = y + 18

    -- pen / pencil switch
    local half = PW / 2
    theme.set("panel")
    ui.rect("fill", x, y, PW, 38, 8)
    local pencil = g.mode == "pencil"
    local slide = 1
    if self.modeT then slide = ui.ease((self.t - self.modeT) / 0.16) end
    local from = pencil and 0 or half
    local to = pencil and half or 0
    local sx = from + (to - from) * slide
    theme.set("accent")
    ui.rect("fill", x + sx + 3, y + 3, half - 6, 32, 6)
    theme.set(pencil and "muted" or "accentText")
    ui.centered("Pen", x + half / 2, y + 19, 20, "bold", "center")
    theme.set(pencil and "accentText" or "muted")
    ui.centered("Pencil", x + half + half / 2, y + 19, 20, "bold", "center")
    y = y + 52

    if self.hint then
        self:drawHintCard(x, y)
        return
    end

    -- remaining digits: each tile has a 3x3 map of the board's boxes, and a
    -- box's dot lights up once it holds that digit
    local counts = g:digitCounts()
    local inBox = {}
    for d = 1, 9 do inBox[d] = {} end
    for i = 1, 81 do
        local v = g.values[i]
        if v ~= 0 then inBox[v][BOX[i]] = true end
    end
    local numberFirst = self:numberFirst()
    local match = self.pad and self.pad.sel or (settings.matching and g.values[g.cursor] or 0)
    if numberFirst then match = g.lastDigit end
    -- the tile A would enter (number-first, or the pad when these tiles are
    -- the pad) gets a tinted fill as well as the outline
    local picking = numberFirst or (self.pad ~= nil and self:padInPanel())
    local tw, th, gap = 68, 54, 6
    for d = 1, 9 do
        local r, c = math.floor((d - 1) / 3), (d - 1) % 3
        local tx, ty = x + c * (tw + gap), y + r * (th + 8)
        local left = 9 - counts[d]
        theme.set((picking and d == match) and "same" or "panel")
        ui.rect("fill", tx, ty, tw, th, 7)
        local tf = self.tileFlash[d]
        if tf then
            local p = (self.t - tf) / 0.8
            theme.set("accent", 0.85 * (1 - p) ^ 1.5)
            ui.rect("fill", tx, ty, tw, th, 7)
        end
        if d == match then
            theme.set("mark")
            local lw = picking and 3 or 2
            love.graphics.setLineWidth(lw)
            ui.rect("line", tx + lw / 2, ty + lw / 2, tw - lw, th - lw, 7)
        end
        local alpha = (left <= 0) and 0.4 or 1
        theme.set("text", alpha)
        ui.centered(tostring(d), tx + 17, ty + th / 2, 28, "bold", "center")
        if left <= 0 then
            theme.set("muted", alpha)
            love.graphics.setLineWidth(3)
            local cx, cy = tx + tw - 22, ty + th / 2
            love.graphics.line(cx - 8, cy, cx - 2, cy + 6, cx + 9, cy - 7)
        else
            local dot, step = 7, 10
            local mx, my = tx + tw - 9 - 2 * step - dot, ty + math.floor((th - 2 * step - dot) / 2)
            for b = 0, 8 do
                theme.set(inBox[d][b] and "text" or "line")
                ui.rect("fill", mx + (b % 3) * step, my + math.floor(b / 3) * step, dot, dot, 2)
            end
        end
    end

    -- controls for the current context: only the face and shoulder buttons,
    -- at most three rows of two (Select and Start are in the README)
    local rows
    if self.pad then
        rows = {
            { { "A", pencil and "Toggle" or "Place" }, { "B", "Close" } },
            { { "X", pencil and "Pen" or "Pencil" }, { "Y", "Erase" } },
            { { input.label("l2"), "Undo" }, { input.label("r2"), "Redo" } },
        }
    else
        local enter = "Enter"
        if numberFirst then enter = (pencil and "Note " or "Place ") .. g.lastDigit end
        rows = {
            { { "A", enter }, { "B", "Erase" } },
            { { "X", pencil and "Pen" or "Pencil" }, settings.hints ~= "off" and { "Y", "Hint" } or nil },
            { { input.label("l2"), "Undo" }, { input.label("r2"), "Redo" } },
        }
    end
    local legendTop = 462 - (#rows - 1) * 32
    ui.legend(rows, { x, x + 116 }, legendTop, 32, nil, 20, 1.2)
    if numberFirst and not self.pad then
        -- its own row, so its wide glyph doesn't push the columns above apart
        ui.hints({ { input.pair("l1"), "Change number" } }, x, legendTop - 32, "left", nil, 20, 1.2)
    end
end

function Play:drawConfetti()
    for _, p in ipairs(self.particles) do
        local age = (self.t - p.born) / p.life
        local alpha = age < 0.7 and 1 or math.max(0, 1 - (age - 0.7) / 0.3)
        theme.set(p.color, alpha)
        love.graphics.push()
        love.graphics.translate(p.x, p.y)
        love.graphics.rotate(p.rot)
        love.graphics.rectangle("fill", -p.w / 2, -p.h / 2, p.w, p.h, 1, 1)
        love.graphics.pop()
    end
end

function Play:drawHintCard(x, top)
    local h = self.hint
    local step = h.steps[h.index]
    local bottom = 470
    theme.set("panel")
    ui.rect("fill", x, top, PW, bottom - top, 10)

    local ix, iw = x + 12, PW - 24
    local y = top + 12
    theme.set("mark")
    ui.text("Hint", ix, y, 15, "bold")
    if #h.steps > 1 then
        theme.set("muted")
        ui.text("Step " .. h.index .. " of " .. #h.steps, ix, y, 15, "regular", "right", iw)
    end
    y = y + 24
    theme.set(step.mistake and "error" or "text")
    ui.text(step.title, ix, y, 21, "bold", "left", iw)
    y = y + ui.wrapHeight(step.title, 21, "bold", iw) + 6
    theme.set("text", 0.88)
    ui.text(step.text, ix, y, 17, "regular", "left", iw)

    local rows = { { { "A", self:hintActionLabel(step) } } }
    local nav = {}
    if h.index < #h.steps then nav[#nav + 1] = { "Y", "Next" } end
    if h.index > 1 then nav[#nav + 1] = { input.label("l2"), "Back" } end
    if #nav > 0 then rows[#rows + 1] = nav end
    rows[#rows + 1] = { { "B", "Close" } }
    ui.legend(rows, { ix, ix + 104 }, bottom - 18 - (#rows - 1) * 28, 28, nil, 17, 1.1)
end

function Play:draw()
    self:drawBoard()
    if self:panelShown() then self:drawPanel() end
    if not self:padInPanel() then self:drawPad() end
    self:drawConfetti()
end

return Play
