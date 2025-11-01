require("./animation")
local Object = require("./classic")

Brog = Object.extend(Object)

Brog.State = {
    ["IDLE"]    = 1,
    ["TURNING"] = 2,
    ["CASTING"] = 3,
    ["PUNCHED"] = 4,
    ["FALLING"] = 5,
}

Audio.create_sound("sounds/kick.ogg", "kick", "static", 2, 0.4)

function Brog.new(self, pos)
    self.vel = V2(0, 0)
    self.pos = pos
    self.anchor = V2(pos.x, pos.y)
    self.state = Brog.State.IDLE
    self.direction = 1
    self.width = 30
    self.height = 20

    self.animation = {
        [Brog.State.IDLE] = Animation({
            {filename = "broom-witch-frog-sheet.png", duration = 240}
        }, 1, self.width, self.height),
        [Brog.State.TURNING] = Animation({
            {filename = "broom-witch-rotating-sheet.png", duration = 30}
        }, 1, self.width, self.height),
        [Brog.State.CASTING] = Animation({
            {filename = "brog-spell-sheet.png", duration = 20}
        }, 1, 100, 80),
        [Brog.State.PUNCHED] = Animation({
            {filename = "witch-frog-punched.png", duration = 20}
        }, 1, self.width, self.height),
        [Brog.State.FALLING] = Animation({
            {filename = "witch-frog-falling.png", duration = 20}
        }, 1, self.width, self.height)
    }
end

function Brog:update()
    self:animate()

    if(self.state == Brog.State.IDLE) then
        -- Float

    elseif(self.state == Brog.State.PUNCHED) then
        self:apply_physics()

        if(self.animation[Brog.State.PUNCHED].has_looped) then
            self.state = Brog.State.FALLING
        end

    elseif(self.state == Brog.State.FALLING) then
        self:apply_physics()
        local FALL_LIMIT_HEIGHT = 1000

        if self.pos.y > FALL_LIMIT_HEIGHT then
            game_state.tile_map:remove_brog_if_exists()
        end
    end
end

function Brog:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + self.width, self.pos.y + self.height)
    )
end

function Brog:draw()
    love.graphics.setColor(1, 1, 1)
    self:current_animation():draw(self.pos.x, self.pos.y, self.direction)
end

function Brog:animate()
    self:current_animation():advance_step()
end

function Brog:current_animation()
    return self.animation[self.state]
end

function Brog:speech_anchor()
    local sprite_width = 30
    -- TODO: include scale in calculations
    return V2(self.anchor.x + sprite_width/2 + 1, self.anchor.y - 10)
end

local PUNCH_FORCE = V2(5, -5)
function Brog:touched_by_player()
    if(self.state == Brog.State.IDLE) then
        self.state = Brog.State.PUNCHED
        self.vel = V2(PUNCH_FORCE.x, PUNCH_FORCE.y)

        game_state:apply_shockwave()
        game_state:apply_chromatic_aberration()
        Audio.play_sound("falling_platform_revive", 0.4, 0.4)
        Audio.play_sound("snail_explode", 0.8, 0.8)
        Audio.play_sound("brog_speak", 0.5, 0.5)
        Audio.play_sound("kick", 0.5, 0.5)
    
        if(Steam) then
            unlock_achievement(ACHIEVEMENT_KEYS.BONK)
        end
        game_state.player:pushed_brog()
    end
end

local GRAVITY = 0.34 
local FRICTION = 0.95
local TERMINAL_V_SPEED = 2.5
function Brog:apply_physics()
    self.vel = v2_scale(self.vel, FRICTION)
    self.vel.y = lume.clamp(-10*TERMINAL_V_SPEED, self.vel.y + GRAVITY, TERMINAL_V_SPEED)

    self.pos = v2_add(self.pos, self.vel)
end
