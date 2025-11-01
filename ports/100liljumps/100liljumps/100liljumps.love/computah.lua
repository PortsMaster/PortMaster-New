require("./utils")
require("./math")
require("./animation")
require("./lume")
require("./audio")

TILE_SIZE = 8
local width = 24
local height = 16
local Object = require("./classic")

Computah = Object.extend(Object)
Computah.animation = Animation({
    {filename = "computah-sheet.png", duration = 64}
}, null, 24, 16)
Computah.broken_animation = Animation({
    {filename = "computah-broken-sheet.png", duration = 32}
}, null, 24, 16)

Computah.State = {
    ["OK"]     = 0,
    ["BROKEN"] = 1,
}

Audio.create_sound("sounds/computer-fan.wav", "computer_fan", "static", 1, 0.1, true)
Audio.create_sound("sounds/computah_explosion.ogg", "computer_explosion", "static", 3, 1.0)
Audio.create_sound("sounds/computah_jump_on.ogg", "computah_jump_on", "static", 10, 1.0)
Audio.create_sound("sounds/computah_jump_off.ogg", "computah_jump_off", "static", 10, 1.0)
Audio.create_sound("sounds/sparks.ogg", "sparks", "static", 3, 1.0)

function Computah.new(self, pos, tile_map)
    self.pos = V2(pos.x, pos.y)
    self.width = width
    self.height = height
    self.player_on_top = false
    self.release = false
    self.squished = false

    self.light = PointLight(
        V2(self.pos.x + width/2, self.pos.y + height/2),
        "#33aa00",
        0.2,
        0.5
    )

    if( game_state.jump_counter_broken ) then
        self.state = Computah.State.BROKEN
        self.broken_stage = 3
        self.light.visible = false
    else
        self.state = Computah.State.OK
        self.broken_stage = 0
    end

    self.broken_particle_emmiter = ParticleEmitter( {
        pos = V2(self.pos.x, self.pos.y),
        particle_type = ParticleType.emitter,
        particle_variant = ParticleVariant.smoke,
        particles_per_second = 4,
        total_time = -1,
        gravity = 0,
        terminal_velocity = 0.1,
        visible = false
    } )

    if self.state == Computah.State.OK then
        tile_map:add_sound("computer_fan", 0.1)
    end
end

function Computah:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y + 3),
        V2(self.pos.x + width, self.pos.y + height - 2)
    )
end

function Computah:update(dt)
    if(self.player_on_top and not self.squished) then
        self:squish()
    end

    if(not self.player_on_top and self.squished) then
        if(self.state == Computah.State.OK) then
            Audio.play_sound("computah_jump_on")
        else
            Audio.play_sound("computah_jump_on", 0.8, 0.8)
        end
        self.squished = false
    end

    if(self.release) then
        self.player_on_top = false
    else
        self.release = true
    end
    self.broken_particle_emmiter.visible = false
    self.light.visible = false

    if(self.state == Computah.State.OK) then
        self.light.visible = true
    elseif(self.state == Computah.State.BROKEN) then
        self.broken_particle_emmiter.visible = true
    end
end

function Computah:draw()
    -- hitbox
    if false then
        draw_hitbox(self)
    end

    if(self.state == Computah.State.OK) then
        Computah.animation:advance_step()
        if(self.player_on_top) then
            Computah.animation:draw(self.pos.x - 1, self.pos.y + 1, 1.1)
        else
            Computah.animation:draw(self.pos.x, self.pos.y)
        end
    else
        Computah.broken_animation:advance_step()
        if(self.player_on_top) then
            Computah.broken_animation:draw(self.pos.x - 1, self.pos.y + 1, 1.1)
        else
            Computah.broken_animation:draw(self.pos.x, self.pos.y)
        end
    end
end

function Computah:touched_by_player(player)
    local player_on_top = player.pos.y + TILE_SIZE <= self:hitbox().top_left.y + 1

    if(player_on_top and not player:on_air()) then
        self.player_on_top = true
        self.release = false
    end
end

function Computah:squish()
    self.squished = true

    if(self.state == Computah.State.OK) then
        Audio.play_sound("computah_jump_off")
        game_state.tile_map:add_effect(EFFECT_TYPE.particles, 1.0, {
            particle_emitter = ParticleEmitter( {
                pos = self.pos,
                particle_type = ParticleType.exploding,
                particle_variant = ParticleVariant.sparks,
                gravity = 0.1,
            } ),
        })
        Audio.play_sound("sparks")
        local pitch = 1.3 - 0.10*self.broken_stage
        Audio.play_sound("snail_explode", pitch, pitch)
        game_state:apply_screenshake()
        game_state:apply_chromatic_aberration()
    else
        Audio.play_sound("computah_jump_off", 0.8, 0.8)
    end

    if(self.broken_stage == 0) then
        Audio.stop_song("glitch_start")
    end

    if(self.state == Computah.State.OK) then
        self.broken_stage = self.broken_stage + 1

        local STEPS_TO_BREAK = 3
        if(self.broken_stage >= STEPS_TO_BREAK ) then
            Audio.play_sound("computer_explosion")
            Audio.play_song("glitch_break")
            Audio.music_fade_enabled = false

            local centered_position = V2(self.pos.x + self.width/2, self.pos.y + self.height/2)
            game_state:apply_shockwave(centered_position)
            game_state:apply_screenshake()
            game_state:apply_chromatic_aberration()
            self.state = Computah.State.BROKEN
            game_state.tile_map:remove_sound("computer_fan")

            game_state.jump_counter_broken = true
        end
    end
end
