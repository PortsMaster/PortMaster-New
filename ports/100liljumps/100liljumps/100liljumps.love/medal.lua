local Object = require("./classic")

Medal = Object.extend(Object)
Medal.image = love.graphics.newImage("medals.png")
Medal.width = 5
Medal.height = 6
Medal.MAX_PREV_POSITIONS = 30

--Audio.create_sound("sounds/medal_obtained.ogg", "medal_obtained", "static", 1, 0.8)
Audio.create_sound("sounds/medal_obtained.mp3", "medal_obtained", "static", 1, 1.0)

-- TODO: Extract to: separate sprite sheet into quads
function init_quads()
    local SPRITE_WIDTH = Medal.width
    local SPRITE_HEIGHT = Medal.height

    local quads = {}
    for x = 0, Medal.image:getWidth(), SPRITE_WIDTH do
        table.insert(quads, love.graphics.newQuad(x, 0, SPRITE_WIDTH, SPRITE_HEIGHT, Medal.image))
    end

    return quads
end

Medal.quads = init_quads()

Medal.quad_for_color = {
    ["YELLOW"] = 1,
    ["PURPLE"] = 2,
    ["GREEN"]  = 3,
    ["ORANGE"] = 4,
    ["BLUE"]   = 5,
    ["RED"]    = 6,
}

Medal.light_color_for_color_name = {
    ["YELLOW"] = "#ffff00",
    ["PURPLE"] = "#ff00ff",
    ["GREEN"]  = "#00ff00",
    ["ORANGE"] = "#ffaa00",
    ["BLUE"]   = "#5555ff",
    ["RED"]    = "#ff0000",
}

Medal.State = {
    IDLE       = 1,
    DESPAWNING = 2,
}

local INITIAL_TIME_OFFSETS = {
    ["YELLOW"] = 0,
    ["ORANGE"] = -0.5,
    ["RED"]    = -1,
    ["PURPLE"] = -1.5,
    ["BLUE"]   = -2,
    ["GREEN"]  = -2.5,
}

function Medal.new(self, color_name, pos, is_interactible)
    self.pos = V2(pos.x, pos.y)
    self.anchor = V2(pos.x, pos.y)
    self.width = Medal.width 
    self.height = Medal.height
    self.color_name = color_name
    self.light_pos = V2(self.pos.x + self.width/2, self.pos.y + self.height/2)
    self.despawning_for_the_first_time = false

    self.time = 0

    local float_speed = 2 
    local float_amplitude = 4
    local time = float_speed*(self.time + INITIAL_TIME_OFFSETS[self.color_name])
    self.pos.y = self.anchor.y + float_amplitude*math.sin(time)

    self.is_interactible = is_interactible
    if(self.is_interactible == nil) then
        self.is_interactible = true
    end

    local light_color = Medal.light_color_for_color_name[self.color_name]
    self.original_light_intensity = 0.4
    if self:should_show_transluscent() then
        self.light = PointLight(self.light_pos, light_color, 0.3, 0.2)
    else
        if not self.is_interactible then
            self.light = PointLight(self.light_pos, light_color, 0.3, 0.22)
        else
            self.light = PointLight(self.light_pos, light_color, 0.3, self.original_light_intensity)
        end
    end

    self.light.pos = V2(self.pos.x + self.width/2, self.pos.y + self.height/2)

    self.state = Medal.State.IDLE
    self.despawn_time = 0
    self.despawn_target_time = 3

    self.prev_positions = {}
    self.prev_position_index = 1
end

function Medal:update(dt)
    self.time = self.time + dt

    self.prev_positions[self.prev_position_index] = V2(self.pos.x, self.pos.y)
    self.prev_position_index = self.prev_position_index + 1 
    if(self.prev_position_index == Medal.MAX_PREV_POSITIONS) then
        self.prev_position_index = 1
    end

    if(self.state == Medal.State.IDLE) then
        local float_speed = 2 
        local float_amplitude = 4
        local time = float_speed*(self.time + INITIAL_TIME_OFFSETS[self.color_name])
        self.pos.y = self.anchor.y + float_amplitude*math.sin(time)
        self.light.pos = V2(self.pos.x + self.width/2, self.pos.y + self.height/2)

    elseif(self.state == Medal.State.DESPAWNING) then
        self.pos.y = self.pos.y - dt*10
        self.light.pos.y = self.pos.y

        self.despawn_time = self.despawn_time + dt
        self.light.intensity = self.original_light_intensity * self:normalized_despawn_time()
        if(self.despawn_time > self.despawn_target_time) then
            self:despawn()
        end
    end
end

function Medal:draw()
    local quad_index = Medal.quad_for_color[self.color_name]
    local quad = Medal.quads[quad_index]

    if false then
        local top_left = self:hitbox().top_left
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("line", top_left.x, top_left.y, self.width, self.height)
        love.graphics.setColor(1, 1, 1)
    end

    local alpha = self:normalized_despawn_time()
    if self:should_show_transluscent() then
        alpha = alpha*0.2
    end

    for i, pos in pairs(self.prev_positions) do
        local r, g, b = lume.color(Medal.light_color_for_color_name[self.color_name])
        if self:should_show_transluscent() then
            local t = self:normalized_despawn_time()
            love.graphics.setColor(r, g, b, 0.05*0.2*easeOut(t, 10))
        else
            love.graphics.setColor(r, g, b, 0.05*alpha)
        end
        love.graphics.rectangle("fill", pos.x + 1, pos.y + 1, Medal.width - 2, Medal.height - 2)
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(Medal.image, quad, self.pos.x, self.pos.y)
    love.graphics.setColor(1, 1, 1)
end

function Medal:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + self.width, self.pos.y + self.height)
    )
end

function Medal:touched_by_player()
    if(self.state == Medal.State.IDLE) then
        self.state = Medal.State.DESPAWNING
        self:apply_medal_obtained_effects()
        self:play_medal_obtained_sounds()

        if not self:already_obtained() then
            self.despawning_for_the_first_time = true
        end

        game_state:obtain_medal(self)
    end
end

function Medal:despawn()
    self:delete_from_tile_map()
end

function Medal:delete_from_tile_map()
    game_state.tile_map:remove_point_light(self.light)
    game_state.tile_map:remove_medal(self)
end

function Medal:play_medal_obtained_sounds()
    Audio.play_sound("medal_obtained", 1, 1, 1.0)
    Audio.play_sound("falling_platform_revive", 1, 1, 0.35)
end

function Medal:apply_medal_obtained_effects()
    local center_pos = v2_add(self.pos, V2(self.width/2, self.height/2))
    game_state:apply_chromatic_aberration()
    game_state:apply_shockwave(center_pos)
    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 10.0, {
        particle_emitter = ParticleEmitter( {
            pos = self.pos,
            particle_type = ParticleType.emitter,
            particle_variant = ParticleVariant.medal,
            particles_per_second = 4,
            total_time = 2,
            gravity = 0,
            terminal_velocity = 0.1,
            gravity = 0.01,
            data = {
                color = Medal.light_color_for_color_name[self.color_name]
            }
        } ),
    })
end

function Medal:normalized_despawn_time()
    return 1 - self.despawn_time / self.despawn_target_time
end

function Medal:already_obtained()
    if game_state then
        return game_state:is_medal_obtained(self.color_name)
    end
end

function Medal:should_show_transluscent()
    if self.despawning_for_the_first_time then
        return false
    end

    local lobby_translucent = not self.is_interactible and not self:already_obtained()
    local regular_translucent = self.is_interactible and self:already_obtained()

    return lobby_translucent or regular_translucent
end
