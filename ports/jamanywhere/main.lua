
local scale_factor = 1
local offset_x = 0
local offset_y = 0

local game_canvas

-- === GLOBAL SETTINGS ===
local V_WIDTH = 640  
local V_HEIGHT = 480
local WIDTH = 640    
local HEIGHT = 480   

local HIT_Y = 400

local LANE_WIDTH = V_WIDTH / 4 
local CX = V_WIDTH / 2
local CY = V_HEIGHT / 2

local Splash = require("splash") 
local splash 
local game_state = "splash"    

local res_options = {
    {w = 320, h = 240}, 
    {w = 480, h = 320}, 
    {w = 640, h = 480},
    {w = 720, h = 720}, 
    {w = 1280, h = 720} 
}
local res_index = 2 

local colors = {
    {1, 0.3, 0.3}, -- Lane 1 / Left (Red)
    {0.3, 1, 0.3}, -- Lane 2 / Top (Green)
    {0.3, 0.3, 1}, -- Lane 3 / Bottom (Blue)
    {1, 1, 0.3}    -- Lane 4 / Right (Yellow)
}
-- Default bindings
local kb_binds_vert = {"d", "f", "j", "k"}
local gp_binds_vert = {"dpleft", "dpup", "x", "a"} 
local kb_binds_cent = {"left", "up", "down", "right"}
local gp_binds_cent = {"dpleft", "dpup", "dpdown", "dpright"} 
local keys_pressed = {false, false, false, false}

-- Save Data
local highscores = {}
local SAVE_FILE = "save.txt"

-- === GAME STATE & MENU ===
local game_state = "splash" 
local song_list = {}
local selected_index = 1
local selected_diff_index = 1
local menu_cursor = 1 
local pause_cursor = 1

local scroll_speed = 600 
local note_height = 40
local play_style = "vertical" 
local bind_type = "" 
local bind_lane = 1

local trim_start = 0
local trim_end = 0

-- === JUICE & EFFECTS ===
local particles = {}
local feedback_scale = 1.0
local combo_scale = 1.0
local bg_scroll = 0

-- === ANTI-DOUBLE INPUT TIMERS ===
local last_menu_action_time = 0
local last_hit_time = {0, 0, 0, 0}
local last_pause_time = 0

-- === PLAYER STATS ===
local score, combo, max_combo = 0, 0, 0
local perfect_hits, good_hits, misses = 0, 0, 0
local bad_hits = 0 
local limit_misses = 0 
local limit_bads = 0   
local failed = false   
local feedback_text, feedback_timer = "", 0
local feedback_color = {1, 1, 1}

-- === AUDIO & BEATMAP ===
local music = nil
local loaded_notes = {}
local current_song_name = ""
local current_time = 0
local error_msg = ""

-- === OSU! MANIA PARSER ===
function parse_osu_file(filepath)
    local notes = {}
    local audio_file = "audio.ogg" -- Domyślny fallback
    local is_4k = false
    local parse_mode = ""

    for line in love.filesystem.lines(filepath) do
        line = line:match("^%s*(.-)%s*$")
        
        if line:match("^%[.-%]$") then
            parse_mode = line
        elseif line ~= "" then
            
            if parse_mode == "[General]" then
                if line:match("^AudioFilename:") then
                    audio_file = line:match("^AudioFilename:%s*(.*)")
                end
                
            elseif parse_mode == "[Difficulty]" then
                if line:match("^CircleSize:") then
                    local keys = tonumber(line:match("^CircleSize:%s*(.*)"))
                    if keys == 4 then is_4k = true end
                end
                
            elseif parse_mode == "[HitObjects]" and is_4k then
                local x, y, time, type_flag, hitSound, rest = line:match("^(%d+),(%d+),(%d+),(%d+),(%d+),(.*)")
                if x then
                    local t_sec = tonumber(time) / 1000.0
                    
                    local lane = math.floor(tonumber(x) * 4 / 512) + 1
                    lane = math.max(1, math.min(4, lane))
                    
                    local duration = 0
                    local t_flag = tonumber(type_flag)
                    
                    local is_hold = math.floor(t_flag / 128) % 2 == 1
                    if is_hold and rest then
                        local endTime = rest:match("^(%d+):")
                        if endTime then
                            duration = (tonumber(endTime) / 1000.0) - t_sec
                        end
                    end
                    
                    table.insert(notes, {
                        time = t_sec, 
                        lane = lane, 
                        duration = duration, 
                        hit = false, missed = false, is_held = false
                    })
                end
            end
        end
    end
    
    return notes, audio_file, is_4k
end

-- === SAVE / LOAD SYSTEM ===
function load_data()
    if love.filesystem.getInfo(SAVE_FILE) then
        for line in love.filesystem.lines(SAVE_FILE) do
            local key, val = line:match("([^=]+)=([^=]+)")
            if key and val then
                if key:match("^kbv_(%d)") then kb_binds_vert[tonumber(key:sub(5))] = val
                elseif key:match("^gpv_(%d)") then gp_binds_vert[tonumber(key:sub(5))] = val
                elseif key:match("^kbc_(%d)") then kb_binds_cent[tonumber(key:sub(5))] = val
                elseif key:match("^gpc_(%d)") then gp_binds_cent[tonumber(key:sub(5))] = val
                elseif key:match("^score_(.*)") then highscores[key:sub(7)] = tonumber(val)
                elseif key == "scroll_speed" then scroll_speed = tonumber(val)
                elseif key == "note_height" then note_height = tonumber(val)
                elseif key == "play_style" then play_style = val
                elseif key == "limit_misses" then limit_misses = tonumber(val)
                elseif key == "limit_bads" then limit_bads = tonumber(val)
                elseif key == "res_index" then 
                    res_index = math.min(#res_options, tonumber(val))
                    WIDTH = res_options[res_index].w
                    HEIGHT = res_options[res_index].h
                end
            end
        end
    end
end

function save_data()
    local data = ""
    for i = 1, 4 do
        data = data .. "kbv_" .. i .. "=" .. kb_binds_vert[i] .. "\n"
        data = data .. "gpv_" .. i .. "=" .. gp_binds_vert[i] .. "\n"
        data = data .. "kbc_" .. i .. "=" .. kb_binds_cent[i] .. "\n"
        data = data .. "gpc_" .. i .. "=" .. gp_binds_cent[i] .. "\n"
    end
    for k, v in pairs(highscores) do data = data .. "score_" .. k .. "=" .. v .. "\n" end
    data = data .. "scroll_speed=" .. scroll_speed .. "\n"
    data = data .. "note_height=" .. note_height .. "\n"
    data = data .. "play_style=" .. play_style .. "\n"
    data = data .. "limit_misses=" .. limit_misses .. "\n"
    data = data .. "limit_bads=" .. limit_bads .. "\n"
    data = data .. "res_index=" .. res_index .. "\n"
    love.filesystem.write(SAVE_FILE, data)
end

function love.load()
    load_data()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Jam Anywhere - Rhythm Game")
    love.keyboard.setKeyRepeat(true) 
    love.graphics.setNewFont(16)


    splash = Splash({fill = "light"})

    splash.onDone = function()
        game_state = "menu"
    end
    
    load_data()

    local info = love.filesystem.getInfo("songs")
    if info and info.type == "directory" then
        for i, folder in ipairs(love.filesystem.getDirectoryItems("songs")) do
            if love.filesystem.getInfo("songs/" .. folder).type == "directory" then
                local diffs = {}
                local has_json = false
                
                for _, file in ipairs(love.filesystem.getDirectoryItems("songs/" .. folder)) do
                    if file:match("%.osu$") then
                        table.insert(diffs, file)
                    elseif file == "map.json" then
                        has_json = true
                    end
                end
                
                if has_json then table.insert(diffs, "map.json") end

                if #diffs > 0 then
                    table.sort(diffs)
                    table.insert(song_list, { name = folder, diffs = diffs })
                end
            end
        end
    end
    if #song_list == 0 then table.insert(song_list, {name = "[No song folders found]", diffs = {""}}) end
end

function get_active_binds(is_kb)
    if play_style == "vertical" then return is_kb and kb_binds_vert or gp_binds_vert
    else return is_kb and kb_binds_cent or gp_binds_cent end
end

function is_lane_down(lane)
    if love.keyboard.isDown(get_active_binds(true)[lane]) then return true end
    for _, joy in ipairs(love.joystick.getJoysticks()) do
        if joy:isGamepad() then
            local bind = get_active_binds(false)[lane]
            if bind == "triggerleft" or bind == "triggerright" then
                if joy:getGamepadAxis(bind) > 0.5 then return true end
            else
                if joy:isGamepadDown(bind) then return true end
            end
        end
    end
    return false
end

function spawn_particles(lane)
    local px, py = 0, 0
    if play_style == "vertical" then
        px = (lane - 1) * LANE_WIDTH + (LANE_WIDTH / 2)
        py = HIT_Y
    else
        local offsets = {{-1, 0}, {0, -1}, {0, 1}, {1, 0}}
        px = CX + (offsets[lane][1] * 50)
        py = CY + (offsets[lane][2] * 50)
    end

    local c = colors[lane]
    for i = 1, 15 do
        table.insert(particles, {
            x = px + (math.random() * 40 - 20),
            y = py + (math.random() * 40 - 20),
            vx = (math.random() - 0.5) * 300,
            vy = (math.random() - 0.5) * 300 - 100, 
            life = 1.0,
            color = c,
            size = math.random(3, 7)
        })
    end
end

function toggle_pause()
    local now = love.timer.getTime()
    if now - last_pause_time < 0.2 then return end
    last_pause_time = now

    if game_state == "play" then
        game_state = "pause"
        pause_cursor = 1
        if music then music:pause() end
    elseif game_state == "pause" then
        game_state = "play"
        if music then music:play() end
        for i = 1, 4 do last_hit_time[i] = now end
    end
end

function try_hit(lane)
    local now = love.timer.getTime()
    if now - last_hit_time[lane] < 0.02 then return end
    last_hit_time[lane] = now

    local is_currently_holding = false
    for _, note in ipairs(loaded_notes) do
        if note.lane == lane and note.is_held then
            is_currently_holding = true
            break
        end
    end
    if is_currently_holding then return end

    local closest_note, min_dist = nil, 999
    for _, note in ipairs(loaded_notes) do
        if note.lane == lane and not note.hit and not note.missed and not note.is_held then
            local dist = math.abs(note.time - current_time)
            if dist < 0.2 and dist < min_dist then
                min_dist, closest_note = dist, note
            end
        end
    end

    if closest_note then
        spawn_particles(lane) 
        feedback_scale = 1.5 
        combo_scale = 1.5

        if min_dist < 0.08 then
            feedback_text, feedback_color = "PERFECT!", {0.2, 1, 0.2}
            score, perfect_hits = score + 100, perfect_hits + 1
        else
            feedback_text, feedback_color = "GOOD!", {1, 1, 0.2}
            score, good_hits = score + 50, good_hits + 1
        end
        feedback_timer = 1.0 
        combo = combo + 1
        if combo > max_combo then max_combo = combo end

        if closest_note.duration > 0 then
            closest_note.is_held = true
        else
            closest_note.hit = true
        end
    else
        score = math.max(0, score - 50)
        combo = 0
        bad_hits = bad_hits + 1
        feedback_text, feedback_color, feedback_timer = "BAD!", {1, 0.2, 0.2}, 1.0
        feedback_scale = 1.3
        
        -- SPRAWDZANIE LIMITU PUDŁA
        if limit_bads > 0 and bad_hits >= limit_bads then
            failed = true
            if music then music:stop() end
            game_state = "results"
        end
    end
end

function menu_action(action)
    local now = love.timer.getTime()
    
    if now - (last_menu_action_time or 0) < 0.15 then 
        return 
    end
    
    last_menu_action_time = now

    if game_state == "menu" then
        if action == "up" then selected_index = math.max(1, selected_index - 1)
        elseif action == "down" then selected_index = math.min(#song_list, selected_index + 1)
        elseif action == "settings" then game_state, menu_cursor = "settings", 1
        elseif action == "info" then game_state = "info"
        elseif action == "confirm" then
            if not song_list[1].name:match("%[No song") then
                game_state = "diff_select"
                selected_diff_index = 1
                error_msg = ""
            end
        elseif action == "quit" then love.event.quit() end

    elseif game_state == "diff_select" then
        local song = song_list[selected_index]
        if action == "up" then selected_diff_index = math.max(1, selected_diff_index - 1)
        elseif action == "down" then selected_diff_index = math.min(#song.diffs, selected_diff_index + 1)
        elseif action == "quit" then game_state = "menu"
        elseif action == "confirm" then
            local folder = song.name
            local map_file = song.diffs[selected_diff_index]
            
            current_song_name = folder .. "/" .. map_file 
            local folder_path = "songs/" .. folder
            local map_path = folder_path .. "/" .. map_file

            loaded_notes = {}
            local target_audio = "audio.ogg"
            local load_success = false

            if map_file:match("%.osu$") then
                local notes, audio_fname, is_4k = parse_osu_file(map_path)
                if is_4k and #notes > 0 then
                    loaded_notes = notes
                    target_audio = audio_fname
                    load_success = true
                    trim_start, trim_end = 0, 0
                else
                    error_msg = "ERROR: " .. map_file .. " is not 4K mode!"
                    game_state = "menu"
                end
            elseif map_file == "map.json" then
                local map_json = love.filesystem.read(map_path)
                for time, lane, dur in map_json:gmatch('"time":%s*([%d%.]+),%s*"lane":%s*(%d+),%s*"duration":%s*([%d%.]+)') do
                    table.insert(loaded_notes, {time = tonumber(time), lane = tonumber(lane), duration = tonumber(dur), hit = false, missed = false, is_held = false})
                end
                trim_start = tonumber(map_json:match('"trim_start":%s*([%d%.]+)')) or 0
                trim_end = tonumber(map_json:match('"trim_end":%s*([%d%.]+)')) or 0
                load_success = true
            end

            if load_success then
                local audio_path = folder_path .. "/" .. target_audio
                if love.filesystem.getInfo(audio_path) then
                    score, combo, max_combo, perfect_hits, good_hits, misses = 0, 0, 0, 0, 0, 0
                    bad_hits = 0
                    failed = false
                    particles = {}
                    
                    music = love.audio.newSource(audio_path, "stream")
                    music:play()
                    if trim_start > 0 then music:seek(trim_start) end
                    game_state, error_msg = "play", ""
                else
                    error_msg = "ERROR: Missing audio (" .. target_audio .. ")"
                    game_state = "menu"
                end
            end
        end

    elseif game_state == "settings" then
        if action == "up" then menu_cursor = math.max(1, menu_cursor - 1)
        elseif action == "down" then menu_cursor = math.min(9, menu_cursor + 1) -- Zwiększone do 9 pozycji
        elseif action == "left" then
            if menu_cursor == 1 then scroll_speed = math.max(200, scroll_speed - 50)
            elseif menu_cursor == 2 then -- NOWOŚĆ: Wybór rozdzielczości
                res_index = math.max(1, res_index - 1)
                WIDTH, HEIGHT = res_options[res_index].w, res_options[res_index].h
                love.window.setMode(WIDTH, HEIGHT) -- Natychmiastowa zmiana okna
            elseif menu_cursor == 3 then note_height = math.max(10, note_height - 5)
            elseif menu_cursor == 4 then play_style = (play_style == "vertical") and "center" or "vertical"
            elseif menu_cursor == 5 then limit_misses = math.max(0, limit_misses - 1)
            elseif menu_cursor == 6 then limit_bads = math.max(0, limit_bads - 1) end
        elseif action == "right" then
            if menu_cursor == 1 then scroll_speed = math.min(1200, scroll_speed + 50)
            elseif menu_cursor == 2 then -- NOWOŚĆ: Wybór rozdzielczości
                res_index = math.min(#res_options, res_index + 1)
                WIDTH, HEIGHT = res_options[res_index].w, res_options[res_index].h
                love.window.setMode(WIDTH, HEIGHT) -- Natychmiastowa zmiana okna
            elseif menu_cursor == 3 then note_height = math.min(150, note_height + 5)
            elseif menu_cursor == 4 then play_style = (play_style == "vertical") and "center" or "vertical"
            elseif menu_cursor == 5 then limit_misses = math.min(100, limit_misses + 1)
            elseif menu_cursor == 6 then limit_bads = math.min(100, limit_bads + 1) end
        elseif action == "confirm" then
            -- Przesunięte indeksy dla przycisków akcji
            if menu_cursor == 7 then game_state, menu_cursor = "controls_kb", 1
            elseif menu_cursor == 8 then game_state, menu_cursor = "controls_gp", 1
            elseif menu_cursor == 9 then save_data(); game_state = "menu" end
        elseif action == "quit" then save_data(); game_state = "menu" end

    elseif game_state == "controls_kb" or game_state == "controls_gp" then
        if action == "up" then menu_cursor = math.max(1, menu_cursor - 1)
        elseif action == "down" then menu_cursor = math.min(6, menu_cursor + 1) -- Zwiększono limit do 6
        elseif action == "confirm" then
            if menu_cursor <= 4 then
                bind_type, bind_lane, game_state = (game_state == "controls_kb") and "kb" or "gp", menu_cursor, "binding"
            elseif menu_cursor == 5 then
                -- LOGIKA RESETOWANIA DO USTAWIEŃ DOMYŚLNYCH
                if game_state == "controls_kb" then
                    kb_binds_vert = {"d", "f", "j", "k"}
                    kb_binds_cent = {"left", "up", "down", "right"}
                else
                    gp_binds_vert = {"dpleft", "dpup", "x", "a"}
                    gp_binds_cent = {"dpleft", "dpup", "dpdown", "dpright"}
                end
                save_data() -- Zapisz od razu po zresetowaniu!
            elseif menu_cursor == 6 then 
                -- Poprawiony powrót do właściwego indeksu w menu Settings
                game_state, menu_cursor = "settings", (game_state == "controls_kb" and 7 or 8) 
            end
        elseif action == "quit" then 
            game_state, menu_cursor = "settings", (game_state == "controls_kb" and 7 or 8) 
        end

    elseif game_state == "pause" then
        if action == "up" then pause_cursor = math.max(1, pause_cursor - 1)
        elseif action == "down" then pause_cursor = math.min(2, pause_cursor + 1)
        elseif action == "confirm" then
            if pause_cursor == 1 then 
                toggle_pause()
            else 
                if music then music:stop() end
                game_state = "menu"
            end
        elseif action == "quit" or action == "settings" then 
            toggle_pause() 
        end

    elseif game_state == "results" then
        if action == "confirm" or action == "quit" then game_state = "menu" end
        
    elseif game_state == "info" then
        if action == "quit" or action == "info" or action == "confirm" then 
            game_state = "menu" 
        end
    end
end
-- KEYBOARD

local function toggle_resolution()
    res_index = res_index + 1
    if res_index > #res_options then res_index = 1 end
    
    WIDTH = res_options[res_index].w
    HEIGHT = res_options[res_index].h
    love.window.setMode(WIDTH, HEIGHT)
    save_data()
end

function love.keypressed(key)
    if game_state == "binding" then
        if love.timer.getTime() - (last_menu_action_time or 0) < 0.2 then return end

        if key == "escape" then game_state = "controls_" .. bind_type return end
        if bind_type == "kb" then
            local binds = (play_style == "vertical") and kb_binds_vert or kb_binds_cent
            binds[bind_lane] = key
            save_data(); game_state = "controls_kb"
        end
        return 
    end

    if game_state == "play" then
        local active_kb = get_active_binds(true)
        for i = 1, 4 do if key == active_kb[i] then try_hit(i) end end
        if key == "escape" then toggle_pause() end
        return 
    end
    
    if game_state == "pause" then
        if key == "escape" then toggle_pause()
        elseif key == "up" then pause_cursor = math.max(1, pause_cursor - 1)
        elseif key == "down" then pause_cursor = math.min(2, pause_cursor + 1)
        elseif key == "return" or key == "space" then
            if pause_cursor == 1 then 
                toggle_pause()
            else 
                if music then music:stop() end
                game_state = "menu"
            end
        end
        return
    end

    if key == "up" then menu_action("up")
    elseif key == "down" then menu_action("down")
    elseif key == "left" then menu_action("left")
    elseif key == "right" then menu_action("right")
    elseif key == "return" or key == "space" or key == "x" then menu_action("confirm")
    elseif key == "escape" or key == "z" then menu_action("quit")
    elseif key == "tab" then menu_action("settings") 
    elseif key == "i" then menu_action("info")
    elseif key == "r" then toggle_resolution() end
end

-- GAMEPAD
function love.gamepadpressed(joystick, button)
    if game_state == "binding" then
        -- Blokada "Ducha PortMastera"
        if love.timer.getTime() - (last_menu_action_time or 0) < 0.2 then return end

        if button == "b" or button == "back" then game_state = "controls_" .. bind_type return end
        if bind_type == "gp" then
            local binds = (play_style == "vertical") and gp_binds_vert or gp_binds_cent
            binds[bind_lane] = button
            save_data(); game_state = "controls_gp"
        end
        return
    end
    if game_state == "play" then
        local active_gp = get_active_binds(false)
        for i = 1, 4 do if button == active_gp[i] then try_hit(i) end end
        if button == "start" or button == "select" or button == "back" then toggle_pause() end
        return 
    end
    
    if game_state == "pause" then
        if button == "start" or button == "select" or button == "back" or button == "b" then toggle_pause()
        elseif button == "dpup" then pause_cursor = math.max(1, pause_cursor - 1)
        elseif button == "dpdown" then pause_cursor = math.min(2, pause_cursor + 1)
        elseif button == "a" then
            if pause_cursor == 1 then 
                toggle_pause()
            else 
                if music then music:stop() end
                game_state = "menu"
            end
        end
        return
    end

    if button == "dpup" then menu_action("up")
    elseif button == "dpdown" then menu_action("down")
    elseif button == "dpleft" then menu_action("left")
    elseif button == "dpright" then menu_action("right")
    elseif button == "a" or button == "start" then menu_action("confirm")
    elseif button == "b" or button == "back" then menu_action("quit")
    elseif button == "select" or button == "y" then menu_action("settings")
    elseif button == "x" then menu_action("info")
    elseif button == "rightshoulder" then toggle_resolution() end
end

function love.update(dt)
    if game_state == "splash" then
        splash:update(dt)
        return
    end
    
    if game_state == "play" then
        feedback_scale = feedback_scale + (1.0 - feedback_scale) * dt * 10
        combo_scale = combo_scale + (1.0 - combo_scale) * dt * 10
        bg_scroll = (bg_scroll + dt * 150) % 60

        for i = #particles, 1, -1 do
            local p = particles[i]
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.life = p.life - dt * 2.5
            if p.life <= 0 then table.remove(particles, i) end
        end

        for i = 1, 4 do keys_pressed[i] = is_lane_down(i) end
        
        if music then
            current_time = music:tell()
            if feedback_timer > 0 then feedback_timer = feedback_timer - dt end

            if trim_end and trim_end > 0 and current_time >= trim_end then
                music:stop()
            end

            for _, note in ipairs(loaded_notes) do
                if note.is_held then
                    if keys_pressed[note.lane] then
                        score = score + math.floor(100 * dt)
                        if math.random() > 0.6 then spawn_particles(note.lane) end
                        
                        
                        if current_time >= note.time + note.duration then
                            note.is_held, note.hit = false, true
                            feedback_text, feedback_color, feedback_timer = "HOLD OK!", {0.2, 0.8, 1}, 0.5
                            feedback_scale = 1.3
                            score = score + 50
                        end
                    else
                        note.is_held = false
                        note.hit = true 
                        
                        
                        feedback_text, feedback_color, feedback_timer = "RELEASED", {1, 1, 0.2}, 0.5
                        feedback_scale = 1.3
                    end
                
                elseif not note.hit and not note.missed and current_time > note.time + 0.2 then
                    note.missed, combo, misses = true, 0, misses + 1
                    feedback_text, feedback_color, feedback_timer = "MISS!", {1, 0.2, 0.2}, 1.0
                    feedback_scale = 1.3
                    
                    
                    if limit_misses > 0 and misses >= limit_misses then
                        failed = true
                        if music then music:stop() end
                        game_state = "results"
                    end
                end
            end

            
            if not music:isPlaying() and game_state == "play" then
                if not failed and score > (highscores[current_song_name] or 0) then
                    highscores[current_song_name] = score
                    save_data()
                end
                game_state = "results"
            end
        end
    end
end

function love.draw()
    scale_factor = math.min(WIDTH / V_WIDTH, HEIGHT / V_HEIGHT)
    
    offset_x = (WIDTH - V_WIDTH * scale_factor) / 2
    offset_y = (HEIGHT - V_HEIGHT * scale_factor) / 2

    love.graphics.push()
    
    love.graphics.translate(offset_x, offset_y)
    love.graphics.scale(scale_factor, scale_factor)

    if game_state == "splash" then splash:draw()
    elseif game_state == "menu" or game_state == "diff_select" then draw_menu()
    elseif game_state == "settings" then draw_settings()
    
    elseif game_state == "controls_kb" then draw_controls(true)
    elseif game_state == "controls_gp" then draw_controls(false)
    elseif game_state == "binding" then draw_binding()
    
    elseif game_state == "play" or game_state == "pause" then 
        if play_style == "vertical" then draw_play_vertical() else draw_play_center() end
        if game_state == "pause" then draw_pause_menu() end
    elseif game_state == "results" then draw_results()
    elseif game_state == "info" then draw_info()
    end

    love.graphics.pop()
    draw_letterbox()
end

function draw_letterbox()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, offset_x, HEIGHT)
    love.graphics.rectangle("fill", WIDTH - offset_x, 0, offset_x, HEIGHT)
    love.graphics.rectangle("fill", 0, 0, WIDTH, offset_y)
    love.graphics.rectangle("fill", 0, HEIGHT - offset_y, WIDTH, offset_y)
end

function draw_menu()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    love.graphics.setColor(0.2, 0.2, 0.3, 0.8)
    love.graphics.rectangle("fill", 0, 0, WIDTH, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("=== Jam Anywhere ===", 20, 15)
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("[TAB] or [Y] -> Settings", 380, 15)
    
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 20, 70, WIDTH - 40, 320, 10, 10)
    love.graphics.setColor(0.7, 0.7, 1)
    
    local font = love.graphics.getFont()
    local max_text_width = 410 
    local max_visible = 9
    local time = love.timer.getTime()
    
    local function draw_scrolling_text(prefix, text, x, y, is_active)
        local pre_w = font:getWidth(prefix)
        local avail_w = max_text_width - pre_w
        local text_w = font:getWidth(text)
        
        love.graphics.print(prefix, x, y)
        
        if text_w > avail_w then
            if is_active then
                local overflow = text_w - avail_w
                local speed = 60 
                local wait_start = 1.5 
                local wait_end = 1.0 
                local scroll_time = overflow / speed
                local cycle = wait_start + scroll_time + wait_end
                local t = time % cycle 
                
                local offset = 0
                if t < wait_start then 
                    offset = 0
                elseif t < wait_start + scroll_time then 
                    offset = (t - wait_start) * speed
                else 
                    offset = overflow
                end
                
                love.graphics.setScissor(x + pre_w, y, avail_w, 30)
                love.graphics.print(text, x + pre_w - offset, y)
                love.graphics.setScissor() 
            else
                local trunc = text
                while string.len(trunc) > 0 and font:getWidth(trunc .. "...") > avail_w do
                    trunc = string.sub(trunc, 1, -2) 
                end
                love.graphics.print(trunc .. "...", x + pre_w, y)
            end
        else
            love.graphics.print(text, x + pre_w, y)
        end
    end

    if game_state == "menu" then
        love.graphics.print("SELECT SONG (" .. selected_index .. "/" .. #song_list .. "):", 30, 80)
        
        local start_i = math.max(1, selected_index - math.floor(max_visible / 2))
        local end_i = math.min(#song_list, start_i + max_visible - 1)
        if end_i - start_i < max_visible - 1 then start_i = math.max(1, end_i - max_visible + 1) end
        
        for i = start_i, end_i do
            local song = song_list[i]
            local y_pos = 115 + ((i - start_i) * 30)
            local is_selected = (i == selected_index)
            local prefix = is_selected and "-> " or "   "
            
            love.graphics.setColor(is_selected and {1, 1, 0} or {0.7, 0.7, 0.7})
            
            draw_scrolling_text(prefix, song.name, 40, y_pos, is_selected)
            
            love.graphics.setColor(0.5, 0.5, 0.6)
            love.graphics.print(#song.diffs .. " maps", 480, y_pos)
        end
        
        love.graphics.setColor(1, 1, 1, 0.4)
        if start_i > 1 then love.graphics.print(" ^ ^ ^ ", 290, 95) end
        if end_i < #song_list then love.graphics.print(" v v v ", 290, 375) end
        
        love.graphics.setColor(0.3, 1, 0.3); love.graphics.print("A/ENTER: Select  |  X/i: Add Songs  |  B/ESC: Quit", 100, 430)
        
    elseif game_state == "diff_select" then
        local song = song_list[selected_index]
        love.graphics.print("SELECT DIFFICULTY (" .. selected_diff_index .. "/" .. #song.diffs .. "):", 30, 80)
        
        local start_i = math.max(1, selected_diff_index - math.floor(max_visible / 2))
        local end_i = math.min(#song.diffs, start_i + max_visible - 1)
        if end_i - start_i < max_visible - 1 then start_i = math.max(1, end_i - max_visible + 1) end
        
        for i = start_i, end_i do
            local diff_file = song.diffs[i]
            local y_pos = 115 + ((i - start_i) * 30)
            
            local display_name = diff_file
            if diff_file:match("%.osu$") then
                display_name = "[OSU] " .. diff_file:gsub("%.osu$", "")
            elseif diff_file == "map.json" then
                display_name = "[JAM] Default Map"
            end
            
            local map_id = song.name .. "/" .. diff_file
            local hs_text = (highscores[map_id] or 0) > 0 and ("Best: " .. highscores[map_id]) or "Unplayed"
            local is_selected = (i == selected_diff_index)
            local prefix = is_selected and "-> " or "   "
            
            love.graphics.setColor(is_selected and {1, 1, 0} or {0.7, 0.7, 0.7})
            
            draw_scrolling_text(prefix, display_name, 40, y_pos, is_selected)
            
            love.graphics.print(hs_text, 480, y_pos)
        end
        
        love.graphics.setColor(1, 1, 1, 0.4)
        if start_i > 1 then love.graphics.print(" ^ ^ ^ ", 290, 95) end
        if end_i < #song.diffs then love.graphics.print(" v v v ", 290, 375) end
        
        love.graphics.setColor(0.3, 1, 0.3); love.graphics.print("A/ENTER: Play  |  B/ESC: Back", 150, 430)
    end
    
    if error_msg ~= "" then love.graphics.setColor(1, 0.2, 0.2); love.graphics.print(error_msg, 20, 400) end
end

function draw_settings()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("=== SETTINGS ===", 20, 20)
    
    local style_display = play_style == "vertical" and "Vertical (Lanes)" or "4-Way (Center)"
    local res_text = WIDTH .. "x" .. HEIGHT -- Wyświetlamy realne wymiary okna
    
    local options = {
        "Scroll Speed: < " .. scroll_speed .. " >",
        "Resolution: < " .. res_text .. " >", -- Index 2
        "Note Size: < " .. note_height .. " >", -- Index 3
        "Play Style: < " .. style_display .. " >",
        "Miss Limit: < " .. (limit_misses == 0 and "Off" or limit_misses) .. " >",
        "Bad Hit Limit: < " .. (limit_bads == 0 and "Off" or limit_bads) .. " >",
        "Controls: Keyboard Mapping",
        "Controls: Gamepad Mapping",
        "Back to Menu"
    }
    
    for i, text in ipairs(options) do
        love.graphics.setColor(i == menu_cursor and {1, 1, 0} or {0.7, 0.7, 0.7})
        love.graphics.print((i == menu_cursor and "-> " or "   ") .. text, 50, 60 + (i * 35))
    end
end
function draw_controls(is_kb)
    love.graphics.clear(0.1, 0.1, 0.15)
    love.graphics.setColor(1, 1, 1)
    
    local title = is_kb and "=== KEYBOARD MAPPING ===" or "=== GAMEPAD MAPPING ==="
    love.graphics.printf(title, 0, 40, V_WIDTH, "center")
    
    local style_name = (play_style == "vertical") and "Vertical (Lanes)" or "4-Way (Center)"
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Current Style: " .. style_name, 0, 80, V_WIDTH, "center")

    local binds = {}
    if is_kb then
        binds = (play_style == "vertical") and kb_binds_vert or kb_binds_cent
    else
        binds = (play_style == "vertical") and gp_binds_vert or gp_binds_cent
    end

    local lane_names = (play_style == "vertical") and {"Lane 1 (Far Left)", "Lane 2 (Mid Left)", "Lane 3 (Mid Right)", "Lane 4 (Far Right)"} or {"Left", "Top", "Bottom", "Right"}

    for i = 1, 4 do
        if i == menu_cursor then
            love.graphics.setColor(1, 1, 0)
            love.graphics.printf("-> " .. lane_names[i] .. ": [ " .. tostring(binds[i]) .. " ]", 0, 140 + (i * 45), V_WIDTH, "center")
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.printf("   " .. lane_names[i] .. ": [ " .. tostring(binds[i]) .. " ]", 0, 140 + (i * 45), V_WIDTH, "center")
        end
    end

    if menu_cursor == 5 then
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.printf("-> Reset to Defaults", 0, 340, V_WIDTH, "center")
    else
        love.graphics.setColor(0.7, 0.4, 0.4)
        love.graphics.printf("   Reset to Defaults", 0, 340, V_WIDTH, "center")
    end

    if menu_cursor == 6 then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("-> Back to Settings", 0, 385, V_WIDTH, "center")
    else
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf("   Back to Settings", 0, 385, V_WIDTH, "center")
    end
end

function draw_binding()
    love.graphics.clear(0.1, 0.1, 0.15)
    
    love.graphics.setColor(1, 1, 0)
    local dev_name = (bind_type == "kb") and "KEY" or "BUTTON"
    -- Używamy V_HEIGHT do centrowania!
    love.graphics.printf("PRESS NEW " .. dev_name .. " FOR LANE " .. bind_lane, 0, V_HEIGHT / 2 - 20, V_WIDTH, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Press ESC or B to cancel", 0, V_HEIGHT / 2 + 30, V_WIDTH, "center")
end

function draw_play_vertical()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.08)
    
    love.graphics.setColor(0.15, 0.15, 0.25)
    for y = bg_scroll, V_HEIGHT, 60 do love.graphics.line(0, y, V_WIDTH, y) end
    
    love.graphics.setColor(0.3, 0.3, 0.4)
    for i = 1, 3 do love.graphics.line(i * LANE_WIDTH, 0, i * LANE_WIDTH, V_HEIGHT) end
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.line(0, HIT_Y, V_WIDTH, HIT_Y)

    for i = 1, 4 do
        if keys_pressed[i] then
            local c = colors[i]
            love.graphics.setColor(c[1], c[2], c[3], 0.3)
            love.graphics.rectangle("fill", (i - 1) * LANE_WIDTH, HIT_Y, LANE_WIDTH, V_HEIGHT - HIT_Y)
            love.graphics.setColor(c[1], c[2], c[3], 0.8)
            love.graphics.line((i - 1) * LANE_WIDTH, HIT_Y, i * LANE_WIDTH, HIT_Y)
        end
    end

    for _, note in ipairs(loaded_notes) do
        if not note.hit or note.is_held then
            local time_diff = note.time - current_time
            local y_bottom = HIT_Y - (time_diff * scroll_speed)
            local h = note.duration > 0 and (note.duration * scroll_speed) or note_height
            local y_top = y_bottom - h
            
            if note.is_held then
                y_bottom = HIT_Y
                y_top = HIT_Y - ((note.time + note.duration - current_time) * scroll_speed)
                h = y_bottom - y_top
            end
            
            if y_top < HEIGHT + 50 and y_bottom > -50 and h > 0 then
                local x_pos = (note.lane - 1) * LANE_WIDTH
                
                if note.missed then
                    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
                    love.graphics.rectangle("fill", x_pos + 10, y_top, LANE_WIDTH - 20, h, 8, 8)
                else
                    local c = colors[note.lane]
                    love.graphics.setColor(c[1]*0.6, c[2]*0.6, c[3]*0.6, 0.9)
                    love.graphics.rectangle("fill", x_pos + 10, y_top, LANE_WIDTH - 20, h, 6, 6)
                    love.graphics.setColor(c[1], c[2], c[3], 1)
                    love.graphics.rectangle("fill", x_pos + 18, y_top + 5, LANE_WIDTH - 36, h - 10, 4, 4)
                    
                    if note.duration > 0 then
                        love.graphics.setColor(1, 1, 1, 0.6)
                        love.graphics.rectangle("fill", x_pos + LANE_WIDTH / 2 - 4, y_top + 10, 8, math.max(0, h - 20), 4, 4)
                    end
                end
            end
        end
    end

    draw_particles()
    draw_hud()
end

function draw_play_center()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.08)
    
    local offsets = {{-1, 0}, {0, -1}, {0, 1}, {1, 0}}
    local center_hit_dist = 50 
    
    for i = 1, 4 do
        local rx = CX + (offsets[i][1] * center_hit_dist)
        local ry = CY + (offsets[i][2] * center_hit_dist)
        if keys_pressed[i] then
            love.graphics.setColor(colors[i][1], colors[i][2], colors[i][3], 0.4)
            love.graphics.circle("fill", rx, ry, 35)
        end
        love.graphics.setColor(colors[i][1], colors[i][2], colors[i][3], keys_pressed[i] and 1 or 0.3)
        love.graphics.rectangle("fill", rx - 20, ry - 20, 40, 40, 8, 8)
    end

    for _, note in ipairs(loaded_notes) do
        if not note.hit or note.is_held then
            local time_diff = note.time - current_time
            local dist_head = center_hit_dist + (time_diff * scroll_speed)
            local dist_tail = dist_head + (note.duration > 0 and (note.duration * scroll_speed) or note_height)
            
            if note.is_held then
                dist_head = center_hit_dist
                dist_tail = center_hit_dist + ((note.time + note.duration - current_time) * scroll_speed)
            end
            
            if dist_tail > 0 and dist_head < math.max(WIDTH, HEIGHT) then
                local dx, dy = offsets[note.lane][1], offsets[note.lane][2]
                
                if note.missed then love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
                else love.graphics.setColor(colors[note.lane]) end
                
                if dx ~= 0 then 
                    local x1, x2 = CX + (dist_head * dx), CX + (dist_tail * dx)
                    local left, right = math.min(x1, x2), math.max(x1, x2)
                    love.graphics.rectangle("fill", left, CY - 20, right - left, 40, 5, 5)
                    if not note.missed then
                        love.graphics.setColor(1, 1, 1, 0.4)
                        love.graphics.rectangle("fill", left+2, CY - 10, right - left - 4, 20, 3, 3)
                    end
                else 
                    local y1, y2 = CY + (dist_head * dy), CY + (dist_tail * dy)
                    local top, bot = math.min(y1, y2), math.max(y1, y2)
                    love.graphics.rectangle("fill", CX - 20, top, 40, bot - top, 5, 5)
                    if not note.missed then
                        love.graphics.setColor(1, 1, 1, 0.4)
                        love.graphics.rectangle("fill", CX - 10, top+2, 20, bot - top - 4, 3, 3)
                    end
                end
            end
        end
    end

    draw_particles()
    draw_hud()
end

function draw_particles()
    for _, p in ipairs(particles) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
        love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
    end
end

function draw_hud()
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, V_WIDTH, 40)
    
    local font = love.graphics.getFont()
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Time: %.2fs", current_time), 10, 10)
    love.graphics.print("Score: " .. score, 260, 10)
    
    if combo > 5 then
        love.graphics.setColor(1, 0.9, 0)
        local c_text = "COMBO: " .. combo
        love.graphics.print(c_text, 480, 20, 0, combo_scale, combo_scale, 0, font:getHeight()/2)
    end
    
    if feedback_timer > 0 then
        love.graphics.setColor(feedback_color[1], feedback_color[2], feedback_color[3], feedback_timer)
        local w = font:getWidth(feedback_text)
        local h = font:getHeight()
        love.graphics.print(feedback_text, CX, CY - 100, 0, feedback_scale, feedback_scale, w / 2, h / 2)
    end
end

function draw_pause_menu()
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
    
    love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
    love.graphics.rectangle("fill", CX - 150, CY - 100, 300, 200, 10, 10)
    love.graphics.setColor(0.3, 0.8, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", CX - 150, CY - 100, 300, 200, 10, 10)
    
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local text = "PAUSED"
    love.graphics.print(text, CX - font:getWidth(text)/2, CY - 70)
    
    local options = {"Resume Game", "Quit to Menu"}
    for i, opt in ipairs(options) do
        if i == pause_cursor then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("-> " .. opt, CX - 80, CY - 10 + (i * 40))
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.print("   " .. opt, CX - 80, CY - 10 + (i * 40))
        end
    end
end

function draw_info()
    love.graphics.clear(0.1, 0.1, 0.15)
    
    love.graphics.setColor(0.2, 0.2, 0.3, 0.95)
    love.graphics.rectangle("fill", 40, 40, V_WIDTH - 80, V_HEIGHT - 80, 15, 15)
    love.graphics.setColor(0.3, 0.8, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 40, 40, V_WIDTH - 80, V_HEIGHT - 80, 15, 15)
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("=== HOW TO ADD NEW SONGS ===", 180, 60)

    -- Najpierw DEFINIUJEMY tekst
    local instrukcja = "1. WEB STUDIO GENERATOR\n" ..
                "Go to: mrozkar.github.io/JamAnywhere/\n" ..
                "Upload an .ogg file to generate a map, then download the ZIP.\n\n" ..
                "2. OSU!MANIA CUSTOM MAPS\n" ..
                "Download any 4K (4-key) map from osu.ppy.sh.\n" ..
                "Rename the downloaded .osz archive to .zip and extract it.\n\n" ..
                "3. FILE PLACEMENT\n" ..
                "Place the EXTRACTED FOLDER into the following directory\n" ..
                "on your console's SD card:\n" ..
                "  /ports/jamanywhere/songs/\n\n"

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(instrukcja, 70, 90, V_WIDTH - 140, "left")

    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.printf("Press [X] or [B] / ESC to return", 40, V_HEIGHT - 70, V_WIDTH - 80, "center")
end

function draw_results()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    love.graphics.setColor(failed and {1, 0.2, 0.2, 0.3} or {0.2, 0.5, 1, 0.3})
    
    love.graphics.rectangle("fill", 50, 50, V_WIDTH - 100, V_HEIGHT - 100, 15, 15)
    
    love.graphics.setColor(1, 1, 1)
    if failed then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.print("=== MISSION FAILED ===", 210, 80)
    else
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.print("=== SONG CLEARED ===", 230, 80)
    end
    
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.print("FINAL SCORE: " .. score, 230, 140)
    
    if not failed and score >= (highscores[current_song_name] or 0) and score > 0 then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print("NEW HIGHSCORE!", 245, 110)
    end
    
    love.graphics.setColor(1, 1, 1); love.graphics.print("Max Combo: " .. max_combo, 250, 180)
    love.graphics.setColor(0.2, 1, 0.2); love.graphics.print("Perfect Hits: " .. perfect_hits, 250, 220)
    love.graphics.setColor(1, 1, 0.2); love.graphics.print("Good Hits:    " .. good_hits, 250, 250)
    love.graphics.setColor(1, 0.2, 0.2); love.graphics.print("Misses:       " .. misses, 250, 280)
    love.graphics.setColor(1, 0.5, 0.5); love.graphics.print("Bad Hits:     " .. bad_hits, 250, 310)
    
    love.graphics.setColor(0.7, 0.7, 0.7); love.graphics.print("Press A / ENTER to return to Menu", 160, 380)
end

local trigger_states = {triggerleft = false, triggerright = false}
local stick_states = {leftx = 0, lefty = 0} 

function love.gamepadaxis(joystick, axis, value)
    if axis == "triggerleft" or axis == "triggerright" then
        if value > 0.5 and not trigger_states[axis] then
            trigger_states[axis] = true
            love.gamepadpressed(joystick, axis) 
        elseif value < 0.2 and trigger_states[axis] then
            trigger_states[axis] = false
        end
        
    elseif axis == "leftx" then
        if value > 0.5 and stick_states.leftx ~= 1 then
            stick_states.leftx = 1
            menu_action("right")
        elseif value < -0.5 and stick_states.leftx ~= -1 then
            stick_states.leftx = -1
            menu_action("left")
        elseif math.abs(value) < 0.2 then
            stick_states.leftx = 0 
        end
        
    elseif axis == "lefty" then
        if value > 0.5 and stick_states.lefty ~= 1 then
            stick_states.lefty = 1
            menu_action("down")
        elseif value < -0.5 and stick_states.lefty ~= -1 then
            stick_states.lefty = -1
            menu_action("up")
        elseif math.abs(value) < 0.2 then
            stick_states.lefty = 0 
        end
    end
end