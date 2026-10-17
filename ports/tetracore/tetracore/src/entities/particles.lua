local parts = {}
parts.current = {}

function parts.addBurst(x, y, count, color)
    count = count or 10
    color = color or {1, 1, 1}

    for i = 1, count do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(150, 300)
        local totalLife = love.math.random(0.3, 0.5)

        table.insert(parts.current, {
            startX = x,
            startY = y,
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = totalLife,
            maxLife = totalLife,
            radius = 2,
            color = color
        })
    end
end

function parts.spawn(x, y, ringsCleared)
    ringsCleared = math.max(1, ringsCleared or 1)

    local count = 10 + (ringsCleared * 10)
    local speedMult = 1 + ((ringsCleared - 1) * 0.45)

    for i = 1, count do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(100, 250) * speedMult
        local totalLife = love.math.random(0.7, 0.7)

        table.insert(parts.current, {
            startX = x,
            startY = y,
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = totalLife,
            maxLife = totalLife,
            radius = 2 + ringsCleared
        })
    end
end

function parts.update(dt)
    for i = #parts.current, 1, -1 do
        local p = parts.current[i]

        local lifeRatio = p.life / p.maxLife

        if lifeRatio > 0.5 then
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.vy = p.vy + 200 * dt
        else
            local dx = p.startX - p.x
            local dy = p.startY - p.y

            local pullStrength = 18.0 * dt
            p.vx = p.vx + dx * pullStrength
            p.vy = p.vy + dy * pullStrength

            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > 1 then
                local nx, ny = dx / dist, dy / dist
                local swirlSpeed = 500
                p.vx = p.vx - ny * swirlSpeed * dt
                p.vy = p.vy + nx * swirlSpeed * dt
            end

            p.vx = p.vx * (1 - 1.5 * dt)
            p.vy = p.vy * (1 - 1.5 * dt)

            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
        end

        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(parts.current, i)
        end
    end
end

function parts.draw()
    for _, p in ipairs(parts.current) do
        local alpha = math.min(1, (p.life / p.maxLife) * 2)
        local color = p.color or {1, 1, 1}
        love.graphics.setColor(color[1], color[2], color[3], alpha)
        love.graphics.rectangle("fill", p.x - p.radius/2, p.y - p.radius/2, p.radius, p.radius)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return parts
