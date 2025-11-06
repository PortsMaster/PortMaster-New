love.joystick.loadGamepadMappings = function() end
love.joystick.getJoysticks = function() return {} end
love.joystick.getJoystickCount = function() return 0 end

STEAM_BUILD = false
-- Steam
if STEAM_BUILD then
    Steam = require("luasteam") -- Luasteam v3.1.0
end

require("./globals")
require("./math")
require("./player")
require("./tile_map")
require("./physics")
require("./editor")
require("./game_state")
require("./input")
require("./render")
require("./speech_dialog")
require("classic")
require("./achievements")
require("./start_screen")

if Steam then
    Steam.init()
    require("./steam")
    request_stats()
end

local profile_enabled = false
dev_mode = false
debugging = false
step = false
scale = 1
offset_x = 0
offset_y = 0

editor = Editor()

-- logic rate (you can set 60 here)
local FRAMES = 50--60

record_mode = true
modifying_recording_params = false
camera_x = 0
camera_y = 0
camera_zoom = 0

if profile_enabled then
    appleCake = require("lib.AppleCake")(true)
    appleCake.setBuffer(false)
    appleCake.beginSession()
    appleCake.setName("Example")
end

GlobalMode = {
    START_SCREEN = 1,
    PLAYING      = 2,
}

function love.quit()
    if profile_enabled then
        appleCake.endSession()
    end
end

function love.load()
    if profile_enabled then
        appleCake.mark("Started load")
    end

    local save_data = load_game_data()
    local w, h = love.window.getDesktopDimensions()
    local width = if_not_nil_else(save_data.resolution_width, w - 100)
    local height = if_not_nil_else(save_data.resolution_height, h - 100)
    if width == w or height == h then
        width  = width - 100
        height = height - 100
    end

    if is_mobile_os() then
        love.window.setMode(w, h, {
            fullscreen = true,
            resizable = false,
            vsync = 1,
        })
    else
        love.window.setMode(width, height, {
            fullscreen = false,
            resizable = true,
            vsync = 1,
        })
    end

    global_mode = GlobalMode.START_SCREEN
    game_state = GameState()
    game_state:restart_game_state()

    if global_mode == GlobalMode.START_SCREEN then
        Audio.stop_all_songs()
        Audio.fade_in_song("lobby")
        init_start_screen_entities()
    end

    love.mouse.setVisible(false)
    love.window.setTitle("100 lil jumps")
    love.graphics.setBackgroundColor(lume.color("#010F14"))
end

function love.keypressed(key)
    if key == "d" then
        debugging = not debugging
    end

    if debugging and key == "n" then
        step = true
    end

    InputState.used_device = InputDevice.KEYBOARD
end

-- ===== fixed-step state =====
local accumulator = 0
local gc_time = 0
local GC_INTERVAL = 5 -- seconds
-- ============================

function love.update(dt)
    local _profileDraw = nil
    if profile_enabled then
        _profileDraw = appleCake.profileFunc()
    end

    -- steam
    if Steam then
        Steam.runCallbacks()
        unlock_queued_achievements()
    end

    -- camera edit mode
    if love.keyboard.isDown("t") then
        modifying_recording_params = false
    end
    if modifying_recording_params then
        local up = love.keyboard.isDown("up")
        local down = love.keyboard.isDown("down")
        local left = love.keyboard.isDown("left")
        local right = love.keyboard.isDown("right")
        local zoom_in = love.keyboard.isDown("z")
        local zoom_out = love.keyboard.isDown("x")

        if up    then camera_y = camera_y - 2 * (1 + camera_zoom) end
        if down  then camera_y = camera_y + 2 * (1 + camera_zoom) end
        if left  then camera_x = camera_x - 2 * (1 + camera_zoom) end
        if right then camera_x = camera_x + 2 * (1 + camera_zoom) end
        if zoom_in  then camera_zoom = math.min(camera_zoom + 0.1, 8) end
        if zoom_out then camera_zoom = math.max(camera_zoom - 0.1, 0) end
    end

    -- per-frame stuff uses real dt
    Audio.update(dt)
    if global_mode == GlobalMode.PLAYING then
        game_state:update_timers(dt)
    elseif global_mode == GlobalMode.START_SCREEN then
        update_start_screen(dt)
    end

    -- poll input ONCE per frame (not per sim step)
    update_input_state()

    -- fixed-step logic
    accumulator = accumulator + dt
    local FIXED_STEP = 1 / FRAMES
    local MAX_STEPS = 3
    local steps = 0
    local didStep = false

    while accumulator >= FIXED_STEP and steps < MAX_STEPS do
        steps = steps + 1
        didStep = true
        accumulator = accumulator - FIXED_STEP

        -- start screen transition
        if not modifying_recording_params then
            if start_screen_transition then
                start_screen_transition:advance_step()

                if global_mode == GlobalMode.START_SCREEN
                    and start_screen_transition:fade_out_has_finished() then
                    global_mode = GlobalMode.PLAYING
                    game_state:start_screen_pressed()
                    resync_accumulator()
                end

                if start_screen_transition:is_done() then
                    start_screen_transition = nil
                end
            end

            -- real game / start-screen logic
            if global_mode == GlobalMode.PLAYING then
                game_state:update(FIXED_STEP)
                Render.update_timers(FIXED_STEP, game_state)
            elseif global_mode == GlobalMode.START_SCREEN then
                update_start_screen_frame(FIXED_STEP)
            end

            -- UI & vibrations at sim rate (fine if cheap)
            UI.update(FIXED_STEP)
            check_queued_vibrations(FIXED_STEP)
        end

        -- editor
        if game_state.game_mode == GameMode.EDITING then
            editor:handle_input(game_state)
        end

        -- dev FPS toggle
        if dev_mode and input.toggle_frames and input.toggle_frames.is_pressed then
            if FRAMES == 60 then FRAMES = 2 else FRAMES = 60 end
        end
    end

    -- if we hit cap, drop leftover so we don't spiral
    if steps == MAX_STEPS then
        accumulator = 0
    end

    -- render once per frame
    if didStep then
        Render.should_render = true
        start_screen_should_render = true
    end

    -- time-based GC
    gc_time = gc_time + dt
    if gc_time > GC_INTERVAL then
        collectgarbage()
        gc_time = 0
    end

    -- profiling
    if profile_enabled then
        _profileDraw.args = love.graphics.getStats()
        _profileDraw:stop()
        appleCake.flush()
    end
end

function love.draw()
    local _profileDraw = nil
    if profile_enabled then
        _profileDraw = appleCake.profileFunc()
    end

    if global_mode == GlobalMode.START_SCREEN then
        draw_start_screen()
    elseif global_mode == GlobalMode.PLAYING then
        Render.render(game_state)
    end

    if start_screen_transition then
        start_screen_transition:draw()
    end

    if false then
        if game_state.game_mode == GameMode.EDITING then
            editor:handle_draw(game_state)
        end
    end

    if profile_enabled then
        _profileDraw.args = love.graphics.getStats()
        _profileDraw:stop()
        appleCake.flush()
    end
end

function resync_accumulator()
    accumulator = 0
end

