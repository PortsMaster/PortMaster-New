require("./utils");
require("./math");
require("./animation")
require("./audio")
local Object = require("./classic")

FallingColumn = Object.extend(Object)

FallingColumn.tile = love.graphics.newImage("column_part.png")

Audio.create_sound("sounds/column_land.ogg", "column_land", "static", 10)

local FallingColumnState = {
    ["HANGING"] = 0,
    ["FALLING"] = 1,
    ["SOLID"]   = 2,
}

local GRAVITY = 0.1
local TERMINAL_VELOCITY = 4

function FallingColumn.new(self, pos, fall_check_height)
    self.pos = V2(pos.x, pos.y - TILE_SIZE)
    self.vel = V2(0, 0)
    self.width  = 2*TILE_SIZE
    self.height = 2*TILE_SIZE

    self.state = FallingColumnState.HANGING

    self.fall_check_collider = FallingColumn.fall_check_collider(self.pos, fall_check_height)
end

FallingColumn.fall_check_collider = function(pos, height)
    return Rectangle(
        V2(pos.x, pos.y),
        V2(pos.x + 2*TILE_SIZE, pos.y + height)
    )
end

function FallingColumn:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + self.width, self.pos.y + self.height)
    )
end

function FallingColumn:update()
    if(self.state == FallingColumnState.SOLID) then

    elseif(self.state == FallingColumnState.FALLING) then
        self.vel.y = math.min(self.vel.y + GRAVITY, TERMINAL_VELOCITY)
        self.pos.y = self.pos.y + self.vel.y
    end

    if self.pos.y > 300 then
        game_state.tile_map:remove_falling_column(self)
    end
end

function FallingColumn:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(FallingColumn.tile, self.pos.x, self.pos.y)

    -- Draw hitbox
    if false then
        local color_map = {
            [FallingColumnState.HANGING] = {1, 0, 0},
            [FallingColumnState.FALLING] = {0, 1, 0},
            [FallingColumnState.SOLID]   = {0, 0, 1}
        }
        love.graphics.setColor(color_map[self.state])
        love.graphics.rectangle(
            "fill",
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
end

function FallingColumn:start_falling()
    if(self.state == FallingColumnState.HANGING) then
        self.state = FallingColumnState.FALLING

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

        game_state.tile_map:add_effect(EFFECT_TYPE.particles, 2.0, {
            particle_emitter = ParticleEmitter( {
                pos = V2(self.pos.x, self.pos.y + self.height),
                particle_type = ParticleType.exploding,
                particle_variant = ParticleVariant.falling_spike,
                gravity = 0.1,
                terminal_velocity = 0.2,
                total_time = 0.1,
                floaty = true
            } ),
        })

        Audio.play_sound("falling_rocks", 0.4, 0.7)
    end
end

function FallingColumn:collided_with_tile(x, y)
    if(self.state == FallingColumnState.FALLING) then
        self.state = FallingColumnState.SOLID
        self.pos.y = y*TILE_SIZE - self.height
    end
    -- Render.add_effect(EFFECT_TYPE.particles, 1.0, {
    --     particle_emitter = ParticleEmitter( {
    --         pos = self.pos,
    --         particle_type = ParticleType.exploding,
    --         particle_variant = ParticleVariant.exploding_column,
    --         gravity = 0.1,
    --         total_time = 0.1
    --     } ),
    -- })

    game_state.tile_map:add_effect(EFFECT_TYPE.screenshake, 0.2)

    Audio.play_sound("column_land", 0.7, 1.0)
    trigger_vibration_feedback(0.4, 0.3)
end

function FallingColumn:is_solid()
    return (self.state == FallingColumnState.SOLID) or (self.state == FallingColumnState.HANGING)
end

function FallingColumn:shadow_casting_segments()
    local top_left     = V2(self.pos.x + 1             , self.pos.y)
    local top_right    = V2(self.pos.x + self.width - 1, self.pos.y)
    local bottom_left  = V2(self.pos.x + 1             , self.pos.y + self.height)
    local bottom_right = V2(self.pos.x + self.width - 1, self.pos.y + self.height)

    local top    = create_segment(top_left   , top_right)
    local left   = create_segment(top_left   , bottom_left)
    local right  = create_segment(top_right  , bottom_right)
    local bottom = create_segment(bottom_left, bottom_right)

    return {top, left, right, bottom}
end
