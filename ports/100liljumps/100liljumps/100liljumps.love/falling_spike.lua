require("./utils");
require("./math");
require("./animation")
require("./audio")
local Object = require("./classic")

FallingSpike = Object.extend(Object)

FallingSpike.tiles = {
    love.graphics.newImage("falling-spike-1.png"),
    love.graphics.newImage("falling-spike-2.png"),
}

Audio.create_sound("sounds/exploding_spike.ogg", "exploding_spike", "static", 10)
Audio.create_sound("sounds/falling_rocks.ogg", "falling_rocks", "static", 10)

local FallingSpikeState = {
    ["SOLID"]       = 0,
    ["FALLING"]     = 1,
}

local GRAVITY = 0.1
local TERMINAL_VELOCITY = 4

function FallingSpike.new(self, pos, fall_check_height)
    self.pos = pos
    self.vel = V2(0, 0)
    self.width  = TILE_SIZE
    self.height = TILE_SIZE

    self.state = FallingSpikeState.SOLID

    self.fall_check_collider = FallingSpike.fall_check_collider(pos, fall_check_height)
end

FallingSpike.fall_check_collider = function(pos, height)
    return Rectangle(
        V2(pos.x, pos.y),
        V2(pos.x + TILE_SIZE, pos.y + height)
    )
end

function FallingSpike:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + self.width, self.pos.y + self.height)
    )
end

function FallingSpike:update()
    if(self.state == FallingSpikeState.SOLID) then

    elseif(self.state == FallingSpikeState.FALLING) then
        self.vel.y = math.min(self.vel.y + GRAVITY, TERMINAL_VELOCITY)
        self.pos.y = self.pos.y + self.vel.y
    end
end

function FallingSpike:draw()
    -- Draw hitbox
    if false then
        local color_map = {
            [FallingSpikeState.SOLID]   = {1, 0, 0},
            [FallingSpikeState.FALLING] = {0, 1, 0},
        }
        love.graphics.setColor(color_map[self.state])
        love.graphics.rectangle(
            "line",
            self:hitbox().top_left.x, self:hitbox().top_left.y,
            self.width, self.height
        )

        love.graphics.setColor(1, 0.5, 0)
        love.graphics.rectangle(
            "line",
            self.fall_check_collider.top_left.x, self.fall_check_collider.top_left.y,
            self.width, self.fall_check_collider.bottom_right.y - self.fall_check_collider.top_left.y
        )
    end

    love.graphics.setColor(1, 1, 1)
    local index = (math.floor(self.pos.x / TILE_SIZE) % #FallingSpike.tiles) + 1
    love.graphics.draw(FallingSpike.tiles[index], self.pos.x, self.pos.y)
end

function FallingSpike:start_falling()
    if(self.state == FallingSpikeState.SOLID) then
        self.state = FallingSpikeState.FALLING

        game_state.tile_map:add_effect(EFFECT_TYPE.particles, 2.0, {
            particle_emitter = ParticleEmitter( {
                pos = self.pos,
                particle_type = ParticleType.exploding,
                particle_variant = ParticleVariant.falling_spike,
                gravity = 0.1,
                terminal_velocity = 0.2,
                total_time = 0.1,
                floaty = true
            } ),
        })

        Audio.play_sound("falling_rocks", 0.7, 1.0)
    end
end

function FallingSpike:collided_with_tile(x, y)
    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 1.0, {
        particle_emitter = ParticleEmitter( {
            pos = self.pos,
            particle_type = ParticleType.exploding,
            particle_variant = ParticleVariant.exploding_spike,
            gravity = 0.1,
            total_time = 0.1
        } ),
    })

    game_state.tile_map:add_effect(EFFECT_TYPE.screenshake, 0.2)

    Audio.play_sound("exploding_spike", 0.7, 1.0)
    trigger_vibration_feedback(0.4, 0.2)
end
