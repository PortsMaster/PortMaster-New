cursortrail = require 'objects/cursortrail'

local cursortrail_array = {}

function cursortrail_array:draw()
	for i = 1, #cursortrail_array do
		cursortrail_array[i]:draw()
	end
end

function cursortrail_array:update(dt, posX, posY, levelIndex)
	table.insert(cursortrail_array, cursortrail:new(posX, posY))
	for i = #cursortrail_array, 1, -1 do
		cursortrail_array[i]:update(dt)
		if cursortrail_array[i].size <= 0 then
			table.remove(cursortrail_array, i)
		end
	end
end

return cursortrail_array
