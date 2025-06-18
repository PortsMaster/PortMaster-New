module("jlib", package.seeall)

function randomItem(list)
    return list[math.random(1, #list)]
end

function map(list, f)
    local result = {}
    for i, v in ipairs(list) do result[i] = f(v) end
    return result
end

-- Parses command line options into a table. For example, {"--width", "600"}
-- would result into a {["width"] = "600"} table. The result is then stored in
-- the PersistenceManager.
function parseOptions()
    local scriptManager = jvgslua.ScriptManager_getInstance()
    local persistenceManager = jvgslua.PersistenceManager_getInstance()

    local i = 0
    local options = {}
    while i + 1 < scriptManager:getNumberOfArguments() do
        local argument = scriptManager:getArgument(i)
        if string.find(argument, "^--%a+$") then
            local key = string.sub(argument, 3)
            local value = scriptManager:getArgument(i + 1)
            options[key] = value
            i = i + 2
        else
            i = i + 1
        end
    end

    for key, value in pairs(options) do
        persistenceManager:set(key, value)
    end
end
