---@diagnostic disable: lowercase-global
-- /math related
math.clamp      = lume.clamp
math.round      = lume.round
math.sign       = lume.sign
math.lerp       = lume.lerp
math.smooth     = lume.smooth
math.pingpong   = lume.pingpong
math.distance   = lume.distance
math.angle      = lume.angle
math.vector     = lume.vector
math.uuid       = lume.uuid

math.randomFloat = function (lower, greater)
    return lower + math.random()  * (greater - lower);
end

-- replacing some math functions with love.math versions.
for key, value in pairs(love.math) do
    math[key] = value
end

-- /table related
table.random         = lume.randomchoice
table.weightedchoice = lume.weightedchoice
table.isArray        = lume.isarray
table.push           = lume.push
table.delete         = lume.remove
table.clear          = lume.clear
table.extend         = lume.extend
table.shuffle        = lume.shuffle
table.each           = lume.each
table.map            = lume.map
table.all            = lume.all
table.any            = lume.any
table.reduce         = lume.reduce
table.unique         = lume.unique
table.filter         = lume.filter
table.reject         = lume.reject
table.merge          = lume.merge
table.concatarray    = lume.concat
table.find           = lume.find
table.match          = lume.match
table.count          = lume.count
table.slice          = lume.slice
table.first          = lume.first
table.last           = lume.last
table.invert         = lume.invert
table.pick           = lume.pick
table.keys           = lume.keys
table.clone          = lume.clone
table.serialize      = lume.serialize
table.deserialize    = lume.deserialize

table.isempty = function (t)
    for key, value in pairs(t) do
        return false
    end
    return true
end

table.values = function (t)
    local k = lume.keys(t)
    local r = {}
    for index, value in ipairs(k) do
        r[index] = t[value]
    end
    return r
end

local function deep_print(table, level, shallow)
    local str = '{'
    local pre = level > 0 and string.rep('    ', level) or ''
    local skipComma = true
    for key, value in pairs(table) do
        if not skipComma then
            str = str .. ','
        end
        
        skipComma = false


        str = str .. '\n' .. pre .. "    " .. tostring(key) .. " = "

        if not shallow and type(value) == "table" then
            str = str .. deep_print(value, level + 1)
        else
            if type(value) == 'string' then
                value = '"' .. value .. '"'
            end
            str = str .. tostring(value)
        end
    end

    str = str .. '\n' .. pre .. '}'
    return str
end

table.print = function (t, isShallow)
    print(deep_print(t, 0, isShallow))
end


-- /string related
string.split        = lume.split
string.trim         = lume.trim
string.wordwrap     = lume.wordwrap

function string.replace(str, old_string, new_string)
    return (str:gsub("%" .. old_string, new_string))
end

-- /timer
timer.delay         = tick.delay
timer.recur         = tick.recur
timer.group         = tick.group
-- Note, tick.update should be called at the end of love.update.
timer.endOfFrame    = function (func)
    tick.delay(func, 0)
end

-- /keyboard
keyboard.isPressed   = input.keyPressed
keyboard.isReleased  = input.keyReleased
keyboard.anyDown     = input.anyKey
keyboard.anyPressed  = input.anyKeyPressed
keyboard.anyReleased = input.anyKeyReleased

-- /mouse
mouse.isPressed     = input.mousePressed
mouse.isReleased    = input.mouseReleased
mouse.any           = input.anyMouse
mouse.anyPressed    = input.anyMousePressed
mouse.anyReleased   = input.anyMouseReleased

-- /gamepad
-- TODO

-- /vectors
vector.zero     = function() return vector(0, 0) end
vector.one      = function() return vector(1, 1) end
vector.up       = function() return vector(0, -1) end
vector.down     = function() return vector(0, 1) end
vector.right    = function() return vector(1, 0) end
vector.left     = function() return vector(-1, 0) end

-- /other
ripairs = lume.ripairs --reverse ipairs
