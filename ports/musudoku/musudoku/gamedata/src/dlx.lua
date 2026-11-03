-- Knuth's Algorithm X with dancing links (DLX), set up for Sudoku.
-- Sudoku is an exact cover problem: 729 choices (digit d in cell i) and 324
-- constraints that must each be met by exactly one choice (every cell is
-- filled, and every digit appears once in each row, column and box).
--
-- The links are built once. Solving covers the givens, searches, then
-- uncovers everything in reverse, so the structure is back to its starting
-- state after every call. Same interface as the backtracking solver in
-- sudoku.lua, so the generator can use either.

local M = {}

local COLUMNS = 324
local L, R, U, D, C = {}, {}, {}, {}, {}
local S = {}       -- [column] = rows left in it
local CHOICE = {}  -- [node] = (cell - 1) * 9 + digit
local FIRST = {}   -- [choice] = the first of its four nodes

-- Node 0 is the root and 1..324 are the column headers:
--   1..81     cell i is filled
--   82..162   row r has digit d
--   163..243  column c has digit d
--   244..324  box b has digit d
do
    for c = 0, COLUMNS do
        L[c], R[c], U[c], D[c], C[c], S[c] = c - 1, c + 1, c, c, c, 0
    end
    L[0], R[COLUMNS] = COLUMNS, 0

    local n = COLUMNS
    for i = 1, 81 do
        local r, c = math.floor((i - 1) / 9), (i - 1) % 9
        local b = math.floor(r / 3) * 3 + math.floor(c / 3)
        for d = 1, 9 do
            local choice = (i - 1) * 9 + d
            local first = n + 1
            for _, col in ipairs({ i, 81 + r * 9 + d, 162 + c * 9 + d, 243 + b * 9 + d }) do
                n = n + 1
                C[n], CHOICE[n] = col, choice
                U[n], D[n] = U[col], col -- append at the bottom of the column
                D[U[col]] = n
                U[col] = n
                S[col] = S[col] + 1
                L[n], R[n] = n - 1, n + 1
            end
            L[first], R[n] = n, first
            FIRST[choice] = first
        end
    end
end

-- Remove column c and every row that meets it.
local function cover(c)
    local l, r = L[c], R[c]
    R[l], L[r] = r, l
    local i = D[c]
    while i ~= c do
        local j = R[i]
        while j ~= i do
            local u, d = U[j], D[j]
            D[u], U[d] = d, u
            S[C[j]] = S[C[j]] - 1
            j = R[j]
        end
        i = D[i]
    end
end

-- Put back what cover(c) removed, in reverse order.
local function uncover(c)
    local i = U[c]
    while i ~= c do
        local j = L[i]
        while j ~= i do
            S[C[j]] = S[C[j]] + 1
            D[U[j]], U[D[j]] = j, j
            j = L[j]
        end
        i = U[i]
    end
    local l, r = L[c], R[c]
    R[l], L[r] = c, c
end

local function shuffle(list, rng)
    for i = #list, 2, -1 do
        local j = rng(i)
        list[i], list[j] = list[j], list[i]
    end
end

-- Counts solutions up to `limit` (default 2, enough for a uniqueness check).
-- With `rng` the rows tried at each step are shuffled, which is how random
-- full grids are made. Returns count, firstSolution.
function M.solve(grid, limit, rng)
    limit = limit or 2

    -- Choose the givens. A given whose constraint is already met clashes
    -- with an earlier one, so the puzzle has no solution.
    local taken, covered, clash = {}, {}, false
    for i = 1, 81 do
        local v = grid[i]
        if v ~= 0 then
            local first = FIRST[(i - 1) * 9 + v]
            local j = first
            repeat
                if covered[C[j]] then clash = true end
                j = R[j]
            until j == first
            if clash then break end
            repeat
                cover(C[j])
                covered[C[j]] = true
                j = R[j]
            until j == first
            taken[#taken + 1] = first
        end
    end

    local count, solution = 0, nil
    local picked, depth = {}, 0
    local search

    local function pick(r)
        depth = depth + 1
        picked[depth] = r
        local j = R[r]
        while j ~= r do cover(C[j]) j = R[j] end
        local stop = search()
        j = L[r]
        while j ~= r do uncover(C[j]) j = L[j] end
        depth = depth - 1
        return stop
    end

    search = function()
        local c = R[0]
        if c == 0 then
            count = count + 1
            if count == 1 then
                solution = {}
                for i = 1, 81 do solution[i] = grid[i] end
                for k = 1, depth do
                    local choice = CHOICE[picked[k]]
                    solution[math.floor((choice - 1) / 9) + 1] = (choice - 1) % 9 + 1
                end
            end
            return count >= limit
        end

        -- the column with the fewest rows left
        local best, size = c, S[c]
        c = R[c]
        while c ~= 0 and size > 0 do
            if S[c] < size then best, size = c, S[c] end
            c = R[c]
        end
        if size == 0 then return false end

        cover(best)
        local stop = false
        if rng then
            local rows = {}
            local r = D[best]
            while r ~= best do rows[#rows + 1] = r r = D[r] end
            shuffle(rows, rng)
            for k = 1, #rows do
                if pick(rows[k]) then stop = true break end
            end
        else
            local r = D[best]
            while r ~= best do
                if pick(r) then stop = true break end
                r = D[r]
            end
        end
        uncover(best)
        return stop
    end

    if not clash then search() end

    for t = #taken, 1, -1 do
        local first = taken[t]
        local j = L[first]
        while j ~= first do uncover(C[j]) j = L[j] end
        uncover(C[first])
    end
    if clash then return 0, nil end
    return count, solution
end

function M.countSolutions(grid, limit)
    return (M.solve(grid, limit or 2))
end

function M.randomSolution(rng)
    local empty = {}
    for i = 1, 81 do empty[i] = 0 end
    local _, solution = M.solve(empty, 1, rng or function(n) return math.random(n) end)
    return solution
end

return M
