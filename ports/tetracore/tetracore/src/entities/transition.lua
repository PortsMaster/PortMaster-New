local signal = require('libs.signal')
local GameConfig = require('src.constants.gameConfig')

local Transition = {
    alpha = 0,
    timer = 0,
    duration = 0.5,
    active = false,
    onComplete = nil,
    startAlpha = 0
}

function Transition.play(duration, onComplete)
    Transition.duration = duration or 0.5
    Transition.onComplete = onComplete
    Transition.timer = 0
    Transition.alpha = 0
    Transition.startAlpha = 0
    Transition.active = true
end

function Transition.fadeIn(duration, onComplete)
    Transition.duration = duration or 0.5
    Transition.onComplete = onComplete
    Transition.timer = 0
    Transition.alpha = 1
    Transition.startAlpha = 1
    Transition.active = true
end

function Transition.update(dt)
    if not Transition.active then return end

    Transition.timer = Transition.timer + dt
    local progress = math.min(Transition.timer / Transition.duration, 1)

    if Transition.startAlpha == 1 then
        Transition.alpha = 1 - progress
    else
        Transition.alpha = progress
    end

    if progress >= 1 then
        Transition.active = false
        signal.emit('Transition_finished')

        if Transition.onComplete then
            Transition.onComplete()
        end
    end
end

function Transition.draw()
    if Transition.alpha <= 0 then return end

    love.graphics.push()
    local r, g, b, a = love.graphics.getColor()
    
    love.graphics.setColor(0, 0, 0, Transition.alpha)
    -- Draw over the full virtual canvas coordinates
    love.graphics.rectangle("fill", 0, 0, GameConfig.VIRTUAL_WIDTH, GameConfig.VIRTUAL_HEIGHT)
    
    love.graphics.setColor(r, g, b, a)
    love.graphics.pop()
end

return Transition
