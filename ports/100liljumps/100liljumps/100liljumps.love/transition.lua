require("./lume")

local Object = require("./classic")

Transition = Object.extend(Object)

local TransitionState = {
    FADE_OUT = 0,
    FADE_IN  = 1,
}

TransitionType = {
    LEVEL_CHANGE = 0,
    PLAYER_DIED  = 1,
}

local FADE_DURATION = 0.5 -- in seconds

function Transition.new(self, type)
    self.type = type or TransitionType.LEVEL_CHANGE
    self.step = 0
    self.total_frames = FADE_DURATION*60

    self.state = TransitionState.FADE_OUT
end

function Transition:draw()
    local w, h = love.graphics.getDimensions()

    local alpha = 0
    
    if(self.state == TransitionState.FADE_OUT) then
        alpha = lume.lerp(0, 1, self.step/self.total_frames)
    end
    if(self.state == TransitionState.FADE_IN) then
        alpha = lume.lerp(1, 0, self.step/self.total_frames)
    end

    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1, 1, 1)
end

function Transition:advance_step()
    self.step = self.step + 1
    if(self.step > self.total_frames) then
        if(self.state == TransitionState.FADE_OUT) then
            self:finish_fade_out()
        end
    end
end

function Transition:finish_fade_out()
    self.step = 0
    self.state = TransitionState.FADE_IN
end

function Transition:fade_out_has_finished()
    return self.state == TransitionState.FADE_IN
end

function Transition:is_done()
    return self.state == TransitionState.FADE_IN and self.step > self.total_frames
end
