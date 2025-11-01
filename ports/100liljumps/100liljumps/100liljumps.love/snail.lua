require("./utils")
require("./math")
require("./animation")
require("./lume")
require("./input")
require("./audio")
local Object = require("./classic")

Snail = Object.extend(Object)

local MOVE_SPEED = 0.3
local GRAVITY = 0.10 
local TERMINAL_VELOCITY = 3
Snail.SNAIL_BOUNCE_MARGIN = 3

Audio.create_sound("sounds/snail_explode.ogg", "snail_explode", "static", 4, 0.8)

love.graphics.setDefaultFilter("nearest")
local snail_image = love.graphics.newImage("snail.png")
local SnailState = {
    ["ON_FLOOR"] = 0,
    ["ON_AIR"]   = 1,
}

function Snail.new(self, pos, direction)
    self.pos = pos
    self.prev_pos = V2(pos.x, pos.y)
    self.vel = V2(0, 0)
    self.state = SnailState.ON_FLOOR

    self.tile_pos = V2(
        math.floor(pos.x / TILE_SIZE),
        math.floor(pos.y / TILE_SIZE)
    )
    self.has_ground_below = false
    assert(direction == 1 or direction == -1)
    self.direction = direction 
    self.animation = Animation({
        {filename = "snail.png", duration = 60}
    }, math.floor(math.random()*60)) 
end

function Snail:update()
    self.prev_pos = V2(self.pos.x, self.pos.y)
    self.pos.x = self.pos.x + self.direction*MOVE_SPEED

    if(self.state == SnailState.ON_FLOOR) then
        if(not self.has_ground_below) then
            self.state = SnailState.ON_AIR
        end

    elseif(self.state == SnailState.ON_AIR) then
        self.vel.y = math.min(self.vel.y + GRAVITY, TERMINAL_VELOCITY)
        self.pos.y = self.pos.y + self.vel.y
    end

    self.animation:advance_step()
    if self.pos.y > 300 then
        game_state.tile_map:remove_snail(self)
    end
end

function Snail:collided_with_tile(x, y)
    -- in tile space
    if(self.prev_pos.x >= x*TILE_SIZE + TILE_SIZE) then
        self.direction = self.direction * -1
        self.pos.x = (x+1)*TILE_SIZE
    elseif(self.prev_pos.x + TILE_SIZE <= x*TILE_SIZE ) then
        self.direction = self.direction * -1
        self.pos.x = x*TILE_SIZE - TILE_SIZE
    elseif(self.prev_pos.y >= y*TILE_SIZE + TILE_SIZE) then
        self.vel.y = 0
        self.pos.y = (y+1)*TILE_SIZE
    elseif((self.prev_pos.y + TILE_SIZE) <= y*TILE_SIZE) then
        -- TODO: move to state machine
        self.state = SnailState.ON_FLOOR
        self.vel.y = 0
        self.pos.y = (y-1)*TILE_SIZE
    end
end

function Snail:draw()
    -- hitbox
    if false then
        love.graphics.setColor(0.5, 0, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", self.pos.x, self.pos.y, TILE_SIZE, TILE_SIZE)

        love.graphics.setColor(1, 0, 0.2)
        love.graphics.rectangle("fill", self.pos.x, self.pos.y, TILE_SIZE, self.SNAIL_BOUNCE_MARGIN)
    end

    love.graphics.setColor(1, 1, 1)
    local offset = 0
    if self.direction == -1 then offset = TILE_SIZE end
    self.animation:draw(self.pos.x, self.pos.y, self.direction, 1)
    --love.graphics.draw(snail_image, self.pos.x, self.pos.y, 0, self.direction, 1, offset, 0)
end

function Snail:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + TILE_SIZE, self.pos.y + TILE_SIZE)
    )
end

function Snail:fall_check_hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y + TILE_SIZE),
        V2(self.pos.x + TILE_SIZE, self.pos.y + 2*TILE_SIZE)
    )
end

function Snail:killed_by_player()
    game_state.tile_map:remove_snail(self)
    self:apply_exploding_particles()
    trigger_vibration_feedback(0.4, 0.2)
    game_state.tile_map:add_effect(EFFECT_TYPE.direction_screenshake, 0.05, {
        direction = "up"
    } )
    Audio.play_sound("snail_explode", 0.8, 1.0)
end

function Snail:apply_exploding_particles()
    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 2.0, {
        particle_emitter = ParticleEmitter( {
            pos = self.pos,
            particle_type = ParticleType.exploding,
            particle_variant = ParticleVariant.snail
        } ),
    })
end
