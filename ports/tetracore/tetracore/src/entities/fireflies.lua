local fireflies = {}
local GameConfig = require "src.constants.gameConfig"

fireflies.current = {}
fireflies.maxCount = 80
fireflies.spawnTimer = 0
fireflies.spawnRate = 0.03

local function getSpeedMultiplierForLevel(level)
    level = math.max(1, math.min(10, level or 1))
    local progress = (level - 1) / 9

    local minSpeed = 1.0
    local maxSpeed = 2.5

    return minSpeed + (maxSpeed - minSpeed) * progress
end

local function spawnFirefly()
    local cx = GameConfig.VIRTUAL_WIDTH / 2
    local cy = GameConfig.VIRTUAL_HEIGHT / 2

    local minRadius = math.min(cx, cy) * 0.8
    local maxRadius = math.max(cx, cy) * 1.2
    local spawnDist = math.random() * (maxRadius - minRadius) + minRadius
    local angle = math.random() * 2 * math.pi

    local x = cx + math.cos(angle) * spawnDist
    local y = cy + math.sin(angle) * spawnDist

    local lifeMax = 3.0 + math.random() * 2.0

    return {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        life = lifeMax,
        lifeMax = lifeMax,
        phase = math.random() * 2 * math.pi,
        wobbleOffset = math.random() * 100,
    }
end

function fireflies.init()
    fireflies.current = {}
    fireflies.spawnTimer = 0
    for i = 1, fireflies.maxCount do
        local f = spawnFirefly()
        f.life = math.random() * f.lifeMax
        fireflies.current[#fireflies.current + 1] = f
    end
end

function fireflies.update(dt, level)
    local cx = GameConfig.VIRTUAL_WIDTH / 2
    local cy = GameConfig.VIRTUAL_HEIGHT / 2

    local speedMultiplier = getSpeedMultiplierForLevel(level)

    fireflies.spawnTimer = fireflies.spawnTimer + dt
    if fireflies.spawnTimer >= fireflies.spawnRate then
        fireflies.spawnTimer = fireflies.spawnTimer - fireflies.spawnRate
        if #fireflies.current < fireflies.maxCount then
            table.insert(fireflies.current, spawnFirefly())
        end
    end

    for i = #fireflies.current, 1, -1 do
        local f = fireflies.current[i]

        f.life = f.life - dt

        local dx = cx - f.x
        local dy = cy - f.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if f.life <= 0 or dist < 12 then
            table.remove(fireflies.current, i)
        else
            local nx = dx / dist
            local ny = dy / dist

            local tx = -ny
            local ty = nx

            local inwardSpeed = 80 * speedMultiplier
            local swirlSpeed = 140 * speedMultiplier

            f.phase = f.phase + dt * 4 * speedMultiplier
            local wobble = math.sin(f.phase + f.wobbleOffset) * (30 * speedMultiplier)

            f.vx = (nx * inwardSpeed) + (tx * swirlSpeed) + (tx * wobble)
            f.vy = (ny * inwardSpeed) + (ty * swirlSpeed) + (ty * wobble)

            f.x = f.x + f.vx * dt
            f.y = f.y + f.vy * dt
        end
    end
end

function fireflies.draw()
    for _, f in ipairs(fireflies.current) do
        local alpha = math.min(1, f.life / (f.lifeMax * 0.3))

        love.graphics.setColor(1, 1, 0.8, alpha)
        love.graphics.circle("fill", f.x, f.y, 2)
    end
end

return fireflies
