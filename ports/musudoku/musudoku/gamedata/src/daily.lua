-- The daily puzzle: one puzzle per calendar day, the same on every device
-- running the same version. It comes from the Classic generator seeded with
-- the date, using the random number generator below, which gives the same
-- sequence everywhere (plain double arithmetic, no platform RNG).
-- Solved days are kept as a set of "YYYY-MM-DD" keys, so streaks stay right
-- even when an earlier day's puzzle is finished late.

local daily = {}

-- os.date's wday: 1 is Sunday. Easy on Monday, getting harder to the weekend.
daily.DIFFICULTY_BY_WEEKDAY = { "expert", "easy", "medium", "medium", "hard", "hard", "expert" }

local WEEKDAYS = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
local MONTHS = { "January", "February", "March", "April", "May", "June", "July",
    "August", "September", "October", "November", "December" }

-- Before this year the clock has clearly never been set (handhelds often
-- start at 1970 or 2000), so there's no "today" to go by.
daily.EARLIEST_YEAR = 2025

local function keyOf(t)
    return string.format("%04d-%02d-%02d", t.year, t.month, t.day)
end

local function parse(key)
    local y, m, d = tostring(key):match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    if not y then return nil end
    return { year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 }
end

function daily.isKey(key)
    return parse(key) ~= nil
end

-- Today's puzzle: { key, seed, difficulty, label }, or nil if the clock isn't set.
-- `now` (os.time() value) is for tests.
function daily.today(now)
    local t = os.date("*t", now or os.time())
    if t.year < daily.EARLIEST_YEAR then return nil end
    return {
        key = keyOf(t),
        seed = t.year * 10000 + t.month * 100 + t.day,
        difficulty = daily.DIFFICULTY_BY_WEEKDAY[t.wday],
        label = WEEKDAYS[t.wday] .. " " .. t.day .. " " .. MONTHS[t.month],
    }
end

-- "2026-11-01" -> "Sunday 1 November"
function daily.label(key)
    local t = parse(key)
    if not t then return tostring(key) end
    local n = os.date("*t", os.time(t))
    return WEEKDAYS[n.wday] .. " " .. n.day .. " " .. MONTHS[n.month]
end

-- The day before. Noon keeps daylight saving changes from skipping a day.
function daily.previousKey(key)
    local t = parse(key)
    if not t then return nil end
    return keyOf(os.date("*t", os.time(t) - 86400))
end

-- Days solved in a row, counting back from today, or from yesterday while
-- today's puzzle is still open (so the streak doesn't look lost all day).
function daily.streak(days, todayKey)
    local k = todayKey
    if not days[k] then k = daily.previousKey(k) end
    local n = 0
    while k and days[k] do
        n = n + 1
        k = daily.previousKey(k)
    end
    return n
end

function daily.bestStreak(days)
    local keys = {}
    for k in pairs(days) do
        if parse(k) then keys[#keys + 1] = k end
    end
    table.sort(keys)
    local best, run, last = 0, 0, nil
    for _, k in ipairs(keys) do
        if last and daily.previousKey(k) == last then run = run + 1 else run = 1 end
        if run > best then best = run end
        last = k
    end
    return best
end

function daily.solvedCount(days)
    local n = 0
    for k in pairs(days) do
        if parse(k) then n = n + 1 end
    end
    return n
end

-- Park-Miller "minimal standard" generator. Every step is exact in doubles,
-- so it gives the same numbers on every platform. rng(n) returns 1..n.
function daily.rng(seed)
    local M, A = 2147483647, 16807
    local state = seed % (M - 1) + 1
    for _ = 1, 8 do state = (state * A) % M end -- spread out nearby seeds
    return function(n)
        state = (state * A) % M
        return 1 + math.floor((state - 1) / (M - 1) * n)
    end
end

return daily
