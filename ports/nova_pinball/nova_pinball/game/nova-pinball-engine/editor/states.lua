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
states.flags = { }
states.current = nil

states.editor = {
    ["timeout"] = nil,
    ["timer"] = nil,
    ["next"] = nil
    }

states.loading = {
    ["timeout"] = 1,
    ["timer"] = 0,
    ["next"] = states.editor
    }

states.startup = {
    ["timeout"] = 1,
    ["timer"] = 0,
    ["next"] = states.loading
    }

function states:new (n)
    self.current = n
    self.current.timer = 0
end

function states:update (dt)
    if (self.current.timeout) then
        self.current.timer = self.current.timer + dt
        if (self.current.timer > self.current.timeout) then
            if (self.current.next ~= nil) then
                self:new (self.current.next)
            end
        end
    end
end

return states
