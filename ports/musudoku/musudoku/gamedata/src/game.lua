-- One puzzle in progress: values, notes, history and counters.
-- No drawing or input here; scenes call these methods and react to results.

local bit = require("bit")
local sudoku = require("src.sudoku")

local band, bor, bxor, bnot = bit.band, bit.bor, bit.bxor, bit.bnot
local DIGIT_BIT, PEERS, UNITS, CELL_UNITS = sudoku.DIGIT_BIT, sudoku.PEERS, sudoku.UNITS, sudoku.CELL_UNITS

local MAX_HISTORY = 300

local Game = {}
Game.__index = Game

function Game.new(generated, difficulty)
    local g = setmetatable({}, Game)
    g.difficulty = difficulty
    g.solution = sudoku.copy(generated.solution)
    g.values, g.notes, g.fixed, g.hinted = {}, {}, {}, {}
    for i = 1, 81 do
        local v = generated.puzzle[i]
        g.values[i] = v
        g.notes[i] = 0
        g.fixed[i] = v ~= 0
        g.hinted[i] = false
    end
    g.elapsed, g.mistakes, g.hints = 0, 0, 0
    g.cursor = 41
    g.mode = "pen"
    g.lastDigit = 1
    g.undoStack, g.redoStack = {}, {}
    g.solved = false
    return g
end

-- History -------------------------------------------------------------------
-- An action records the before/after value and notes of every cell it
-- touched, flattened as {cell, beforeValue, beforeNotes, afterValue, afterNotes, ...}.

function Game:_begin()
    self._touched, self._order = {}, {}
end

function Game:_set(i, value, notes)
    if not self._touched[i] then
        self._touched[i] = true
        self._order[#self._order + 1] = { i, self.values[i], self.notes[i] }
    end
    self.values[i], self.notes[i] = value, notes
end

function Game:_commit()
    local entry = {}
    for _, rec in ipairs(self._order) do
        local i = rec[1]
        if rec[2] ~= self.values[i] or rec[3] ~= self.notes[i] then
            local n = #entry
            entry[n + 1], entry[n + 2], entry[n + 3] = i, rec[2], rec[3]
            entry[n + 4], entry[n + 5] = self.values[i], self.notes[i]
        end
    end
    self._touched, self._order = nil, nil
    if #entry == 0 then return false end
    local stack = self.undoStack
    stack[#stack + 1] = entry
    if #stack > MAX_HISTORY then table.remove(stack, 1) end
    self.redoStack = {}
    return true
end

local function applyEntry(self, entry, after)
    local first
    for k = 1, #entry, 5 do
        local i = entry[k]
        if not self.fixed[i] then -- hints lock cells; history never unlocks them
            if after then
                self.values[i], self.notes[i] = entry[k + 3], entry[k + 4]
            else
                self.values[i], self.notes[i] = entry[k + 1], entry[k + 2]
            end
            first = first or i
        end
    end
    return first
end

function Game:canUndo() return #self.undoStack > 0 end
function Game:canRedo() return #self.redoStack > 0 end

-- Returns the cell the change happened in (so the cursor can jump there), or nil.
function Game:undo()
    local entry = table.remove(self.undoStack)
    if not entry then return nil end
    self.redoStack[#self.redoStack + 1] = entry
    return applyEntry(self, entry, false) or entry[1]
end

function Game:redo()
    local entry = table.remove(self.redoStack)
    if not entry then return nil end
    self.undoStack[#self.undoStack + 1] = entry
    return applyEntry(self, entry, true) or entry[1]
end

-- Queries -------------------------------------------------------------------

function Game:isWrong(i)
    local v = self.values[i]
    return v ~= 0 and v ~= self.solution[i]
end

function Game:isSolved()
    for i = 1, 81 do
        if self.values[i] ~= self.solution[i] then return false end
    end
    return true
end

-- How many times each digit appears on the board (right or wrong).
function Game:digitCounts()
    local counts = { 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    for i = 1, 81 do
        local v = self.values[i]
        if v ~= 0 then counts[v] = counts[v] + 1 end
    end
    return counts
end

function Game:filledCount()
    local n = 0
    for i = 1, 81 do
        if self.values[i] ~= 0 then n = n + 1 end
    end
    return n
end

-- The next empty cell after `from` in reading order (dir 1) or before it
-- (dir -1), wrapping around the board. Cells with only notes count as empty.
-- nil if no other cell is empty.
function Game:nextEmpty(from, dir)
    local i = from
    for _ = 1, 80 do
        i = (i - 1 + dir) % 81 + 1
        if self.values[i] == 0 then return i end
    end
    return nil
end

-- The number after d (dir 1) or before it (dir -1) that isn't already on the
-- board nine times, wrapping from 9 to 1. If every number is, just the next one.
function Game:nextNeededDigit(d, dir)
    local counts = self:digitCounts()
    local n = d
    for _ = 1, 9 do
        n = (n - 1 + dir) % 9 + 1
        if counts[n] < 9 then return n end
    end
    return (d - 1 + dir) % 9 + 1
end

-- For checking the board: how many numbers the player placed (givens and
-- hinted cells left out), and how many of those are wrong.
function Game:checkPlaced()
    local placed, wrong = 0, 0
    for i = 1, 81 do
        if not self.fixed[i] and self.values[i] ~= 0 then
            placed = placed + 1
            if self.values[i] ~= self.solution[i] then wrong = wrong + 1 end
        end
    end
    return placed, wrong
end

-- Units (row/column/box) through cell i that are now complete.
-- strict: every number matches the solution. Otherwise the unit just has to be
-- full with nine different numbers, which is all the player can see when
-- mistake checking is off (so celebrations never give away mistakes).
function Game:completedUnits(i, strict)
    local done = {}
    for _, u in ipairs(CELL_UNITS[i]) do
        local full, seen = true, {}
        for _, j in ipairs(UNITS[u]) do
            local v = self.values[j]
            if v == 0 or seen[v] or (strict and v ~= self.solution[j]) then
                full = false
                break
            end
            seen[v] = true
        end
        if full then done[#done + 1] = u end
    end
    return done
end

-- True when all nine copies of digit d are on the board (and right, if strict).
function Game:digitComplete(d, strict)
    local n = 0
    for j = 1, 81 do
        if self.values[j] == d then
            if strict and self.solution[j] ~= d then return false end
            n = n + 1
        end
    end
    return n == 9
end

-- Actions -------------------------------------------------------------------
-- Each returns a result table the scene uses for sound and animation:
--   blocked   the cell can't be changed (a given or a hint)
--   placed / cleared / wrong / units / solved / changed

local function finish(self, i, res)
    if res.placed and not res.wrong then
        res.units = self:completedUnits(i, true)
    end
    if self:isSolved() then
        res.solved = true
        self.solved = true
    end
    return res
end

local function clearNotePeers(self, i, d)
    local m = DIGIT_BIT[d]
    for _, j in ipairs(PEERS[i]) do
        if self.values[j] == 0 and band(self.notes[j], m) ~= 0 then
            self:_set(j, 0, band(self.notes[j], bnot(m)))
        end
    end
end

function Game:enter(i, d, settings)
    if self.fixed[i] then return { blocked = true } end
    local res = {}
    self:_begin()
    if self.values[i] == d then
        self:_set(i, 0, 0)
        res.cleared = true
    else
        self:_set(i, d, 0)
        res.placed = true
        if d ~= self.solution[i] then
            res.wrong = true
            if settings.mistakes then self.mistakes = self.mistakes + 1 end
        end
        if settings.autoclear then clearNotePeers(self, i, d) end
    end
    res.changed = self:_commit()
    self.lastDigit = d
    return finish(self, i, res)
end

function Game:toggleNote(i, d)
    if self.fixed[i] or self.values[i] ~= 0 then return { blocked = true } end
    self:_begin()
    local m = DIGIT_BIT[d]
    self:_set(i, 0, bxor(self.notes[i], m))
    local res = { noted = true, on = band(self.notes[i], m) ~= 0 }
    res.changed = self:_commit()
    self.lastDigit = d
    return res
end

function Game:erase(i)
    if self.fixed[i] then return { blocked = true } end
    if self.values[i] == 0 and self.notes[i] == 0 then return { empty = true } end
    self:_begin()
    self:_set(i, 0, 0)
    return { erased = true, changed = self:_commit() }
end

-- Fill every empty cell's notes with the digits that can legally go there.
function Game:fillNotes()
    self:_begin()
    for i = 1, 81 do
        if self.values[i] == 0 then
            self:_set(i, 0, sudoku.candidates(self.values, i))
        end
    end
    return { filled = true, changed = self:_commit() }
end

function Game:clearNotes()
    self:_begin()
    for i = 1, 81 do
        if self.notes[i] ~= 0 then self:_set(i, self.values[i], 0) end
    end
    return { cleared = true, changed = self:_commit() }
end

-- Select's notes button: clear all notes if there are any, otherwise fill them.
function Game:toggleNotes()
    for i = 1, 81 do
        if self.notes[i] ~= 0 then return self:clearNotes() end
    end
    return self:fillNotes()
end

-- Picks the cell a hint should reveal when the cursor's cell is already right:
-- the unsolved cell with the fewest legal candidates.
function Game:_hintTarget()
    local best, bestCount
    for i = 1, 81 do
        if not self.fixed[i] and self.values[i] ~= self.solution[i] then
            local count = sudoku.POP[sudoku.candidates(self.values, i)]
            if not best or count < bestCount then best, bestCount = i, count end
        end
    end
    return best
end

-- Reveals the right number in cell i (or a good empty cell if i is already
-- right). Revealed cells lock like givens. Hints can't be undone.
-- Counts a hint without changing the board (explained hints count when opened).
function Game:countHint()
    self.hints = self.hints + 1
end

-- Remove candidates from the player's notes: list of {cell, digit}. Undoable.
function Game:removeNotes(list)
    self:_begin()
    for _, r in ipairs(list) do
        local i, m = r[1], DIGIT_BIT[r[2]]
        if self.values[i] == 0 and band(self.notes[i], m) ~= 0 then
            self:_set(i, 0, band(self.notes[i], bnot(m)))
        end
    end
    return { noted = true, changed = self:_commit() }
end

function Game:hasNote(i, d)
    return self.values[i] == 0 and band(self.notes[i], DIGIT_BIT[d]) ~= 0
end

-- opts.free: don't count it (the explained hint was counted when opened).
function Game:hint(i, opts)
    local target = i
    if self.fixed[i] or self.values[i] == self.solution[i] then
        target = self:_hintTarget()
        if not target then return { blocked = true } end
    end
    local d = self.solution[target]
    self:_begin()
    self:_set(target, d, 0)
    clearNotePeers(self, target, d)
    self._touched, self._order = nil, nil
    self.fixed[target], self.hinted[target] = true, true
    if not (opts and opts.free) then self.hints = self.hints + 1 end
    local res = finish(self, target, { placed = true, hinted = true, cell = target })
    return res
end

function Game:restart()
    for i = 1, 81 do
        if not self.fixed[i] or self.hinted[i] then
            self.values[i] = 0
            self.fixed[i], self.hinted[i] = false, false
        end
        self.notes[i] = 0
    end
    self.elapsed, self.mistakes, self.hints = 0, 0, 0
    self.undoStack, self.redoStack = {}, {}
    self.solved = false
    self.mode = "pen"
end

-- Saving --------------------------------------------------------------------

local function bitsToString(list)
    local out = {}
    for i = 1, 81 do out[i] = list[i] and "1" or "0" end
    return table.concat(out)
end

local function stringToBits(s)
    local out = {}
    for i = 1, 81 do out[i] = s:sub(i, i) == "1" end
    return out
end

function Game:serialize()
    return {
        version = 1,
        difficulty = self.difficulty,
        solution = table.concat(self.solution),
        values = table.concat(self.values),
        notes = self.notes,
        fixed = bitsToString(self.fixed),
        hinted = bitsToString(self.hinted),
        elapsed = self.elapsed,
        mistakes = self.mistakes,
        hints = self.hints,
        cursor = self.cursor,
        mode = self.mode,
        lastDigit = self.lastDigit,
        undoStack = self.undoStack,
        redoStack = self.redoStack,
        pack = self.pack,
        daily = self.daily,
    }
end

local function digitsFromString(s)
    local out = {}
    for i = 1, 81 do out[i] = tonumber(s:sub(i, i)) or 0 end
    return out
end

function Game.deserialize(t)
    if type(t) ~= "table" or t.version ~= 1 then return nil end
    if type(t.solution) ~= "string" or #t.solution ~= 81 then return nil end
    if type(t.values) ~= "string" or #t.values ~= 81 then return nil end
    local g = setmetatable({}, Game)
    g.difficulty = t.difficulty or "medium"
    g.solution = digitsFromString(t.solution)
    g.values = digitsFromString(t.values)
    g.notes = {}
    for i = 1, 81 do g.notes[i] = tonumber(t.notes and t.notes[i]) or 0 end
    g.fixed = stringToBits(t.fixed or "")
    g.hinted = stringToBits(t.hinted or "")
    g.elapsed = tonumber(t.elapsed) or 0
    g.mistakes = tonumber(t.mistakes) or 0
    g.hints = tonumber(t.hints) or 0
    g.cursor = math.max(1, math.min(81, tonumber(t.cursor) or 41))
    g.mode = (t.mode == "pencil") and "pencil" or "pen"
    g.lastDigit = math.max(1, math.min(9, tonumber(t.lastDigit) or 1))
    g.undoStack = type(t.undoStack) == "table" and t.undoStack or {}
    g.redoStack = type(t.redoStack) == "table" and t.redoStack or {}
    g.solved = g:isSolved()
    if type(t.pack) == "table" and type(t.pack.file) == "string" then
        g.pack = {
            file = t.pack.file, name = tostring(t.pack.name or t.pack.file),
            path = tostring(t.pack.path or ""), index = tonumber(t.pack.index) or 1,
            count = tonumber(t.pack.count) or 0, size = tonumber(t.pack.size) or 0,
        }
    end
    if type(t.daily) == "string" and require("src.daily").isKey(t.daily) then g.daily = t.daily end
    if not sudoku.isValidSolution(g.solution) then return nil end
    return g
end

return Game
