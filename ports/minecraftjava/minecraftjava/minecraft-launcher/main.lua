local Launcher = require("launcher")

local launcher
local selectedRow = 1
local selectedColumn = 1
local rows = { "Vanilla", "Forge", "Fabric" }

function love.load()
    love.window.setTitle("Minecraft Launcher")
    love.window.setMode(800, 600)

    launcher = Launcher.new()
    launcher:loadVersions()
end

function love.update(dt)
    -- Update logic if needed
end

function love.draw()
    love.graphics.clear(47 / 255, 60 / 255, 126 / 255) -- Backy color
    local startX, startY = 50, 50
    local boxSize = 100
    local boxPadding = 20
    local rowPadding = 50 -- Additional space between rows

    for rowIndex, rowName in ipairs(rows) do
        local rowVersions = launcher:getVersionsByLoader(rowName)
        for colIndex, version in ipairs(rowVersions) do
            local x = startX + (colIndex - 1) * (boxSize + boxPadding)
            local y = startY + (rowIndex - 1) * (boxSize + rowPadding)

            if rowIndex == selectedRow and colIndex == selectedColumn then
                love.graphics.setColor(0.2, 0.6, 1) -- Highlight selected box
            else
                love.graphics.setColor(1, 1, 1) -- Default color
            end
            love.graphics.rectangle("fill", x, y, boxSize, boxSize)
            love.graphics.setColor(0, 0, 0) -- Text color
            love.graphics.printf(version.name, x, y + boxSize / 2 - 10, boxSize, "center")
        end

        -- Draw row labels (e.g., "Vanilla:", "Forge:", "Fabric:") above the row
        love.graphics.setColor(1, 1, 1) -- Label color
        love.graphics.print(
            rowName .. ":", 
            startX - 30, -- Slightly to the left of the first column
            startY + (rowIndex - 1) * (boxSize + rowPadding) - 20 -- Above the row
        )
    end
end

function love.keypressed(key)
    local currentRowVersions = launcher:getVersionsByLoader(rows[selectedRow])

    if key == "right" then
        selectedColumn = math.min(selectedColumn + 1, #currentRowVersions)
     elseif key == "left" then
        selectedColumn = math.max(selectedColumn - 1, 1)
    elseif key == "down" then
        selectedRow = math.min(selectedRow + 1, #rows)
        local newRowVersions = launcher:getVersionsByLoader(rows[selectedRow])
        selectedColumn = math.min(selectedColumn, #newRowVersions) -- Keep column within bounds
    elseif key == "up" then
        selectedRow = math.max(selectedRow - 1, 1)
        local newRowVersions = launcher:getVersionsByLoader(rows[selectedRow])
        selectedColumn = math.min(selectedColumn, #newRowVersions)  -- Keep column within bounds
    elseif key == "return" then
        local selectedVersion = currentRowVersions[selectedColumn]
        if selectedVersion then
            launcher:startVersion(selectedVersion)
        end
    end
end

function love.gamepadpressed(joystick, button)
    local currentRowVersions = launcher:getVersionsByLoader(rows[selectedRow])

    if button == "dpright" then
        selectedColumn = math.min(selectedColumn + 1, #currentRowVersions)
    elseif button == "dpleft" then
        selectedColumn = math.max(selectedColumn - 1, 1)
    elseif button == "dpdown" then
        selectedRow = math.min(selectedRow + 1, #rows)
        local newRowVersions = launcher:getVersionsByLoader(rows[selectedRow])
        selectedColumn = math.min(selectedColumn, #newRowVersions)
    elseif button == "dpup" then
        selectedRow = math.max(selectedRow - 1, 1)
        local newRowVersions = launcher:getVersionsByLoader(rows[selectedRow])
        selectedColumn = math.min(selectedColumn, #newRowVersions)
    elseif button == "a" or button == "start" or button == "1" then
        local selectedVersion = currentRowVersions[selectedColumn]
        if selectedVersion then
            launcher:startVersion(selectedVersion)
        end
    end
end

