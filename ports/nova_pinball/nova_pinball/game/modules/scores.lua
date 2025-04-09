-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
   
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see http://www.gnu.org/licenses/.

-----------------------------------------------------------------------

-- Written by Wesley "keyboard monkey" Werner 2015
-- https://github.com/wesleywerner/

-- A score tracking and display module

local scores = {}
-- Maximum number of scores to keep
scores.maxScores = 8
-- List of culled scores
scores.culled = {}
-- The top scores
scores.high = {}
-- The newest earned score
scores.newScore = 0
-- The entered initials
scores.initials = ""
-- If the player is entering initials
scores.isTyping = false
-- The index of the new score (if any)
scores.newScoreIndex = nil

function scores:load()
    -- Default scores
    self.scores = {
        {score=9000, initials="AAA", date="03/11/2015"},
        {score=8000, initials="BBB", date="03/11/2015"},
        {score=7000, initials="CCC", date="03/11/2015"},
        {score=6000, initials="DDD", date="03/11/2015"},
        {score=5000, initials="EEE", date="03/11/2015"},
        {score=4000, initials="FFF", date="03/11/2015"},
        {score=3000, initials="GGG", date="03/11/2015"},
        {score=2000, initials="HHH", date="03/11/2015"},
        }
    -- Load scores from file
    local info = love.filesystem.getInfo("scores")
    if info then
        local pickle = require("modules.pickle")
        local rawData, size = love.filesystem.read("scores")
        local data = pickle.unpickle(rawData)
        -- Validate
        if (type(data) == "table") then
            for _, entry in ipairs(data) do
                if (not entry.score) or (not entry.initials) or (not entry.date) then
                    print("The scores file is invalid")
                    return
                end
            end
            self.scores = data
        else
            print("The scores file is invalid")
        end
    end
end

function scores:save()
    local pickle = require("modules.pickle")
    local data = pickle.pickle(self.scores)
    love.filesystem.write("scores", data, data:len())
end

function scores:register(score)
    self.newScoreIndex = nil
    -- Today's date
    local dt = os.date("*t")
    local dateString = string.format("%02d/%02d/%s", dt.day, dt.month, dt.year)
    -- Find the position of this score
    for i, entry in ipairs(self.scores) do
        if (score > entry.score) then
            local newEntry = {score=score, initials="", date=dateString}
            table.insert(self.scores, i, newEntry)
            self.newScoreIndex = i
            break
        end
    end
    -- Or add to the end
    if (not self.newScoreIndex) then
        table.insert(self.scores, {score=score, initials="", date=dateString})
        self.newScoreIndex = #self.scores
    end
    -- Cull the list
    scores.culled = {}
    while (#self.scores > self.maxScores) do
        table.insert(self.culled, table.remove(self.scores))
    end
    -- We did not make it after all :(
    if (self.newScoreIndex > #self.scores) then
        self.newScoreIndex = nil
    end
    
    self.initials = ""
    -- The new score made it on the list
    if (self.newScoreIndex) then self.isTyping = true end
end

function scores:update(dt)

end

function scores:keypressed(key)
    -- Entering Initials
    if (self.isTyping) then
        if (key == "return" or key == "enter") then
            self.isTyping = false
            self:save()
        else
            if (self.initials:len() < 3 and string.find("0123456789abcdefghijklmnopqrstuvwxyz", key)) then
                self.initials = self.initials .. string.upper(key)
            elseif (key == "backspace") then
                self.initials = self.initials:sub(1, self.initials:len() - 1)
            end
            self.scores[scores.newScoreIndex].initials = self.initials
        end
        return true
    end
    
    if (key == "escape" or key == "space" or key == "return" or key == "enter") then
        return false
    end

    return true
end

function scores:draw()
    local y = 50
    for i, entry in ipairs(self.scores) do
        if (i == scores.newScoreIndex) then
            if (self.isTyping) then
                -- Highligh initial being entered
                love.graphics.setColor (0, 1, 1, 1)
            else
                -- Highlight latest score
                love.graphics.setColor (100/256, 1, 100/256, 1)
            end
        else
            -- Normal score
            love.graphics.setColor (1, 1, 1, 1)
        end
        love.graphics.print(entry.initials, 80, y)
        love.graphics.print(scores.formatNumber(entry.score), 200, y)
        love.graphics.print(entry.date, 500, y)
        y = y + 50
    end
    -- Draw culled scores
    y = y + 50
    love.graphics.setColor (1, 100/256, 100/256, 1)
    for i, entry in ipairs(self.culled) do
        love.graphics.print(entry.initials, 80, y)
        love.graphics.print(scores.formatNumber(entry.score), 200, y)
        love.graphics.print(entry.date, 500, y)
        y = y + 60
    end
end

function scores.formatNumber(number)
    local formatted = number
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then break end
    end
    return formatted
end

return scores
