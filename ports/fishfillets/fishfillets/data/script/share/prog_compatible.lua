-- -----------------------------------------------------------------
-- There are functions used in levels to raise dialogs and animation
-- -----------------------------------------------------------------

file_include("script/share/prog_goanim.lua")
file_include("script/share/prog_finder.lua")

-- -----------------------------------------------------------------
-- Compatibility functions
-- -----------------------------------------------------------------
function no_dialog()
    return not dialog_isDialog() and not game_isPlanning()
end

function isReady(model)
    -- fish is ready for dialog
    return model:isAlive() and not model:isOut()
end

function odd(number)
    return math.mod(number, 2) == 1
end

function getRestartCount()
    return level_getRestartCounter()
end

-- -----------------------------------------------------------------
-- Planning
-- -----------------------------------------------------------------
function addm(time, text)
    small:planDialog(time, text)
end
function addv(time, text)
    big:planDialog(time, text)
end
function adddel(time)
    -- plan delay
    planTimeAction(time, function() end)
end

function planSet(model, variable_name, value)
    -- plan value set, variable_name must be string
    planTimeAction(0, function() model[variable_name] = value end)
end
function planDialogSet(time, text, value, model, variable_name)
    -- plan value set, and unset after dialog end
    model:planDialog(time, text, function() model[variable_name] = value end)
    planTimeAction(0, function() model[variable_name] = 0 end)
end

function planBusy(model, value, delay)
    if delay == nil then
        delay = 0
    end
    planTimeAction(delay, function()
            model:setBusy(value)
        end)
end

-- -----------------------------------------------------------------
-- Distance measuring
-- -----------------------------------------------------------------
function xdist(one, second)
    local result = 0
    local one_min = one.X
    local one_max = one.X + one:getW() - 1
    local second_min = second.X
    local second_max = second.X + second:getW() - 1
    if one_max < second_min then
        result = one_max - second_min
    elseif second_max < one_min then
        result = one_min - second_max
    else
        result = 0
    end
    return result
end
function ydist(one, second)
    local result = 0
    local one_min = one.Y
    local one_max = one.Y + one:getH() - 1
    local second_min = second.Y
    local second_max = second.Y + second:getH() - 1
    if one_max < second_min then
        result = one_max - second_min
    elseif second_max < one_min then
        result = one_min - second_max
    else
        result = 0
    end
    return result
end
function dist(one, second)
    local dx = math.abs(xdist(one, second))
    local dy = math.abs(ydist(one, second))
    return math.max(dx, dy)
end

function look_at(fish, object)
    local dx = xdist(fish, object)
    return (fish:isLeft() and dx > 0) or (not fish:isLeft() and dx < 0)
end

-- -----------------------------------------------------------------
-- Alternative for FArray
-- -----------------------------------------------------------------
function modelEquals(model, x, y)
    -- Compares this model and model on [x,y] position
    -- index -1 is for empty space (water)
    return model_equals(model.index, x, y)
end

function isWater(x, y)
    -- Compares model on [x,y] position
    return model_equals(-1, x, y)
end

