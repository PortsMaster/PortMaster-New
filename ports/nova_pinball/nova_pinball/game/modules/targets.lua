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

-- Manages stationary targets.
-- Call switchOn(tag) to toggle a target.
-- Hook into the onSwitch(tag) callback to get notifications.
-- Hook into onComplete() to get notified when the entire word is on.
-- The targets reset when all of them are on.

local manager = { }
manager.items = nil
manager.flashingEnabled = true

function manager:new()
    local function deepcopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key)] = deepcopy(orig_value)
            end
            setmetatable(copy, deepcopy(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end
    
    local newManager = deepcopy(self)
    newManager.items = {}
    return newManager
end

-- Creates and returns a new target object
function manager.newTarget()
    local target = {x=0, y=0, timer=0, flashing=false, flashMode=0}
    function target:setOffImage(filename)
        self.offSprite = loadSprite(filename)
        self.sprite = self.offSprite   -- default the displaying sprite
    end
    function target:setOnImage(filename)
        self.onSprite = loadSprite(filename)
    end
    function target:setFlashImage(filename)
        self.flashSprite = loadSprite(filename)
    end
    function target:addToGroup(groupName)
        self.group = groupName
    end
    return target
end

function manager:add(tag)
    if (not self.items) then
        print("Cannot add targets to the module directly. Use :new() to obtain an instance to use instead.")
        return
    end
    local newTarget = self.newTarget()
    newTarget.tag = tag
    self.items[tag] = newTarget
    return newTarget
end

function manager:get(tag)
    return self.items[tag]
end

function manager:draw()
    for _, v in pairs(self.items) do
        if (v.sprite) then
            love.graphics.draw(v.sprite.image, v.x, v.y, 0, 1, 1, v.sprite.ox, v.sprite.oy)
        end
    end
end

function manager:switchOn(tag)
    if (self.items[tag]) then
        if (not self.items[tag].on) then
            self.items[tag].on = true
            self.items[tag].sprite = self.items[tag].onSprite
            self.onSwitch(tag)
            self:testStatus()
        end
    end
end

-- Turn on flashing mode for a target, or a group of targets. nil always flashes.
function manager:flash(tag)
    for _, target in pairs(self.items) do
        if (target.tag == tag or target.group == tag or tag == nil) then
            target.flashing = true
        end
    end
end

-- Reset flashing status of all targets
function manager:clearFlashing()
    for _, target in pairs(self.items) do
        target.flashing = false
        if (not target.on) then target.sprite = target.offSprite end
    end
end

function manager:testStatus()
    for _, v in pairs(self.items) do
        if (not v.on) then return false end
    end
    self.onComplete()
    self:reset()
end

function manager.onSwitch(tag)

end

function manager.onComplete()

end

function manager:reset()
    self:clearFlashing()
    for _, v in pairs(self.items) do
        v.on = false
        v.flashing = false
        v.sprite = v.offSprite
    end
end

function manager:update(dt)
    -- Do not flash if the manager is disabled
    if (not self.flashingEnabled) then return end
    -- Flash off targets
    for _, target in pairs(self.items) do
        -- Do not bother updating on targets, they do not need to flash for attention.
        if (not target.on and target.flashing) then
            target.timer = target.timer - dt
            if (target.timer < 0) then
                target.timer = 0.5
                -- Flip-flop between showing and hiding the flash image
                if (target.flashMode == 0) then
                    target.flashMode = 1
                    target.sprite = target.flashSprite
                else
                    target.flashMode = 0
                    target.sprite = target.offSprite
                end
            end
        end
    end
end

return manager
