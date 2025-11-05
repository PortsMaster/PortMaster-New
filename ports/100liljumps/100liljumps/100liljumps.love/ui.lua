require("./utils")
require("./credits")
lume = require("lume")

local BASE_RESOLUTION = {
    width = 320,
    height = 180
}

-- Base size is targeting 1920
local function create_font(font_path, normal_size)
    local normal_size_width = 1920
    local scale_factor = normal_size / normal_size_width
    local base_resolution_width = 320

    return {
        [2]  = love.graphics.newFont(font_path, lume.round(scale_factor * base_resolution_width*2)),  -- 640x360
        [3]  = love.graphics.newFont(font_path, lume.round(scale_factor * base_resolution_width*3)),  -- 960x540
        [4]  = love.graphics.newFont(font_path, lume.round(scale_factor * base_resolution_width*4)),  -- 1280x720
        [6]  = love.graphics.newFont(font_path, lume.round(normal_size)),                             -- 1920x1080
        [8]  = love.graphics.newFont(font_path, lume.round(scale_factor * base_resolution_width*8)),  -- 2560x1440
        [12] = love.graphics.newFont(font_path, lume.round(scale_factor * base_resolution_width*12)), -- 3840x2160
        [24] = love.graphics.newFont(font_path, lume.round(scale_factor * base_resolution_width*24))  -- 7680x4320
    }
end

UI = {}

UI.checkbox_unchecked_sprite = love.graphics.newImage("checkbox-unchecked.png")
UI.checkbox_checked_sprite   = love.graphics.newImage("checkbox-checked.png")
UI.widgets_left_margin = 300

UI.get_scaled_font = function(font_key)
    local font_scales = UI.fonts2[font_key]
    local width, height = love.graphics.getDimensions()
    local scale = resolution_scale()

    local keys = lume.keys(font_scales)
    assert(#keys > 0)

    local closest_scale = keys[1]

    for _, key in pairs(keys) do
        local distance = math.abs(scale - key)
        local closest_distance = math.abs(closest_scale - key)

        if distance < closest_distance then
            closest_scale = key
        end
    end

    return font_scales[closest_scale]
end

UI.fonts2 = {
    jumps_counter_2       = create_font("fonts/MavenPro-Medium.ttf", 40+10),
    info_box              = create_font("fonts/MavenPro-Medium.ttf", 20+10),
    dialog                = create_font("fonts/MavenPro-Medium.ttf", 30+10),
    pause_option          = create_font("fonts/MavenPro-Medium.ttf", 40+10),
    pause_option_selected = create_font("fonts/MavenPro-Medium.ttf", 45+10),
    image_description     = create_font("fonts/MavenPro-Medium.ttf", 28+10),
    game_over_title       = create_font("fonts/MavenPro-Medium.ttf", 50+10),
    start_screen_title    = create_font("fonts/MavenPro-Medium.ttf", 120+10),
    start_subtitle        = create_font("fonts/MavenPro-Medium.ttf", 60+10),
}

UI.fonts = {
    --jumps_counter = create_font("fonts/MavenPro-Medium.ttf", 40+10),
    jumps_counter = love.graphics.newFont("fonts/monogram.ttf", 50+10),
    jumps_counter_2 = love.graphics.newFont("fonts/MavenPro-Medium.ttf", 40+10),
    info_box = love.graphics.newFont("fonts/MavenPro-Medium.ttf", 20+10),
    dialog = love.graphics.newFont("fonts/MavenPro-Medium.ttf", 30+10),
    credits_text = love.graphics.newFont("fonts/MavenPro-Medium.ttf", 30+10),

    pause_option          = love.graphics.newFont("fonts/MavenPro-Medium.ttf", 40+10),
    pause_option_selected = love.graphics.newFont("fonts/MavenPro-Medium.ttf", 45+10),
}

UI.info_box_text = ""

local glitch_frag = love.filesystem.read("shaders/glitch.frag")
UI.glitch_shader = love.graphics.newShader(nil, glitch_frag)
UI.symbol_canvas = love.graphics.newCanvas(1000, 300, {
})
UI.glitch_mask = love.graphics.newCanvas(300, 300, {
})
UI.jumps_counter_canvas = love.graphics.newCanvas(300, 100, {
})
UI.jump_counter_string = ""
UI.broken_counter_timer = 0
UI.broken_timer_target = 0.5 
UI.glitched_symbols_idxs = {}
UI.glitched_symbols = {}
UI.speech_dialog = nil
UI.queued_museum_images = {}
UI.initial_time = 0

UI.jumps_record_number_color = "#fbe1b5"

UI.jump_counter_timer = 0
UI.should_show_jumps_counter = false 
local JUMP_COUNTER_ANIMATION_TIME = 1.0

UI.show_debug_info = true

Audio.create_sound("sounds/Modern5.ogg", "ui_change_value", "static", 30)

local volume_control_base_image = love.graphics.newImage("volume-base.png")
local volume_control_slider_image = love.graphics.newImage("volume-slider.png")

local function draw_jumps_counter(game_state)
    UI.jump_counter_string = tostring(game_state:jumps_left_to_show()) .. " jumps left"
    love.graphics.setFont(UI.get_scaled_font("jumps_counter_2"))
    if(game_state.jump_counter_broken) then
        if(game_state.time - UI.broken_counter_timer >= UI.broken_timer_target) then
            local random_string_length = 14
            -- TODO: Better
            UI.glitched_symbols_idxs = {
                math.floor(lume.random(1, random_string_length)),
                math.floor(lume.random(1, random_string_length)),
                math.floor(lume.random(1, random_string_length)),
            }
            UI.glitched_symbols = {
                random_string(1),
                random_string(1),
                random_string(1)
            }
            UI.broken_counter_timer = game_state.time 
        end
    end



    local t = UI.jump_counter_timer / JUMP_COUNTER_ANIMATION_TIME
    t = easeOut(t)
    local text_x = 20
    local text_y = lume.lerp(-50 * scale/6, 10 * scale/6, t)

    local jumps_counter_2_font = UI.get_scaled_font("jumps_counter_2")
    local font_height = jumps_counter_2_font:getHeight()
    local y_offset = font_height * (22 / 47)
    local container_width  = jumps_counter_2_font:getWidth(UI.jump_counter_string) + 2*20
    local container_height = font_height * (30 / 47)

    UI.draw_info_box(UI.jump_counter_string, text_y)

    local draw_x = text_x
    local draw_y = text_y
    love.graphics.setCanvas(UI.glitch_mask)
        love.graphics.clear()
    love.graphics.setCanvas()

    for i = 1, #UI.jump_counter_string do
        local c = UI.jump_counter_string:sub(i, i)
        if(game_state.jump_counter_broken and table_contains(UI.glitched_symbols_idxs, i)) then
            local idx = indexof(UI.glitched_symbols_idxs, i)
            local glitched_symbol = UI.glitched_symbols[idx]
            UI.draw_shaddowed_string(glitched_symbol, draw_x, draw_y, true)
            draw_x = draw_x + jumps_counter_2_font:getWidth(glitched_symbol)
        else
            UI.draw_shaddowed_string(c, draw_x, draw_y)
            draw_x = draw_x + jumps_counter_2_font:getWidth(c)
        end
    end

    if(game_state.jump_counter_broken) then
        love.graphics.setShader(UI.glitch_shader)
            love.graphics.draw(UI.glitch_mask)
        love.graphics.setShader()
    end
end

UI.draw = function(game_state)
    if true then
        draw_jumps_counter(game_state)
    end

    if(game_state.tile_map.name == "lobby") then
        UI.draw_jumps_record(game_state)
    end

    if(game_state.show_speedrun_timer and game_state.config_show_speedrun_timer) then
        local width, height = love.graphics.getDimensions()
        local scale = resolution_scale()
        local box_v_offset = scale * (60 / 6)

        UI.draw_speedrun_timer(time_difference(game_state.speedrun_timer), 10 + box_v_offset)
    end

    UI.draw_queued_museum_image()

    for _, required_jumps in pairs(game_state.door_required_jumps) do
        UI.draw_required_jumps(required_jumps.tile_pos_x, required_jumps.tile_pos_y, game_state.lowest_jumps_record, required_jumps.total)
    end

    for _, puzzle_door_info in pairs(game_state.locked_puzzle_doors_info) do
        UI.draw_puzzle_door_info(puzzle_door_info.tile_pos_x, puzzle_door_info.tile_pos_y, puzzle_door_info.obtained_medals, puzzle_door_info.medals_to_unlock)
    end

    if(UI.info_box_text and #UI.info_box_text > 0) then
        UI.draw_info_box()
    end

    if(game_state.game_mode == GameMode.SIMULATING) then
        if game_state.quick_restart_timer > 0 then
            UI.draw_quick_restart_message()
        end
    end

    if(game_state.game_mode == GameMode.GAME_OVER) then
        UI.draw_game_over_overlay()
    end

    if(game_state.tile_map.name == "credits") then
        UI.draw_credits_overlay()
    end

    if(is_mobile_os()) then
        UI.draw_mobile_controls()
    end

    if(game_state.game_mode == GameMode.PAUSE) then
        UI.draw_pause_menu()
    end

    if(UI.speech_dialog) then
        UI.speech_dialog:draw()
    end

    if(dev_mode and UI.show_debug_info) then
        UI.draw_debug_info()
    end
end

UI.set_info_text = function(text)
    UI.info_box_text = text
end

UI.game_over_time = 0
UI.draw_game_over_overlay = function()
    local screen_width, screen_height = love.graphics.getDimensions()

    local title_font = UI.get_scaled_font("game_over_title")
    local items_font = UI.get_scaled_font("dialog")

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
    love.graphics.setColor(1, 1, 1)

    local menu_center_x = screen_width  / 2
    local menu_center_y = screen_height / 2
    local draw_y = menu_center_y - screen_height/4
    local v_margin = (scale / 6) * 80
    local s_margin = (scale / 6) * 120
    local title = "GAME OVER"
    local title_width = title_font:getWidth(title)

    local subtitle_gap = 8 * scale / 6

    local subtitle1 = "You ran out of jumps"
    local subtitle1_width = items_font:getWidth(subtitle1)
    local subtitle2_first = "Press "
    local subtitle2_first_width = items_font:getWidth(subtitle2_first)
    local croak_icon = input_action_icon("croak")
    local subtitle2_second = " to croak"
    local subtitle2_second_width = items_font:getWidth(subtitle2_second)
    local subtitle2_width = items_font:getWidth(subtitle2_first..subtitle2_second) + 2*subtitle_gap + croak_icon:getWidth()*scale/12

    local subtitle3_first = "Press "
    local subtitle3_first_width = items_font:getWidth(subtitle3_first)
    local restart_icon = input_action_icon("restart")
    local subtitle3_second = " to restart"
    local subtitle3_second_width = items_font:getWidth(subtitle3_second)
    local subtitle3_width = items_font:getWidth(subtitle3_first..subtitle3_second) + 2*subtitle_gap + restart_icon:getWidth()*scale/12

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(title_font)
    love.graphics.print(title, menu_center_x, draw_y, 0, 1, 1, title_width/2)

    draw_y = draw_y + s_margin

    love.graphics.setFont(items_font)
    love.graphics.print(subtitle1, menu_center_x, draw_y, 0, 1, 1, subtitle1_width/2)

    local subtitle2_alpha = math.max(UI.game_over_time - 1, 0) / 1
    draw_y = draw_y + v_margin

    local subtitle2_x = menu_center_x
    love.graphics.setColor(1, 1, 1, subtitle2_alpha)
    love.graphics.print(subtitle2_first, subtitle2_x, draw_y, 0, 1, 1, subtitle2_width/2)
    subtitle2_x = subtitle2_x + subtitle2_first_width + subtitle_gap
    love.graphics.draw(croak_icon, subtitle2_x - subtitle2_width/2, draw_y + items_font:getHeight()/2 - croak_icon:getHeight()*(scale/24), 0, scale/12, scale/12)
    subtitle2_x = subtitle2_x + croak_icon:getWidth() * scale / 12 + subtitle_gap
    love.graphics.print(subtitle2_second, subtitle2_x, draw_y, 0, 1, 1, subtitle2_width/2)

    draw_y = draw_y + v_margin

    local subtitle3_alpha = math.max(UI.game_over_time - 3, 0) / 2

    local subtitle3_x = menu_center_x
    love.graphics.setColor(1, 1, 1, subtitle3_alpha)
    love.graphics.print(subtitle3_first, subtitle3_x, draw_y, 0, 1, 1, subtitle3_width/2)
    subtitle3_x = subtitle3_x + subtitle3_first_width + subtitle_gap
    love.graphics.draw(restart_icon, subtitle3_x - subtitle3_width/2, draw_y + items_font:getHeight()/2 - restart_icon:getHeight()*(scale/24), 0, scale/12, scale/12)
    subtitle3_x = subtitle3_x + restart_icon:getWidth() * scale / 12 + subtitle_gap
    love.graphics.print(subtitle3_second, subtitle3_x, draw_y, 0, 1, 1, subtitle3_width/2)
end

UI.final_screen_overlay = function()
    local screen_width, screen_height = love.graphics.getDimensions()

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 180, screen_height / 2 - 20, 1000, 200)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(UI.fonts.jumps_counter_2)
    love.graphics.print("YOU COMPLETED THE CHALLENGE", 200, screen_height / 2)
    love.graphics.print("Thanks for playing", 200, screen_height / 2 + 100)
end

function pause_option(key, name, link)
    return {
        key       = key,
        name      = name,
    }
end

local options_main = {
    pause_option("main_continue", "Continue"),
    pause_option("main_restart", "Restart"),
    pause_option("main_options", "Options"),
    pause_option("main_new_game", "Delete save"),
    pause_option("main_exit", "Save and quit")
}

local options_options = nil

if is_mobile_os() then
    options_options = {
        pause_option("options_music", "Music"),
        pause_option("options_sounds", "Sounds"),
        pause_option("options_speedrun_timer", "Speedrun timer"),
        pause_option("options_vibration", "Controller vibration"),
        pause_option("options_particles", "Disable particles"),
        pause_option("options_screenshake", "Disable screenshake"),
        pause_option("options_effects", "Disable flashy effects"),
        pause_option("options_back", "Back"),
    }
else
    options_options = {
        pause_option("options_fullscreen", "Fullscreen"),
        pause_option("options_music", "Music"),
        pause_option("options_sounds", "Sounds"),
        pause_option("options_speedrun_timer", "Speedrun timer"),
        pause_option("options_vibration", "Controller vibration"),
        pause_option("options_particles", "Disable particles"),
        pause_option("options_screenshake", "Disable screenshake"),
        pause_option("options_effects", "Disable flashy effects"),
        pause_option("options_back", "Back"),
    }
end

local options_delete_save = {
    pause_option("delete_save_yes", "Yes"),
    pause_option("delete_save_no", "No"),
}

local pause_state = {
    selected_menu = options_main,
    selected_option = 1,
}

UI.draw_pause_menu = function()
    local screen_width, screen_height = love.graphics.getDimensions()

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
    love.graphics.setColor(1, 1, 1)

    local pause_option_selected_font = UI.get_scaled_font("pause_option_selected")
    local pause_option_font          = UI.get_scaled_font("pause_option")

    local option_margin = scale * (80 / 6)
    local options_amount = #pause_state.selected_menu

    local pause_menu_width = 600 -- Dynamic with scale
    local font_height = pause_option_font:getHeight()
    -- Font height doesnt get summed up for next row
    -- option_margin takes into account font height and line height
    local pause_menu_height = (options_amount - 1)*option_margin + font_height

    local pause_menu_x = ( screen_width  / 2 ) - ( pause_menu_width  / 2 )
    local pause_menu_y = ( screen_height / 2 )
    if pause_menu_height > screen_height / 2 then
        pause_menu_y = pause_menu_y - ( pause_menu_height / 2 )
    else
        pause_menu_y = pause_menu_y - ( screen_height / 4 )
    end

    if pause_state.selected_menu == options_delete_save then
        local pause_title_font = UI.get_scaled_font("jumps_counter_2")
        love.graphics.setFont(pause_title_font)
        love.graphics.setColor(1, 1, 1)
        local delete_save_menu_title = "Are you sure you want \n to delete your save?"
        local text_width  = pause_title_font:getWidth(delete_save_menu_title)
        local text_height = pause_title_font:getHeight()
        love.graphics.print(delete_save_menu_title, pause_menu_x + pause_menu_width/2, pause_menu_y, 0, 1, 1, text_width/2)

        pause_menu_y = pause_menu_y + 2*option_margin
    end
    

    local current_option_x = math.floor(pause_menu_x)
    local current_option_y = math.floor(pause_menu_y)

    for i, option in pairs(pause_state.selected_menu) do
        local key = option.key
        if(i == pause_state.selected_option) then
            love.graphics.setFont(pause_option_selected_font)
            local range = 0.3
            local delta = range*math.abs(math.sin(6*love.timer.getTime()))
            if game_state.config_effects_disabled then
                love.graphics.setColor(0.6 + range, 1, 0.6) -- TODO: lerp between 2 colors
            else
                love.graphics.setColor(0.6 + delta, (1 - range) + delta, 0.6) -- TODO: lerp between 2 colors
            end
            local text_width  = pause_option_selected_font:getWidth(option.name)
            local text_height = pause_option_selected_font:getHeight()
            love.graphics.print(option.name, current_option_x + pause_menu_width/2, current_option_y, 0, 1, 1, text_width/2)
        else
            love.graphics.setFont(pause_option_font)
            love.graphics.setColor(1, 1, 1)
            local text_width  = pause_option_font:getWidth(option.name)
            local text_height = pause_option_font:getHeight()
            love.graphics.print(option.name, current_option_x + pause_menu_width/2, current_option_y, 0, 1, 1, text_width/2)
        end

        love.graphics.setColor(1, 1, 1)
        if(key == "options_music") then
            UI.draw_slider(current_option_y, Audio.music_volume, scale)

        elseif(key == "options_sounds") then
            UI.draw_slider(current_option_y, Audio.sounds_volume, scale)

        elseif(key == "options_fullscreen") then
            UI.draw_checkbox(current_option_y, love.window.getFullscreen(), scale)

        elseif(key == "options_speedrun_timer") then
            UI.draw_checkbox(current_option_y, game_state.config_show_speedrun_timer, scale)

        elseif(key == "options_vibration") then
            UI.draw_checkbox(current_option_y, game_state.config_vibration_disabled, scale)

        elseif(key == "options_particles") then
            UI.draw_checkbox(current_option_y, game_state.config_particles_disabled, scale)

        elseif(key == "options_screenshake") then
            UI.draw_checkbox(current_option_y, game_state.config_screenshake_disabled, scale)

        elseif(key == "options_effects") then
            UI.draw_checkbox(current_option_y, game_state.config_effects_disabled, scale)

        end

        current_option_y = current_option_y + option_margin
    end
end

UI.draw_slider = function(y, value, scale)
    local screen_width, screen_height = love.graphics.getDimensions()
    local left_margin = scale * (UI.widgets_left_margin / 6)

    local pause_option_font = UI.get_scaled_font("pause_option")
    local text_height       = pause_option_font:getHeight()

    local draw_x = screen_width/2 + left_margin
    local draw_y = y + scale*4/6 + text_height/2 - (scale/2)*volume_control_base_image:getHeight()/2

    local base_width = volume_control_base_image:getWidth() - volume_control_slider_image:getWidth()
    local slider_x = draw_x + value*base_width * math.floor(scale/2)
    local slider_y = draw_y + (scale/2)*volume_control_base_image:getHeight()/2 - scale/2 * volume_control_slider_image:getHeight()/2

    love.graphics.draw(volume_control_base_image, math.floor(draw_x), math.floor(draw_y), 0, math.floor(scale/2))
    love.graphics.draw(volume_control_slider_image, math.floor(slider_x), math.floor(slider_y), 0, math.floor(scale/2))
end

local function increment_pause_option(pause_state)
    pause_state.selected_option = ( pause_state.selected_option + 1 )
    if(pause_state.selected_option > #pause_state.selected_menu) then
        pause_state.selected_option = 1
    end
end

local function decrement_pause_option(pause_state)
    pause_state.selected_option = ( pause_state.selected_option - 1 )
    if(pause_state.selected_option < 1) then
        pause_state.selected_option = #pause_state.selected_menu
    end
end

local function restart_pause_state(pause_state)
    pause_state.selected_menu = options_main
    pause_state.selected_option = 1
end

UI.handle_pause_input = function(game_state)
    if(input.move_down.is_pressed) then
        increment_pause_option(pause_state)
        Audio.play_sound("ui_change_value", 0.6, 0.6)
    end
    if(input.move_up.is_pressed) then
        decrement_pause_option(pause_state)
        Audio.play_sound("ui_change_value", 0.5, 0.5)
    end

    local option_key = pause_state.selected_menu[pause_state.selected_option].key

    if(option_key == "options_music") then
        if(input.move_right.is_pressed) then
            Audio.increase_music_volume_pressed()
            Audio.play_sound("ui_change_value", 0.9, 0.9, Audio.music_volume)
        end
        if(input.move_left.is_pressed) then
            Audio.decrease_music_volume_pressed()
            Audio.play_sound("ui_change_value", 0.7, 0.7, Audio.music_volume)
        end
    end

    if(option_key == "options_sounds") then
        if(input.move_right.is_pressed) then
            Audio.increase_sounds_volume_pressed()
            Audio.play_sound("ui_change_value", 0.9, 0.9, Audio.sounds_volume)
        end
        if(input.move_left.is_pressed) then
            Audio.decrease_sounds_volume_pressed()
            Audio.play_sound("ui_change_value", 0.7, 0.7, Audio.sounds_volume)
        end
    end

    if(input.confirm.is_pressed) then
        if(option_key == "main_continue") then
            game_state:pause_continue_pressed()
            save_game_data(game_state)
            restart_pause_state(pause_state)
        end

        if(option_key == "main_restart") then
            game_state:pause_restart_pressed()
            save_game_data(game_state)
            restart_pause_state(pause_state)
        end

        if(option_key == "main_new_game") then
            restart_pause_state(pause_state)
            pause_state.selected_menu = options_delete_save

            -- game_state:pause_new_game_pressed()
            -- save_game_data(game_state)
            -- restart_pause_state(pause_state)
        end

        if(option_key == "main_exit") then
            save_game_data(game_state)
            game_state:pause_exit_pressed()
        end

        if(option_key == "main_options") then
            restart_pause_state(pause_state)
            pause_state.selected_menu = options_options
        end

        if(option_key == "options_fullscreen") then
            game_state:pause_fullscreen_pressed()

            local toggled_on = love.window.getFullscreen()
            UI.play_toggle_sound_for(toggled_on)
        end

        if(option_key == "options_speedrun_timer") then
            game_state:toggle_speedrun_timer_pressed()

            local toggled_on = game_state.config_show_speedrun_timer
            UI.play_toggle_sound_for(toggled_on)
        end

        if(option_key == "options_vibration") then
            game_state:toggle_vibration_pressed()

            local toggled_on = game_state.config_vibration_disabled
            UI.play_toggle_sound_for(toggled_on)
        end

        if(option_key == "options_particles") then
            game_state:toggle_particles_pressed()

            local toggled_on = game_state.config_particles_disabled
            UI.play_toggle_sound_for(toggled_on)
        end

        if(option_key == "options_screenshake") then
            game_state:toggle_screenshake_pressed()

            local toggled_on = game_state.config_screenshake_disabled
            UI.play_toggle_sound_for(toggled_on)
        end

        if(option_key == "options_effects") then
            game_state:toggle_effects_pressed()

            local toggled_on = game_state.config_effects_disabled
            UI.play_toggle_sound_for(toggled_on)
        end

        if(option_key == "options_back") then
            restart_pause_state(pause_state)
        end

        if(option_key == "delete_save_yes") then
            pause_state.selected_menu = options_main

            game_state:pause_new_game_pressed()
            save_game_data(game_state)
            restart_pause_state(pause_state)
        end

        if(option_key == "delete_save_no") then
            restart_pause_state(pause_state)
            pause_state.selected_menu = options_main
        end
    end

    if(input.pause.is_pressed) then
        game_state:pause_continue_pressed()
        restart_pause_state(pause_state)
    end
end

UI.play_toggle_sound_for = function(toggled_on)
    if toggled_on then
        Audio.play_sound("ui_change_value", 0.4, 0.4)
    else
        Audio.play_sound("ui_change_value", 0.3, 0.3)
    end
end

UI.draw_door_info_backround = function(x, y, full_string_width, y_padding)
    local info_box_font = UI.get_scaled_font("info_box")
    local string_height = info_box_font:getHeight()

    local background_x_padding = 16 
    local background_y_padding = y_padding 
    local background_x = x - full_string_width/2 - background_x_padding
    local background_y = y - background_y_padding
    local background_width = full_string_width + 2*background_x_padding
    local background_height = string_height + 2*background_y_padding

    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", background_x, background_y, background_width, background_height, 4, 4, 100)

end

UI.draw_required_jumps = function(door_x, door_y, current, total)
    local width, height = love.graphics.getDimensions() 
    local canvas_width = BASE_RESOLUTION.width * scale
    local canvas_height = BASE_RESOLUTION.height * scale

    local offset_x = (width - canvas_width) / 2
    local offset_y = (height - canvas_height) / 2

    local anchor_y = (door_y - 1)*TILE_SIZE*scale + offset_y
    local draw_x = ((door_x + 0.5)*TILE_SIZE)*scale + offset_x
    local y_padding = 4
    local draw_y = anchor_y + 0.5*UI.jumps_left_record_y_offset


    local info_box_font = UI.get_scaled_font("info_box")
    local full_string_width = info_box_font:getWidth(current .. " / " .. total)
    local number_string_width = info_box_font:getWidth(current .. " ")

    UI.draw_door_info_backround(draw_x, anchor_y, full_string_width, y_padding)

    love.graphics.setColor(lume.color(UI.jumps_record_number_color))
    love.graphics.setFont(info_box_font)
    love.graphics.print(current, draw_x - full_string_width/2, draw_y)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("/ " .. total, draw_x - full_string_width/2 + number_string_width, anchor_y)
end

local DOOR_MEDAL_IMAGE = love.graphics.newImage("door_medal.png")
UI.draw_puzzle_door_info = function(door_x, door_y, obtained_medals, medals_to_unlock)
    local width, height = love.graphics.getDimensions() 
    local canvas_width = BASE_RESOLUTION.width * scale
    local canvas_height = BASE_RESOLUTION.height * scale

    local offset_x = (width - canvas_width) / 2
    local offset_y = (height - canvas_height) / 2

    local anchor_y = (door_y - 1)*TILE_SIZE*scale + offset_y
    local draw_x = ((door_x + 0.5)*TILE_SIZE)*scale + offset_x
    local draw_y = anchor_y + 0.5*UI.jumps_left_record_y_offset

    local info_box_font = UI.get_scaled_font("info_box")
    local full_string_width = info_box_font:getWidth(obtained_medals .. " / " .. 3)
    local number_string_width = info_box_font:getWidth(obtained_medals .. " ")

    UI.draw_door_info_backround(draw_x, draw_y, full_string_width, 4)

    love.graphics.setColor(lume.color(UI.jumps_record_number_color))
    love.graphics.setFont(info_box_font)
    love.graphics.print(obtained_medals, draw_x - full_string_width/2, draw_y)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("/ " .. 3, draw_x - full_string_width/2 + number_string_width, draw_y)
    local font_height = info_box_font:getHeight()
    local y_offset = font_height/2 - (DOOR_MEDAL_IMAGE:getHeight() - 2)*scale/2
    love.graphics.draw(DOOR_MEDAL_IMAGE, draw_x - full_string_width/2 - scale*DOOR_MEDAL_IMAGE:getWidth() - 2*scale, draw_y + y_offset, 0, 0.8*scale)
end

UI.draw_image_description = function(x, y, description, alpha)
    local draw_x = x
    local draw_y = y
    local border_width = 1
    local font = UI.get_scaled_font("image_description")
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.print(description, draw_x - border_width, draw_y, 0)
    love.graphics.print(description, draw_x + border_width, draw_y, 0)
    love.graphics.print(description, draw_x               , draw_y - border_width, 0)
    love.graphics.print(description, draw_x               , draw_y + border_width, 0)

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.print(description, draw_x, draw_y)
end

UI.max_v_speed = 0
UI.draw_debug_info = function()
    local width, height = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", width/2 + width/4, 0, width/4, height)
    love.graphics.setColor(1, 1, 1)
    local font = UI.get_scaled_font("info_box")
    love.graphics.setFont(font)

    local padding = 20
    local v_space = scale * 40 / 6
    local draw_x = 3*width/4 + padding
    local draw_y = 0 + padding

    local v_speed = game_state.player.vel.y
    UI.max_v_speed = math.max(UI.max_v_speed, v_speed) 

    love.graphics.print(v_speed, draw_x, draw_y)
    draw_y = draw_y + v_space
    love.graphics.print(UI.max_v_speed, draw_x, draw_y)

    local player_pos = game_state.player.pos
    draw_y = draw_y + v_space
    love.graphics.print("Player pos: x = " .. player_pos.x .. " | y = " .. player_pos.y, draw_x, draw_y)

    draw_y = draw_y + v_space
    love.graphics.print("Map name: " .. game_state.tile_map.name, draw_x, draw_y)

    local cs = game_state.tile_map.computahs
    local c = nil
    if(#cs > 0) then
        c = cs[1]
        draw_y = draw_y + v_space
        love.graphics.print("Comp pos: x = " .. c.pos.x .. " | y = " .. c.pos.y, draw_x, draw_y)
        draw_y = draw_y + v_space
        love.graphics.print("Comp h: " .. c.height, draw_x, draw_y)
    end

    draw_y = draw_y + v_space
    draw_y = draw_y + v_space
    love.graphics.print("Dev shortcuts", draw_x, draw_y)

    draw_y = draw_y + v_space
    love.graphics.print("[J] Toggle counting of Jumps", draw_x, draw_y)
    draw_y = draw_y + v_space
    love.graphics.print("[I] Increase available jumps", draw_x, draw_y)
    draw_y = draw_y + v_space
    love.graphics.print("[K] Decrease available jumps", draw_x, draw_y)
    draw_y = draw_y + v_space
    love.graphics.print("[Tab] Toggle show/hide dev info", draw_x, draw_y)
    draw_y = draw_y + v_space
    love.graphics.print("[M] Show audio triggers: " .. tostring(game_state.show_audio_triggers), draw_x, draw_y)

    draw_y = draw_y + v_space
    local w, h = love.graphics.getDimensions()
    love.graphics.print("Window resolution: " .. tostring(w) .. "x" .. tostring(h), draw_x, draw_y)
end

UI.draw_shaddowed_string = function(s, text_x, text_y, glitched, color, canvas)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setDefaultFilter("linear")
    local border_width = 2
    local base_r, base_g, base_b, base_a = lume.color(color or "#eeeeee")
    local text_color = {base_r, base_g, base_b, base_a}

    love.graphics.setCanvas(UI.symbol_canvas)
        love.graphics.clear()
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(s, -border_width,  0)
        love.graphics.print(s,  border_width,  0)
        love.graphics.print(s,  0           , -border_width)
        love.graphics.print(s,  0           ,  border_width)

        love.graphics.setColor(text_color)
        love.graphics.print(s, 0, 0)

    love.graphics.setCanvas()

    if(glitched) then
        love.graphics.setCanvas(UI.glitch_mask)
            love.graphics.draw(UI.symbol_canvas, text_x, text_y)
        love.graphics.setCanvas()
    else
        if(canvas) then
            love.graphics.setCanvas(canvas)
        end
        love.graphics.draw(UI.symbol_canvas, math.floor(text_x), math.floor(text_y))
        love.graphics.setCanvas()
    end

    love.graphics.setDefaultFilter("nearest")
end

UI.clear_speech_dialog = function(str, pos)
    UI.speech_dialog = nil
end

UI.add_speech_dialog = function(str, follow_entity)
    UI.speech_dialog = SpeechDialog(str, follow_entity)
end

UI.clear_queued_museum_image = function()
    UI.queued_museum_images = {}
end

UI.remove_queued_museum_image = function(id)
    if(#UI.queued_museum_images > 0) then
        for _, queued_museum_image in pairs(UI.queued_museum_images) do
            if(queued_museum_image.id == id) then
                queued_museum_image.fade_out = true
                queued_museum_image.initial_time = love.timer.getTime()
            end
        end
    end
end

UI.draw_museum_image = function(id)
    local image = nil
    for _, queued_museum_image in pairs(UI.queued_museum_images) do
        if(queued_museum_image.id == id) then
            image = queued_museum_image
        end
    end

    if image then
        image.fade_out = false
        image.initial_time = love.timer.getTime()
    else
        UI.queued_museum_images = { {
            ["id"] = id,
            t = 0,
            initial_time = love.timer.getTime(),
            fade_out = false,
        } }
    end
end

love.graphics.setDefaultFilter("linear", "linear")
local museum_images = {
    {
        image = love.graphics.newImage("museum_images/image_1.png"),
        description = "Design sketches",
    },
    {
        image = love.graphics.newImage("museum_images/image_2.png"),
        description = "Initial levels layout",
    },
    {
        image = love.graphics.newImage("museum_images/image_3.png"),
        description = "Nara and Brog posible names",
    },
    {
        image = love.graphics.newImage("museum_images/old_screenshot_1.png"),
        description = "Early screenshot",
    },
    {
        image = love.graphics.newImage("museum_images/old_screenshot_2.png"),
        description = "Early screenshot",
    },
    {
        image = love.graphics.newImage("museum_images/old_screenshot_3.png"),
        description = "Early screenshot",
    },
    {
        image = love.graphics.newImage("museum_images/old_screenshot_4.png"),
        description = "Early screenshot",
    },
    {
        image = love.graphics.newImage("museum_images/old_screenshot_5.png"),
        description = "Early screenshot",
    },
}

love.graphics.setDefaultFilter("nearest", "nearest")
table.insert(museum_images,
    {
        image = love.graphics.newImage("museum_images/old_nara_designs.png"),
        description = "Discarded nara designs",
    }
)
table.insert(museum_images,
    {
        image = love.graphics.newImage("museum_images/snail.png"),
        description = "Discarded snail design",
    }
)
table.insert(museum_images,
    {
        image = love.graphics.newImage("museum_images/brog.png"),
        description = "Discarded brog design",
    }
)


local museum_image_t = 0
UI.draw_queued_museum_image = function()
    local scale_offset = get_canvas_offset()

    for i, image_control in pairs(UI.queued_museum_images) do
        local image_id = image_control.id
        local eased_t = 0
        local image_control_t = 0
        if(image_control.fade_out) then
            image_control_t = love.timer.getTime() - image_control.initial_time
            image_control_t = image_control_t*2
            image_control_t = 1 - image_control_t
            image_control_t = lume.clamp(image_control_t, 0, 1)
            eased_t = easeIn(image_control_t)
            if(image_control_t <= 0) then
                UI.clear_queued_museum_image()
            end
        else
            image_control_t = love.timer.getTime() - image_control.initial_time
            image_control_t = image_control_t*2
            image_control_t = lume.clamp(image_control_t, 0, 1)
            eased_t = easeOut(image_control_t)
        end
        local alpha_t = lume.lerp(0, 1, eased_t)
        local y_offset = lume.lerp(64, 0, eased_t)
        local angle_offset = lume.lerp(-math.pi/64, 0, eased_t)

        local image_obj = museum_images[image_control.id]
        local image = image_obj.image
        local description = image_obj.description

        local width_padding_percentage = 0.2
        local height_padding_percentage = 0.1

        local width = BASE_RESOLUTION.width * scale

        local height = BASE_RESOLUTION.height * scale

        local horizontal_padding = width_padding_percentage * width
        local vertical_padding = height_padding_percentage * height

        local cx = horizontal_padding 
        local cy = vertical_padding 

        local c_width = width - 2*horizontal_padding 
        local c_height = height * 0.5 -- TODO: adjust to aspect ratio

        local image_width = image:getWidth()
        local image_height = image:getHeight()

        -- TODO: What if taller than larger
        local image_scale = c_width / image_width

        if false then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", cx, cy, c_width, c_height)
        end

        love.graphics.setColor(1, 1, 1, alpha_t)
        love.graphics.draw(image, cx + scale_offset.x, cy + y_offset + scale_offset.y, angle_offset, image_scale, image_scale)
        love.graphics.setColor(1, 1, 1)

        if(#description > 0) then
            local font = UI.get_scaled_font("image_description")
            local description_width = font:getWidth(description)
            local center_x = horizontal_padding + c_width / 2
            local draw_x = center_x - description_width/2
            UI.draw_image_description(draw_x + scale_offset.x, cy + image_height*image_scale + scale_offset.y, description, alpha_t)
        end
        love.graphics.setColor(1, 1, 1)
    end
end

UI.shadowed_text = function(text, x, y, font) 
    local border_width = 2

    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(text, x - border_width, y)
    love.graphics.print(text, x + border_width, y)
    love.graphics.print(text, x               , y - border_width)
    love.graphics.print(text, x               , y + border_width)

    love.graphics.setColor(lume.color("#eeeeee"))
    love.graphics.print(text, x, y)
end

UI.reset_credits_state = function()
    UI.credits_scroll_time = 0
    UI.credits_current_time = 0
    UI.credits_initial_time = game_state.time
end

UI.credits_scroll_time = 0
UI.credits_current_time = 0

UI.draw_credits_overlay = function()
    local _, height = love.graphics.getDimensions()

    local new_time = game_state.time - UI.credits_initial_time
    local delta_time = new_time - UI.credits_current_time
    UI.credits_current_time = new_time

    local speed = 0
    if game_state.game_mode == GameMode.SIMULATING then
        speed = 0.7

        if input.move_up.is_down then
            speed = speed*2
        elseif input.move_down.is_down then
            speed = -speed*2
        end
    end
    UI.credits_scroll_time = UI.credits_scroll_time + delta_time*speed

    local y_offset = (UI.credits_scroll_time / 10) * height
    local center_x = BASE_RESOLUTION.width*scale / 2
    local y_pos = height - y_offset

    for i, element in pairs(credits) do
        local font_to_use = nil
        if(element.type == "title") then
            font_to_use = UI.get_scaled_font("jumps_counter_2")
            y_pos = y_pos + 40
        else
            font_to_use = UI.get_scaled_font("dialog")
            y_pos = y_pos + 10
        end

        local element_width = font_to_use:getWidth(element.text)
        local element_x = center_x - element_width/2
        local element_y = y_pos

        local scale_offset = get_canvas_offset()
        UI.shadowed_text(element.text, element_x + scale_offset.x, y_pos + scale_offset.y, font_to_use)

        y_pos = y_pos + font_to_use:getHeight()

        if(element.type == "title") then
            y_pos = y_pos + 10
        end
    end
end

UI.update = function(dt)
    if(input.toggle_debug_info.is_pressed) then
        UI.show_debug_info = not UI.show_debug_info
    end

    if(UI.should_show_jumps_counter) then
        UI.jump_counter_timer = UI.jump_counter_timer + dt 
        UI.jump_counter_timer = math.min(UI.jump_counter_timer, JUMP_COUNTER_ANIMATION_TIME)
    else
        UI.jump_counter_timer = UI.jump_counter_timer - dt 
        UI.jump_counter_timer = math.max(UI.jump_counter_timer, 0)
    end

    if game_state.game_mode == GameMode.GAME_OVER then
        UI.game_over_time = UI.game_over_time + dt
    else
        UI.game_over_time = 0
    end

    -- Update mobile buttons state
    local touches = love.touch.getTouches()
    local width, height = love.graphics.getDimensions()

    for _, mobile_button in pairs(UI.mobile_buttons) do
        mobile_button.is_down = false
        for _, touch_id in pairs(touches) do
            touch_x, touch_y = love.touch.getPosition( touch_id )
            local world_mobile_button_hitbox = Circle(
                V2(
                    mobile_button.hitbox.center.x * width,
                    mobile_button.hitbox.center.y * height
                ),
                mobile_button.hitbox.radius * width
            )
            local touch_in_button = check_circ_circ_collision(
                world_mobile_button_hitbox,
                Circle(V2(touch_x, touch_y), 0)
            )

            if touch_in_button then
                mobile_button.is_down = true
            end
        end
        local draw_x = mobile_button.position.x * width
        local draw_y = mobile_button.position.y * height
        local draw_radius = mobile_button.visual_radius * width
        if mobile_button.is_down then
            love.graphics.setColor(1, 0, 1, 0.5)
        else
            love.graphics.setColor(1, 0, 1, 0.8)
        end
        love.graphics.circle("fill", draw_x, draw_y, draw_radius)
    end
end

UI.show_jumps_counter = function()
    UI.should_show_jumps_counter = true 
end

UI.hide_jumps_counter = function()
    UI.should_show_jumps_counter = false 
end

UI.draw_info_box = function(string, y)
    local text_x = 20
    local text_y = y
    local info_box_font = UI.get_scaled_font("jumps_counter_2")
    local font_height = info_box_font:getHeight()

    local padding = info_box_font:getWidth("xx")
    local string_width = info_box_font:getWidth(string) + text_x + padding
    local box_v_offset = font_height * (22 / 47)
    local box_height = font_height * (30 / 47)

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", -10, text_y + box_v_offset, string_width, box_height, 8, 8)
end


UI.jumps_left_record_y_offset = 0
local jumps_offset_time = 0
UI.draw_jumps_record = function(game_state)
    local width, height = love.graphics.getDimensions()
    local scale = resolution_scale()
    local box_y = 30
    local box_v_space = scale * (60 / 6)

    local info_box_font = UI.get_scaled_font("jumps_counter_2")
    love.graphics.setFont(info_box_font)
    UI.draw_info_box("Best", box_y)
    UI.draw_shaddowed_string("Best", 20, box_y, false, "#fbe1b5")

    box_y = box_y + box_v_space
    local number_string = tostring(game_state.lowest_jumps_record)
    local number_string_width = info_box_font:getWidth(number_string)
    local blink_speed = 5
    if(#game_state.door_required_jumps > 0) then
        if(jumps_offset_time == 0) then
            jumps_offset_time = game_state.time
        end
        local t = math.sin(blink_speed * (game_state.time - jumps_offset_time))
        UI.jumps_left_record_y_offset = t*8
    else
        if(math.abs(UI.jumps_left_record_y_offset) < 0.5) then
            UI.jumps_left_record_y_offset = 0
            jumps_offset_time = 0
        else
            local t = math.sin(blink_speed * (game_state.time - jumps_offset_time))
            UI.jumps_left_record_y_offset = t*8
        end
    end
    local y_pos = box_y + UI.jumps_left_record_y_offset

    UI.draw_info_box(number_string .. " jumps left", box_y)
    UI.draw_shaddowed_string(number_string, 20, y_pos, false, UI.jumps_record_number_color)

    love.graphics.setDefaultFilter("nearest")
    UI.draw_shaddowed_string(" jumps left", 20 + number_string_width, box_y)

    box_y = box_y + box_v_space
    UI.draw_speedrun_timer(game_state.best_time_record_in_seconds, box_y)
end

UI.draw_speedrun_timer = function(time_in_seconds, y_pos)
    local info_box_font = UI.get_scaled_font("jumps_counter_2")
    local small_info_box_font = UI.get_scaled_font("info_box")

    local time_string, milliseconds_string = time_display_string(time_in_seconds)
    local time_string_width = info_box_font:getWidth(time_string)
    local milliseconds_y_offset = info_box_font:getHeight() - 1.20*small_info_box_font:getHeight()
    UI.draw_info_box(time_string .. "0", y_pos)

    love.graphics.setFont(info_box_font)
    UI.draw_shaddowed_string(time_string, 20, y_pos)
    love.graphics.setFont(small_info_box_font)
    UI.draw_shaddowed_string(milliseconds_string, 20 + time_string_width, y_pos + milliseconds_y_offset)
end

UI.reset_ui_state = function()
    UI.clear_queued_museum_image()
end

UI.draw_checkbox = function(y, value, scale)
    local screen_width, screen_height = love.graphics.getDimensions()
    local left_margin = scale * (UI.widgets_left_margin / 6)

    local pause_option_font = UI.get_scaled_font("pause_option")
    local text_height       = pause_option_font:getHeight()

    local draw_x = screen_width/2 + left_margin
    local draw_y = y + text_height/2 - (math.floor((scale/2))*UI.checkbox_checked_sprite:getHeight())/2

    if value then
        love.graphics.draw(UI.checkbox_checked_sprite, math.floor(draw_x), math.floor(draw_y), 0, math.floor(scale/2))
    else
        love.graphics.draw(UI.checkbox_unchecked_sprite, math.floor(draw_x), math.floor(draw_y), 0, math.floor(scale/2))
    end
end

UI.draw_quick_restart_message = function()
    local width, height = love.graphics.getDimensions()
    local scale = resolution_scale()
    local bottom_padding = scale*(120 / 6)
    local y_pos = height - bottom_padding

    local restarting_t = game_state.quick_restart_timer / game_state.QUICK_RESTART_WAIT_TIME
    local stage = 1 + math.floor(restarting_t / 0.3)
    local restarting_string = "Restarting"

    for i = 1, stage do
        restarting_string = restarting_string .. "."
    end


    UI.draw_info_box(restarting_string, y_pos)

    local font = UI.get_scaled_font("jumps_counter_2")
    love.graphics.setFont(font)
    UI.draw_shaddowed_string(restarting_string, 20, y_pos)
end

UI.draw_centered = function(label, font_key, y, color)
    local screen_width, screen_height = love.graphics.getDimensions()

    local font = UI.get_scaled_font(font_key)

    local menu_center_x = screen_width  / 2
    local menu_center_y = screen_height / 2
    local label_width = font:getWidth(label)

    love.graphics.setColor(color)
    love.graphics.setFont(font)
    UI.draw_shaddowed_string(label, math.floor(menu_center_x - label_width/2), y, nil, "rgba(255, 255, 255, "..color[4]..")")
end

UI.draw_start_screen_title = function(t)
    local screen_width, screen_height = love.graphics.getDimensions()
    local title_font = UI.get_scaled_font("start_screen_title")

    local menu_center_y = screen_height / 2
    local draw_y = math.floor(menu_center_y - screen_height/3)

    UI.draw_centered("100 lil jumps", "start_screen_title", draw_y, {1, 1, 1, t})
end

UI.draw_start_screen_subtitle = function(t)
    local screen_width, screen_height = love.graphics.getDimensions()
    local menu_center_y = screen_height / 2
    local draw_y = math.floor(menu_center_y - screen_height/8)

    UI.draw_centered("by Koliao & Grayson Varn", "start_subtitle", draw_y, {1, 1, 1, t})
end

UI.draw_start_screen_action = function(t)
    local screen_width, screen_height = love.graphics.getDimensions()
    local label = "Press C to start"
    local color = {1, 1, 1, t}

    local font = UI.get_scaled_font("start_subtitle")

    local label_width = font:getWidth(label)
    local label_height = font:getHeight()
    local draw_x = math.floor(screen_width - label_width - 64)
    local draw_y = math.floor(screen_height - label_height - 64)

    local action_first = "Press "
    local action_first_width = font:getWidth(action_first)

    local action_icon = input_action_icon("jump")

    local action_gap = scale / 6
    local action_second = " to start"
    local action_second_width = font:getWidth(action_second)
    local action_width = font:getWidth(action_first..action_second) + 2*action_gap + action_icon:getWidth()*scale/12

    love.graphics.setColor(color)
    love.graphics.setFont(font)

    UI.draw_shaddowed_string(action_first, draw_x, draw_y, nil, "rgba(255, 255, 255, "..t..")")

    local action_icon_draw_x = math.floor(draw_x + action_first_width)
    love.graphics.setColor(color)
    love.graphics.draw(action_icon, action_icon_draw_x, math.floor(draw_y + font:getHeight()/2 - action_icon:getHeight()*(scale/24)), 0, scale/12, scale/12)

    local action_second_draw_x = action_icon_draw_x + action_icon:getWidth()*scale/12 + action_gap
    UI.draw_shaddowed_string(action_second, action_second_draw_x, draw_y, nil, "rgba(255, 255, 255, "..t..")")
end

UI.draw_mobile_controls = function()
    local mobile_gamepad = mobile_gamepad_data()

    love.graphics.setColor(0.2, 0.2, 0.2, 0.2)

    love.graphics.circle("fill", mobile_gamepad.position.x, mobile_gamepad.position.y, mobile_gamepad.visual_radius)

    if mobile_gamepad_state.is_down then
        love.graphics.setColor(1, 0, 0, 0.2)
    else
        love.graphics.setColor(0, 1, 0, 0.2)
    end

    local mobile_stick_draw_x = mobile_gamepad.visual_radius*mobile_gamepad_state.position.x + mobile_gamepad.position.x
    local mobile_stick_draw_y = mobile_gamepad.visual_radius*mobile_gamepad_state.position.y + mobile_gamepad.position.y
    love.graphics.circle("fill", mobile_stick_draw_x, mobile_stick_draw_y, 20)
    love.graphics.setColor(1, 1, 1)

    local width, height = love.graphics.getDimensions()

    for _, mobile_button in pairs(UI.mobile_buttons) do
        local draw_x = mobile_button.position.x * width
        local draw_y = mobile_button.position.y * height
        local draw_radius = mobile_button.radius * width
        if mobile_button.is_down then
            love.graphics.setColor(1, 0, 1, 0.5)
        else
            love.graphics.setColor(1, 0, 1, 0.3)
        end
        love.graphics.circle("fill", draw_x, draw_y, draw_radius)
    end

    love.graphics.setColor(1, 1, 1)
end

UI.create_mobile_button = function(keys, x, y, radius)
    local touch_button_radius = radius
    local touch_button_x = x
    local touch_button_y = y
    local touch_hitbox = Circle(V2(touch_button_x, touch_button_y), touch_button_radius) -- normalized

    return {
        keys = keys or {},
        position = V2(touch_button_x, touch_button_y),
        radius = 1.1*touch_button_radius,
        visual_radius = touch_button_radius,
        hitbox = touch_hitbox,
        is_down = false
    }
end

local touch_button_radius = 0.04
local x_padding = 0.04
local y_padding = 0.04
local touch_button_x_1 = 1 - x_padding - touch_button_radius
local touch_button_y_1 = 1 - y_padding*(320/180) - touch_button_radius*(320/180)
local touch_button_x_2 = 1 - x_padding - 3*touch_button_radius
local touch_button_y_2 = 1 - y_padding*(320/180) - touch_button_radius*(320/180) - 0.75*touch_button_radius*(320/180)


UI.mobile_buttons = {
    UI.create_mobile_button({"jump", "confirm"}, touch_button_x_1, touch_button_y_1, touch_button_radius),
    UI.create_mobile_button({"croak"}, touch_button_x_2, touch_button_y_2, 0.4*touch_button_radius)
}
