-- Explained hints: finds the easiest move a person could make from the
-- current board and describes why it works.
--
-- A hint is a list of steps. The last step places a number. Steps before it
-- rule out candidates (pointing pairs, naked pairs...) and appear only when
-- the final move depends on them. If the board has a wrong number, the hint
-- points that out instead, because logic built on it would mislead.
--
-- Candidates are worked out from the numbers on the board, not from the
-- player's notes, which may be incomplete. Pure Lua, testable with luajit.

local bit = require("bit")
local sudoku = require("src.sudoku")

local band, bor, bnot = bit.band, bit.bor, bit.bnot
local UNITS, PEERS = sudoku.UNITS, sudoku.PEERS
local ROW, COL, BOX = sudoku.ROW, sudoku.COL, sudoku.BOX
local DB, BD, POP = sudoku.DIGIT_BIT, sudoku.BIT_DIGIT, sudoku.POP

local hints = {}

-- Boxes first: scanning a box is what most people try first.
local SCAN_ORDER = {}
for u = 19, 27 do SCAN_ORDER[#SCAN_ORDER + 1] = u end
for u = 1, 18 do SCAN_ORDER[#SCAN_ORDER + 1] = u end

local function unitName(u)
    if u <= 9 then return "row" elseif u <= 18 then return "column" end
    return "box"
end
hints.unitName = unitName

local function inUnit(u, i)
    if u <= 9 then return ROW[i] == u - 1 elseif u <= 18 then return COL[i] == u - 10 end
    return BOX[i] == u - 19
end

local function cellsWith(cand, unit, m)
    local out = {}
    for _, i in ipairs(unit) do
        if band(cand[i], m) ~= 0 then out[#out + 1] = i end
    end
    return out
end

local function digitsOf(mask)
    local out = {}
    for d = 1, 9 do
        if band(mask, DB[d]) ~= 0 then out[#out + 1] = d end
    end
    return out
end

local function listDigits(ds)
    if #ds == 1 then return tostring(ds[1]) end
    if #ds == 2 then return ds[1] .. " or " .. ds[2] end
    local parts = {}
    for k = 1, #ds - 1 do parts[k] = tostring(ds[k]) end
    return table.concat(parts, ", ") .. " or " .. ds[#ds]
end

-- Placements ---------------------------------------------------------------------

local function findPlacement(values, cand)
    -- Last empty cell in a unit
    for _, u in ipairs(SCAN_ORDER) do
        local empty, used = nil, 0
        local n = 0
        for _, i in ipairs(UNITS[u]) do
            if values[i] == 0 then
                n = n + 1
                empty = i
            else
                used = bor(used, DB[values[i]])
            end
        end
        if n == 1 then
            return { kind = "place", technique = "full", cell = empty, digit = BD[band(bnot(used), 511)], unit = u }
        end
    end
    -- A digit with only one possible cell in a unit
    for _, u in ipairs(SCAN_ORDER) do
        for d = 1, 9 do
            local cells = cellsWith(cand, UNITS[u], DB[d])
            if #cells == 1 then
                local placed = false
                for _, i in ipairs(UNITS[u]) do
                    if values[i] == d then placed = true break end
                end
                if not placed then
                    return { kind = "place", technique = "hidden", cell = cells[1], digit = d, unit = u }
                end
            end
        end
    end
    -- A cell with only one possible digit
    for i = 1, 81 do
        if values[i] == 0 and POP[cand[i]] == 1 then
            return { kind = "place", technique = "naked", cell = i, digit = BD[cand[i]] }
        end
    end
    return nil
end

-- Eliminations -------------------------------------------------------------------

local function removalsIn(cand, cells, mask, skip)
    local out = {}
    for _, j in ipairs(cells) do
        if not (skip and skip[j]) then
            local hit = band(cand[j], mask)
            if hit ~= 0 then
                for _, d in ipairs(digitsOf(hit)) do out[#out + 1] = { j, d } end
            end
        end
    end
    return out
end

local function setOf(list)
    local s = {}
    for _, i in ipairs(list) do s[i] = true end
    return s
end

local function lockedCandidates(cand)
    -- Pointing: inside a box, a digit is confined to one row or column.
    for u = 19, 27 do
        for d = 1, 9 do
            local cells = cellsWith(cand, UNITS[u], DB[d])
            if #cells >= 2 then
                local sameR, sameC = true, true
                for k = 2, #cells do
                    if ROW[cells[k]] ~= ROW[cells[1]] then sameR = false end
                    if COL[cells[k]] ~= COL[cells[1]] then sameC = false end
                end
                local lines = {}
                if sameR then lines[#lines + 1] = ROW[cells[1]] + 1 end
                if sameC then lines[#lines + 1] = COL[cells[1]] + 10 end
                for _, line in ipairs(lines) do
                    local others = {}
                    for _, j in ipairs(UNITS[line]) do
                        if not inUnit(u, j) then others[#others + 1] = j end
                    end
                    local removals = removalsIn(cand, others, DB[d])
                    if #removals > 0 then
                        return { kind = "elim", technique = "pointing", unit = u, line = line, digit = d, pattern = cells, removals = removals }
                    end
                end
            end
        end
    end
    -- Claiming: inside a row or column, a digit is confined to one box.
    for u = 1, 18 do
        for d = 1, 9 do
            local cells = cellsWith(cand, UNITS[u], DB[d])
            if #cells >= 2 then
                local same = true
                for k = 2, #cells do
                    if BOX[cells[k]] ~= BOX[cells[1]] then same = false end
                end
                if same then
                    local box = BOX[cells[1]] + 19
                    local others = {}
                    for _, j in ipairs(UNITS[box]) do
                        if not inUnit(u, j) then others[#others + 1] = j end
                    end
                    local removals = removalsIn(cand, others, DB[d])
                    if #removals > 0 then
                        return { kind = "elim", technique = "claiming", unit = u, line = box, digit = d, pattern = cells, removals = removals }
                    end
                end
            end
        end
    end
end

local function subsets(values, cand)
    for _, u in ipairs(SCAN_ORDER) do
        local open = {}
        for _, i in ipairs(UNITS[u]) do
            if values[i] == 0 then open[#open + 1] = i end
        end
        local n = #open
        -- Naked pairs
        for a = 1, n do
            for b = a + 1, n do
                local mask = bor(cand[open[a]], cand[open[b]])
                if POP[mask] == 2 then
                    local pattern = { open[a], open[b] }
                    local removals = removalsIn(cand, open, mask, setOf(pattern))
                    if #removals > 0 then
                        return { kind = "elim", technique = "nakedPair", unit = u, digits = digitsOf(mask), pattern = pattern, removals = removals }
                    end
                end
            end
        end
        -- Hidden pairs
        local where = {}
        for d = 1, 9 do where[d] = cellsWith(cand, open, DB[d]) end
        for d1 = 1, 8 do
            if #where[d1] == 2 then
                for d2 = d1 + 1, 9 do
                    local w1, w2 = where[d1], where[d2]
                    if #w2 == 2 and w1[1] == w2[1] and w1[2] == w2[2] then
                        local keep = bor(DB[d1], DB[d2])
                        local removals = removalsIn(cand, w1, band(bnot(keep), 511))
                        if #removals > 0 then
                            return { kind = "elim", technique = "hiddenPair", unit = u, digits = { d1, d2 }, pattern = { w1[1], w1[2] }, removals = removals }
                        end
                    end
                end
            end
        end
        -- Naked triples
        for a = 1, n do
            for b = a + 1, n do
                for c = b + 1, n do
                    local mask = bor(cand[open[a]], cand[open[b]], cand[open[c]])
                    if POP[mask] == 3 then
                        local pattern = { open[a], open[b], open[c] }
                        local removals = removalsIn(cand, open, mask, setOf(pattern))
                        if #removals > 0 then
                            return { kind = "elim", technique = "nakedTriple", unit = u, digits = digitsOf(mask), pattern = pattern, removals = removals }
                        end
                    end
                end
            end
        end
    end
end

-- Fish: X-Wing (2 lines) and Swordfish (3). For a digit, `size` rows whose
-- places for it fall within `size` columns between them, or the same with rows
-- and columns swapped.
local function lineUnit(across, k)
    return (across == 0) and (k + 1) or (k + 10) -- row k or column k
end

local function fishes(cand)
    for size = 2, 3 do
        for d = 1, 9 do
            local m = DB[d]
            for across = 0, 1 do -- 0: base rows, cover columns
                local lines = {}
                for k = 0, 8 do
                    local cells = cellsWith(cand, UNITS[lineUnit(across, k)], m)
                    if #cells >= 2 and #cells <= size then
                        local cover = {}
                        for _, i in ipairs(cells) do cover[(across == 0) and COL[i] or ROW[i]] = true end
                        lines[#lines + 1] = { k = k, cells = cells, cover = cover }
                    end
                end
                local function try(chosen)
                    local cover, base, pattern = {}, {}, {}
                    local n = 0
                    for _, line in ipairs(chosen) do
                        base[line.k] = true
                        for j in pairs(line.cover) do
                            if not cover[j] then cover[j], n = true, n + 1 end
                        end
                        for _, i in ipairs(line.cells) do pattern[#pattern + 1] = i end
                    end
                    if n ~= size then return nil end
                    local others, coverUnits, baseUnits = {}, {}, {}
                    for j in pairs(cover) do
                        local u = lineUnit(1 - across, j)
                        coverUnits[#coverUnits + 1] = u
                        for _, i in ipairs(UNITS[u]) do
                            if not base[(across == 0) and ROW[i] or COL[i]] then others[#others + 1] = i end
                        end
                    end
                    for k in pairs(base) do baseUnits[#baseUnits + 1] = lineUnit(across, k) end
                    table.sort(coverUnits)
                    table.sort(baseUnits)
                    local removals = removalsIn(cand, others, m)
                    if #removals == 0 then return nil end
                    return {
                        kind = "elim", technique = (size == 2) and "xWing" or "swordfish", digit = d,
                        base = baseUnits, cover = coverUnits, pattern = pattern, removals = removals,
                    }
                end
                local n = #lines
                for a = 1, n do
                    for b = a + 1, n do
                        if size == 2 then
                            local e = try({ lines[a], lines[b] })
                            if e then return e end
                        else
                            for c = b + 1, n do
                                local e = try({ lines[a], lines[b], lines[c] })
                                if e then return e end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function sees(i, j)
    return ROW[i] == ROW[j] or COL[i] == COL[j] or BOX[i] == BOX[j]
end

-- XY-Wing: a cell that can only be x or y (the pivot), and two cells it sees
-- that can only be x or z and y or z. One of those two must be z.
local function xyWing(values, cand)
    for p = 1, 81 do
        local pc = cand[p]
        if values[p] == 0 and POP[pc] == 2 then
            local wings = {}
            for _, q in ipairs(PEERS[p]) do
                local qc = cand[q]
                if values[q] == 0 and POP[qc] == 2 and qc ~= pc and POP[band(qc, pc)] == 1 then
                    wings[#wings + 1] = q
                end
            end
            for a = 1, #wings do
                for b = a + 1, #wings do
                    local qa, qb = wings[a], wings[b]
                    local z = band(cand[qa], bnot(pc))
                    if z == band(cand[qb], bnot(pc)) and band(cand[qa], pc) ~= band(cand[qb], pc) then
                        local both = {}
                        for _, j in ipairs(PEERS[qa]) do
                            if j ~= qb and j ~= p and sees(j, qb) then both[#both + 1] = j end
                        end
                        local removals = removalsIn(cand, both, z)
                        if #removals > 0 then
                            -- wings ordered to match the pivot's digits (x first)
                            local x = BD[band(cand[qa], pc)]
                            local y = BD[band(cand[qb], pc)]
                            if x > y then qa, qb, x, y = qb, qa, y, x end
                            return {
                                kind = "elim", technique = "xyWing", digit = BD[z], pivot = p,
                                wings = { qa, qb }, digits = { x, y }, seesBoth = both,
                                pattern = { p, qa, qb }, removals = removals,
                            }
                        end
                    end
                end
            end
        end
    end
end

-- Which earlier eliminations does a step depend on? `needs(cell, digit)` is
-- true if removing that candidate earlier could have changed the step.
local function needsFn(step)
    local pattern = setOf(step.pattern or {})
    local t = step.technique
    if t == "full" then
        return function() return false end
    elseif t == "naked" then
        return function(i) return i == step.cell end
    elseif t == "hidden" then
        return function(i, d) return d == step.digit and i ~= step.cell and inUnit(step.unit, i) end
    elseif t == "pointing" or t == "claiming" then
        return function(i, d) return d == step.digit and not pattern[i] and inUnit(step.unit, i) end
    elseif t == "nakedPair" or t == "nakedTriple" then
        return function(i) return pattern[i] == true end
    elseif t == "hiddenPair" then
        local a, b = step.digits[1], step.digits[2]
        return function(i, d) return (d == a or d == b) and not pattern[i] and inUnit(step.unit, i) end
    elseif t == "xWing" or t == "swordfish" then
        -- the fish exists because the digit was ruled out elsewhere in its base lines
        return function(i, d)
            if d ~= step.digit or pattern[i] then return false end
            for _, u in ipairs(step.base) do
                if inUnit(u, i) then return true end
            end
            return false
        end
    elseif t == "xyWing" then
        return function(i) return pattern[i] == true end
    end
    return function() return true end
end

local function keepNeeded(elims, final)
    local needed = { [#elims + 1] = true }
    local all = {}
    for k, e in ipairs(elims) do all[k] = e end
    all[#elims + 1] = final
    for k = #elims, 1, -1 do
        for later = k + 1, #elims + 1 do
            if needed[later] then
                local needs = needsFn(all[later])
                for _, r in ipairs(elims[k].removals) do
                    if needs(r[1], r[2]) then
                        needed[k] = true
                        break
                    end
                end
            end
            if needed[k] then break end
        end
    end
    local out = {}
    for k = 1, #elims do
        if needed[k] then out[#out + 1] = elims[k] end
    end
    return out
end

-- Raw search -------------------------------------------------------------------
-- Returns { mistake = cell, mistakes = n } or { steps = {...} } where the last
-- step is a placement, or { advanced = true, cell, digit } when nothing simple
-- works.

function hints.search(values, solution, fixed, preferCell)
    local wrong = {}
    for i = 1, 81 do
        if values[i] ~= 0 and values[i] ~= solution[i] and not fixed[i] then wrong[#wrong + 1] = i end
    end
    if #wrong > 0 then
        local pick = wrong[1]
        for _, i in ipairs(wrong) do
            if i == preferCell then pick = i end
        end
        return { mistake = pick, mistakes = #wrong }
    end

    local cand = {}
    for i = 1, 81 do
        cand[i] = values[i] == 0 and sudoku.candidates(values, i) or 0
    end

    local elims = {}
    for _ = 1, 60 do
        local place = findPlacement(values, cand)
        if place then
            local steps = keepNeeded(elims, place)
            steps[#steps + 1] = place
            return { steps = steps }
        end
        local e = lockedCandidates(cand) or subsets(values, cand) or fishes(cand) or xyWing(values, cand)
        if not e then break end
        for _, r in ipairs(e.removals) do
            cand[r[1]] = band(cand[r[1]], bnot(DB[r[2]]))
        end
        elims[#elims + 1] = e
    end

    -- Nothing simple works: reveal the selected cell, or the cell with the
    -- fewest candidates.
    local cell = (preferCell and values[preferCell] == 0) and preferCell or nil
    if not cell then
        local best
        for i = 1, 81 do
            if values[i] == 0 and (not best or POP[cand[i]] < best) then cell, best = i, POP[cand[i]] end
        end
    end
    return { advanced = true, cell = cell, digit = cell and solution[cell] }
end

-- Presentation -------------------------------------------------------------------
-- Turns the search into display steps:
--   title, text, action ("erase" | "remove" | "place" | "next"), digit,
--   unitCells, focusCells (sets), blockers (set of cells holding a digit that
--   rules things out), marks ({cell, digit, "focus" | "removed"}), target.

local function unitSet(...)
    local s = {}
    for _, u in ipairs({ ... }) do
        for _, i in ipairs(UNITS[u]) do s[i] = true end
    end
    return s
end

-- For "only place for d in unit u": the cells holding d that block every
-- other empty cell of the unit.
local function hiddenBlockers(values, u, d, target)
    local blockers = {}
    for _, j in ipairs(UNITS[u]) do
        if values[j] == 0 and j ~= target then
            for _, k in ipairs(PEERS[j]) do
                if values[k] == d and not inUnit(u, k) then
                    blockers[k] = true
                    break
                end
            end
        end
    end
    return blockers
end

local function nakedBlockers(values, cell, d)
    local blockers = {}
    for e = 1, 9 do
        if e ~= d then
            for _, k in ipairs(PEERS[cell]) do
                if values[k] == e then
                    blockers[k] = true
                    break
                end
            end
        end
    end
    return blockers
end

-- "a 7", "an 8"
local function a(d) return (d == 8 and "an " or "a ") .. d end
hints.article = a

local function describePlacement(values, s, afterSteps)
    local d, name = s.digit, s.unit and unitName(s.unit)
    local step = { action = "place", digit = d, target = s.cell, marks = {}, focusCells = {} }
    if s.technique == "full" then
        step.title = "Last empty cell"
        step.text = "This is the only empty cell left in this " .. name .. ", so it must be the missing " .. d .. "."
        step.unitCells = unitSet(s.unit)
        step.blockers = {}
    elseif s.technique == "hidden" then
        step.title = "Only place for " .. a(d)
        local seen = (s.unit > 18) and "row or column" or (s.unit <= 9 and "column or box" or "row or box")
        step.text = "In this " .. name .. ", " .. d .. " can only go here. The other empty cells already have "
            .. a(d) .. " in their " .. seen
            .. (afterSteps and (", or lost " .. d .. " as an option in the step before.") or ".")
        step.unitCells = unitSet(s.unit)
        step.blockers = hiddenBlockers(values, s.unit, d, s.cell)
    else
        step.title = "Only number that fits"
        step.text = "Every other number is already in this cell's row, column or box"
            .. (afterSteps and ", or was ruled out in the step before" or "") .. ", so it can only be " .. d .. "."
        step.unitCells = unitSet(ROW[s.cell] + 1, COL[s.cell] + 10, BOX[s.cell] + 19)
        step.blockers = nakedBlockers(values, s.cell, d)
    end
    return step
end

local function describeElimination(e, cand)
    local step = { action = "remove", removals = e.removals, marks = {}, blockers = {}, focusCells = setOf(e.pattern) }
    for _, r in ipairs(e.removals) do step.marks[#step.marks + 1] = { r[1], r[2], "removed" } end
    local name = e.unit and unitName(e.unit) -- fish and wings span several units
    local t = e.technique
    if t == "pointing" or t == "claiming" then
        local d, other = e.digit, unitName(e.line)
        local count = #e.pattern == 2 and "pair" or "triple"
        for _, i in ipairs(e.pattern) do step.marks[#step.marks + 1] = { i, d, "focus" } end
        step.unitCells = unitSet(e.unit, e.line)
        if t == "pointing" then
            step.title = "Pointing " .. count
            step.text = "In this box, " .. d .. " can only go in one " .. other .. ". So " .. d
                .. " can't go anywhere else in that " .. other .. "."
        else
            step.title = "Locked in a box"
            step.text = "In this " .. name .. ", " .. d .. " can only go inside one box. So the rest of that box can't be " .. d .. "."
        end
    elseif t == "nakedPair" or t == "nakedTriple" then
        for _, i in ipairs(e.pattern) do
            for _, d in ipairs(digitsOf(cand[i])) do step.marks[#step.marks + 1] = { i, d, "focus" } end
        end
        step.unitCells = unitSet(e.unit)
        local ds = listDigits(e.digits)
        if t == "nakedPair" then
            step.title = "Naked pair"
            step.text = "These two cells can only be " .. ds .. ". Between them they use both, so no other cell in this "
                .. name .. " can be " .. ds .. "."
        else
            step.title = "Naked triple"
            step.text = "These three cells can only hold " .. ds .. " between them, so no other cell in this "
                .. name .. " can be " .. ds .. "."
        end
    elseif t == "xWing" or t == "swordfish" then
        local d = e.digit
        for _, i in ipairs(e.pattern) do step.marks[#step.marks + 1] = { i, d, "focus" } end
        step.unitCells = unitSet(unpack(e.base))
        local base = (e.base[1] <= 9) and "rows" or "columns"
        local cover = (base == "rows") and "columns" or "rows"
        if t == "xWing" then
            step.title = "X-Wing"
            step.text = "In these two " .. base .. ", " .. d .. " can only go in the same two " .. cover
                .. ". Either way, those " .. cover .. " get their " .. d .. " from these " .. base
                .. ", so " .. d .. " can't go anywhere else in them."
        else
            step.title = "Swordfish"
            step.text = "In these three " .. base .. ", " .. d .. " can only go in three " .. cover
                .. " between them. Those " .. cover .. " get their " .. d .. "s from these " .. base
                .. ", so " .. d .. " can't go anywhere else in them."
        end
    elseif t == "xyWing" then
        local x, y, z = e.digits[1], e.digits[2], e.digit
        step.marks[#step.marks + 1] = { e.pivot, x, "focus" }
        step.marks[#step.marks + 1] = { e.pivot, y, "focus" }
        step.marks[#step.marks + 1] = { e.wings[1], x, "focus" }
        step.marks[#step.marks + 1] = { e.wings[1], z, "focus" }
        step.marks[#step.marks + 1] = { e.wings[2], y, "focus" }
        step.marks[#step.marks + 1] = { e.wings[2], z, "focus" }
        step.unitCells = setOf(e.seesBoth)
        step.target = e.pivot
        step.title = "XY-Wing"
        step.text = "The outlined cell is " .. x .. " or " .. y .. ". If " .. x .. ", the cell with "
            .. x .. " and " .. z .. " is " .. z .. ". If " .. y .. ", the cell with " .. y .. " and "
            .. z .. " is. So no cell seeing both can be " .. z .. "."
    else -- hidden pair
        local a, b = e.digits[1], e.digits[2]
        for _, i in ipairs(e.pattern) do
            step.marks[#step.marks + 1] = { i, a, "focus" }
            step.marks[#step.marks + 1] = { i, b, "focus" }
        end
        step.unitCells = unitSet(e.unit)
        step.title = "Hidden pair"
        step.text = "In this " .. name .. ", " .. a .. " and " .. b .. " can only go in these two cells. So these cells can't hold anything else."
    end
    return step
end

-- For tests: the pattern finders on their own.
hints._fishes, hints._xyWing = fishes, xyWing

function hints.build(values, solution, fixed, preferCell)
    local found = hints.search(values, solution, fixed, preferCell)

    if found.mistake then
        local i = found.mistake
        local more = found.mistakes > 1 and (" It's one of " .. found.mistakes .. " wrong numbers on the board.") or ""
        return { {
            title = "There's a mistake",
            text = "This " .. values[i] .. " doesn't fit the solution, so hints built on it would mislead you." .. more,
            action = "erase", target = i, mistake = true,
            unitCells = {}, focusCells = {}, blockers = {}, marks = {},
        } }
    end

    if found.advanced then
        if not found.cell then return {} end
        return { {
            title = "This needs advanced logic",
            text = "None of the techniques hints explain works from here, so this hint just reveals a number.",
            action = "place", target = found.cell, digit = found.digit,
            unitCells = {}, focusCells = {}, blockers = {}, marks = {},
        } }
    end

    -- Replay the eliminations so each step can show the candidates it sees.
    local cand = {}
    for i = 1, 81 do cand[i] = values[i] == 0 and sudoku.candidates(values, i) or 0 end
    local out = {}
    local n = #found.steps
    for k, s in ipairs(found.steps) do
        if s.kind == "elim" then
            out[#out + 1] = describeElimination(s, cand)
            for _, r in ipairs(s.removals) do cand[r[1]] = band(cand[r[1]], bnot(DB[r[2]])) end
        else
            out[#out + 1] = describePlacement(values, s, n > 1)
        end
    end
    return out
end

return hints
