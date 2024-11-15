
-- -----------------------------------------------------------------
-- Random numbers
-- -----------------------------------------------------------------
function random(limit)
    -- return number from [0, limit)
    if limit <= 0 then
        return 0
    else
        return math.random(limit) - 1
    end
end
-- -----------------------------------------------------------------
function randint(start, max)
    -- return number from [start, max]
    if start >= max then
        return start
    else
        return math.random(start, max)
    end
end

-- -----------------------------------------------------------------
-- Switch statement for lua
-- -----------------------------------------------------------------
function switch(case)
  return function(codetable)
           local f = codetable[case] or codetable.default
           if f then
             if type(f) == "function" then
               return f(case)
             else
               error("case '"..tostring(case).."' is not a function")
             end
           end
         end
end

-- -----------------------------------------------------------------
-- Manipulation with tables
-- -----------------------------------------------------------------
function createArray(size)
    local array = {}
    for i = 0, size - 1 do
        array[i] = 0
    end
    return array
end

function isIn(item, table)
    for index, value in pairs(table) do
        if value == item then
            return true
        end
    end
    return false
end

function isRange(value, min, max)
    return min <= value and value <= max
end

function countPairs(table)
    local count = 0
    for index, value in pairs(table) do
        count = count + 1
    end
    return count
end

-- -----------------------------------------------------------------
-- Planning functions
-- -----------------------------------------------------------------
local function isTime(delay, count)
    return count >= delay
end

function planTimeAction(delay, action)
    local waitTime = 0
    game_planAction(function(count)
            local done = false
            if dialog_isDialog() then
                waitTime = count
            elseif isTime(delay + waitTime, count) then
                action()
                done = true
            end
            return done
        end)
end

function planDialog(actor_index, delay, dialog, action)
    planTimeAction(delay, function()
            model_talk(actor_index, dialog, 100, 0, true)
            if nil ~= action then
            action()
            end
        end)
end

-- -----------------------------------------------------------------
-- Options
-- -----------------------------------------------------------------
function optionsGetParam(paramName)
    return options_getParam(paramName)
end
function optionsGetAsInt(paramName)
    local value = tonumber(options_getParam(paramName))
    if nil == value then
        value = 0
    end
    return value
end

