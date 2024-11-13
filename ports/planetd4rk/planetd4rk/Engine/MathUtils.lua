function clampVecToLength(x, y, targetLength)
    local magnitude = math.sqrt(x^2 + y^2)
    x = x / magnitude
    y = y / magnitude
    return {x=x*targetLength, y=y*targetLength}
end

function interpolateBetween(from, to, fraction)
    return from + (to - from) * fraction
end

function randomBetween(r1, r2)
    return r1 + math.random() * (r2 - r1)
end

function roundTo(num, dec)
    local mult = 10^(dec or 0)
    return math.floor(num * mult + 0.5) / mult
end

function squareDistance(v1, v2)
    return (v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2
end

function lerp(v1, v2, dt)
    return v1 + (v2 - v1) * dt
end