-- Recent solves, newest first, for the Recent page in Statistics.
-- Each entry: { at = os.time(), kind = "puzzle" | "daily" | "pack",
-- difficulty, pack (name), index, time (seconds), hints, mistakes }.
-- Pure Lua, testable with luajit.

local history = {}

history.MAX = 50

local NAMES = { easy = "Easy", medium = "Medium", hard = "Hard", expert = "Expert", master = "Master" }
local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

-- Before this the clock was never set, so the date means nothing.
local EARLIEST_YEAR = 2025

function history.add(list, entry)
    table.insert(list, 1, entry)
    while #list > history.MAX do table.remove(list) end
    return list
end

-- Keeps only well-formed entries from a saved list.
function history.clean(saved)
    local out = {}
    if type(saved) ~= "table" then return out end
    for _, e in ipairs(saved) do
        if type(e) == "table" and tonumber(e.at) and tonumber(e.time)
            and (e.kind == "puzzle" or e.kind == "daily" or e.kind == "pack") then
            out[#out + 1] = {
                at = tonumber(e.at), kind = e.kind, time = tonumber(e.time),
                difficulty = NAMES[e.difficulty] and e.difficulty or nil,
                pack = type(e.pack) == "string" and e.pack or nil,
                index = tonumber(e.index),
                hints = tonumber(e.hints) or 0, mistakes = tonumber(e.mistakes) or 0,
            }
            if #out >= history.MAX then break end
        end
    end
    return out
end

-- "Hard", "Daily, Expert", "Starter pack #12"
function history.label(e)
    local level = NAMES[e.difficulty] or ""
    if e.kind == "daily" then return "Daily, " .. level end
    if e.kind == "pack" then return (e.pack or "Pack") .. " #" .. (e.index or "?") end
    return level
end

-- "Perfect", "2 hints", "1 mistake, 1 hint"
function history.note(e)
    if e.hints == 0 and e.mistakes == 0 then return "Perfect" end
    local parts = {}
    if e.mistakes > 0 then parts[#parts + 1] = e.mistakes == 1 and "1 mistake" or (e.mistakes .. " mistakes") end
    if e.hints > 0 then parts[#parts + 1] = e.hints == 1 and "1 hint" or (e.hints .. " hints") end
    return table.concat(parts, ", ")
end

-- "Today 14:03", "Yesterday 09:12", "28 Oct 21:40", or "" with an unset clock.
-- `now` is for tests.
function history.when(at, now)
    local t = os.date("*t", at)
    if t.year < EARLIEST_YEAR then return "" end
    local clock = string.format("%02d:%02d", t.hour, t.min)
    local today = os.date("*t", now or os.time())
    local function sameDay(a, b) return a.year == b.year and a.month == b.month and a.day == b.day end
    if sameDay(t, today) then return "Today " .. clock end
    local noon = os.time({ year = today.year, month = today.month, day = today.day, hour = 12 })
    if sameDay(t, os.date("*t", noon - 86400)) then return "Yesterday " .. clock end
    return t.day .. " " .. MONTHS[t.month] .. " " .. clock
end

return history
