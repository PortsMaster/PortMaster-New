local Object = require("./classic")

MusicFrog = Object.extend(Object)

local NOTE_SPAWN_FRAMES = 30

Audio.create_sound("sounds/GltchNote1.mp3", "music_frog_glitch_1", "static", 4, 1.0)
Audio.create_sound("sounds/GltchNote2.mp3", "music_frog_glitch_2", "static", 4, 1.0)
Audio.create_sound("sounds/GltchNote3.mp3", "music_frog_glitch_3", "static", 4, 1.0)
Audio.create_sound("sounds/GltchNote4.mp3", "music_frog_glitch_4", "static", 4, 1.0)

Audio.create_sound("sounds/JnglNote1.mp3", "music_frog_jungle_1", "static", 4, 1.0)
Audio.create_sound("sounds/JnglNote2.mp3", "music_frog_jungle_2", "static", 4, 1.0)
Audio.create_sound("sounds/JnglNote3.mp3", "music_frog_jungle_3", "static", 4, 1.0)
Audio.create_sound("sounds/JnglNote4.mp3", "music_frog_jungle_4", "static", 4, 1.0)

MusicFrog.glitch_sound_keys = {
    "music_frog_glitch_1",
    "music_frog_glitch_2",
    "music_frog_glitch_3",
    "music_frog_glitch_4"
}

MusicFrog.jungle_sound_keys = {
    "music_frog_jungle_1",
    "music_frog_jungle_2",
    "music_frog_jungle_3",
    "music_frog_jungle_4"
}

function MusicFrog.new(self, pos, tile_map)
    self.pos = V2(pos.x, pos.y)
    self.animation = Animation({
        {filename = "music_frog.png", duration = 98}
    }, 1, 21, 11) 
    self.modular_1_animation = Animation({
        {filename = "music_frog_modular.png", duration = 98}
    }, 1, 8, 16) 
    self.modular_2_animation = Animation({
        {filename = "music_frog_modular2.png", duration = 98}
    }, 1, 13, 8) 

    self.timer = 0
    self.queued_sound_time = 0
end


function MusicFrog:queue_sound(time)
    queued_sound_time = time
end

function MusicFrog:update()
    self.animation:advance_step()
    self.modular_1_animation:advance_step()
    self.modular_2_animation:advance_step()
    self.timer = self.timer + 1

    if self.queued_sound_time > 0 then
        self.queued_sound_time = self.queued_sound_time - 1
        if self.queued_sound_time <= 0 then
            self.queued_sound_time = 0
            if game_state.jump_counter_broken then
                local sound_key = lume.randomchoice(MusicFrog.glitch_sound_keys)
                Audio.play_sound(sound_key)
            else
                local sound_key = lume.randomchoice(MusicFrog.jungle_sound_keys)
                Audio.play_sound(sound_key)
            end
        end
    end

    if self.timer > NOTE_SPAWN_FRAMES then
        local note_variants = {"negra", "corchea"}
        local note_idx = 1 + math.floor(2*math.random())
        local note_variant = note_variants[note_idx]

        if note_idx == 2 then
            self.queued_sound_time = math.floor(NOTE_SPAWN_FRAMES/2)
        end

        self.timer = 0
        if game_state.jump_counter_broken then
            local sound_key = lume.randomchoice(MusicFrog.glitch_sound_keys)
            Audio.play_sound(sound_key)
        else
            local sound_key = lume.randomchoice(MusicFrog.jungle_sound_keys)
            Audio.play_sound(sound_key)
        end

        local particles_pos = V2(self.pos.x + 12, self.pos.y - 4)
        tile_map:add_effect(EFFECT_TYPE.particles, nil, {
            particle_emitter = ParticleEmitter( {
                pos = particles_pos,
                particle_type = ParticleType.exploding,
                particle_variant = ParticleVariant.notes,
                particles_per_second = 1,
                total_time = 4,
                gravity = 0,
                terminal_velocity = 0.1,
                gravity = 0.01,
                data = {
                    note_variant = note_variant
                }
            } ),
        })
    end
end

function MusicFrog:draw()
    self.animation:draw(self.pos.x, self.pos.y)
    self.modular_1_animation:draw(self.pos.x + self.animation.width + 3, self.pos.y - (self.modular_1_animation.height - self.animation.height))
    self.modular_2_animation:draw(self.pos.x + 4*TILE_SIZE - 1, self.pos.y - TILE_SIZE + 4)
end
