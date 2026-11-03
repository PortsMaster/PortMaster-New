-- Sudoku engine: solving, generating and grading puzzles.
-- Pure Lua (LuaJIT `bit` library), no LÖVE dependency, so it can be
-- unit-tested with plain `luajit`.
--
-- Grids are flat arrays of 81 numbers (index 1 = top-left, row-major),
-- 0 meaning empty. Candidate sets are 9-bit masks (bit d-1 = digit d).

local bit = require("bit")
local band, bor, bxor, bnot, lshift, rshift = bit.band, bit.bor, bit.bxor, bit.bnot, bit.lshift, bit.rshift

local M = {}

M.ALL = 511

local ROW, COL, BOX = {}, {}, {}
local UNITS = {}       -- 27 units (9 rows, 9 columns, 9 boxes), each a list of 9 cells
local CELL_UNITS = {}  -- [cell] = { rowUnit, colUnit, boxUnit }
local PEERS = {}       -- [cell] = list of the 20 cells sharing a unit
local POP = {}         -- [mask] = number of set bits
local BIT_DIGIT = {}   -- [single-bit mask] = digit
local DIGIT_BIT = {}   -- [digit] = single-bit mask

for i = 1, 81 do
    local r, c = math.floor((i - 1) / 9), (i - 1) % 9
    ROW[i], COL[i] = r, c
    BOX[i] = math.floor(r / 3) * 3 + math.floor(c / 3)
end

for u = 0, 8 do
    local row, col, box = {}, {}, {}
    local br, bc = math.floor(u / 3) * 3, (u % 3) * 3
    for k = 0, 8 do
        row[#row + 1] = u * 9 + k + 1
        col[#col + 1] = k * 9 + u + 1
        box[#box + 1] = (br + math.floor(k / 3)) * 9 + bc + (k % 3) + 1
    end
    UNITS[u + 1], UNITS[u + 10], UNITS[u + 19] = row, col, box
end

for i = 1, 81 do
    CELL_UNITS[i] = { ROW[i] + 1, COL[i] + 10, BOX[i] + 19 }
    local seen, list = { [i] = true }, {}
    for _, u in ipairs(CELL_UNITS[i]) do
        for _, j in ipairs(UNITS[u]) do
            if not seen[j] then
                seen[j] = true
                list[#list + 1] = j
            end
        end
    end
    PEERS[i] = list
end

for m = 0, 511 do
    local n, x = 0, m
    while x > 0 do
        n = n + band(x, 1)
        x = rshift(x, 1)
    end
    POP[m] = n
end

for d = 1, 9 do
    local b = lshift(1, d - 1)
    BIT_DIGIT[b], DIGIT_BIT[d] = d, b
end

M.ROW, M.COL, M.BOX = ROW, COL, BOX
M.UNITS, M.CELL_UNITS, M.PEERS = UNITS, CELL_UNITS, PEERS
M.POP, M.BIT_DIGIT, M.DIGIT_BIT = POP, BIT_DIGIT, DIGIT_BIT

-- Helpers -------------------------------------------------------------------

local function copy(t)
    local out = {}
    for i = 1, #t do out[i] = t[i] end
    return out
end
M.copy = copy

local function defaultRng(n) return math.random(n) end

local function shuffle(list, rng)
    for i = #list, 2, -1 do
        local j = rng(i)
        list[i], list[j] = list[j], list[i]
    end
    return list
end
M.shuffle = shuffle

-- Mask of digits that can legally go in `cell` given the values in `grid`.
function M.candidates(grid, cell)
    local used = 0
    for _, j in ipairs(PEERS[cell]) do
        local v = grid[j]
        if v ~= 0 then used = bor(used, DIGIT_BIT[v]) end
    end
    return band(bnot(used), M.ALL)
end

-- Solver --------------------------------------------------------------------
-- Backtracking with "fewest candidates first". Counts solutions up to
-- `limit` (default 2, which is all a uniqueness check needs). With `rng`
-- it tries candidates in random order, which is how full grids are made.
-- Returns count, firstSolution.

function M.solve(grid, limit, rng)
    limit = limit or 2
    local rows, cols, boxes = {}, {}, {}
    for k = 0, 8 do rows[k], cols[k], boxes[k] = 0, 0, 0 end

    local work, empties = {}, {}
    for i = 1, 81 do
        local v = grid[i]
        work[i] = v
        if v ~= 0 then
            local m = DIGIT_BIT[v]
            local r, c, b = ROW[i], COL[i], BOX[i]
            if band(rows[r], m) ~= 0 or band(cols[c], m) ~= 0 or band(boxes[b], m) ~= 0 then
                return 0, nil -- the givens already clash
            end
            rows[r], cols[c], boxes[b] = bor(rows[r], m), bor(cols[c], m), bor(boxes[b], m)
        else
            empties[#empties + 1] = i
        end
    end

    local count, solution = 0, nil
    local order = {}

    local function search(n)
        if n == 0 then
            count = count + 1
            if count == 1 then solution = copy(work) end
            return count >= limit
        end

        local bestK, bestMask, bestCount = 0, 0, 10
        for k = 1, n do
            local i = empties[k]
            local mask = band(bnot(bor(rows[ROW[i]], cols[COL[i]], boxes[BOX[i]])), 511)
            local cnt = POP[mask]
            if cnt < bestCount then
                bestK, bestMask, bestCount = k, mask, cnt
                if cnt <= 1 then break end
            end
        end
        if bestCount == 0 then return false end

        local i = empties[bestK]
        empties[bestK], empties[n] = empties[n], empties[bestK]
        local r, c, b = ROW[i], COL[i], BOX[i]

        local digits = {}
        local mask = bestMask
        while mask ~= 0 do
            local m = band(mask, -mask)
            mask = bxor(mask, m)
            digits[#digits + 1] = m
        end
        if rng then shuffle(digits, rng) end

        for _, m in ipairs(digits) do
            rows[r], cols[c], boxes[b] = bor(rows[r], m), bor(cols[c], m), bor(boxes[b], m)
            work[i] = BIT_DIGIT[m]
            if search(n - 1) then return true end
            rows[r], cols[c], boxes[b] = bxor(rows[r], m), bxor(cols[c], m), bxor(boxes[b], m)
        end

        work[i] = 0
        empties[bestK], empties[n] = empties[n], empties[bestK]
        return false
    end

    search(#empties)
    return count, solution
end

function M.countSolutions(grid, limit)
    return (M.solve(grid, limit or 2))
end

function M.randomSolution(rng)
    local empty = {}
    for i = 1, 81 do empty[i] = 0 end
    local _, solution = M.solve(empty, 1, rng or defaultRng)
    return solution
end

-- Grader --------------------------------------------------------------------
-- Solves the way a person would and reports the hardest technique needed:
--   1  hidden singles only (cross-hatching)
--   2  + naked singles
--   3  + locked candidates (pointing / claiming)
--   4  + naked and hidden pairs, naked triples
--   5  + X-Wing, Swordfish and XY-Wing
--   6  needs something beyond these (chains, forcing, guessing...)

M.TECHNIQUE_NAMES = {
    "Hidden singles", "Naked singles", "Locked candidates", "Pairs and triples",
    "X-Wing, Swordfish, XY-Wing", "Advanced",
}
M.MAX_GRADE = 6

function M.grade(puzzle)
    local g, cand = copy(puzzle), {}
    local empty = 0
    for i = 1, 81 do
        if g[i] == 0 then
            cand[i] = M.candidates(g, i)
            empty = empty + 1
        else
            cand[i] = 0
        end
    end

    local function place(i, d)
        g[i] = d
        cand[i] = 0
        empty = empty - 1
        local m = bnot(DIGIT_BIT[d])
        for _, j in ipairs(PEERS[i]) do cand[j] = band(cand[j], m) end
    end

    local function eliminate(i, mask)
        if band(cand[i], mask) ~= 0 then
            cand[i] = band(cand[i], bnot(mask))
            return true
        end
        return false
    end

    local level = 0

    local function hiddenSingle()
        for u = 1, 27 do
            local unit = UNITS[u]
            for d = 1, 9 do
                local m, found, n = DIGIT_BIT[d], 0, 0
                for k = 1, 9 do
                    local i = unit[k]
                    if band(cand[i], m) ~= 0 then
                        n = n + 1
                        found = i
                        if n > 1 then break end
                    end
                end
                if n == 1 then
                    place(found, d)
                    return true
                end
            end
        end
        return false
    end

    local function nakedSingle()
        for i = 1, 81 do
            if g[i] == 0 and POP[cand[i]] == 1 then
                place(i, BIT_DIGIT[cand[i]])
                return true
            end
        end
        return false
    end

    -- Pointing: a digit confined to one row/column inside a box is removed from
    -- the rest of that row/column. Claiming: a digit confined to one box inside
    -- a row/column is removed from the rest of that box.
    local function lockedCandidates()
        local changed = false
        for u = 1, 27 do
            local unit = UNITS[u]
            for d = 1, 9 do
                local m = DIGIT_BIT[d]
                local r, c, b, n = -1, -1, -1, 0
                local sameR, sameC, sameB = true, true, true
                for k = 1, 9 do
                    local i = unit[k]
                    if band(cand[i], m) ~= 0 then
                        n = n + 1
                        if r == -1 then
                            r, c, b = ROW[i], COL[i], BOX[i]
                        else
                            if ROW[i] ~= r then sameR = false end
                            if COL[i] ~= c then sameC = false end
                            if BOX[i] ~= b then sameB = false end
                        end
                    end
                end
                if n >= 2 then
                    local targets = {}
                    if u > 18 then -- box: pointing
                        if sameR then targets[#targets + 1] = UNITS[r + 1] end
                        if sameC then targets[#targets + 1] = UNITS[c + 10] end
                    elseif sameB then -- row or column: claiming
                        targets[#targets + 1] = UNITS[b + 19]
                    end
                    for _, other in ipairs(targets) do
                        for k = 1, 9 do
                            local j = other[k]
                            local inside = false
                            if u > 18 then inside = (BOX[j] == b)
                            elseif u <= 9 then inside = (ROW[j] == r)
                            else inside = (COL[j] == c) end
                            if not inside and eliminate(j, m) then changed = true end
                        end
                    end
                end
                if changed then return true end
            end
        end
        return false
    end

    local function subsets()
        for u = 1, 27 do
            local unit = UNITS[u]
            local open = {}
            for k = 1, 9 do
                local i = unit[k]
                if g[i] == 0 then open[#open + 1] = i end
            end
            local n = #open

            -- Naked pairs and triples
            for size = 2, 3 do
                if n > size then
                    for a = 1, n do
                        for b2 = a + 1, n do
                            if size == 2 then
                                local mask = bor(cand[open[a]], cand[open[b2]])
                                if POP[mask] == 2 then
                                    local changed = false
                                    for k = 1, n do
                                        if k ~= a and k ~= b2 and eliminate(open[k], mask) then changed = true end
                                    end
                                    if changed then return true end
                                end
                            else
                                for c2 = b2 + 1, n do
                                    local mask = bor(cand[open[a]], cand[open[b2]], cand[open[c2]])
                                    if POP[mask] == 3 then
                                        local changed = false
                                        for k = 1, n do
                                            if k ~= a and k ~= b2 and k ~= c2 and eliminate(open[k], mask) then changed = true end
                                        end
                                        if changed then return true end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Hidden pairs: two digits that only fit in the same two cells
            local where = {}
            for d = 1, 9 do
                local m, cells = DIGIT_BIT[d], {}
                for k = 1, n do
                    if band(cand[open[k]], m) ~= 0 then cells[#cells + 1] = open[k] end
                end
                where[d] = cells
            end
            for d1 = 1, 8 do
                local w1 = where[d1]
                if #w1 == 2 then
                    for d2 = d1 + 1, 9 do
                        local w2 = where[d2]
                        if #w2 == 2 and w1[1] == w2[1] and w1[2] == w2[2] then
                            local keep = bor(DIGIT_BIT[d1], DIGIT_BIT[d2])
                            local changed = false
                            for _, i in ipairs(w1) do
                                if eliminate(i, band(bnot(keep), 511)) then changed = true end
                            end
                            if changed then return true end
                        end
                    end
                end
            end
        end
        return false
    end

    -- Fish: X-Wing (size 2) and Swordfish (size 3). For a digit, `size` rows
    -- whose places for it fall within `size` columns between them: those
    -- columns get the digit from these rows, so the rest of each column can't
    -- have it. The same with rows and columns swapped.
    local function fish(size)
        for d = 1, 9 do
            local m = DIGIT_BIT[d]
            for across = 0, 1 do -- 0: base rows, cover columns; 1: the other way
                local lines, masks = {}, {}
                for k = 0, 8 do
                    local mask, n = 0, 0
                    for j = 0, 8 do
                        local i = (across == 0) and (k * 9 + j + 1) or (j * 9 + k + 1)
                        if band(cand[i], m) ~= 0 then
                            mask = bor(mask, lshift(1, j))
                            n = n + 1
                        end
                    end
                    if n >= 2 and n <= size then
                        lines[#lines + 1], masks[#masks + 1] = k, mask
                    end
                end
                local function sweep(chosen, union)
                    local base = {}
                    for _, k in ipairs(chosen) do base[k] = true end
                    local changed = false
                    for j = 0, 8 do
                        if band(union, lshift(1, j)) ~= 0 then
                            for k = 0, 8 do
                                if not base[k] then
                                    local i = (across == 0) and (k * 9 + j + 1) or (j * 9 + k + 1)
                                    if eliminate(i, m) then changed = true end
                                end
                            end
                        end
                    end
                    return changed
                end
                local n = #lines
                for a = 1, n do
                    for b2 = a + 1, n do
                        if size == 2 then
                            local union = bor(masks[a], masks[b2])
                            if POP[union] == 2 and sweep({ lines[a], lines[b2] }, union) then return true end
                        else
                            for c2 = b2 + 1, n do
                                local union = bor(masks[a], masks[b2], masks[c2])
                                if POP[union] == 3 and sweep({ lines[a], lines[b2], lines[c2] }, union) then return true end
                            end
                        end
                    end
                end
            end
        end
        return false
    end

    local function sees(i, j)
        return ROW[i] == ROW[j] or COL[i] == COL[j] or BOX[i] == BOX[j]
    end

    -- XY-Wing: a cell that can only be x or y, and two cells it sees that can
    -- only be x or z and y or z. Whatever the first cell is, one of the other
    -- two is z, so no cell seeing both of them can be z.
    local function xyWing()
        for p = 1, 81 do
            local pc = cand[p]
            if g[p] == 0 and POP[pc] == 2 then
                local wings = {}
                for _, q in ipairs(PEERS[p]) do
                    local qc = cand[q]
                    if g[q] == 0 and POP[qc] == 2 and qc ~= pc and POP[band(qc, pc)] == 1 then
                        wings[#wings + 1] = q
                    end
                end
                for a = 1, #wings do
                    for b2 = a + 1, #wings do
                        local qa, qb = wings[a], wings[b2]
                        local z = band(cand[qa], bnot(pc))
                        if z == band(cand[qb], bnot(pc)) and band(cand[qa], pc) ~= band(cand[qb], pc) then
                            local changed = false
                            for _, j in ipairs(PEERS[qa]) do
                                if j ~= qb and j ~= p and sees(j, qb) and eliminate(j, z) then changed = true end
                            end
                            if changed then return true end
                        end
                    end
                end
            end
        end
        return false
    end

    while empty > 0 do
        if hiddenSingle() then
            if level < 1 then level = 1 end
        elseif nakedSingle() then
            if level < 2 then level = 2 end
        elseif lockedCandidates() then
            if level < 3 then level = 3 end
        elseif subsets() then
            if level < 4 then level = 4 end
        elseif fish(2) or fish(3) or xyWing() then
            if level < 5 then level = 5 end
        else
            return 6
        end
    end
    return math.max(level, 1)
end

-- Generator -----------------------------------------------------------------
-- Makes a full grid, then removes clues in 180° rotationally symmetric pairs
-- while the puzzle keeps exactly one solution. The result is graded and
-- accepted if it matches the difficulty. Too easy: it digs deeper. Too hard:
-- it puts removed pairs back one at a time (more clues never add a second
-- solution) until it isn't. Otherwise it retries.

M.DIFFICULTIES = { "easy", "medium", "hard", "expert", "master" }

M.SPECS = {
    easy   = { target = 40, minClues = 36, minGrade = 1, maxGrade = 1, attempts = 20 },
    medium = { target = 33, minClues = 28, minGrade = 2, maxGrade = 2, attempts = 30 },
    hard   = { target = 28, minClues = 23, minGrade = 3, maxGrade = 4, attempts = 80 },
    expert = { target = 0,  minClues = 17, minGrade = 5, maxGrade = 5, attempts = 120 },
    master = { target = 0,  minClues = 17, minGrade = 6, maxGrade = 6, attempts = 80 },
}

-- `yield` (optional) is called after every uniqueness check so a caller can
-- spread the work over several frames with coroutines. `method` picks the
-- solver that makes the full grid and checks uniqueness: "classic" (the
-- backtracking solver above, the default) or "dlx" (Knuth's Algorithm X with
-- dancing links, in dlx.lua). Digging and grading are the same for both.
function M.generate(difficulty, rng, yield, method)
    rng = rng or defaultRng
    local solver = (method == "dlx") and require("src.dlx") or M
    local spec = M.SPECS[difficulty] or M.SPECS.medium
    local best, bestScore

    for _ = 1, spec.attempts do
        local solution = solver.randomSolution(rng)
        local puzzle = copy(solution)

        local order = {}
        for i = 1, 41 do order[i] = i end
        shuffle(order, rng)

        local clues, pos = 81, 1
        local removed = {} -- first cell of each pair taken out
        local function digTo(target)
            while clues > target and pos <= #order do
                local i = order[pos]
                local j = 82 - i
                pos = pos + 1
                local a, b = puzzle[i], puzzle[j]
                puzzle[i], puzzle[j] = 0, 0
                if solver.countSolutions(puzzle, 2) == 1 then
                    clues = clues - ((i == j) and 1 or 2)
                    removed[#removed + 1] = i
                else
                    puzzle[i], puzzle[j] = a, b
                end
                if yield then yield() end
            end
        end

        digTo(spec.target)
        local grade = M.grade(puzzle)
        while grade < spec.minGrade and clues > spec.minClues and pos <= #order do
            digTo(clues - 2)
            grade = M.grade(puzzle)
        end
        if grade > spec.maxGrade then
            shuffle(removed, rng)
            for _, i in ipairs(removed) do
                local j = 82 - i
                puzzle[i], puzzle[j] = solution[i], solution[j]
                clues = clues + ((i == j) and 1 or 2)
                grade = M.grade(puzzle)
                if grade <= spec.maxGrade then break end
                if yield then yield() end
            end
        end

        local result = { puzzle = puzzle, solution = solution, grade = grade, clues = clues }
        local score = 0
        if grade < spec.minGrade then score = spec.minGrade - grade
        elseif grade > spec.maxGrade then score = grade - spec.maxGrade end
        if clues < spec.minClues then score = score + 1 end

        if score == 0 then return result end
        if not best or score < bestScore then best, bestScore = result, score end
    end

    return best
end

function M.isValidSolution(grid)
    for u = 1, 27 do
        local seen = 0
        for _, i in ipairs(UNITS[u]) do
            local v = grid[i]
            if v < 1 or v > 9 then return false end
            seen = bor(seen, DIGIT_BIT[v])
        end
        if seen ~= 511 then return false end
    end
    return true
end

return M
