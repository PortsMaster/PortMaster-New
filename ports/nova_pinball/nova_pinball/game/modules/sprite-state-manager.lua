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

-- This module manages sprite states linked to missions

local manager = {}
manager.items = {}

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
    
    local t = deepcopy(self)
    t.items = {}
    return t
end

function manager:add(key, sprite)
    local o = {}
    o.sprite = sprite
    o.visible = true
    o.scaleIncrement = nil
    o.angleIncrement = nil
    o.key = key
    o.blendmode = "alpha"   -- Default blend mode
    function o:setRotation(angle)
        self.angleIncrement = angle
        return self
    end
    function o:setScale(scale)
        self.sprite.scale = scale
        self.visible = scale > 0
        return self
    end
    function o:scale(scale)
        self.scaleIncrement = scale
        return self
    end
    function o:setVisible(visible)
        self.visible = visible
        return self
    end
    function o:setBlendmode(mode)
        self.blendmode = mode
        return self
    end
    table.insert(self.items, o)
    return o
end

function manager:item(key)
    for _, v in pairs(self.items) do
        if (v.key == key) then return v end
    end
    print(string.format("sprite manager could not find the item with key %q", key))
end

function manager:update(dt)
    for k, v in pairs(self.items) do
        -- only update visible
        if (v.visible) then
            -- auto scale sprites towards "1"
            if (v.scaleIncrement) then
                v.sprite.scale = v.sprite.scale + (v.scaleIncrement*dt)
                -- Auto stop scaling
                if (v.sprite.scale >= 1 and v.scaleIncrement > 0) then
                    v.sprite.scale = 1
                    v.scaleIncrement = nil
                elseif (v.sprite.scale <= 0 and v.scaleIncrement < 0) then
                    v.sprite.scale = 0
                    v.scaleIncrement = nil
                    -- Stop drawing sprites at zero scale
                    v.visible = false
                end
            end
            if (v.angleIncrement) then
                v.sprite.angle = v.sprite.angle + (v.angleIncrement*dt)
            end
        end
    end
end

function manager:draw()
    for k, v in pairs(self.items) do
        -- only draw visible
        if (v.visible) then
            love.graphics.setBlendMode(v.blendmode)
            v.sprite:draw()
            love.graphics.setBlendMode("alpha")
        end
    end
end

return manager
