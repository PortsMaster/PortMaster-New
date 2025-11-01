require("./math")

love.graphics.setDefaultFilter("nearest")
start_screen_background = love.graphics.newImage("caves-background.png")

start_screen_state = {
    title_time = 0,
    title_target_time = 0.8,

    subtitle_time = 0,
    subtitle_target_time = 1.0,

    action_time = 0,
    action_target_time = 1.0,
}

start_screen_particle_emiters = {}
start_screen_time = 0
start_screen_canvas = love.graphics.newCanvas(BASE_RESOLUTION.width, BASE_RESOLUTION.height, {
    dpiscale = 1
}) 
start_screen_transition = nil

start_screen_should_render = false

function init_start_screen_entities()
    local p_emitter = ParticleEmitter( {
        pos = V2(0, 0),
        particle_type = ParticleType.emitter,
        particle_variant = ParticleVariant.start_screen,
        particles_per_second = 2,
        total_time = -1,
        gravity = 0.01,
        terminal_velocity = 0.8,
        floaty = false,
        prepopulate = true
    } )
    table.insert(start_screen_particle_emiters, p_emitter)

    Audio.create_sound("sounds/start_pressed.mp3", "start_pressed")
end

function update_start_screen(dt)
    start_screen_time = start_screen_time + dt 

    start_screen_state.title_time = math.min(start_screen_state.title_time + dt, start_screen_state.title_target_time)

    if start_screen_state.title_time >= start_screen_state.title_target_time then
        start_screen_state.subtitle_time = math.min(start_screen_state.subtitle_time + dt, start_screen_state.subtitle_target_time)
    end

    if start_screen_state.subtitle_time >= start_screen_state.subtitle_target_time then
        start_screen_state.action_time = math.min(start_screen_state.action_time + dt, start_screen_state.action_target_time)
    end
end

function update_start_screen_frame(dt)
    if input.jump.is_pressed then
        if not start_screen_transition then
            start_screen_transition = Transition()
            Audio.play_sound("start_pressed", 1, 1, 0.5)
        end
    end
end

function draw_start_screen()
    -- Draw particles
    if start_screen_should_render then
        start_screen_should_render = false
        love.graphics.setCanvas(start_screen_canvas)
            love.graphics.clear()
            love.graphics.setColor(1, 1, 1)
            for _, p_emitter in pairs(start_screen_particle_emiters) do
                p_emitter:update_and_draw(start_screen_time)
            end
        love.graphics.setCanvas()
    end

    local offset = get_canvas_offset()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(start_screen_background, offset.x, offset.y, 0, scale, scale)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(start_screen_canvas, offset.x, offset.y, 0, scale, scale)

    local title_t = start_screen_state.title_time / start_screen_state.title_target_time
    UI.draw_start_screen_title(title_t)

    local subtitle_t = start_screen_state.subtitle_time / start_screen_state.subtitle_target_time
    UI.draw_start_screen_subtitle(subtitle_t)

    local action_t = start_screen_state.action_time / start_screen_state.action_target_time
    UI.draw_start_screen_action(action_t)
end
