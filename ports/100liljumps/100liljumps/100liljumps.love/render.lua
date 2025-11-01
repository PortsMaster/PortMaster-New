require("./ui")

EFFECT_TYPE = {
    shockwave = "shockwave",
    screenshake = "screenshake",
    direction_screenshake = "direction_screenshake",
    chromatic_aberration = "chromatic_aberration",
    particles = "particles",
    cinematic = "cinematic",
    slowdown = "slowdown",
}

Render = {}

-- For accesibility config checks
Render.screenshake_effects = {
    EFFECT_TYPE.screenshake,
    EFFECT_TYPE.direction_screenshake,
}
Render.effects_effects = {
    EFFECT_TYPE.shockwave,
    EFFECT_TYPE.chromatic_aberration,
}

Render.should_render = false

local BASE_RESOLUTION = {
    width = 320,
    height = 180
}

local dpi = love.window.getDPIScale()
Render.post_process_canvas = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})

Render.game_canvas = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.base_shadow_mask = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.shadow_mask = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.blurred_shadow_mask = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.solid_tiles_light_mask = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.point_lights_mask = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.dark_view_region_mask = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})

Render.light_mask = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.light_receiver_mask = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.scene = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})

local base_shadow_casting_frag = love.filesystem.read("shaders/base_shadow_casting.frag")
local base_shadow_casting_vert = love.filesystem.read("shaders/base_shadow_casting.vert")
base_shadow_casting_shader = love.graphics.newShader(base_shadow_casting_vert, base_shadow_casting_frag)

local shadow_casting_frag = love.filesystem.read("shaders/shadow_casting.frag")
shadow_casting_shader = love.graphics.newShader(nil, shadow_casting_frag)

local light_mask_frag = love.filesystem.read("shaders/light_mask.frag")
light_mask_shader = love.graphics.newShader(nil, light_mask_frag)

local scene_light_frag = love.filesystem.read("shaders/scene_light.frag")
scene_light_shader = love.graphics.newShader(nil, scene_light_frag)

local light_receiver_frag = love.filesystem.read("shaders/light_receiver.frag")
light_receiver_shader = love.graphics.newShader(nil, light_receiver_frag)

local point_light_frag = love.filesystem.read("shaders/point_light.frag")
point_light_shader = love.graphics.newShader(nil, point_light_frag)

local dark_view_region_frag = love.filesystem.read("shaders/dark_view_region.frag")
dark_view_region_shader = love.graphics.newShader(nil, dark_view_region_frag)

-- TODO: abstract into effect?
Render.effect_canvas_1 = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.effect_canvas_2 = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
-- effects
local shockwave_frag = love.filesystem.read("shaders/shockwave.frag")
shockwave_shader = love.graphics.newShader(nil, shockwave_frag)
local chromatic_aberration = love.filesystem.read("shaders/chromatic_aberration.frag")
chromatic_aberration_shader = love.graphics.newShader(nil, chromatic_aberration)

local directional_light_vert = love.filesystem.read("shaders/directional_light.vert")
local directional_light_frag = love.filesystem.read("shaders/directional_light.frag")
directional_light_shader = love.graphics.newShader(directional_light_vert, directional_light_frag)
local directional_light_effect_frag = love.filesystem.read("shaders/directional_light_effect.frag")
directional_light_effect_shader = love.graphics.newShader(nil, directional_light_effect_frag)
Render.directional_light_canvas_1 = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.directional_light_canvas_2 = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
})
Render.directional_light_texture_1 = love.graphics.newImage("jungle-light-mask-1.png")
Render.directional_light_texture_2 = love.graphics.newImage("jungle-light-mask-2.png")

Render.dark_entrance_mask = love.graphics.newImage("dark_entrance_mask.png")

local water_frag = love.filesystem.read("shaders/water.frag")
water_shader = love.graphics.newShader(nil, water_frag)

local mirror_frag = love.filesystem.read("shaders/mirror.frag")
mirror_shader = love.graphics.newShader(nil, mirror_frag)

Render.clear_cinematic = function()
    game_state.tile_map.effects = lume.filter(game_state.tile_map.effects, function(e)
        return e.type ~= EFFECT_TYPE.cinematic
    end)
end

Render.clear_lights = function()
    game_state.tile_map.point_lights = {}
end

Render.render = function(game_state, render)
    if Render.should_render then
        if(appleCake and profile_enabled) then
            appleCake.mark("render start")
        end
        Render.should_render = false
        local is_dark = game_state:is_dark()
        if(is_dark) then
            love.graphics.setCanvas(Render.scene)
                love.graphics.clear()
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", 0, 0, BASE_RESOLUTION.width, BASE_RESOLUTION.height)
                love.graphics.setColor(1, 1, 1)
            love.graphics.setCanvas()
            Render.render_dark_view_region_mask(game_state)
            Render.render_game_back_layers(game_state) -- game_canvas
            Render.render_scene(game_state) -- draw game_canvas appliyng light and shadows
            Render.render_entities(game_state)
            Render.render_player(game_state)
            Render.render_game_front_layers(game_state)
            Render.render_front_entities(game_state)
            Render.apply_effects(game_state)

            Render.clear_light_mask()
        else
            Render.render_game_back_layers(game_state) -- game_canvas
            Render.render_light_receiver_tiles_light_mask(game_state) -- all tiles that receive light
            Render.render_base_shadow_mask(game_state) -- shadow_mask
            Render.render_shadow_mask(game_state) -- shadow_mask
            Render.render_light_mask(game_state) -- light_mask
            Render.render_point_lights_mask(game_state) -- point lights mask
            if game_state.tile_map.has_jungle_light then
                Render.apply_directional_light(game_state)
            end

            Render.render_scene() -- draw game_canvas appliyng light and shadows
            Render.render_entities(game_state)
            Render.apply_point_lights(game_state)
            if game_state.tile_map.has_jungle_light then
                Render.apply_directional_light_effect()
            end
            Render.render_game_front_layers(game_state)
            Render.render_front_entities(game_state)
            love.graphics.setCanvas(Render.scene)
                game_state.tile_map:draw()
                love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
            love.graphics.setCanvas()
            Render.apply_effects(game_state)
            Render.apply_mirror_effects(game_state)
        end
        -- TODO use real scale
        -- transform or draw the canvas scaled
        -- love.graphics.draw(Render.game_canvas, 0, 0, 0, 4, 4)
        -- love.graphics.draw(Render.shadow_mask, 0, 0, 0, 4, 4)
        --love.graphics.draw(Render.light_mask, 0, 0, 0, 4, 4)
        --love.graphics.draw(Render.shadow_mask, 0, 0, 0, 4, 4)
        if(appleCake and profile_enabled) then
            appleCake.mark("render end")
        end
    end

    if false then
        love.graphics.draw(Render.scene, camera_x, camera_y, 0, 4+camera_zoom, 4+camera_zoom)
    else
        love.graphics.setColor(1.0, 1.0, 1.0)
        local width, height = love.graphics.getDimensions() 

        local offset = get_canvas_offset()
        local scale = resolution_scale()

        local background_color_hex_string = game_state.tile_map:background_color()
        love.graphics.setColor(lume.color(background_color_hex_string))
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1, 1, 1)

        love.graphics.draw(Render.scene, offset.x, offset.y, 0, scale, scale)
        if(dev_mode and love.keyboard.isDown("l")) then
            love.graphics.setColor(1.0, 1.0, 1.0, 0.5)
            love.graphics.draw(Render.light_receiver_mask, 0, 0, 0, scale, scale)
            love.graphics.setColor(1.0, 1.0, 1.0)
        end
    end
    UI.draw(game_state)
end

Render.render_shadow_casting_segments = function(game_state)
    -- debug: render segments
    if false then
        local shadow_casting_segments = game_state.tile_map.shadow_casting_segments
        if shadow_casting_segments then
            for x, s in pairs(shadow_casting_segments) do
                love.graphics.setColor(1, 0, 1)
                love.graphics.setLineWidth(1)
                love.graphics.line(s.a.x, s.a.y, s.b.x, s.b.y)
                love.graphics.setColor(0, 1, 1)
                love.graphics.circle("line", s.a.x, s.a.y, 1)
                love.graphics.circle("line", s.b.x, s.b.y, 1)
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
    if false then
        local segment_points = game_state.tile_map.segment_points
        if segment_points then
            for y, row in pairs(segment_points) do
                for x, sp in pairs(row) do
                    if sp then
                        love.graphics.setColor(0, 1, 1)
                        love.graphics.circle("line", (x-1)*TILE_SIZE, (math.floor(y/2)-1)*TILE_SIZE, 1)
                    end
                end
            end
            love.graphics.setColor(1, 1, 1)
        end
    end
end

Render.draw_dark_view_mask = function(game_state)
    local is_dark = game_state:is_dark()
    if(is_dark) then
        love.graphics.setBlendMode("multiply", "premultiplied")
        love.graphics.draw(Render.dark_view_region_mask)
        love.graphics.setBlendMode("alpha")
    end
end

Render.render_game_back_layers = function(game_state)
    love.graphics.setCanvas(Render.game_canvas)
    love.graphics.clear()
        game_state.tile_map:draw_background()
        game_state.tile_map:draw_back_layers()
        Render.draw_dark_view_mask(game_state)
    love.graphics.setCanvas()
end

Render.render_game_front_layers = function(game_state)
    love.graphics.setCanvas()
    Render.apply_water_effects(game_state)
    love.graphics.setCanvas()

    love.graphics.setCanvas(Render.effect_canvas_1)
        love.graphics.clear()

    love.graphics.setCanvas(Render.scene)
        game_state.tile_map:draw_front_layers()
        if(game_state.player_eaten_light_fly) then
            love.graphics.setColor(1, 1, 1 - easeOut(game_state.eaten_light_fly_time)*0.5)
        end
        love.graphics.draw(Render.effect_canvas_1)

        love.graphics.setColor(1, 1, 1)
        game_state.tile_map:draw_hidden_layers()
        Render.draw_dark_view_mask(game_state)

    love.graphics.setCanvas(Render.effect_canvas_1)
        love.graphics.clear()
    love.graphics.setCanvas()
end

Render.render_player = function(game_state)
    love.graphics.setColor(1, 1, 1)
    game_state.player:draw()
    love.graphics.setColor(1, 1, 1)
end

Render.render_base_shadow_mask = function(game_state)
    local shadow_casting_segments = game_state.tile_map.shadow_casting_segments
    local dynamic_shadow_casting_segments = game_state.tile_map:dynamic_shadow_casting_segments()

    love.graphics.setCanvas(Render.base_shadow_mask)
    love.graphics.clear()
    love.graphics.setShader(base_shadow_casting_shader)
        base_shadow_casting_shader:send("L", {game_state.player:light_position().x, game_state.player:light_position().y})
        for _, s in pairs(shadow_casting_segments) do
            love.graphics.draw(
                love.graphics.newMesh( -- TODO: generate meshes instead of segments
                    {
                        {"VertexPosition", "float", 3},
                    },
                    {
                        {s.a.x, s.a.y, 0},
                        {s.a.x, s.a.y, 1},
                        {s.b.x, s.b.y, 0},
                        {s.b.x, s.b.y, 1}
                    },
                    "strip"
                )
            )
        end
        for _, s in pairs(dynamic_shadow_casting_segments) do
            love.graphics.draw(
                love.graphics.newMesh( -- TODO: generate meshes instead of segments
                    {
                        {"VertexPosition", "float", 3},
                    },
                    {
                        {s.a.x, s.a.y, 0},
                        {s.a.x, s.a.y, 1},
                        {s.b.x, s.b.y, 0},
                        {s.b.x, s.b.y, 1}
                    },
                    "strip"
                )
            )
        end
    love.graphics.setShader()
    love.graphics.setCanvas()
end

Render.render_shadow_mask = function(game_state)
    local shadow_casting_segments = game_state.tile_map.shadow_casting_segments

    love.graphics.setCanvas(Render.shadow_mask)
    love.graphics.clear()
    love.graphics.setShader(shadow_casting_shader)
        love.graphics.draw(Render.base_shadow_mask)
    love.graphics.setShader()
    love.graphics.setCanvas()
end

Render.render_light_mask = function(game_state)
    local is_temple = game_state.tile_map.has_temple_light
    local light_intensity = 1.0
    if(is_temple) then
        light_intensity = 0.5
    end
    local light_radius = 0.10
    local light_color = {1, 1, 1}
    local eaten_light_fly_scale = easeOut(game_state.eaten_light_fly_time)
    if(game_state.player_eaten_light_fly) then
        light_radius = math.max(0.15 * eaten_light_fly_scale, light_radius)
        light_color = {
            light_color[1] - eaten_light_fly_scale*0.2,
            light_color[2],
            light_color[3] - eaten_light_fly_scale*0.2
        }
        light_intensity = math.max(2.0 * eaten_light_fly_scale, light_intensity)
    end
    love.graphics.setCanvas(Render.light_mask)
    love.graphics.clear()
    love.graphics.setShader(light_mask_shader)
        light_mask_shader:send("L", {game_state.player:light_position().x, game_state.player:light_position().y})
        light_mask_shader:send("light_intensity", light_intensity)
        light_mask_shader:send("light_radius", light_radius)
        light_mask_shader:send("light_color", light_color)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, BASE_RESOLUTION.width, BASE_RESOLUTION.height)
    love.graphics.setShader()
    love.graphics.setCanvas()
end

Render.render_point_lights_mask = function(game_state)
    if #game_state.tile_map.point_lights == 0 then
        love.graphics.setCanvas(Render.point_lights_mask)
            love.graphics.clear()
        love.graphics.setCanvas()
        return
    end

    love.graphics.setCanvas(Render.point_lights_mask)
    love.graphics.clear()
    love.graphics.setShader(point_light_shader)
        local n_lights = 0
        local index = 1
        for i, l in pairs(game_state.tile_map.point_lights) do
            love.graphics.setColor(1, 1, 1)
            if index > 100 then
                print("max lights limit reached")
                break
            end
            if(l.visible) then
                point_light_shader:send("lights["..(index-1).."].pos", {l.pos.x, l.pos.y})
                point_light_shader:send("lights["..(index-1).."].color", {lume.color(l.color)})
                point_light_shader:send("lights["..(index-1).."].radius", l.radius)
                point_light_shader:send("lights["..(index-1).."].intensity", l.intensity)
                index = index + 1
                n_lights = n_lights + 1
            end
        end
        point_light_shader:send("n_lights", n_lights)
        love.graphics.rectangle("fill", 0, 0, BASE_RESOLUTION.width, BASE_RESOLUTION.height)

    love.graphics.setShader()
    love.graphics.setCanvas()
end

Render.render_entities = function(game_state)
    love.graphics.setCanvas(Render.scene)
        game_state.tile_map:draw_entities()
        Render.draw_dark_view_mask(game_state)
    love.graphics.setCanvas()
end

Render.render_front_entities = function(game_state)
    love.graphics.setCanvas(Render.scene)
        game_state.tile_map:draw_front_entities()
        Render.draw_dark_view_mask(game_state)
    love.graphics.setCanvas()
end

Render.apply_point_lights = function(game_state)
    love.graphics.setCanvas(Render.scene)
        love.graphics.setBlendMode("add")
        love.graphics.draw(Render.point_lights_mask)
        love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()
end

Render.render_scene = function()
    love.graphics.setCanvas(Render.scene)
    love.graphics.clear()
    love.graphics.setShader(scene_light_shader)
        scene_light_shader:send("shadow_mask", Render.shadow_mask)
        scene_light_shader:send("light_mask", Render.light_mask)
        scene_light_shader:send("point_lights_mask", Render.point_lights_mask)
        scene_light_shader:send("light_receiver_mask", Render.light_receiver_mask)
        love.graphics.draw(Render.game_canvas)
        Render.draw_dark_view_mask(game_state)
    love.graphics.setShader()
    love.graphics.setCanvas()
end

Render.update_timers = function(dt, game_state)
    game_state.tile_map:update_timers(dt)
end

Render.apply_effects = function(game_state)
    for _, effect in pairs(game_state.tile_map.effects) do
        if(effect.type == EFFECT_TYPE.shockwave) then
            love.graphics.setCanvas(Render.effect_canvas_1)
            shockwave_shader:send("time", effect.time)
            shockwave_shader:send("shockwave_origin", effect.data.shockwave_origin)
            love.graphics.setShader(shockwave_shader)
                love.graphics.clear()
                love.graphics.draw(Render.scene)
            love.graphics.setShader()
            love.graphics.setCanvas()

            love.graphics.setCanvas(Render.scene)
                love.graphics.draw(Render.effect_canvas_1)
            love.graphics.setCanvas()
        end

        if(effect.type == EFFECT_TYPE.screenshake) then
            local x_offset = lume.round(2*(math.random() - 0.5))
            local y_offset = lume.round(2*(math.random() - 0.5))

            love.graphics.setCanvas(Render.effect_canvas_1)
                love.graphics.clear()
                love.graphics.draw(Render.scene, 0, 0, 0, 1, 1, x_offset, y_offset)
            love.graphics.setCanvas()

            love.graphics.setCanvas(Render.scene)
                love.graphics.draw(Render.effect_canvas_1)
            love.graphics.setCanvas()
        end

        if(effect.type == EFFECT_TYPE.direction_screenshake) then
            local y_offset = 0
            local x_offset = 0
            if(effect.data.direction == "up") then
                y_offset = 1
            end
            if(effect.data.direction == "down") then
                y_offset = -1 
            end
            if(effect.data.direction == "left") then
                x_offset = 1 
            end
            if(effect.data.direction == "right") then
                x_offset = -1 
            end

            love.graphics.setCanvas(Render.effect_canvas_1)
                love.graphics.clear()
                love.graphics.draw(Render.scene, 0, 0, 0, 1, 1, x_offset, y_offset)
            love.graphics.setCanvas()

            love.graphics.setCanvas(Render.scene)
                love.graphics.draw(Render.effect_canvas_1)
            love.graphics.setCanvas()
        end

        if(effect.type == EFFECT_TYPE.chromatic_aberration) then
            love.graphics.setCanvas(Render.effect_canvas_1)
            chromatic_aberration_shader:send("time", effect.time)
            chromatic_aberration_shader:send("total_time", effect.target_time)
            love.graphics.setShader(chromatic_aberration_shader)
                love.graphics.clear()
                love.graphics.draw(Render.scene)
            love.graphics.setShader()
            love.graphics.setCanvas()

            love.graphics.setCanvas(Render.scene)
                love.graphics.draw(Render.effect_canvas_1)
            love.graphics.setCanvas()
        end

        if(effect.type == EFFECT_TYPE.particles) then
            love.graphics.setCanvas(Render.scene)
                effect.data.particle_emitter:update_and_draw(effect.time)
            love.graphics.setCanvas()
        end

        if(effect.type == EFFECT_TYPE.cinematic) then
            local target_height = 20
            local target_time = 0.4
            local t = 0
            local bar_height = 0
            if(effect.data.type == "in") then
                t = math.min(effect.time / target_time, 1)
                bar_height = lume.lerp(0, target_height, easeOut(t, 0.8))
            elseif(effect.data.type == "out") then
                t = math.min(effect.time / target_time, 1)
                bar_height = lume.lerp(0, target_height, 1 - easeOut(t, 0.8))
            end

            love.graphics.setCanvas(Render.scene)
                love.graphics.setColor(0, 0, 0, 0.8)
                love.graphics.rectangle("fill", 0, 0, BASE_RESOLUTION.width, bar_height)
                love.graphics.rectangle("fill", 0, BASE_RESOLUTION.height - bar_height, BASE_RESOLUTION.width, bar_height)
                love.graphics.setColor(1, 1, 1)
            love.graphics.setCanvas()
        end

        if(effect.type == EFFECT_TYPE.slowdown) then
            local TARGET_FPS = 60
            local BOTTOM_FPS = 10

            local fps = lume.lerp(BOTTOM_FPS, TARGET_FPS, effect.time / effect.target_time)
            fps = lume.round(fps)
            if (effect.time / effect.target_time) > 0.8 then
                fps = BASE_FRAMES
            end

            FRAMES = fps
        end
    end

    love.graphics.setCanvas(Render.scene)
        game_state:draw()
        Render.draw_dark_view_mask(game_state)
    love.graphics.setCanvas()
end

Render.apply_directional_light = function(game_state, angle)
    local shadow_casting_segments = game_state.tile_map.shadow_casting_segments
    directional_light_shader:send("shadow_intensity", 1.0)

    -- light 1
    love.graphics.setCanvas(Render.directional_light_canvas_1)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, BASE_RESOLUTION.width, BASE_RESOLUTION.height)

    love.graphics.setShader(directional_light_shader)
        directional_light_shader:send("dir", {2, 1})
        for _, s in pairs(shadow_casting_segments) do
            -- TODO: parametrize
            -- hardcoded limits based on light map
            local c1 = (s.a.x >= 96 and s.a.y >= 127) or (s.b.x >= 96 and s.b.y >= 127)
            local c2 = (s.a.x >= 119 and s.a.y >= 104) or (s.b.x >= 119 and s.b.y >= 104)

            if(c1 or c2) then
                love.graphics.draw(
                    love.graphics.newMesh( -- TODO: generate meshes instead of segments
                        {
                            {"VertexPosition", "float", 3},
                        },
                        {
                            {s.a.x, s.a.y, 0},
                            {s.a.x, s.a.y, 1},
                            {s.b.x, s.b.y, 0},
                            {s.b.x, s.b.y, 1}
                        },
                        "strip"
                    )
                )
            end
        end
        for _, fp in pairs(game_state.tile_map.falling_columns) do
            for _, s in pairs(fp:shadow_casting_segments()) do
            -- TODO: parametrize
            -- hardcoded limits based on light map
            local c1 = (s.a.x >= 96 and s.a.y >= 127) or (s.b.x >= 96 and s.a.y >= 127)
            local c2 = (s.a.x >= 119 and s.a.y >= 104) or (s.b.x >= 119 and s.a.y >= 104)

            if(c1 or c2) then
                love.graphics.draw(
                    love.graphics.newMesh( -- TODO: generate meshes instead of segments
                        {
                            {"VertexPosition", "float", 3},
                        },
                        {
                            {s.a.x, s.a.y, 0},
                            {s.a.x, s.a.y, 1},
                            {s.b.x, s.b.y, 0},
                            {s.b.x, s.b.y, 1}
                        },
                        "strip"
                    )
                )
            end
            end
        end
        local draw_player_shadow = false
        for _, s in pairs(game_state.player:shadow_casting_segments()) do
            local c1 = (s.a.x >= 96 and s.a.y >= 102) or (s.b.x >= 96 and s.a.y >= 102)
            local c2 = (s.a.x >= 119 and s.a.y >= (104 - 3*TILE_SIZE)) or (s.b.x >= 119 and s.a.y >= (104 - 3*TILE_SIZE))
            if(c1 or c2) then
                draw_player_shadow = true
            end
            local dx = math.min(math.max(game_state.player.pos.x - (96 - TILE_SIZE), 0), 16) / 16;
            local dy = math.min(math.max(game_state.player.pos.y - (104 - 4*TILE_SIZE), 0), 16) / 16;
            local intensity = math.min(dx, dy)
            directional_light_shader:send("shadow_intensity", intensity)

            if(draw_player_shadow) then
                love.graphics.draw(
                    love.graphics.newMesh( -- TODO: generate meshes instead of segments
                        {
                            {"VertexPosition", "float", 3},
                        },
                        {
                            {s.a.x, s.a.y, 0},
                            {s.a.x, s.a.y, 1},
                            {s.b.x, s.b.y, 0},
                            {s.b.x, s.b.y, 1}
                        },
                        "strip"
                    )
                )
            end
        end
    directional_light_shader:send("shadow_intensity", 1.0)
    love.graphics.setShader()
    love.graphics.setBlendMode("multiply", "premultiplied")
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(Render.directional_light_texture_1)
    love.graphics.setBlendMode("alpha")

    -- light 2
    love.graphics.setCanvas(Render.directional_light_canvas_2)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, BASE_RESOLUTION.width, BASE_RESOLUTION.height)

    love.graphics.setShader(directional_light_shader)
        directional_light_shader:send("dir", {2, 1})
        directional_light_shader:send("shadow_intensity", 1.0)
        love.graphics.rectangle("fill", 0, 0, BASE_RESOLUTION.width, BASE_RESOLUTION.height)
        for _, s in pairs(shadow_casting_segments) do
            -- TODO: parametrize
            -- hardcoded limits based on light map
            local c1 = (s.a.x >= 208 and s.a.y >= 47) or (s.b.x >= 208 and s.a.y >= 47)
            local c2 = (s.a.x >= 231 and s.a.y >= 24) or (s.b.x >= 231 and s.a.y >= 24)

            if(c1 or c2) then
                love.graphics.draw(
                    love.graphics.newMesh( -- TODO: generate meshes instead of segments
                        {
                            {"VertexPosition", "float", 3},
                        },
                        {
                            {s.a.x, s.a.y, 0},
                            {s.a.x, s.a.y, 1},
                            {s.b.x, s.b.y, 0},
                            {s.b.x, s.b.y, 1}
                        },
                        "strip"
                    )
                )
            end
        end
        for _, fp in pairs(game_state.tile_map.falling_columns) do
            for _, s in pairs(fp:shadow_casting_segments()) do
                local c1 = (s.a.x >= 208 and s.a.y >= 47) or (s.b.x >= 208 and s.a.y >= 47)
                local c2 = (s.a.x >= 231 and s.a.y >= 24) or (s.b.x >= 231 and s.a.y >= 24)

                if(c1 or c2) then
                    love.graphics.draw(
                        love.graphics.newMesh( -- TODO: generate meshes instead of segments
                            {
                                {"VertexPosition", "float", 3},
                            },
                            {
                                {s.a.x, s.a.y, 0},
                                {s.a.x, s.a.y, 1},
                                {s.b.x, s.b.y, 0},
                                {s.b.x, s.b.y, 1}
                            },
                            "strip"
                        )
                    )
                end
            end
        end
        local draw_player_shadow = false
        for _, s in pairs(game_state.player:shadow_casting_segments()) do
            local c2 = (s.a.x >= 208 and s.a.y >= 24) or (s.b.x >= 208 and s.a.y >= 24)
            if(c2) then
                draw_player_shadow = true
            end
        end
        for _, s in pairs(game_state.player:shadow_casting_segments()) do
            if(draw_player_shadow) then
                local dx = math.min(math.max(game_state.player.pos.x - (208 - TILE_SIZE), 0), 32) / 32;
                local dy = math.min(math.max(game_state.player.pos.y - (24 - TILE_SIZE), 0), 32) / 32;
                local intensity = math.min(dx, dy)
                directional_light_shader:send("shadow_intensity", intensity)
                love.graphics.draw(
                    love.graphics.newMesh( -- TODO: generate meshes instead of segments
                        {
                            {"VertexPosition", "float", 3},
                        },
                        {
                            {s.a.x, math.min(s.a.y, 24), 0},
                            {s.a.x, s.a.y, 1},
                            {s.b.x, math.min(s.b.y, 24), 0},
                            {s.b.x, s.b.y, 1}
                        },
                        "strip"
                    )
                )
            end
        end
    directional_light_shader:send("shadow_intensity", 1.0)
    love.graphics.setShader()
    love.graphics.setBlendMode("multiply", "premultiplied")
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(Render.directional_light_texture_2)
    love.graphics.setBlendMode("alpha")

    love.graphics.setCanvas()
end

Render.apply_directional_light_effect = function()
    love.graphics.setCanvas(Render.effect_canvas_1)
        love.graphics.clear()
        directional_light_effect_shader:send("mask_1", Render.directional_light_canvas_1)
        directional_light_effect_shader:send("mask_2", Render.directional_light_canvas_2)
        
        love.graphics.setShader(directional_light_effect_shader)
            love.graphics.draw(Render.scene)
        love.graphics.setShader()
    love.graphics.setCanvas()

    love.graphics.setCanvas(Render.scene)
        love.graphics.draw(Render.effect_canvas_1)
    love.graphics.setCanvas()
end

Render.clear_effects = function()
    FRAMES = BASE_FRAMES
    game_state.tile_map.effects = {}
end

Render.apply_mirror_effects = function(game_state)
    if(not game_state.tile_map.mirrors or #game_state.tile_map.mirrors == 0) then
        return
    end

    love.graphics.setCanvas(Render.effect_canvas_1)
        love.graphics.clear()
        love.graphics.setShader(mirror_shader)
        for _, mirror in pairs(game_state.tile_map.mirrors) do
            mirror_shader:send("left_x", mirror.pos.x)
            mirror_shader:send("width", mirror.width)
            mirror_shader:send("scene", Render.scene)
            mirror_shader:send("direction", mirror.direction)
            love.graphics.rectangle("fill", mirror.pos.x, mirror.pos.y, mirror.width, mirror.height)
        end
        love.graphics.setShader()
    love.graphics.setCanvas()

    love.graphics.setCanvas(Render.scene)
        love.graphics.draw(Render.effect_canvas_1)
    love.graphics.setCanvas()
end

Render.apply_water_effects = function(game_state)
    love.graphics.setCanvas(Render.effect_canvas_1)
        love.graphics.clear()
        game_state.tile_map:draw_water_tiles()
    love.graphics.setCanvas()
    if not game_state.tile_map.top_water_y then
        love.graphics.setCanvas(Render.scene)
            Render.render_player(game_state)
        love.graphics.setCanvas()
        return
    end

    love.graphics.setCanvas(Render.scene)
        Render.render_player(game_state)
    love.graphics.setCanvas()

    love.graphics.setCanvas(Render.effect_canvas_2)
        love.graphics.clear()
        water_shader:send("time", game_state.time)
        water_shader:send("top_y", game_state.tile_map.top_water_y)
        water_shader:send("water_tiles_mask", Render.effect_canvas_1)
        love.graphics.setShader(water_shader)
            love.graphics.draw(Render.scene)
        love.graphics.setShader()
    love.graphics.setCanvas()

    love.graphics.setCanvas(Render.scene)
        love.graphics.draw(Render.effect_canvas_2)
    love.graphics.setCanvas()
end

Render.render_light_receiver_tiles_light_mask = function(game_state)
    love.graphics.setCanvas(Render.light_receiver_mask)
    love.graphics.setShader(light_receiver_shader)
    love.graphics.clear()
        love.graphics.setColor(1, 1, 1)
        game_state.tile_map:draw_back_layers()
    love.graphics.setShader()
    love.graphics.setCanvas()
end

Render.render_dark_view_region_mask = function(game_state)
    love.graphics.setCanvas(Render.dark_view_region_mask)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, BASE_RESOLUTION.width, BASE_RESOLUTION.height)

        if(game_state.player_eaten_light_fly) then
            love.graphics.setShader(dark_view_region_shader)
                local n_lights = 1
                dark_view_region_shader:send("lights[".. 0 .."].pos", {game_state.player.pos.x + TILE_SIZE/2, game_state.player.pos.y + TILE_SIZE/2})
                dark_view_region_shader:send("lights[".. 0 .."].radius", 0.92)
                dark_view_region_shader:send("lights[".. 0 .."].alpha", 1.0)

                for _, door in pairs(game_state.tile_map.doors) do
                    if (door.visible) then
                        n_lights = n_lights + 1
                        local door_x = door.pos.x + door.width/2
                        local door_y = door.pos.y + door.height/2
                        dark_view_region_shader:send("lights["..(n_lights-1).."].pos", {door_x, door_y})
                        dark_view_region_shader:send("lights["..(n_lights-1).."].radius", 0.95)
                        dark_view_region_shader:send("lights["..(n_lights-1).."].alpha", 1.0)
                    end
                end

                for _, medal in pairs(game_state.tile_map.medals) do
                    n_lights = n_lights + 1
                    local medal_x = medal.pos.x + medal.width/2
                    local medal_y = medal.pos.y + medal.height/2
                    local medal_alpha = 1.0 - medal.despawn_time / medal.despawn_target_time
                    medal_alpha = easeOut(medal_alpha)
                    dark_view_region_shader:send("lights["..(n_lights-1).."].pos", {medal_x, medal_y})
                    dark_view_region_shader:send("lights["..(n_lights-1).."].radius", 0.96)
                    dark_view_region_shader:send("lights["..(n_lights-1).."].alpha", medal_alpha)
                end

                dark_view_region_shader:send("n_lights", n_lights)
                dark_view_region_shader:send("time", game_state.time)

                love.graphics.rectangle("fill", 0, 0, BASE_RESOLUTION.width, BASE_RESOLUTION.height)

                local first_dark_level = game_state.tile_map.name == "dark_01"

            love.graphics.setShader()
            local first_dark_level = game_state.tile_map.name == "dark_01"

            if first_dark_level then
                love.graphics.setColor(1, 1, 1)
                love.graphics.setBlendMode("lighten", "premultiplied")
                local w = Render.dark_entrance_mask:getWidth()
                love.graphics.draw(Render.dark_entrance_mask, BASE_RESOLUTION.width/2 - w/2, 0)
                love.graphics.setBlendMode("alpha")
            end
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.setBlendMode("alpha")
            local first_dark_level = game_state.tile_map.name == "dark_01"

            if first_dark_level then
                local w = Render.dark_entrance_mask:getWidth()
                love.graphics.draw(Render.dark_entrance_mask, BASE_RESOLUTION.width/2 - w/2, 0)
            end

            game_state.player:draw()
        end
    love.graphics.setCanvas()
end

Render.clear_light_mask = function()
    love.graphics.setCanvas(Render.light_mask)
    love.graphics.clear()
    love.graphics.setCanvas()
end
