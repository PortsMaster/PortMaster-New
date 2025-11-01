require("./utils")
require("./math")
require("./lume")
local Object = require("./classic")

Vine = Object.extend(Object)

Vine.MARGIN = 0

Vine.tiles = {
    love.graphics.newImage("vine_1.png"),
    love.graphics.newImage("vine_2.png"),
}

function Vine.new(self, pos, height_in_tiles)
    self.pos = pos
    self.height_in_tiles = height_in_tiles

    self.being_climbed = false

    self.climbed_frames = 0

    self.y_offset = 0
    self.climbed_offset_t = 0
end

local TARGET_OFSSET_TIME = 0.5
function Vine:update(dt)
    local new_normalized_time = 0

    if(self.being_climbed) then
        local new_time = self.climbed_offset_t * TARGET_OFSSET_TIME + dt
        new_normalized_time = new_time / TARGET_OFSSET_TIME
    else
        local new_time = self.climbed_offset_t * (TARGET_OFSSET_TIME/2) - dt
        new_normalized_time = new_time / (TARGET_OFSSET_TIME/2)
    end

    self.climbed_offset_t = lume.clamp(new_normalized_time, 0, 1)
end

local top_vine_quad = love.graphics.newQuad(0, TILE_SIZE/2, TILE_SIZE, TILE_SIZE/2, TILE_SIZE, TILE_SIZE)
function Vine:draw()
    if false then
        draw_hitbox(self)
    end

    love.graphics.setColor(1, 1, 1)
    eased_t = easeOut(self.climbed_offset_t)
    local TARGET_OFFSET = 4
    self.y_offset = TARGET_OFFSET*eased_t
    love.graphics.draw(Vine.tiles[1], top_vine_quad, self.pos.x, self.pos.y - TILE_SIZE/2 + self.y_offset)

    for tile_y = 0, (self.height_in_tiles - 1) do
        local vine_tile = math.floor(tile_y % 2) + 1
        local draw_x = self.pos.x
        local draw_y = self.pos.y + tile_y*TILE_SIZE + self.y_offset
        love.graphics.draw(Vine.tiles[vine_tile], draw_x, draw_y)
    end
end

function Vine:hitbox()
    return Rectangle(
        V2(self.pos.x + Vine.MARGIN, self.pos.y),
        V2(self.pos.x + TILE_SIZE - Vine.MARGIN, self.pos.y + self.height_in_tiles*TILE_SIZE - 1)
    )
end

function Vine:landed_by_player(player)
    self.being_climbed = true
    self.climbed_frames = 0
    self:apply_landing_vine_particles(player.pos)
end

function Vine:climbed_by_player(player)
    --self.draw_pos.y = self.pos.y + 1

    self.climbed_frames = self.climbed_frames + 1
    if(self.climbed_frames > 5) then
        self:apply_climbing_vine_particles(player.pos)
        self.climbed_frames = 0
    end
end

function Vine:apply_landing_vine_particles(player_pos)
    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 8.0, {
        particle_emitter = ParticleEmitter( {
            pos = V2(self.pos.x, player_pos.y),
            particle_type = ParticleType.exploding,
            particle_variant = ParticleVariant.landing_vine,
            gravity = 0.02,
            terminal_velocity = 0.8,
            floaty = true
        } ),
    })
end

function Vine:apply_climbing_vine_particles(player_pos)
    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 8.0, {
        particle_emitter = ParticleEmitter( {
            pos = V2(self.pos.x, player_pos.y),
            particle_type = ParticleType.exploding,
            particle_variant = ParticleVariant.climbing_vine,
            gravity = 0.02,
            terminal_velocity = 0.8,
            floaty = true
        } ),
    })
end

function Vine:released()
    self.being_climbed = false
end
