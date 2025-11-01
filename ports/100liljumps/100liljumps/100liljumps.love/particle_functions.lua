local nara_image = love.graphics.newImage("nara.png")

function exploding_nara_particles(pos)
    local c1 = "#076149"
    local c2 = "#09b386"
    local c3 = "#000000"
    local c4 = "#0bd19d"
    local c5 = "#0a916d"
    local c6 = "#afe8d9"
    local nara_colors = {c1, c2, c3, c4, c5, c6}

    local nara_map = {
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 1, 2, 2, 2, 2, 0},
        {0, 1, 2, 3, 2, 2, 3, 2},
        {0, 1, 2, 2, 2, 2, 2, 2},
        {1, 1, 4, 2, 2, 5, 5, 5},
        {1, 4, 2, 2, 4, 6, 6, 0},
        {1, 4, 2, 2, 2, 4, 0, 0},
        {1, 1, 4, 4, 0, 4, 0, 0},
    }

    local particles = {}
    for y, row in pairs(nara_map) do
        for x, c in pairs(row) do
            local p_pos = V2(pos.x + (x-1), pos.y + (y-1))
            if(c > 0) then
                local v = nil
                local p = nil
                local random_vel = nil
                local random_angle = nil
                local x_vel = 0
                local y_vel = 0

                random_vel = 1.3*math.random()
                random_angle = math.random()*2*math.pi
                x_vel = math.cos(random_angle)*random_vel
                y_vel = -math.abs(math.sin(random_angle)*2*random_vel)
                v = V2(x_vel, y_vel)
                p = create_particle(p_pos, v, nara_colors[c], 1)
                table.insert(particles, p)

                random_vel = 1.3*math.random()
                random_angle = math.random()*2*math.pi
                x_vel = math.cos(random_angle)*random_vel
                y_vel = -math.abs(math.sin(random_angle)*2*random_vel)
                v = V2(x_vel, y_vel)
                p = create_particle(p_pos, v, nara_colors[c], 2)
                table.insert(particles, p)
            end
        end
    end

    return particles
end

function exploding_snail_particles(pos)
    local c1 = "rgba(132, 0, 0, 0.8)"
    local c2 = "rgba(186, 17, 17, 0.8)"
    local c3 = "rgba(204, 96, 63, 0.8)"
    local c4 = "rgba(128, 60, 40, 0.8)"
    local snail_colors = {c1, c2, c3, c4}

    local particles = {}
    local particles_amnt = 10
    for t = 1, particles_amnt do
        local p_pos = V2(pos.x + math.random()*TILE_SIZE, pos.y + math.random()*TILE_SIZE)
        local v = nil
        local p = nil
        local random_vel = nil
        local random_angle = nil
        local x_vel = 0
        local y_vel = 0

        local rand_color_index = math.floor(lume.lerp(1, #snail_colors, math.random()))

        random_vel = 1.3*math.random()
        random_angle = math.random()*2*math.pi
        x_vel = math.cos(random_angle)*random_vel
        y_vel = -math.abs(math.sin(random_angle)*2*random_vel)
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, snail_colors[rand_color_index], 1)
        table.insert(particles, p)

        random_vel = 1.3*math.random()
        random_angle = math.random()*2*math.pi
        x_vel = math.cos(random_angle)*random_vel
        y_vel = -math.abs(math.sin(random_angle)*2*random_vel)
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, snail_colors[rand_color_index], 2)
        table.insert(particles, p)
    end

    return particles
end

function create_falling_platform_particle(pos)
    local c1 = "#3f6e8a"
    local c2 = "#2a4859"
    local c3 = "#7ac4f0"
    local c4 = "#65a3c7"
    local colors = {c1, c2, c3, c4}

    local p_pos = V2(pos.x + math.random()*TILE_SIZE, pos.y + math.random()*TILE_SIZE)
    local v = nil
    local p = nil

    local rand_color_index = math.floor(lume.lerp(1, #colors + 0.1, math.random()))

    local x_vel = 0
    local y_vel = 0
    v = V2(x_vel, y_vel)
    return create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(0.5, 0.8, math.random()))
end

function nara_landing_particles(pos)
    local c1 = "rgba(255, 255, 255, 0.5)"
    local c2 = "rgba(170, 170, 170, 0.5)"
    local colors = {c1, c2}

    local particles = {}
    local particles_amnt = 10
    for t = 1, particles_amnt do
        local p_pos = V2(pos.x + TILE_SIZE/2 + ((math.random() - 0.5)*TILE_SIZE/4), pos.y + TILE_SIZE)
        local v = nil
        local p = nil
        local x_vel = 0
        local y_vel = 0

        local rand_color_index = lume.round(lume.lerp(1, #colors, math.random()))

        local random_vel = 1.3*(math.random() - 0.5)
        x_vel = 0.5*random_vel
        y_vel = -0.3*math.random()
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(0.2, 0.5, math.random()))
        table.insert(particles, p)
    end

    return particles
end

function bouncer_particles(pos)
    local c1 = "rgba(118, 66, 138, 0.5)"
    local c2 = "rgba(92, 43, 110, 0.5)"
    local colors = {c1, c2}

    local particles = {}
    local particles_amnt = 5
    for t = 1, particles_amnt do
        local p_pos = V2(pos.x + TILE_SIZE/2, pos.y + TILE_SIZE/2)
        local v = nil
        local p = nil
        local x_vel = 0
        local y_vel = 0

        local rand_color_index = lume.round(lume.lerp(1, #colors, math.random()))

        local random_vel = (math.random() - 0.5)
        x_vel = 0.8*random_vel
        y_vel = -0.8*math.random()
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 2, lume.lerp(0.2, 0.5, math.random()))
        table.insert(particles, p)

        random_vel = (math.random() - 0.5)
        x_vel = 0.8*random_vel
        y_vel = -0.8*math.random()
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(0.2, 0.8, math.random()))
        table.insert(particles, p)
    end

    return particles
end

function landing_vine_particles(pos)
    local c1 = "rgba(80, 159, 20, 0.5)"
    local c2 = "rgba(135, 209, 7, 0.5)"
    local colors = {c1, c2}

    local particles = {}
    local particles_amnt = 5
    for t = 1, particles_amnt do
        local p_pos = V2(pos.x + TILE_SIZE/2, pos.y + math.random()*TILE_SIZE)
        local v = nil
        local p = nil
        local x_vel = 0
        local y_vel = 0

        local rand_color_index = lume.round(lume.lerp(1, #colors, math.random()))

        local random_vel = (math.random() - 0.5)
        x_vel = 0.8*random_vel
        y_vel = 0.1*math.random()
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(1.0, 4, math.random()))
        table.insert(particles, p)
    end

    return particles
end

function climbing_vine_particles(pos)
    local c1 = "rgba(80, 159, 20, 0.5)"
    local c2 = "rgba(135, 209, 7, 0.5)"
    local colors = {c1, c2}

    local particles = {}
    local particles_amnt = 1 
    for t = 1, particles_amnt do
        local p_pos = V2(pos.x + TILE_SIZE/2, pos.y + math.random()*TILE_SIZE)
        local v = nil
        local p = nil
        local x_vel = 0
        local y_vel = 0

        local rand_color_index = lume.round(lume.lerp(1, #colors, math.random()))

        local random_vel = (math.random() - 0.5)
        x_vel = 0.8*random_vel
        y_vel = 0.1*math.random()
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(1.0, 4, math.random()))
        table.insert(particles, p)
    end

    return particles
end

function exploding_spike(pos)
    local c1 = "#fff0e4"
    local c2 = "#ded1c8"
    local colors = {c1, c2}

    local particles = {}
    local particles_amnt = 5
    for t = 1, particles_amnt do
        local p_pos = V2(pos.x + math.random()*TILE_SIZE, pos.y + math.random()*TILE_SIZE)
        local v = nil
        local p = nil
        local random_vel = nil
        local random_angle = nil
        local x_vel = 0
        local y_vel = 0

        local rand_color_index = math.floor(lume.lerp(1, #colors, math.random()))

        random_vel = 1.2*math.random()
        random_angle = math.random()*2*math.pi
        x_vel = math.cos(random_angle)*random_vel
        y_vel = -math.abs(math.sin(random_angle)*2*random_vel)
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 1, math.random())
        table.insert(particles, p)

        random_vel = 1.2*math.random()
        random_angle = math.random()*2*math.pi
        x_vel = math.cos(random_angle)*random_vel
        y_vel = -math.abs(math.sin(random_angle)*2*random_vel)
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 2, math.random())
        table.insert(particles, p)
    end

    return particles
end

function falling_spike(pos)
    local c1 = "rgba(255, 240, 228, 0.5)"
    local c2 = "rgba(222, 209, 200, 0.5)"
    local colors = {c1, c2}

    local particles = {}
    local particles_amnt = 4
    for t = 1, particles_amnt do
        local p_pos = V2(pos.x + math.random()*TILE_SIZE, pos.y)
        local v = nil
        local p = nil
        local random_vel = nil
        local x_vel = 0
        local y_vel = 0

        local rand_color_index = math.floor(lume.lerp(1, #colors, math.random()))

        random_vel = 0.5*2*(math.random()-0.5)
        x_vel = random_vel
        y_vel = 0
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 1, math.random())
        table.insert(particles, p)

        random_vel = 0.5*2*(math.random()-0.5)
        x_vel = random_vel
        y_vel = 0
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 2, math.random())
        table.insert(particles, p)
    end

    return particles
end

function create_portal_particle(pos)
    local c1 = "#dbf7ff"
    local c2 = "#4bd2fb"
    local colors = {c1, c2}

    local p_pos = V2(pos.x + math.random()*TILE_SIZE, pos.y + math.random()*TILE_SIZE)
    local v = nil
    local p = nil

    local rand_color_index = math.floor(math.random()*#colors) + 1

    local x_vel = 0
    local y_vel = 0
    v = V2(x_vel, y_vel)
    return create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(1.0, 2, math.random()), true)
end

function splash(pos)
    local c1 = "rgba(172, 224, 240, 1)"
    local c2 = "rgba(240, 240, 240, 0.4)"
    local c3 = "rgba(112, 201, 228, 1)"
    local c4 = "rgba(11, 178, 234, 1)"
    local colors = {c1, c2, c3, c4}

    local particles = {}
    local particles_amnt = 5
    for t = 1, particles_amnt do
        local p_pos = V2(pos.x + TILE_SIZE/2, pos.y + TILE_SIZE)
        local v = nil
        local p = nil
        local random_vel = nil
        local random_angle = nil
        local x_vel = 0
        local y_vel = 0

        local rand_color_index = lume.round(lume.lerp(1, #colors, math.random()))
        local splash_angle_top    = 0.9
        local splash_angle_bottom = 0.4
        local live_max = 0.4
        local live_min = 0.1

        --left
        random_vel = lume.lerp(0.6, 0.7, math.random())
        random_angle = lume.lerp(math.pi - splash_angle_top, math.pi - splash_angle_bottom, math.random())
        x_vel = 1.0*math.cos(random_angle)*random_vel
        y_vel = -1.0*math.abs(math.sin(random_angle)*2*random_vel)
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(live_min, live_max, math.random()), true)
        table.insert(particles, p)

        --right
        random_vel = lume.lerp(0.6, 0.7, math.random())
        random_angle = lume.lerp(splash_angle_bottom, splash_angle_top, math.random())
        x_vel = 1.0*math.cos(random_angle)*random_vel
        y_vel = -1.0*math.abs(math.sin(random_angle)*2*random_vel)
        v = V2(x_vel, y_vel)
        p = create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(live_min, live_max, math.random()), true)
        table.insert(particles, p)
    end

    return particles
end

function sleep(pos, data)
    local particles = {}
    local colors = {"#afe8d9", "#c2a7cc", "#ebcac0"}
    local selected_color = lume.randomchoice(colors)
    local positions = {
        {1, 1, 1, 1},
        {2, 2, 1, 2},
        {0, 1, 2, 0},
        {1, 1, 1, 1},
        {2, 2, 2, 2},
    }
    local v = V2(data.dir*math.max(math.random()*0.4, 0.2), -math.max(math.random()*0.3, 0.1))
    for y, row in pairs(positions) do
        for x, color in pairs(row) do
            if (color ~= 0) then
                if (color == 1) then
                    p = create_particle(V2(pos.x + x - 1, pos.y + y - 1), v, selected_color, 1, 0.8, true)
                    table.insert(particles, p)
                else
                    p = create_particle(V2(pos.x + x - 1, pos.y + y - 1), v, "#000000", 1, 0.8, true)
                    table.insert(particles, p)
                end
            end
        end
    end

    return particles
end

function create_smoke_particle(pos, data)
    local c1 = "#555555"
    local c2 = "#888888"
    local c3 = "#aaaaaa"
    local colors = {c1, c2, c3}

    local width = 24
    local p_pos_1 = V2(pos.x + 4 + TILE_SIZE + math.random()*TILE_SIZE, pos.y + 0.3*TILE_SIZE)
    local p_pos_2 = V2(pos.x + math.random()*TILE_SIZE, pos.y + 0.3*TILE_SIZE)
    local p_pos = lume.randomchoice({p_pos_1, p_pos_2})
    local v = nil
    local p = nil

    local rand_color_index = math.floor(math.random()*#colors) + 1

    local x_vel = 0
    local y_vel = -0.5
    v = V2(x_vel, y_vel)

    local choices = {1,2,3}
    local choice = lume.randomchoice(choices)
    local t_start = 1
    local t_end = 2
    if(choice == 1) then
        return create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(t_start, t_end, math.random()), true, 1)
    elseif(choice == 2) then
        return create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(t_start, t_end, math.random()), true, 2)
    else
        return create_particle(p_pos, v, colors[rand_color_index], 1, lume.lerp(t_start, t_end, math.random()), true, 3)
    end
end

function medal(pos, data)
    local base_color = data.color
    local c1 = "#555555"
    local c2 = "#ffff00"
    local c3 = "#aaaaaa"
    local colors = {base_color}

    local v = nil
    local width = 4
    local height = 5
    local p = V2(pos.x + math.random()*width, pos.y + math.random()*height)

    local rand_color_index = math.floor(math.random()*#colors) + 1

    v = V2((math.random() - 0.5)*0.2, 1)

    local t_start = 1
    local t_end = 2

    return create_particle(p, v, colors[rand_color_index], 1, lume.lerp(t_start, t_end, math.random()), true)
end

function sparks(pos, data)
    local colors = {"#fbf236"}

    local particles = {}
    local particles_amnt = 20 
    for t = 1, particles_amnt do
        local p_pos = V2(pos.x + 24/2 + 4*(math.random()), pos.y + TILE_SIZE/2 + 2*math.random())
        local x_vel = 2*(math.random() - 0.5)
        local v = V2(x_vel, -math.random())
        local p = nil

        local live_max = 0.4
        local live_min = 0.2

        p = create_particle(p_pos, v, colors[1], 1, lume.lerp(live_min, live_max, math.random()), true)
        table.insert(particles, p)
    end

    return particles
end

function create_vine_particle(pos)
    local c1 = "rgba(80, 159, 20, 0.22)"
    local c2 = "rgba(135, 209, 7, 0.22)"
    local colors = {c1, c2}

    local p_pos = V2(pos.x + TILE_SIZE/2, pos.y + math.random()*TILE_SIZE)
    local v = nil
    local p = nil
    local x_vel = 0
    local y_vel = 0

    local rand_color_index = lume.round(lume.lerp(1, #colors, math.random()))

    local random_vel = (math.random() - 0.5)
    x_vel = 0.8*random_vel
    y_vel = 0.1*math.random()
    v = V2(x_vel, y_vel)
    return create_particle(p_pos, v, colors[rand_color_index], 1, 20)
end

function notes(pos, data)
    local particles = {}
    local colors = {"#afe8d9", "#c2a7cc", "#ebcac0"}
    -- local colors = {"#000000", "#c2a7cc", "#ebcac0"}
    local selected_color = lume.randomchoice(colors)
    local note_1 = {
        {0, 1},
        {0, 1},
        {0, 1},
        {1, 1},
        {2, 2},
    }
    local note_2 = {
        {0, 1, 1, 1, 1},
        {0, 1, 2, 2, 1},
        {0, 1, 0, 0, 1},
        {1, 1, 0, 1, 1},
        {2, 2, 0, 2, 2},
    }
    local positions = nil
    if data.note_variant == "negra" then
        positions = note_1
    else
        positions = note_2
    end
    local direction = 1
    --TODO: randomize direction
    local v = V2(direction*math.max(math.random()*0.4, 0.2), -math.max(math.random()*0.3, 0.1))
    for y, row in pairs(positions) do
        for x, color in pairs(row) do
            if (color ~= 0) then
                if (color == 1) then
                    p = create_particle(V2(pos.x + x - 1, pos.y + y - 1), v, selected_color, 1, 0.8, true)
                    table.insert(particles, p)
                else
                    p = create_particle(V2(pos.x + x - 1, pos.y + y - 1), v, "#000000", 1, 0.8, true)
                    table.insert(particles, p)
                end
            end
        end
    end

    return particles
end

function water_drops(pos)
    local c1 = "rgba(172, 224, 240, 1)"
    local c2 = "rgba(100, 100, 255, 0.4)"
    local c3 = "rgba(112, 201, 228, 1)"
    local c4 = "rgba(11, 178, 234, 1)"
    local colors = {c1, c2, c3, c4}

    local x_offset = 2*(math.random() - 0.5)
    local p_pos = V2(pos.x + x_offset*TILE_SIZE, pos.y + math.random()*TILE_SIZE)
    local v = nil
    local p = nil

    local rand_color_index = math.floor(math.random()*#colors) + 1

    local x_vel = 0
    local y_vel = 0
    v = V2(x_vel, y_vel)

    local y_size = lume.randomchoice({1, 2})
    return create_particle(p_pos, v, colors[rand_color_index], 1, 5, true, y_size, true)
end

function dust(pos)
    local c1 = "rgba(255, 240, 228, 0.2)"
    local c2 = "rgba(222, 209, 200, 0.2)"
    local colors = {c1, c2}

    local size = lume.randomchoice({1, 2})

    local p_pos = V2(pos.x + math.random()*TILE_SIZE, pos.y)
    local v = nil
    local p = nil
    local random_vel = nil
    local x_vel = 0
    local y_vel = 0

    local rand_color_index = math.floor(lume.lerp(1, #colors, math.random()))

    random_vel = 0.5*2*(math.random()-0.5)
    x_vel = random_vel
    y_vel = 0
    v = V2(x_vel, y_vel)

    return create_particle(p_pos, v, colors[rand_color_index], size, math.random()*10, true, size, false, true)
end

function puzzle(pos)
    local c1 = "rgba(104, 45, 128, 0.4)"
    local c2 = "rgba(150, 67, 186, 0.4)"
    local colors = {c1, c2}

    local size = lume.randomchoice({1, 2, 4})

    local p_pos = V2(pos.x + math.random()*TILE_SIZE, pos.y)
    local v = nil
    local p = nil
    local random_vel = nil
    local x_vel = 0
    local y_vel = 0

    local rand_color_index = math.random(#colors)

    x_vel = (math.random()-0.5)
    y_vel = (math.random()-0.5)
    v = V2(x_vel, y_vel)

    return create_particle(p_pos, v, colors[rand_color_index], size, math.random()*4, true, size, false, true)
end

function start_screen(pos) 
    local c1 = "#9989ff"
    local c2 = "#1e3999"
    local c3 = "#5b95cc"
    local colors = {c1, c2, c3}

    local size = lume.randomchoice({1, 2})

    local x_offset = -200 + math.random()*300
    local y_offset = -100 + math.random()*BASE_RESOLUTION.height
    local p_pos = V2(pos.x + x_offset, pos.y + y_offset)
    local v = nil
    local p = nil
    local random_vel = nil
    local x_vel = 0
    local y_vel = 0

    local rand_color_index = math.random(#colors)

    x_vel = lume.lerp(2, 3, math.random())
    y_vel = (math.random()-0.5)
    v = V2(x_vel, y_vel)

    if math.random() < 0.11 then
        return create_particle(p_pos, v, colors[rand_color_index], size, math.random()*8, true, size, false, true, nara_image)
    else
        return create_particle(p_pos, v, colors[rand_color_index], size, math.random()*8, true, size, false, true)
    end
end
