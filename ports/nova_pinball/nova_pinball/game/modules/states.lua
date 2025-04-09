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

-- A simple state machine that allows chaining of states with timed delays.
-- Written by Wesley "keyboard monkey" Werner 2015

local states = { }
states.all = {}
states.current = nil

function states:add(name, timeout, nextstate)
    local s = {name=name, timeout=timeout, nextstate=nextstate, timer=0}
    table.insert(self.all, s)
end

function states:new()
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
    
    local s = deepcopy(self)
    s.current = nil
    s.all = {}
    return s
end

function states:set(state)
    self.current = state
end

function states:on(value)
    return self.current == value
end

function states:update(dt)
    local current = self.all[self.current]
    if (current and current.timeout) then
        current.timer = current.timer + dt
        if (current.timer > current.timeout) then
            if (current.nextstate ~= nil) then
                self:set(current.nextstate)
            end
        end
    end
end

return states
