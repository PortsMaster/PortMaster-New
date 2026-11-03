-- Per-difficulty records for generated puzzles: counts, times and streaks.
-- entry = { started, solved, total, best, perfect, streak, bestStreak }
-- Pure Lua, testable with luajit.

local records = {}

records.FIELDS = { "started", "solved", "best", "total", "perfect", "streak", "bestStreak" }

function records.empty()
    local e = {}
    for _, k in ipairs(records.FIELDS) do e[k] = 0 end
    return e
end

-- A solve in `seconds`. Returns true if it's a new best time (only solves
-- without hints count for that).
function records.solve(e, seconds, hints, mistakes)
    e.solved = e.solved + 1
    e.total = e.total + seconds
    if hints == 0 and mistakes == 0 then e.perfect = e.perfect + 1 end
    e.streak = e.streak + 1
    if e.streak > e.bestStreak then e.bestStreak = e.streak end
    if hints == 0 and (e.best == 0 or seconds < e.best) then
        e.best = seconds
        return true
    end
    return false
end

-- The puzzle in progress was replaced before it was solved.
function records.abandon(e)
    e.streak = 0
end

return records
