require("./utils");
require("./math");
require("./tile_map")
require("./animation")
require("./audio")
local Object = require("./classic")

Bouncer = Object.extend(Object)

Bouncer.Orientation = {
    ["UP"] = 0,
    ["RIGHT"] = 1,
    ["DOWN"] = 2,
    ["LEFT"] = 3,
}

local BouncerState = {
    ["IDLE"] = 0,
    ["BOUNCING"] = 1,
}

function Bouncer.new(self, pos, orientation, tile_map) --rect?
    self.pos = pos -- top_left
    assert(
        orientation == Bouncer.Orientation.UP or
        orientation == Bouncer.Orientation.RIGHT or
        orientation == Bouncer.Orientation.DOWN or
        orientation == Bouncer.Orientation.LEFT
    )
    self.orientation = orientation or Bouncer.Orientation.RIGHT --orientation or Orientation.RIGHT 

    -- NOTE: maybe use smaller hitboxes than visual info
    -- NOTE: maybe use orientation to use different heights
    -- NOTE: maybe get dimensions from hitbox?
    self.width  = TILE_SIZE
    self.height = TILE_SIZE/2
    self.state = BouncerState.IDLE

    self.animation = nil

    self.light = PointLight(
        V2(self.pos.x + TILE_SIZE/2, self.pos.y + TILE_SIZE/2),
        "#76428a",
        0.10,
        0.3
    )

    tile_map:add_point_light(self.light)

    self.colliding_with_player = false

    if(self.orientation == Bouncer.Orientation.UP or self.orientation == Bouncer.Orientation.DOWN) then
        self.animation = Animation({{filename = "bouncer.png", duration = 40}})
    else
        self.animation = Animation({{filename = "bouncer-horizontal.png", duration = 40}})
    end
end

function Bouncer:dimensions()
    local orientation_dimensions = {
        [Bouncer.Orientation.UP]    = {
            width  = TILE_SIZE,
            height = TILE_SIZE/2,
        },
        [Bouncer.Orientation.RIGHT] = {
            width  = TILE_SIZE/2,
            height = TILE_SIZE,
        },
        [Bouncer.Orientation.DOWN]  = {
            width  = TILE_SIZE,
            height = TILE_SIZE/2,
        },
        [Bouncer.Orientation.LEFT]  = {
            width  = TILE_SIZE/2,
            height = TILE_SIZE,
        },
    }

    return orientation_dimensions[self.orientation]
end

function Bouncer:hitbox()
    local orientation_delta = {
        [Bouncer.Orientation.UP]    = V2(0, TILE_SIZE/2),
        [Bouncer.Orientation.RIGHT] = V2(0, 0),
        [Bouncer.Orientation.DOWN]  = V2(0, 0),
        [Bouncer.Orientation.LEFT]  = V2(TILE_SIZE/2, 0),
    }
    local dx = orientation_delta[self.orientation].x
    local dy = orientation_delta[self.orientation].y
    local width  = self:dimensions().width
    local height = self:dimensions().height

    return Rectangle(
        V2(self.pos.x + dx, self.pos.y + dy),
        V2(self.pos.x + dx + width, self.pos.y + dy + height)
    )
end

function Bouncer:draw()
    -- Draw hitbox
    -- TODO: make method or table
    local dir_x = 1
    local dir_y = 1
    if false then
        love.graphics.setColor(1, 0, 0, 0.6)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle(
            "line",
            self:hitbox().top_left.x, self:hitbox().top_left.y,
            self:dimensions().width, self:dimensions().height
        )
    end
    -- Draw shape
    if(self.orientation == Bouncer.Orientation.RIGHT) then
        dir_x = 1
    end
    if(self.orientation == Bouncer.Orientation.LEFT) then
        dir_x = -1
    end
    if(self.orientation == Bouncer.Orientation.UP) then
        dir_y = 1
    end
    if(self.orientation == Bouncer.Orientation.DOWN) then
        dir_y = -1
    end

    if(self.state == BouncerState.IDLE) then
        self.animation:draw(self.pos.x, self.pos.y, dir_x, dir_y, math.pi/2)
    elseif(self.state == BouncerState.BOUNCING) then
        self.animation:draw(self.pos.x, self.pos.y, dir_x, dir_y)
        self.animation:advance_step()
        if(self.animation.step == 1) then
            self.state = BouncerState.IDLE
        end
    end
end

function Bouncer:start_bouncing()
    self.colliding_with_player = true
    self.animation:reset()
    trigger_vibration_feedback(0.4, 0.2)
    self.state = BouncerState.BOUNCING
    Audio.play_sound("bounce1", 0.8, 1.0)
    self:apply_bouncing_particles()
    local bouncer_map = {
        [Bouncer.Orientation.UP] = "up",
        [Bouncer.Orientation.DOWN] = "down",
        [Bouncer.Orientation.LEFT] = "left",
        [Bouncer.Orientation.RIGHT] = "right",
    }
    game_state.tile_map:add_effect(EFFECT_TYPE.direction_screenshake, 0.05, {
        direction = bouncer_map[self.orientation]
    } )
end

function Bouncer:apply_bouncing_particles()
    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 2.0, {
        particle_emitter = ParticleEmitter( {
            pos = self.pos,
            particle_type = ParticleType.exploding,
            particle_variant = ParticleVariant.bouncer,
            gravity = 0.01
        } ),
    })
end
