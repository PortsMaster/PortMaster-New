function printMatrix(matrix)
    print(matrix[1]..","..matrix[2]..","..matrix[3]..","..matrix[4])
    print(matrix[5]..","..matrix[6]..","..matrix[7]..","..matrix[8])
    print(matrix[9]..","..matrix[10]..","..matrix[11]..","..matrix[12])
    print(matrix[13]..","..matrix[14]..","..matrix[15]..","..matrix[16])
end

function binarySearch(array, valueToFind)
    -- https://github.com/rozenmad/Menori/blob/dev/menori/modules/libs/utils.lua
    local left = 1
    local right = #array

    while right >= left do
        local mid = math.floor((left + right) / 2)
        if array[mid] < valueToFind then
            left = mid + 1
        elseif array[mid] > valueToFind then
            right = mid - 1
        else
            return mid
        end
    end

    return array[left] == valueToFind and left or left-1
end

function lerpVector(v1, v2, t)
    for k = 1,#v1 do
        v1[k] = lerp(v1[k], v2[k], t)
    end
end

function slerpQuaternion(q1, q2, t)
    -- Ensure that t is within the valid range [0, 1]
    t = math.max(0, math.min(1, t))

    local dotProduct = q1[1] * q2[1] + q1[2] * q2[2] + q1[3] * q2[3] + q1[4] * q2[4]

    -- Adjust signs if necessary to ensure the shortest path
    if dotProduct < 0 then
        q2[1] = -q2[1]
        q2[2] = -q2[2]
        q2[3] = -q2[3]
        q2[4] = -q2[4]
        dotProduct = -dotProduct
    end
    
    if dotProduct > 0.99 then
        -- quaternions are basically aligned. Just do linear interpolation
        lerpVector(q1, q2, t)
        return
    end

    -- Interpolate
    local theta = math.acos(dotProduct)
    local sinTheta = math.sin(theta)

    local weight1 = math.sin((1 - t) * theta) / sinTheta
    local weight2 = math.sin(t * theta) / sinTheta

    q1[1] = weight1 * q1[1] + weight2 * q2[1]
    q1[2] = weight1 * q1[2] + weight2 * q2[2]
    q1[3] = weight1 * q1[3] + weight2 * q2[3]
    q1[4] = weight1 * q1[4] + weight2 * q2[4]
end

function normalize3D(x,y,z)
    local dist = math.sqrt(x^2 + y^2 + z^2)
    return x/dist, y/dist, z/dist
end

function dot3D(x1,y1,z1,x2,y2,z2)
    return x1*x2 + y1*y2 + z1*z2
end

function cross3D(x1,y1,z1,x2,y2,z2)
    return
        y1*z2 - z1*y2,
        z1*x2 - x1*z2,
        x1*y2 - y1*x2
end

function clampVecToLength3D(x,y,z,targetLength)
    local magnitude = math.sqrt(x^2 + y^2 + z^2)
    x = x / magnitude
    y = y / magnitude
    z = z / magnitude
    if x ~= x then
        print("nan detected")
        x = 0
    end
    if y ~= y then
        print("nan detected")
        y = 0
    end
    if z ~= z then
        print("nan detected")
        z = 0
    end
    return x*targetLength, y*targetLength, z*targetLength
end

function clampVecToLength(x, y, targetLength)
    local magnitude = math.sqrt(x^2 + y^2)
    x = x / magnitude
    y = y / magnitude
    if x ~= x then
        print("nan detected")
        x = 0
    end
    if y ~= y then
        print("nan detected")
        y = 0
    end
    return x*targetLength, y*targetLength
end

function randomBetween(r1, r2)
    return r1 + math.random() * (r2 - r1)
end

function randomWithinCircle(radius)
    local randRadius = math.random()*radius
    local x = randRadius * math.cos(math.random()*2*math.pi)
    local y = randRadius * math.sin(math.random()*2*math.pi)
    return x, y
end

function roundTo(num, dec)
    local mult = 10^(dec or 0)
    return math.floor(num * mult + 0.5) / mult
end

function squareDistance(v1, v2)
    return (v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2
end

function squareDistance2(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

function squareDistance3D(x1, y1, z1, x2, y2, z2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2
end

function lerp(startValue, targetValue, t)
    return startValue + (targetValue - startValue) * t
end

function lerpAngle(startAngle, targetAngle, t)
    dAngle = wrap(0, targetAngle - startAngle, 360)
    if dAngle > 180 then
        dAngle = dAngle - 360
    end
    return startAngle + dAngle * t
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function cosd(degVal)
    return math.cos(math.rad(degVal))
end

function sind(degVal)
    return math.sin(math.rad(degVal))
end

function sign(val)
    if val > 0 then
        return 1
    elseif val < 0 then
        return -1
    else
        return 0
    end
end

function wrap(min, val, max)
    if val < min then
        return max - (min - val)
    elseif val > max then
        return min + (val - max)
    end
    return val
end

function magnitude(x, y, z)
    return math.sqrt(squareMagnitude(x,y,z))
end

function squareMagnitude(x, y, z)
    return x^2 + y^2 + z^2
end

function rotateVec(x, y, angle, clockwise)
    local angleRad = math.rad(angle) * (clockwise and 1 or -1)
    local rx = x * math.cos(angleRad) - y * math.sin(angleRad);
    local ry = x * math.sin(angleRad) + y * math.cos(angleRad);
    return rx, ry
end

function hex2rgb(hex)
    local color = {}
    for k = 1,3 do
        color[k] = tonumber("0x"..string.sub(hex, k*2,k*2+1))/255
    end
    color[4] = 1
    return color
end

-- stolen from stackoverflow
-- https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end