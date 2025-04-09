PI = 3.1415926535

function degrees2radians(degrees)
    return degrees * PI / 180
end

function radians2degrees(radians)
    return radians * 180 / PI
end

function checkCircleCollision(circleCenterPosA, circleCenterPosB, circleRadiusA, circleRadiusB)
    local dist = circleCenterPosA:dist(circleCenterPosB)
    return dist < circleRadiusA + circleRadiusB
end

function tointeger(x)
    num = tonumber(x)
    return num < 0 and math.ceil(num) or math.floor(num)
end

function copyTable(tab)
	function _copy(obj)
		if type(obj) ~= "table" then
			return obj
		end
		local new_table = {}
		for k, v in pairs(obj) do
			new_table[_copy(k)] = _copy(v)
		end
		return setmetatable(new_table, getmetatable(obj))
	end
	return _copy(tab)
end


function generateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end