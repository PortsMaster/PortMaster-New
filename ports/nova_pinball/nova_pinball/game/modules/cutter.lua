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

local cutter = {}

-- Cut the screen by giving width and height ratios (0.5 halves)
-- and centers the result inside the parent container.
-- Returns the result as a new container 
--      {x, y, width, height, center {x, y}}.
-- Alignment can be:
--  left, right, top, bottom, top left, top right, bottom left, bottom right
function cutter.cut(width, height, alignment, container)
    
    local X, Y = 0, 0
    local W, H = love.graphics.getDimensions()
    
    if (container and container.width and container.height) then
        X = container.x
        Y = container.y
        W = container.width
        H = container.height
    end
    
    local rect = {x=0, y=0, width=W*width, height=H*height}
    
    rect.x = (W - rect.width) / 2
    rect.y = (H - rect.height) / 2
    
    if alignment == "left" then
        rect.x = 0
    elseif alignment == "right" then
        rect.x = W - rect.width
    elseif alignment == "top" then
        rect.y = 0
    elseif alignment == "bottom" then
        rect.y = H - rect.height
    elseif alignment == "top left" then
        rect.x = 0
        rect.y = 0
    elseif alignment == "top right" then
        rect.x = W - rect.width
        rect.y = 0
    elseif alignment == "bottom left" then
        rect.x = 0
        rect.y = H - rect.height
    elseif alignment == "bottom right" then
        rect.x = W - rect.width
        rect.y = H - rect.height
    end
    
    -- Apply the parent container position
    rect.x = rect.x + X
    rect.y = rect.y + Y
    
    -- Store the center of the resulting container
    rect.center = {x=rect.width/2 + rect.x, y=rect.height/2 + rect.y}
    
    return rect

end

function cutter.test()
    local fakeScreen = {x=0, y=0, width=800, height=600}
    local test = nil
    
    -- Center align (default)
    test = cutter.cut(0.5, 0.5, nil, fakeScreen)
    assert(test.x == 200, "cutter x test failed")
    assert(test.y == 150, "cutter y test failed")
    assert(test.width == 400, "cutter width test failed")
    assert(test.height == 300, "cutter height test failed")
    assert(test.center.x == 400, "cutter center x failed")
    assert(test.center.y == 300, "cutter center y failed")
    
    -- Left align
    test = cutter.cut(0.5, 0.5, "left", fakeScreen)
    assert(test.x == 0, "cutter x test failed")
    assert(test.y == 150, "cutter y test failed")
    assert(test.width == 400, "cutter width test failed")
    assert(test.height == 300, "cutter height test failed")
    assert(test.center.x == 200, "cutter center x failed")
    assert(test.center.y == 300, "cutter center y failed")

    -- Right align
    test = cutter.cut(0.5, 0.5, "right", fakeScreen)
    assert(test.x == 400, "cutter x test failed")
    assert(test.y == 150, "cutter y test failed")
    assert(test.width == 400, "cutter width test failed")
    assert(test.height == 300, "cutter height test failed")
    assert(test.center.x == 600, "cutter center x failed")
    assert(test.center.y == 300, "cuttter center y failed")

    -- Top align
    test = cutter.cut(0.5, 0.5, "top", fakeScreen)
    assert(test.x == 200, "cutter x test failed")
    assert(test.y == 0, "cutter y test failed")
    assert(test.width == 400, "cutter width test failed")
    assert(test.height == 300, "cutter height test failed")
    assert(test.center.x == 400, "cutter center x failed")
    assert(test.center.y == 150, "cuttter center y failed")

    -- Bottom align
    test = cutter.cut(0.5, 0.5, "bottom", fakeScreen)
    assert(test.x == 200, "cutter x test failed")
    assert(test.y == 300, "cutter y test failed")
    assert(test.width == 400, "cutter width test failed")
    assert(test.height == 300, "cutter height test failed")
    assert(test.center.x == 400, "cutter center x failed")
    assert(test.center.y == 450, "cuttter center y failed")

    -- Top left
    test = cutter.cut(0.5, 0.5, "top left", fakeScreen)
    assert(test.x == 0, "cutter x test failed")
    assert(test.y == 0, "cutter y test failed")
    assert(test.width == 400, "cutter width test failed")
    assert(test.height == 300, "cutter height test failed")
    assert(test.center.x == 200, "cutter center x failed")
    assert(test.center.y == 150, "cuttter center y failed")

    -- Top right
    test = cutter.cut(0.5, 0.5, "top right", fakeScreen)
    assert(test.x == 400, "cutter x test failed")
    assert(test.y == 0, "cutter y test failed")
    assert(test.width == 400, "cutter width test failed")
    assert(test.height == 300, "cutter height test failed")
    assert(test.center.x == 600, "cutter center x failed")
    assert(test.center.y == 150, "cuttter center y failed")

    -- Bottom left
    test = cutter.cut(0.5, 0.5, "bottom left", fakeScreen)
    assert(test.x == 0, "cutter x test failed")
    assert(test.y == 300, "cutter y test failed")
    assert(test.width == 400, "cutter width test failed")
    assert(test.height == 300, "cutter height test failed")
    assert(test.center.x == 200, "cutter center x failed")
    assert(test.center.y == 450, "cuttter center y failed")

    -- Bottom right
    test = cutter.cut(0.5, 0.5, "bottom right", fakeScreen)
    assert(test.x == 400, "cutter x test failed")
    assert(test.y == 300, "cutter y test failed")
    assert(test.width == 400, "cutter width test failed")
    assert(test.height == 300, "cutter height test failed")
    assert(test.center.x == 600, "cutter center x failed")
    assert(test.center.y == 450, "cuttter center y failed")

    -- Test cutting from sub-sections
    test = cutter.cut(0.5, 0.5, nil, fakeScreen)
    -- {x=200, y=150, width=400, height=300}
    test = cutter.cut(0.5, 0.5, nil, test)
    -- {x=100, y=75, width=200, height=150}    
    assert(test.x == 300, "cutter x test failed")
    assert(test.y == 225, "cutter y test failed")
    assert(test.width == 200, "cutter width test failed")
    assert(test.height == 150, "cutter height test failed")
    assert(test.center.x == 400, "cutter center x failed")
    assert(test.center.y == 300, "cuttter center y failed")

end

return cutter