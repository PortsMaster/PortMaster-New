-- Puzzle packs: text files of puzzles the player drops into a folder.
--
-- Accepted formats (mixed freely, one file can contain several):
--   * One puzzle per line: 81 characters, 1-9 for givens and 0 or . for
--     empty cells. Anything else on the line (ids, ratings, CSV columns,
--     a second 81-character solution) is ignored, so Sudoku Exchange,
--     Kaggle CSV, Royle's 17-clue list and forum "hardest" lists all work.
--   * Grids of 9 lines with 9 characters each. Spaces, | and +--- divider
--     lines are allowed, as are header lines such as "Grid 01".
--   * Lines starting with # are comments.
--
-- Parsing and indexing are pure Lua so they can be unit-tested with luajit.

local packs = {}

packs.MAX_PUZZLES = 100000
packs.EXTENSIONS = { txt = true, sdm = true, sdk = true, csv = true, ss = true }

local RUN = "%f[%d%.]" .. string.rep("[%d%.]", 81) .. "%f[^%d%.]"

-- Classify one line: "one" + puzzle, "row" + 9 cells, "sep", or nil.
function packs.parseLine(line)
    if line:find("^%s*#") then return nil end
    local s, e = line:find(RUN)
    if s then
        return "one", (line:sub(s, e):gsub("%.", "0"))
    end
    local compact = line:gsub("[%s|]", "")
    if #compact == 9 and not compact:find("[^%d%.]") then
        return "row", (compact:gsub("%.", "0"))
    end
    if #compact > 0 and not compact:find("[^%-+=]") then
        return "sep"
    end
    return nil
end

-- Read lines from an open file handle, starting at its current position,
-- until one puzzle is complete. Returns the 81-character puzzle or nil.
local function readPuzzle(f)
    local rows = {}
    for line in f:lines() do
        local kind, value = packs.parseLine(line)
        if kind == "one" and #rows == 0 then
            return value
        elseif kind == "row" then
            rows[#rows + 1] = value
            if #rows == 9 then return table.concat(rows) end
        elseif kind ~= "sep" and #rows > 0 then
            rows = {}
        end
    end
    return nil
end

-- Build an index of where each puzzle starts in the file.
-- `yield(fraction)` is called every few thousand lines so callers can show
-- progress and spread the work over frames.
function packs.scan(path, yield)
    local f = io.open(path, "rb")
    if not f then return nil, "Couldn't open the file." end
    local size = f:seek("end") or 0
    f:seek("set", 0)

    local offsets, truncated = {}, false
    local pos, rows, gridStart, n = 0, 0, 0, 0
    local max = packs.MAX_PUZZLES

    for line in f:lines() do
        local start = pos
        pos = pos + #line + 1
        n = n + 1
        local kind = packs.parseLine(line)
        if kind == "one" then
            offsets[#offsets + 1] = start
            rows = 0
        elseif kind == "row" then
            if rows == 0 then gridStart = start end
            rows = rows + 1
            if rows == 9 then
                offsets[#offsets + 1] = gridStart
                rows = 0
            end
        elseif kind ~= "sep" then
            rows = 0
        end
        if #offsets >= max then
            truncated = pos < size
            break
        end
        if yield and n % 2000 == 0 then yield(size > 0 and pos / size or 1) end
    end
    f:close()
    return { path = path, offsets = offsets, count = #offsets, size = size, truncated = truncated }
end

-- Fetch puzzle n (1-based) from a scanned pack, as an 81-character string.
function packs.fetch(index, n)
    local offset = index.offsets[n]
    if not offset then return nil end
    local f = io.open(index.path, "rb")
    if not f then return nil end
    f:seek("set", offset)
    local puzzle = readPuzzle(f)
    f:close()
    return puzzle
end

function packs.toGrid(puzzle)
    local grid = {}
    for i = 1, 81 do grid[i] = tonumber(puzzle:sub(i, i)) or 0 end
    return grid
end

-- Folder and file listing ------------------------------------------------------

packs.override = nil -- set by the dev harness to point somewhere else

-- The launcher sets MUSUDOKU_PACKS to MUOS/application/muSudoku/packs on the
-- device; on a PC it falls back to a "packs" folder in the save directory.
function packs.dir()
    if packs.override then return packs.override end
    local env = os.getenv("MUSUDOKU_PACKS")
    if env and env ~= "" then return env end
    love.filesystem.createDirectory("packs")
    return love.filesystem.getSaveDirectory() .. "/packs"
end

local function shellQuote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function prettyName(file)
    local name = file:gsub("%.[^%.]+$", ""):gsub("_", " ")
    return name
end

function packs.list(dir)
    dir = dir or packs.dir()
    local files = {}
    local windows = package.config:sub(1, 1) == "\\"
    local cmd = windows and ('dir /b "' .. dir .. '" 2>nul') or ("ls -1 " .. shellQuote(dir) .. " 2>/dev/null")
    local ok, p = pcall(io.popen, cmd)
    if ok and p then
        for file in p:lines() do
            local ext = file:match("%.([^%.]+)$")
            if ext and packs.EXTENSIONS[ext:lower()] and file:sub(1, 1) ~= "." then
                local path = dir .. "/" .. file
                local f = io.open(path, "rb")
                if f then
                    local size = f:seek("end") or 0
                    f:close()
                    files[#files + 1] = { file = file, path = path, name = prettyName(file), size = size }
                end
            end
        end
        p:close()
    end
    table.sort(files, function(a, b) return a.name:lower() < b.name:lower() end)
    return files
end

-- Progress -----------------------------------------------------------------------
-- progress[file] = { count, size, last, solved = {n, ...}, invalid = {n, ...},
--                    best, total, timed, perfect }
-- Lists are stored as arrays and turned into sets in memory. best is the
-- fastest solve without hints (0 = none yet), total / timed the average.

local TIMES = { "best", "total", "timed", "perfect" }

local function toSet(list)
    local set = {}
    for _, n in ipairs(list or {}) do set[n] = true end
    return set
end

local function toList(set)
    local list = {}
    for n in pairs(set) do list[#list + 1] = n end
    table.sort(list)
    return list
end

function packs.loadProgress(saved)
    local progress = {}
    for file, p in pairs(saved or {}) do
        if type(p) == "table" then
            progress[file] = {
                count = tonumber(p.count) or 0,
                size = tonumber(p.size) or 0,
                last = tonumber(p.last) or 0,
                solved = toSet(p.solved),
                invalid = toSet(p.invalid),
            }
            for _, k in ipairs(TIMES) do progress[file][k] = tonumber(p[k]) or 0 end
        end
    end
    return progress
end

function packs.saveableProgress(progress)
    local out = {}
    for file, p in pairs(progress) do
        out[file] = { count = p.count, size = p.size, last = p.last, solved = toList(p.solved), invalid = toList(p.invalid) }
        for _, k in ipairs(TIMES) do out[file][k] = p[k] end
    end
    return out
end

function packs.entry(progress, file)
    local p = progress[file]
    if not p then
        p = { count = 0, size = 0, last = 0, solved = {}, invalid = {}, best = 0, total = 0, timed = 0, perfect = 0 }
        progress[file] = p
    end
    return p
end

-- Starts a pack's progress over (its file changed).
function packs.reset(p)
    p.solved, p.invalid, p.last = {}, {}, 0
    for _, k in ipairs(TIMES) do p[k] = 0 end
end

-- Records a solve of one of the pack's puzzles. Returns true for a new best.
function packs.recordSolve(p, n, seconds, hints, mistakes)
    p.solved[n] = true
    p.timed, p.total = p.timed + 1, p.total + seconds
    if hints == 0 and mistakes == 0 then p.perfect = p.perfect + 1 end
    if hints == 0 and (p.best == 0 or seconds < p.best) then
        p.best = seconds
        return true
    end
    return false
end

function packs.solvedCount(p)
    local n = 0
    for _ in pairs(p.solved) do n = n + 1 end
    return n
end

-- Next puzzle after `from` that isn't solved or known to be broken.
function packs.nextUnsolved(p, count, from)
    if count == 0 then return nil end
    local n = from or p.last or 0
    for _ = 1, count do
        n = n % count + 1
        if not p.solved[n] and not p.invalid[n] then return n end
    end
    return nil
end

function packs.randomUnsolved(p, count, rng)
    rng = rng or math.random
    for _ = 1, 200 do
        local n = rng(count)
        if not p.solved[n] and not p.invalid[n] then return n end
    end
    return packs.nextUnsolved(p, count, rng(count))
end

return packs
