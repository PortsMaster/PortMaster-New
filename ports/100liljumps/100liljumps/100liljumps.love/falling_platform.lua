require("./utils");
require("./math");
require("./animation")
require("./audio")
local Object = require("./classic")

FallingPlatform = Object.extend(Object)

FallingPlatform.FALLING_TIME = 30
FallingPlatform.BROKEN_TIME  = 120
FallingPlatform.REBUILD_TIME = 10

Audio.create_sound("sounds/rumble_falling_platform.ogg", "falling_falling_platform", "static", 6, 0.2)
Audio.create_sound("sounds/pop.wav", "falling_platform_revive", "static", 6, 0.1)

local FallingPlatformState = {
    ["SOLID"]       = 0,
    ["FALLING"]     = 1,
    ["BROKEN"]      = 2,
    ["REBUILDING"]  = 3,
}

function FallingPlatform.new(self, pos)
    self.pos = pos
    self.width  = TILE_SIZE
    self.height = TILE_SIZE

    self.state = FallingPlatformState.SOLID

    self.falling_animation = Animation({
        {filename = "falling-platform-sheet.png", duration = 40},
    })
    self.broken_animation = Animation({
        {filename = "falling-platform-broken-sheet.png", duration = 60},
    })
    self.falling_counter = 0
    self.broken_counter  = 0
    self.rebuild_counter = 0
end

function FallingPlatform:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + self.width, self.pos.y + self.height)
    )
end

function FallingPlatform:update()
    if(self.state == FallingPlatformState.FALLING) then
        if self.falling_counter == 0 then
            Audio.play_sound("falling_falling_platform", 0.6, 1.0)
        end

        self.falling_counter = self.falling_counter + 1

        if self.falling_counter > FallingPlatform.FALLING_TIME then
            self.state = FallingPlatformState.BROKEN
            self.falling_counter = 0
        end

    elseif(self.state == FallingPlatformState.BROKEN) then
        self.broken_counter = self.broken_counter + 1

        if self.broken_counter > FallingPlatform.BROKEN_TIME then
            self.broken_counter = 0 
            self.state = FallingPlatformState.REBUILDING
        end
    elseif(self.state == FallingPlatformState.REBUILDING) then
        if self.rebuild_counter == 0 then
            Audio.play_sound("falling_platform_revive", 0.2, 0.4, 0.35)
        end
        self.rebuild_counter = self.rebuild_counter + 1

        if self.rebuild_counter > FallingPlatform.REBUILD_TIME then
            self.rebuild_counter = 0 
            self.state = FallingPlatformState.SOLID
        end
    end
end

function FallingPlatform:draw()
    -- Draw hitbox
    if false then
        local color_map = {
            [FallingPlatformState.SOLID]   = {1, 0, 0},
            [FallingPlatformState.FALLING] = {0, 1, 0},
            [FallingPlatformState.BROKEN]  = {0, 0, 1}
        }
        love.graphics.setColor(color_map[self.state])
        love.graphics.setLineWidth(1)
        love.graphics.rectangle(
            "line",
            self:hitbox().top_left.x, self:hitbox().top_left.y,
            self.width, self.height
        )
    end

    if(self.state == FallingPlatformState.SOLID) then
        self.falling_animation:reset()
        self.falling_animation:draw(self.pos.x, self.pos.y)
    elseif(self.state == FallingPlatformState.FALLING or self.state == FallingPlatformState.BROKEN) then
        if(not self.falling_animation.has_looped) then
            self.falling_animation:draw(self.pos.x, self.pos.y)
            self.falling_animation:advance_step()
        else
            self.broken_animation:draw(self.pos.x, self.pos.y)
            self.broken_animation:advance_step(self.pos.x, self.pos.y)
        end
    elseif(self.state == FallingPlatformState.REBUILDING) then
        local alpha = lume.lerp(0, 0.8, self.rebuild_counter / FallingPlatform.REBUILD_TIME)
        self.broken_animation:advance_step(self.pos.x, self.pos.y)
        self.broken_animation:draw(self.pos.x, self.pos.y, 1, 1, 1/math.max(2*alpha, 0.01))
        self.falling_animation:reset()
        self.falling_animation:draw(self.pos.x, self.pos.y, 1, 1, alpha)
    end
end

function FallingPlatform:touched_by_player(player)
    local falling = player.prev_pos.y <= player.pos.y;
    local distance = math.abs((player.pos.y + TILE_SIZE) - self.pos.y)
    if(distance < 2 and falling) then
        self:start_falling()
    end
end

function FallingPlatform:start_falling()
    -- self.animation:reset()
    -- TODO: move to state machine
    if(self.state == FallingPlatformState.SOLID) then
        self:apply_falling_particles()
    end
    self.state = FallingPlatformState.FALLING
end

function FallingPlatform:is_solid()
    local solid_values = {
        FallingPlatformState.SOLID,
        FallingPlatformState.FALLING,
    }
    return table_contains(solid_values, self.state)
end

function FallingPlatform:apply_falling_particles()
    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 2, {
        particle_emitter = ParticleEmitter( {
            pos = self.pos,
            particle_type = ParticleType.emitter,
            particle_variant = ParticleVariant.falling_platform,
            particles_per_second = 20,
            total_time = 0.5,
            gravity = 0.04
        } ),
    })
end

function FallingPlatform:shadow_casting_segments()
    local top_left     = V2(self.pos.x + 1            , self.pos.y)
    local top_right    = V2(self.pos.x + TILE_SIZE - 1, self.pos.y)
    local bottom_left  = V2(self.pos.x                , self.pos.y + TILE_SIZE)
    local bottom_right = V2(self.pos.x + TILE_SIZE    , self.pos.y + TILE_SIZE)

    local top    = create_segment(top_left   , top_right)
    local left   = create_segment(top_left   , bottom_left)
    local right  = create_segment(top_right  , bottom_right)

    return {top, left, right}
end
