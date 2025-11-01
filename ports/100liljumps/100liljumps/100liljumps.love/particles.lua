require("./utils")
require("./math")
require("./animation")
require("./lume")
require("./particle_functions")
local Object = require("./classic")

Audio.create_sound("sounds/water_drop.wav", "water_drop", "static", 20)

ParticleEmitter = Object.extend(Object)

ParticleType = {
    ["exploding"] = 0,
    ["emitter"]   = 1,
}

ParticleVariant = {
    ["nara"]             = 0,
    ["snail"]            = 1,
    ["falling_platform"] = 2,
    ["nara_landing"]     = 3,
    ["bouncer"]          = 4,
    ["landing_vine"]     = 5,
    ["climbing_vine"]    = 6,
    ["exploding_spike"]  = 7,
    ["falling_spike"]    = 8,
    ["portal"]           = 9,
    ["splash"]           = 10,
    ["sleep"]            = 11,
    ["smoke"]            = 12,
    ["medal"]            = 13,
    ["sparks"]           = 14,
    ["notes"]            = 15,
    ["water_drops"]      = 16,
    ["dust"]             = 17,
    ["puzzle"]           = 18,
    ["start_screen"]     = 19,
}

emitter_map = {
    [ParticleVariant.nara] = exploding_nara_particles,
    [ParticleVariant.snail] = exploding_snail_particles,
    [ParticleVariant.nara_landing] = nara_landing_particles,
    [ParticleVariant.bouncer] = bouncer_particles,
    [ParticleVariant.landing_vine] = landing_vine_particles,
    [ParticleVariant.climbing_vine] = climbing_vine_particles,
    [ParticleVariant.exploding_spike] = exploding_spike,
    [ParticleVariant.falling_spike] = falling_spike,
    [ParticleVariant.splash] = splash,
    [ParticleVariant.sleep] = sleep,
    [ParticleVariant.sparks] = sparks,
    [ParticleVariant.notes] = notes
}

particle_creator_map = {
    [ParticleVariant.landing_vine] = create_vine_particle,
    [ParticleVariant.falling_platform] = create_falling_platform_particle,
    [ParticleVariant.portal] = create_portal_particle,
    [ParticleVariant.smoke] = create_smoke_particle,
    [ParticleVariant.medal] = medal,
    [ParticleVariant.water_drops] = water_drops,
    [ParticleVariant.dust] = dust,
    [ParticleVariant.puzzle] = puzzle,
    [ParticleVariant.start_screen] = start_screen,
}

function create_particle(initial_pos, initial_vel, color, size, target_time, fade_out, size_y, should_collide, fade_in, image)
    local initial_alpha = 1
    if fade_in then
        initial_alpha = 0
    end

    return {
        pos = V2(initial_pos.x, initial_pos.y),
        vel = V2(initial_vel.x, initial_vel.y),
        color = color,
        size = size,
        time = 0,
        target_time = target_time,
        fade_out = fade_out or false,
        fade_in = fade_in or false,
        alpha = initial_alpha,
        size_y = size_y,
        should_collide = should_collide or false,
        image = image or nil,
        has_faded_in = false
    }
end

function ParticleEmitter.new(self, data)
    self.pos = data.pos
    self.gravity = data.gravity or 0.15
    self.prev_time = 0
    self.current_time = 0
    self.particle_type = data.particle_type
    self.particle_variant = data.particle_variant
    self.particles_per_second = data.particles_per_second or 10
    self.total_time = data.total_time or 0.8
    self.terminal_velocity = data.terminal_velocity
    self.floaty = data.floaty
    self.prepopulate = data.prepopulate or false
    self.data = data.data
    if(data.visible ~= nil) then
        self.visible = data.visible
    else
        self.visible = true
    end
    
    if(data.particle_type == ParticleType.exploding) then
        self.particles = emitter_map[data.particle_variant](data.pos, data.data)
    else
        self.particles = {}
        if self.prepopulate then
            local prepopulate_frames = 10*60
            for i = 1, prepopulate_frames do
                local prepopulating = true
                self:update_and_draw(1/60 * i, prepopulating)
            end
            self:reset_timers()
        end
    end
end

function ParticleEmitter:update_and_draw(time, prepopulating)
    if(not self.visible) then
        return
    end

    local dt = time - self.prev_time
    self.current_time = self.current_time + dt
    self.prev_time = time

    if game_state.config_particles_disabled then
        return
    end

    for i, particle in pairs(self.particles) do
        -- Update
        local r, g, b, a = lume.color(particle.color)
        love.graphics.setColor(r, g, b, math.min(a, particle.alpha))
        particle.vel.x = particle.vel.x*0.99

        if(self.floaty) then
            if math.random() > 0.95 then
                particle.vel.x = particle.vel.x + -lume.sign(particle.vel.x)*0.5
            end
        end

        particle.vel.y = particle.vel.y + self.gravity
        if(self.terminal_velocity) then
            if particle.vel.y > 0 then
                particle.vel.y = math.min(particle.vel.y, self.terminal_velocity)
            else
                --particle.vel.y = math.max(particle.vel.y, -self.terminal_velocity)
            end
        end
        particle.pos.x = particle.pos.x + particle.vel.x
        particle.pos.y = particle.pos.y + particle.vel.y

        local should_remove_particle = false
        if particle.should_collide and not prepopulating then
            if check_collisions_for_particle(game_state.tile_map, particle) then
                -- TODO: check type
                particle.vel.y = -1
                particle.vel.x = math.random() - 0.5
                particle.time = (particle.target_time or 0.1) - 0.2
                particle.should_collide = false
                particle.size = 1
                particle.size_y = 1

                Audio.play_sound("water_drop", 0.6, 0.8, 0.4)
            end
        end

        -- Draw
        if not prepopulating then
            if particle.image then
                love.graphics.draw(particle.image, particle.pos.x, particle.pos.y)
            else
                love.graphics.rectangle("fill", particle.pos.x, particle.pos.y, particle.size, particle.size_y or particle.size)
            end
        end

        if not particle.has_faded_in and particle.fade_in then
            particle.alpha = particle.alpha + 0.01
            if particle.alpha >= 1 then
                particle.has_faded_in = true
            end
        end

        if particle.target_time then
            particle.time = particle.time + dt
            if particle.time > particle.target_time then
                if particle.fade_out then
                    particle.alpha = particle.alpha - 0.04
                else
                    table.remove(self.particles, i) -- TODO: mark as ready to use? and use buffer
                end
            end
        end

        if particle.alpha < 0 then
            table.remove(self.particles, i) -- TODO: mark as ready to use? and use buffer
        end
    end

    if (time < self.total_time) or (self.total_time == -1) then
        if(self.particle_type == ParticleType.emitter) then
            if self.current_time > (1 / self.particles_per_second) then
                self.current_time = 0

                table.insert(self.particles, particle_creator_map[self.particle_variant](self.pos, self.data))
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
end

function ParticleEmitter:reset_timers()
    self.current_time = 0
    self.prev_time = 0
    for i, particle in pairs(self.particles) do
        particle.time = 0
    end
end
