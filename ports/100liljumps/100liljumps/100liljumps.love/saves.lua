require("./lume")

local SAVE_FILE_NAME = "savefile.lua"

function load_game_data()
    local contents, size_or_error = love.filesystem.read(SAVE_FILE_NAME)

    if(not contents) then
        print("[ERROR] Couldn't open the save file:", size_or_error)
        print("Creating save file")

        local success, error_message = love.filesystem.write(SAVE_FILE_NAME, "{}")
        if(success) then
            print("Save file created successfully")
        else
            print("[ERROR] Couldn't create the save file:", error_message)
        end

        return {}
    end

    local is_table = string_is_table(contents)
    if(not is_table) then
        print("[ERROR] Save file doesn't behave like a table, might contain malicious code, or brackets in strings")

        return {}
    end

    local save_data = lume.deserialize(contents)
    if(not save_data) then
        print("[ERROR] Couldn't deserialize data")

        return {}
    end

    return save_data
end

function save_game_data(game_state)
    local save_data = {
        has_finished_the_game = game_state.has_finished_the_game,
        lowest_jumps_record = game_state.lowest_jumps_record or 1,
        yellow_medal_obtained = game_state.yellow_medal_obtained,
        red_medal_obtained = game_state.red_medal_obtained,
        green_medal_obtained = game_state.green_medal_obtained,
        orange_medal_obtained = game_state.orange_medal_obtained,
        purple_medal_obtained = game_state.purple_medal_obtained,
        blue_medal_obtained = game_state.blue_medal_obtained,

        caves_challenge_completed =  game_state.caves_challenge_completed,
        temple_challenge_completed = game_state.temple_challenge_completed,
        jungle_challenge_completed = game_state.jungle_challenge_completed,
        puzzle_challenge_completed = game_state.puzzle_challenge_completed,

        has_watched_start_animation = game_state.has_watched_start_animation,
        best_time_record_in_seconds = game_state.best_time_record_in_seconds, 

        player_is_wearing_hat = (game_state.player and game_state.player.is_wearing_hat) or false,

        -- Resolution
        resolution_width  = game_state.resolution_width,
        resolution_height = game_state.resolution_height,

        -- Options info
        music_volume = Audio.music_volume,
        sounds_volume = Audio.sounds_volume,
        is_fullscreen = love.window.getFullscreen(),
        config_show_speedrun_timer  = game_state.config_show_speedrun_timer,
        config_vibration_disabled   = game_state.config_vibration_disabled,
        config_particles_disabled   = game_state.config_particles_disabled,
        config_screenshake_disabled = game_state.config_screenshake_disabled,
        config_effects_disabled     = game_state.config_effects_disabled
    }

    local serialized_save_data = lume.serialize(save_data)

    local success, error_message = love.filesystem.write(SAVE_FILE_NAME, serialized_save_data)
    if(success) then
        print("Save file updated successfully")
    else
        -- TODO: handle file deletion, maybe
        print("[ERROR] Couldn't write to the save file:", error_message)
    end
end

function is_whitespace_char(char)
    local whitespace_chars = {"\r", "\n", "\t", "\v", "\0"}

    return table_contains(whitespace_chars, char)
end

function string_is_table(raw_contents)
    local stack = {}
    local contents = nil

    for i = #raw_contents, 1, -1 do
        local char = raw_contents:sub(i, i)
        if(not is_whitespace_char(char)) then
            contents = raw_contents:sub(0, i)
            print(contents)
            break
        end
    end

    local first_char = contents:sub(1, 1)
    local last_char = contents:sub(#contents, #contents)

    if(first_char ~= "{" or last_char ~= "}") then
        return false
    end

    for i = 1, #contents do
        local c = contents:sub(i, i)

        if(c == "{") then
            table.insert(stack, "{")
        elseif(c == "}") then
            if(stack[#c] == "{") then
                table.remove(stack, #c)
            else
                -- Doesn't handle brackets inside strings
                return false
            end
        end
    end

    return #stack == 0
end
