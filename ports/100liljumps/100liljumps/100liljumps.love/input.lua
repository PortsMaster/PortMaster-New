-- TODO: think about gamepad mapping
function create_input(name, mappings)
    return {
        name = name,
        keyboard_maps = mappings.keyboard or {},
        gamepad_maps = mappings.gamepad or {},
        mobile_stick_maps = mappings.mobile_stick or {},
        is_pressed = false,
        is_released = false,
        is_down = false,
        is_up = false,
    }
end

-- Refer to https://www.love2d.org/wiki/GamepadButton
-- and https://www.love2d.org/wiki/KeyConstant

local MOBILE_STICK = {
    X_POSITIVE = 0,
    X_NEGATIVE = 1,
    Y_POSITIVE = 2,
    Y_NEGATIVE = 3
}

input = {
    move_left = create_input("move_left", {
        keyboard = {
            "left", "a"
        },
        gamepad = {
            "left_stick_left",
            "dpleft"
        },
        mobile_stick = { MOBILE_STICK.X_NEGATIVE }
    } ),
    move_right = create_input("move_right", {
        keyboard = {
            "right", "d"
        },
        gamepad = {
            "left_stick_right",
            "dpright"
        },
        mobile_stick = { MOBILE_STICK.X_POSITIVE }
    } ),
    move_up = create_input("move_up", {
        keyboard = {
            "up", "w"
        },
        gamepad = {
            "left_stick_up",
            "dpup"
        },
        mobile_stick = { MOBILE_STICK.Y_POSITIVE }
    } ),
    move_down = create_input("move_down", {
        keyboard = {
            "down", "s"
        },
        gamepad = {
            "left_stick_down",
            "dpdown"
        },
        mobile_stick = { MOBILE_STICK.Y_NEGATIVE }
    } ),
    jump = create_input("jump", {
        keyboard = {
            "c", "space"
        },
        gamepad = {
            "a",
        },
    } ),
    confirm = create_input("confirm", {
        keyboard = {
            "c", "space", "return"
        },
        gamepad = {
            "a",
        },
    } ),
    release = create_input("release", {
        keyboard = {
            "z"
        },
    } ),
    croak = create_input("croak", {
        keyboard = {
            "x"
        },
        gamepad = {
            "b"
        },
    } ),
    exit = create_input("exit", {
        keyboard = {
            "escape"
        },
    } ),
    editor_toggle = create_input("editor_toggle", {
        keyboard = {
            "tab"
        },
    } ),
    editor_save = create_input("editor_save", {
        keyboard = {
            "s"
        },
    } ),
    editor_new_level = create_input("editor_new_level", {
        keyboard = {
            "n"
        },
    } ),
    toggle_audio_triggers = create_input("toggle_audio_triggers", {
        keyboard = {
            "m"
        },
    } ),
    toggle_frames = create_input("toggle_frames", {
        keyboard = {
            "f"
        },
    } ),
    restart = create_input("restart", {
        keyboard = {
            "r"
        },
        gamepad = {
            "y"
        }
    } ),
    pause = create_input("pause", {
        keyboard = { "escape" },
        gamepad = { "start" }
    } ),
    toggle_debug_info = create_input("toggle_debug_info", {
        keyboard = { "tab" }
    } ),
    toggle_jumps_counting = create_input("toggle_jumps_counting", {
        keyboard = { "j" }
    } ),
    decrease_jumps = create_input("decrease_jumps", {
        keyboard = { "k" }
    } ),
    increase_jumps = create_input("increase_jumps", {
        keyboard = { "i" }
    } )
}

InputState = {}

gamepad = {
    left = {
        x = 0,
        y = 0
    },
    right = {
        x = 0,
        y = 0
    }
}

mobile_gamepad_state = {
    is_down = false,
    position = V2(0, 0), -- Normalized
}

InputDevice = {
    KEYBOARD = 1,
    GAMEPAD  = 2,
}
InputState.used_device = InputDevice.KEYBOARD

queued_vibrations = {}
local current_vibrating_time      = 0
local current_vibrating_intensity = 0

function trigger_vibration_feedback(intensity, duration)
    if not game_state.config_vibration_active then
        return
    end

    local joysticks = love.joystick.getJoysticks()
    if(#joysticks > 0) then
        table.insert(queued_vibrations, {
            intensity = intensity or 0.5,
            duration = duration or 0.3,
        } )
    end
end

function check_queued_vibrations(dt)
    current_vibrating_time = math.max(0, current_vibrating_time - dt)
    if current_vibrating_time == 0 then
        current_vibrating_intensity = 0
    end

    if (#queued_vibrations == 0) then return end

    local joysticks = love.joystick.getJoysticks()
    if (#joysticks == 0) then return end

    local max_intensity_idx = 1
    local max_intensity = queued_vibrations[1].intensity 
    if(#queued_vibrations > 1) then
        for i, v in pairs(queued_vibrations) do
            if v.intensity > max_intensity then
                max_intensity     = v.intensity
                max_intensity_idx = i
            end
        end
    end

    local v = queued_vibrations[max_intensity_idx]
    if(v.intensity > current_vibrating_intensity) then
        joysticks[1]:setVibration(v.intensity, v.intensity, v.duration)
        current_vibrating_time = v.duration
        current_vibrating_intensity = v.intensity
    end
    queued_vibrations = {}
end

function love.gamepadpressed( joystick, button )
    InputState.used_device = InputDevice.GAMEPAD
end

-- TODO: maybe it isn't necesary to compute every time
-- or do on redimendion if it is possible
function mobile_gamepad_data()
    local width, height = love.graphics.getDimensions()
    local scale = resolution_scale()
    local mobile_gamepad_radius = (scale/6) * 700
    local mobile_gamepad_visual_radius = (scale/6) * 140
    local x_padding = 32
    local y_padding = 32
    local mobile_gamepad_x = x_padding + mobile_gamepad_visual_radius
    local mobile_gamepad_y = height - y_padding - mobile_gamepad_visual_radius
    local mobile_gamepad_hitbox = Circle(V2(mobile_gamepad_x, mobile_gamepad_y), mobile_gamepad_radius)

    return {
        hitbox = mobile_gamepad_hitbox,
        position = V2(mobile_gamepad_x, mobile_gamepad_y),
        radius = mobile_gamepad_radius,
        visual_radius = mobile_gamepad_visual_radius
    }
end

function update_input_state()
    local joysticks = love.joystick.getJoysticks()

    local frame_mobile_gamepad_data = mobile_gamepad_data()

    touches = love.touch.getTouches()
    -- Reset touch state
    mobile_gamepad_state.is_down = false
    mobile_gamepad_state.position = V2(0, 0)
    for _, touch_id in pairs(touches) do
        x, y = love.touch.getPosition( touch_id )
        local touch_hitbox = Circle(V2(x, y), 0)

        local touch_in_mobile_gamepad = check_circ_circ_collision(frame_mobile_gamepad_data.hitbox, touch_hitbox)

        if touch_in_mobile_gamepad then
            local centered_touch_position = v2_sub(V2(x, y), frame_mobile_gamepad_data.position)
            local normalized_touch_position = v2_scale(centered_touch_position, 1/frame_mobile_gamepad_data.visual_radius)

            mobile_gamepad_state.is_down = true
            local clamped_stick_position = v2_clamp(normalized_touch_position, 1)
            mobile_gamepad_state.position.x = clamped_stick_position.x
            mobile_gamepad_state.position.y = clamped_stick_position.y
        end
    end

    gamepad.left.x = 0
    gamepad.left.y = 0

    local first_joystick = nil
    if(#joysticks > 0) then
        first_joystick = joysticks[1]
        gamepad.left.x = first_joystick:getGamepadAxis("leftx")
        gamepad.left.y = first_joystick:getGamepadAxis("lefty")

        local death_zone_limit = 0.4
        if math.abs(gamepad.left.x) < death_zone_limit then
            gamepad.left.x = 0
        else
            gamepad.left.x = lume.sign(gamepad.left.x)
        end
        if math.abs(gamepad.left.y) < death_zone_limit then
            gamepad.left.y = 0
        else
            gamepad.left.y = lume.sign(gamepad.left.y)
        end
    end

    for i, input_action in pairs(input) do
        local is_down = false
        local is_up = false

        if first_joystick then
            for _, gamepad_map in pairs(input_action.gamepad_maps) do
                if gamepad_map == "left_stick_left" then
                    is_down = is_down or gamepad.left.x == -1
                elseif gamepad_map == "left_stick_right" then
                    is_down = is_down or gamepad.left.x == 1
                elseif gamepad_map == "left_stick_up" then
                    is_down = is_down or gamepad.left.y == -1
                elseif gamepad_map == "left_stick_down" then
                    is_down = is_down or gamepad.left.y == 1
                else
                    is_down = is_down or first_joystick:isGamepadDown( gamepad_map )
                end
            end
        end

        for _, key_map in pairs(input_action.keyboard_maps) do
            is_down = is_down or love.keyboard.isDown(key_map)
            is_up = is_up or (not is_down)
        end

        local deadzone = 0.3
        for _, mobile_stick  in pairs(input_action.mobile_stick_maps) do
            if mobile_stick == MOBILE_STICK.X_POSITIVE then
                is_down = is_down or mobile_gamepad_state.position.x > deadzone
                is_up = is_up or (not is_down)
            end

            if mobile_stick == MOBILE_STICK.X_NEGATIVE then
                is_down = is_down or mobile_gamepad_state.position.x < -deadzone 
                is_up = is_up or (not is_down)
            end

            if mobile_stick == MOBILE_STICK.Y_POSITIVE then
                is_down = is_down or mobile_gamepad_state.position.y < -deadzone 
                is_up = is_up or (not is_down)
            end

            if mobile_stick == MOBILE_STICK.Y_NEGATIVE then
                is_down = is_down or mobile_gamepad_state.position.y > deadzone 
                is_up = is_up or (not is_down)
            end
        end

        -- Check ui mobile buttons
        for _, button in pairs(UI.mobile_buttons) do
            for _, key in pairs(button.keys) do
                if i == key then
                    is_down = is_down or button.is_down
                end
            end
        end

        input_action.is_pressed = is_down and (not input_action.is_down)
        input_action.is_released = is_up and (not input_action.is_up)
        input_action.is_down = is_down
        input_action.is_up = not is_down

    end
end

love.graphics.setDefaultFilter("linear")
InputIcons = {
    gamepad_a = love.graphics.newImage("input_icons/xbox_button_color_a.png"),
    gamepad_b = love.graphics.newImage("input_icons/xbox_button_color_b.png"),
    gamepad_x = love.graphics.newImage("input_icons/xbox_button_color_x.png"),
    gamepad_y = love.graphics.newImage("input_icons/xbox_button_color_y.png"),

    keyboard_r = love.graphics.newImage("input_icons/keyboard_r.png"),
    keyboard_x = love.graphics.newImage("input_icons/keyboard_x.png"),
    keyboard_c = love.graphics.newImage("input_icons/keyboard_c.png"),
}
love.graphics.setDefaultFilter("nearest")

function input_action_icon(action)
    local input_action = input[action]
    if not input_action then return nil end
    local maps = {}
    if InputState.used_device == InputDevice.KEYBOARD then
        maps = input_action.keyboard_maps
        if not maps then return end
        local map_for_icon = maps[1]

        local input_key = "keyboard_"..map_for_icon
        return InputIcons[input_key]

    else
        maps = input_action.gamepad_maps
        if not maps then return end
        local map_for_icon = maps[1]

        local input_key = "gamepad_"..map_for_icon
        return InputIcons[input_key]
    end
end
