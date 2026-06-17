-- Input handler for D-pad / keyboard controls
-- Modeled after Scrappy's helpers/input.lua

local input = {}

local joystick

-- Hold-to-repeat configuration
local repeat_delay = 0.3    -- initial delay before auto-repeat
local repeat_rate  = 0.15   -- time between repeats while holding (slower than Scrappy — game moves are heavier)
local holding = {
    dir = nil,
    start_time = 0,
    started = false,
    last_fire = 0
}

-- Event queue
local event_queue = {}

local is_web = love.system.getOS() == "Web"

input.events = {
    LEFT   = "left",
    RIGHT  = "right",
    UP     = "up",
    DOWN   = "down",
    CONFIRM = "return",               -- A button
    BACK   = is_web and "escape" or "backspace", -- B button
    SELECT = is_web and "tab" or "rshift",    -- Select button
    START  = is_web and "return" or "space",  -- Start button
    MENU   = "escape",                -- Physical Menu/Function button
    X      = is_web and "space" or "x", -- X button
    Y      = is_web and "c" or "y",     -- Y button
    L1     = is_web and "z" or "l1",    -- Left shoulder
    R1     = is_web and "x" or "r1",    -- Right shoulder
}

input.state = {}

input.joystick_mapping = {
    ["dpleft"]    = input.events.LEFT,
    ["dpright"]   = input.events.RIGHT,
    ["dpup"]      = input.events.UP,
    ["dpdown"]    = input.events.DOWN,
    ["a"]         = input.events.CONFIRM,
    ["b"]         = input.events.BACK,
    ["x"]         = input.events.X,
    ["y"]         = input.events.Y,
    ["back"]      = input.events.SELECT,
    ["start"]     = input.events.START,
    ["guide"]     = input.events.MENU,
    ["leftshoulder"] = input.events.L1,
    ["rightshoulder"] = input.events.R1,
}

-- Cooldown to prevent accidental double-inputs
local cooldown_duration = 0.12
local last_trigger_time = -cooldown_duration

local function can_trigger()
    local now = love.timer.getTime()
    if now - last_trigger_time >= cooldown_duration then
        last_trigger_time = now
        return true
    end
    return false
end

local function emit(event, bypass)
    if bypass or can_trigger() then
        table.insert(event_queue, event)
    end
end

function input.load()
    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        joystick = joysticks[1]
    end
end

function input.update(dt)
    -- Process hold-to-repeat for directional events
    if holding.dir then
        local now = love.timer.getTime()
        if not holding.started then
            if now - holding.start_time >= repeat_delay then
                holding.started = true
                holding.last_fire = now
                emit(holding.dir, true)
            end
        else
            if now - holding.last_fire >= repeat_rate then
                holding.last_fire = now
                emit(holding.dir, true)
            end
        end
    end
end

-- Process all queued events via callback
function input.processEvents(callback)
    for _, event in ipairs(event_queue) do
        callback(event)
    end
    event_queue = {}
end

-- Check if a direction is being held
local function is_directional(event)
    return event == input.events.LEFT or event == input.events.RIGHT
        or event == input.events.UP or event == input.events.DOWN
end

function love.keypressed(key)
    for event_name, k in pairs(input.events) do
        if key == k or (is_web and key == "backspace" and k == "escape") then
            input.state[key] = true
            emit(k, false)
        end
    end

    if is_directional(key) then
        holding.dir = key
        holding.start_time = love.timer.getTime()
        holding.started = false
        holding.last_fire = holding.start_time
    end
end

function love.keyreleased(key)
    for _, k in pairs(input.events) do
        if key == k then
            input.state[key] = false
        end
    end

    if key == holding.dir then
        holding.dir = nil
        holding.started = false
    end
end

function love.gamepadpressed(js, button)
    local event = input.joystick_mapping[button]
    if event then
        input.state[event] = true
        emit(event, false)

        if is_directional(event) then
            holding.dir = event
            holding.start_time = love.timer.getTime()
            holding.started = false
            holding.last_fire = holding.start_time
        end
    end
end

function love.gamepadreleased(js, button)
    local event = input.joystick_mapping[button]
    if event then
        input.state[event] = false
        if event == holding.dir then
            holding.dir = nil
            holding.started = false
        end
    end
end

-- Touch tracking
local active_touch_id = nil
local touch_start_x = 0
local touch_start_y = 0
local touch_start_time = 0

function love.touchpressed(id, x, y, dx, dy, pressure)
    -- Only track the first finger to avoid multi-touch confusion
    if not active_touch_id then
        active_touch_id = id
        touch_start_x = x
        touch_start_y = y
        touch_start_time = love.timer.getTime()
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if active_touch_id ~= id then return end
    active_touch_id = nil

    -- Calculate distance and duration
    local end_time = love.timer.getTime()
    local duration = end_time - touch_start_time
    local diff_x = x - touch_start_x
    local diff_y = y - touch_start_y
    local abs_x = math.abs(diff_x)
    local abs_y = math.abs(diff_y)

    local swipe_threshold = 30 -- pixels
    local tap_threshold = 15

    if abs_x > swipe_threshold or abs_y > swipe_threshold then
        -- It's a swipe (D-Pad)
        if abs_x > abs_y then
            if diff_x > 0 then emit(input.events.RIGHT, false)
            else emit(input.events.LEFT, false) end
        else
            if diff_y > 0 then emit(input.events.DOWN, false)
            else emit(input.events.UP, false) end
        end
    elseif abs_x < tap_threshold and abs_y < tap_threshold then
        -- It's a tap
        local w, h = love.graphics.getDimensions()
        if y < h * 0.2 then
            -- Top 20% of screen
            if duration > 0.4 then
                -- Long press top = Switch Theme (Y button)
                emit(input.events.Y, false)
            else
                if x < w * 0.5 then
                    -- Top Left tap = BACK / UNDO (B button)
                    emit(input.events.BACK, false)
                else
                    -- Top Right tap = START / PAUSE (Start button)
                    emit(input.events.START, false)
                end
            end
        else
            -- Bottom 80% of screen
            if duration > 0.4 then
                if x < w * 0.5 then
                    -- Bottom Left Long press = Swap (L1/Z button)
                    emit(input.events.L1, false)
                else
                    -- Bottom Right Long press = Bomb (X button)
                    emit(input.events.X, false)
                end
            else
                -- Short tap = CONFIRM (A button)
                emit(input.events.CONFIRM, false)
            end
        end
    end
end

return input
