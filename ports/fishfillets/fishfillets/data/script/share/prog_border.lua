
-- -----------------------------------------------------------------
-- NOTE: uses 'small' and 'big' names for fishes
local function canReport()
    --TODO: don't talk when room is solved
    return no_dialog() and small:isAlive() and big:isAlive()
end
-- -----------------------------------------------------------------
local wereAtBorder = {}
local function markAtBorder(unit, value)
    wereAtBorder[unit] = value
end
local function wasAtBorder(unit)
    return wereAtBorder[unit]
end
-- -----------------------------------------------------------------
-- NOTE: uses 'small' and 'big' names for fishes
local function selectMessage(unit, n)
    if unit == small then
        addm(0, 'cil-m-hlaska'..n)
    elseif unit == big then
        addv(0, 'cil-v-hlaska'..n)
    end
end
-- -----------------------------------------------------------------
local reportLimit = 1
local reportRate = 0
local lastMessage = random(4)
local function reportBorder(unit)
    local result = false
    reportRate = reportRate + 1
    if reportRate == reportLimit then
        reportLimit = reportLimit + 1
        reportRate = random(reportLimit)
        local message = random(3)
        if message == lastMessage then
            message = 3
        end
        lastMessage = message
        selectMessage(unit, message)
        result = true
    end
    return result
end

-- -----------------------------------------------------------------
local loaded = false
function stdBorderReportLoad()
    if not loaded then
        loaded = true
        dialogLoad("script/share/border_", "sound/share/border/")
    end
end
-- -----------------------------------------------------------------
function stdBorderReport()
    stdBorderReportLoad()
    local reported = false
    local oneTry = true
    if canReport() then
        for index, unit in pairs(getUnitTable()) do
            if unit:isAtBorder() then
                if oneTry and not wasAtBorder(unit) then
                    oneTry = false
                    reported = reportBorder(unit)
                end
                markAtBorder(unit, true)
            else
                markAtBorder(unit, false)
            end
        end
    end
    return reported
end

