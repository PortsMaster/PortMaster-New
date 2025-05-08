local socket = require("socket")
local push = require "push"

love.graphics.setDefaultFilter("nearest", "nearest")
local gameWidth, gameHeight = 640, 480 -- Fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})

--local mpd_host = "10.1.1.2" -- Just for Debugging on my PC to other devices
local mpd_host = "127.0.0.1"
local mpd_port = 6970
local mpd_client
local songs = {}
local selected_index = 1
local metadata = {}
local screenWidth, screenHeight = 640, 480
local scroll_offset = 0
local max_visible_songs = 15 -- Number of songs visible at a time

local current_time = 0
local total_time = 0

local font = love.graphics.newFont("assets/font/Monocraft.ttf", 14) 
local bigfont = love.graphics.newFont("assets/font/Monocraft.ttf", 40)
local minifont = love.graphics.newFont("assets/font/Monocraft.ttf", 12)  
love.graphics.setFont(font)

local key_hold = { up = false, down = false } 
local key_hold_timer = 0 
local key_hold_interval = 0.1

local is_playing = false -- Shared variable to track playback state, i love and hate using this

local song_scroll_offset = 0 -- Horizontal scroll offset for the selected song
local song_scroll_speed = 50 -- Pixels per second for scrolling
local song_scroll_timer = 0 -- Timer to control when scrolling starts
local song_scroll_delay = 2 -- Seconds to wait before scrolling starts

-- Scroll variables for metadata
local metadata_scroll_offset = { title = 0, artist = 0, album = 0, genre = 0, length = 0 }
local metadata_scroll_speed = 20 -- Slower scrolling speed (pixels per second)
local metadata_scroll_timer = { title = 0, artist = 0, album = 0, genre = 0, length = 0 }
local metadata_scroll_delay = 2 -- Seconds to wait before scrolling starts

-- Scroll variables for play queue
local play_queue_scroll_offset = 0
local play_queue_scroll_speed = 20 -- Slower scrolling speed (pixels per second)
local play_queue_scroll_timer = 0
local play_queue_scroll_delay = 2 -- Seconds to wait before scrolling starts

-- Variables for playlist support
local is_playlist_view = false
local playlists = {}
local selected_playlist_index = 1
local playlist_songs = {}

-- Variables for toggle cooldown
local toggle_timer = 0
local toggle_interval = 0.3 -- 300ms cooldown
local r_key_pressed = false -- Track if the R key is currently pressed


function love.update(dt)

    toggle_timer = toggle_timer + dt
    if toggle_timer >= toggle_interval then
        r_key_pressed = false
    end

    update_playback_info()
    fetch_play_queue()

    if is_playlist_view then
        if love.keyboard.isDown("up") and selected_playlist_index > 1 then
            selected_playlist_index = selected_playlist_index - 1
            fetch_playlist_songs(playlists[selected_playlist_index])
        elseif love.keyboard.isDown("down") and selected_playlist_index < #playlists then
            selected_playlist_index = selected_playlist_index + 1
            fetch_playlist_songs(playlists[selected_playlist_index])
        end
    end

    -- Handle key holding for scrolling
    key_hold_timer = key_hold_timer + dt
    if key_hold_timer >= key_hold_interval then
        if key_hold.down and selected_index < #songs then
            selected_index = selected_index + 1
            if selected_index > scroll_offset + max_visible_songs then
                scroll_offset = scroll_offset + 1
            end
            song_scroll_offset = 0 
            song_scroll_timer = 0 
            metadata = fetch_metadata(songs[selected_index]) -- Fetch metadata for the selected song
        elseif key_hold.up and selected_index > 1 then
            selected_index = selected_index - 1
            if selected_index <= scroll_offset then
                scroll_offset = scroll_offset - 1
            end
            song_scroll_offset = 0 
            song_scroll_timer = 0 
            metadata = fetch_metadata(songs[selected_index]) -- Was i drunk or why are we fetching metadata here twice?
        end
        key_hold_timer = 0 
    end
    

    if #songs > 0 then
        local selected_song = songs[selected_index]
        local song_width = font:getWidth(selected_song)
        local max_song_width = screenWidth * 0.4 - 20 

        if song_width > max_song_width then
            song_scroll_timer = song_scroll_timer + dt
            if song_scroll_timer > song_scroll_delay then
                song_scroll_offset = song_scroll_offset + song_scroll_speed * dt
                if song_scroll_offset > song_width then
                    song_scroll_offset = -max_song_width
                end
            end
        else
            song_scroll_offset = 0 
        end
    end

    -- Handle scrolling for metadata fields
    for field, offset in pairs(metadata_scroll_offset) do
        local text = metadata[field] or "N/A"
        local text_width = font:getWidth(text)
        local max_width = screenWidth * 0.35 - 20 -- Width of the metadata box minus padding

        if text_width > max_width then
            metadata_scroll_timer[field] = metadata_scroll_timer[field] + dt
            if metadata_scroll_timer[field] > metadata_scroll_delay then
                metadata_scroll_offset[field] = metadata_scroll_offset[field] + metadata_scroll_speed * dt
                if metadata_scroll_offset[field] > text_width then
                    metadata_scroll_offset[field] = -max_width -- Reset scrolling to the start
                end
            end
        else
            metadata_scroll_offset[field] = 0 -- Reset scrolling if the text fits
            metadata_scroll_timer[field] = 0 -- Reset the scroll timer
        end
    end
end

function love.load()
    reload_mpd()
    connect_mpd()
end


-----------------------------------------------------------------------------
-----------------------INPUT SHIT -------------------------------------------
-----------------------------------------------------------------------------
function play_selected_playlist()
    if #playlists > 0 then
        local selected_playlist = playlists[selected_playlist_index]
        send_command("clear")
        send_command('load "' .. selected_playlist .. '"') 
        send_command("play")
        print("Playing playlist:", selected_playlist)
    end
end


function love.keypressed(key)
    if key == "r" and not r_key_pressed and toggle_timer >= toggle_interval then
        toggle_playlist_view()
        toggle_timer = 0 
        r_key_pressed = true 
    elseif is_playlist_view then
        if key == "up" and selected_playlist_index > 1 then
            selected_playlist_index = selected_playlist_index - 1
            fetch_playlist_songs(playlists[selected_playlist_index])
        elseif key == "down" and selected_playlist_index < #playlists then
            selected_playlist_index = selected_playlist_index + 1
            fetch_playlist_songs(playlists[selected_playlist_index])
        elseif key == "return" then
            play_selected_playlist() -- why did i not write that here?
        end
    else
        if key == "down" then
            key_hold.down = true
        elseif key == "up" then
            key_hold.up = true
        elseif key == "x" then
            send_command("clear")
            local song = songs[selected_index]
            print("Adding song to playlist: " .. song)
            send_command('add "' .. song .. '"')
            send_command("play")
        elseif key == "a" then
            if is_playing then
                send_command("pause")
                print("Music stopped.")
            else
                send_command("pause 0")
                print("Music started.")
            end
        elseif key == "y" then
            send_command("clear")
            print("Playlist cleared.")
        elseif key == "b" then
            local song = songs[selected_index]
            print("Adding song to playlist: " .. song)
            send_command('add "' .. song .. '"')
        elseif key == "return" then    
            if #songs > 0 then
                local song = songs[selected_index]
                send_command("clear")
                print("Adding song to playlist: " .. song)
                send_command('add "' .. song .. '"')
                send_command("play")
            else
                print("No song selected.")
            end
        elseif key == "l" then
            send_command("update")
            print("Updating MPD database.")
        end
    end
end

function love.keyreleased(key)
    if key == "r" then
        r_key_pressed = false 
    elseif key == "down" then
        key_hold.down = false
    elseif key == "up" then
        key_hold.up = false
    end
end

-----------------------------------------------------------------------------
----------------MPD FUNCTIONS -----------------------------------------------
-----------------------------------------------------------------------------

function update_playback_info()
    local response = send_command("status")
    for _, line in ipairs(response) do
        if line:find("time:") then
            local current, total = line:match("time: (%d+):(%d+)")
            if current and total then
                current_time = tonumber(current)
                total_time = tonumber(total)
            else
                current_time = 0
                total_time = 0
            end
        end
    end


    is_playing = false
    for _, line in ipairs(response) do
        if line:find("state: play") then
            is_playing = true
            break
        end
    end

    -- Like why cant you just see its not set and always give it 0
    -- This is a workaround to avoid nil values because lua is shit
    if not current_time or not total_time then
        current_time = 0
        total_time = 0
    end
end


function send_command(cmd) -- Yeah i love this shit
    if not mpd_client then
        print("Connecting to MPD...")
        connect_mpd()
    end
    
    -- print("Sending command: " .. cmd)  -- Debugging the command being sent to MPD
    mpd_client:send(cmd .. "\n")
    
    local response = {}
    while true do
        local line, err = mpd_client:receive("*l")
        if not line then
            print("Error receiving response: " .. err)
            break
        end
        
        -- Print all lines of the response for debugging, activate it if you want a log that is a 1gb file
        -- print("MPD Response Line: " .. line)

        if line:find("OK") or line:find("ACK") then
            break
        end

        table.insert(response, line)
    end


    return response
end

function connect_mpd()
    mpd_client = assert(socket.tcp(), "Failed to create TCP socket.")
    
    local success, err = pcall(function()
        mpd_client:connect(mpd_host, mpd_port)
        mpd_client:settimeout(0.5)
        mpd_client:receive("*l") -- Consume MPD welcome message, like i consume your soul
    end)

    -- Check if the connection was successful, i should build a safe fail here but nah
    if success then
        print("Connected to MPD!")
    else
        print("Failed to connect to MPD:", err)
    end
        send_command("update")
end

function reload_mpd()
    print("Reloading DB")
    
    songs = {}
    local response = send_command("listall")
    
    for _, line in ipairs(response) do
        if line:find("file:") then
            local song = line:gsub("file: ", "")
            if song and song ~= "" then
                table.insert(songs, song)
            end
        end
    end
    
    -- Debug output for songs
    print("Songs List:")
    for _, song in ipairs(songs) do
        print(song)  -- This will show all the songs found, log is getting crazy
    end

    if #songs > 0 then
        selected_index = 1
        metadata = fetch_metadata(songs[selected_index]) -- Fetch metadata for the first song, because if i dont system goes bluescreen
    end
end

-- I dont know what a "^" is but it works so i dont care
function fetch_metadata(song_path)
    local response = send_command('lsinfo "' .. song_path .. '"')
    local metadata = {}

    for _, line in ipairs(response) do
        if line:find("^Title:") then
            metadata.title = line:gsub("Title: ", "") -- Remove the "Title: " prefix
        elseif line:find("^Artist:") then
            metadata.artist = line:gsub("Artist: ", "") -- Remove the "Artist: " prefix
        elseif line:find("^Album:") then
            metadata.album = line:gsub("Album: ", "") -- Remove the "Album: " prefix
        elseif line:find("^Track:") then
            metadata.track = line:gsub("Track: ", "") -- Remove the "Track: " prefix
        elseif line:find("^Genre:") then
            metadata.genre = line:gsub("Genre: ", "") -- Remove the "Genre: " prefix
        elseif line:find("^Time:") then
            local time_str = line:gsub("Time: ", "") -- Remove the "Time: " prefix
            local time_in_seconds = tonumber(time_str)
            if time_in_seconds then
                local minutes = math.floor(time_in_seconds / 60)
                local seconds = time_in_seconds % 60
                metadata.length = string.format("%d:%02d", minutes, seconds)
            else
                metadata.length = "N/A"
            end
        end
    end

    return metadata
end

function fetch_playlists()
    playlists = {}
    local response = send_command("listplaylists")
    for _, line in ipairs(response) do
        if line:find("^playlist:") then
            local playlist_name = line:gsub("playlist: ", "")
            table.insert(playlists, playlist_name)
        end
    end
end

-- Function to fetch songs, BABY
function fetch_playlist_songs(playlist_name)
    playlist_songs = {}
    local response = send_command('listplaylistinfo "' .. playlist_name .. '"')
    for _, line in ipairs(response) do
        if line:find("^file:") then
            local song = line:gsub("file: ", "")
            table.insert(playlist_songs, song)
        end
    end
end

-- Why did i make a function for this?
function toggle_playlist_view()
    is_playlist_view = not is_playlist_view
    if is_playlist_view then
        fetch_playlists()
        if #playlists > 0 then
            selected_playlist_index = 1
            fetch_playlist_songs(playlists[selected_playlist_index])
        end
    end
    print("Toggled view. Playlist view:", is_playlist_view)
end

-- Variable to store the play queue
local play_queue = {}

-- Function to fetch the play queue
function fetch_play_queue()
    play_queue = {}
    local response = send_command("playlistinfo")
    for _, line in ipairs(response) do
        if line:find("^file:") then
            local song = line:gsub("file: ", "")
            table.insert(play_queue, song)
        end
    end
end


-----------------------------------------------------------------------------
---- DRAW Function because its long and makes the "important" shit unreadable
-----------------------------------------------------------------------------

function love.draw()
    love.graphics.clear(0.82, 0.71, 0.55)
    push:start()
    

    -- MPD PLAYER LOGO
    love.graphics.setFont(bigfont)
    local title = "MPD Player"
    local titleWidth = bigfont:getWidth(title)
    local titleX = (screenWidth / 2) - (titleWidth / 2)
    local titleY = (screenHeight / 200) -- You know i could just give it the number instead of dividing thru 200
    love.graphics.print(title, titleX, titleY)

    love.graphics.setFont(font)

    -- "Show Playlists" Button 
    local button_box_x = screenWidth - 150 
    local button_box_y = 10
    local button_box_width = 140 
    local button_box_height = 25 

    love.graphics.setColor(0.2, 0.2, 0.2) 
    love.graphics.rectangle("fill", button_box_x, button_box_y, button_box_width, button_box_height, 5) -- rounded corners

    love.graphics.setColor(1, 1, 1)

    local button_text = "Playlists (R)"
    local button_text_width = font:getWidth(button_text)
    local button_text_x = button_box_x + (button_box_width / 2) - (button_text_width / 2)
    local button_text_y = button_box_y + (button_box_height / 2) - (font:getHeight() / 2)
    love.graphics.print(button_text, button_text_x, button_text_y)


    -- Draw the progress bar at the bottom, thanks Github Copilot for this
    if total_time > 0 then
        local progress = current_time / total_time -- Calculate progress percentage
        local bar_width = screenWidth * 0.8 -- 80% of the screen width
        local bar_height = 20
        local bar_x = (screenWidth - bar_width) / 2
        local bar_y = screenHeight - 50 -- Position near the bottom
        local corner_radius = bar_height / 2 -- Radius for rounded corners

        -- Draw the border of the progress bar
        love.graphics.setColor(1, 1, 1) -- White color for the border
        love.graphics.rectangle("line", bar_x, bar_y, bar_width, bar_height, corner_radius, corner_radius)

        
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", bar_x, bar_y, bar_width * progress, bar_height, corner_radius, corner_radius)

        -- I hate it but i have to do this to make it work, i should just use a library for this but nah
        local remaining_time = total_time - current_time
        local minutes = math.floor(remaining_time / 60)
        local seconds = remaining_time % 60
        local time_text = string.format("Time Left: %02d:%02d", minutes, seconds)
        local time_text_width = font:getWidth(time_text)
        local time_text_x = (screenWidth / 2) - (time_text_width / 2)
        local time_text_y = bar_y + bar_height + 10 

        love.graphics.setColor(1, 1, 1) 
        love.graphics.print(time_text, time_text_x, time_text_y)
    end

     --  shortcut bar
    local shortcut_bar_x = 20
    local shortcut_bar_y = screenHeight - 90
    local shortcut_bar_width = screenWidth - 40
    local shortcut_bar_height = 30

    love.graphics.setColor(0.2, 0.2, 0.2) 
    love.graphics.rectangle("fill", shortcut_bar_x, shortcut_bar_y, shortcut_bar_width, shortcut_bar_height, 10)
    love.graphics.setFont(minifont)
    love.graphics.setColor(1, 1, 1) 
    local shortcuts = {
        { key = "X", action = "Play " },
        { key = "A", action = "Pause/Resume " },
        { key = "Y", action = "Clear Song Queue " },
        { key = "B", action = "Add to Play Queue " },
    }
    local shortcut_x = shortcut_bar_x + 10
    local shortcut_y = shortcut_bar_y + 7
    for _, shortcut in ipairs(shortcuts) do
        local text = shortcut.key .. ":" .. shortcut.action
        love.graphics.print(text, shortcut_x, shortcut_y)
        shortcut_x = shortcut_x + font:getWidth(text) 
    end

    love.graphics.setFont(font)


    if is_playlist_view then
        -- Draw playlists on the left side
        local playlist_x = 20
        local playlist_y = 50
        local playlist_width = screenWidth * 0.4
        local playlist_height = screenHeight - 150

        love.graphics.setColor(0.2, 0.2, 0.2) -- Dark background for playlists
        love.graphics.rectangle("fill", playlist_x, playlist_y, playlist_width, playlist_height, 10)

        love.graphics.setColor(1, 1, 1) -- Reset color to white for text
        for i, playlist in ipairs(playlists) do
            local x = playlist_x + 10
            local y = playlist_y + (i - 1) * 20 + 10
            if i == selected_playlist_index then
                love.graphics.setColor(1, 1, 0) -- Highlight selected playlist
            else
                love.graphics.setColor(1, 1, 1) -- Reset color to white
            end
            love.graphics.print(playlist, x, y)
        end

        
        local playlist_songs_x = screenWidth * 0.6
        local playlist_songs_y = 50
        local playlist_songs_width = screenWidth * 0.35
        local playlist_songs_height = screenHeight - 150

        love.graphics.setColor(0.2, 0.2, 0.2) 
        love.graphics.rectangle("fill", playlist_songs_x, playlist_songs_y, playlist_songs_width, playlist_songs_height, 10)

        love.graphics.setColor(1, 1, 1) 
        for i, song in ipairs(playlist_songs) do
            local x = playlist_songs_x + 10
            local y = playlist_songs_y + (i - 1) * 20 + 10
            love.graphics.print(song, x, y)
        end
    else
        
        local song_list_x = 20
        local song_list_y = 50
        local song_list_width = screenWidth * 0.4 
        local song_list_height = screenHeight - 150 

        love.graphics.setColor(0.2, 0.2, 0.2) 
        love.graphics.rectangle("fill", song_list_x, song_list_y, song_list_width, song_list_height, 10)

        love.graphics.setColor(1, 1, 1) 
        if #songs == 0 then
            -- Display a message when no songs are available
            love.graphics.setColor(1, 1, 1) -- White color for text
            local no_songs_message = "No songs available"
            local message_x = song_list_x + (song_list_width / 2) - (font:getWidth(no_songs_message) / 2)
            local message_y = song_list_y + (song_list_height / 2) - (font:getHeight() / 2)
            love.graphics.print(no_songs_message, message_x, message_y)
        else
            -- Render the list of songs
            for i = 1, max_visible_songs do
                local song_index = i + scroll_offset
                if song_index > #songs then break end 
                local song = songs[song_index]
                local x = song_list_x + 10 
                local y = song_list_y + (i - 1) * 20 + 10 
                local max_song_width = song_list_width - 20 

                if song_index == selected_index then
                    love.graphics.setColor(1, 1, 0) 

                    local song_width = font:getWidth(song)
                    if song_width > max_song_width then
                        love.graphics.setScissor(x, y, max_song_width, 20) 
                        love.graphics.print(song, x - song_scroll_offset, y)
                        love.graphics.setScissor() 
                    else
                        love.graphics.print(song, x, y)
                    end
                else
                    love.graphics.setColor(1, 1, 1) 
                    love.graphics.setScissor(x, y, max_song_width, 20)
                    love.graphics.printf(song, x, y, max_song_width, "left") 
                    love.graphics.setScissor() 
                end
            end
        end

        -- Song Metadata Box
        local box_x = screenWidth * 0.6
        local box_y = 50
        local box_width = screenWidth * 0.35
        local box_height = screenHeight - 150

        -- Draw the metadata box background
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", box_x, box_y, box_width, box_height, 10)

        -- Set up text positioning and spacing
        local text_x = box_x + 10
        local text_y = box_y + 10
        local field_spacing = 30 -- Space between fields

        -- Draw metadata fields
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(minifont)

        -- Helper function to draw a metadata field with scrolling
        local function draw_metadata_field(label, value, scroll_offset, field)
            love.graphics.print(label, text_x, text_y)

            local max_width = box_width - 60 -- Width available for the value
            local text_width = font:getWidth(value or "N/A")

            if text_width > max_width then
                -- Enable clipping for scrolling
                love.graphics.setScissor(text_x + 50, text_y, max_width, 20)

                -- Draw the scrolling text
                love.graphics.print(value or "N/A", text_x + 50 - scroll_offset, text_y)

                -- Disable clipping
                love.graphics.setScissor()

                -- Update the scroll offset
                metadata_scroll_timer[field] = metadata_scroll_timer[field] + love.timer.getDelta()
                if metadata_scroll_timer[field] > metadata_scroll_delay then
                    metadata_scroll_offset[field] = metadata_scroll_offset[field] + metadata_scroll_speed * love.timer.getDelta()
                    if metadata_scroll_offset[field] > text_width + 20 then
                        metadata_scroll_offset[field] = -max_width -- Reset scrolling to the start
                    end
                end
            else
                -- Draw static text if it fits
                love.graphics.print(value or "N/A", text_x + 50, text_y)
                metadata_scroll_offset[field] = 0 -- Reset scrolling if the text fits
                metadata_scroll_timer[field] = 0 -- Reset the scroll timer
            end

            text_y = text_y + field_spacing
        end

        -- Draw each metadata field with scrolling
        draw_metadata_field("Title:", metadata.title, metadata_scroll_offset.title, "title")
        draw_metadata_field("Artist:", metadata.artist, metadata_scroll_offset.artist, "artist")
        draw_metadata_field("Album:", metadata.album, metadata_scroll_offset.album, "album")
        draw_metadata_field("Genre:", metadata.genre, metadata_scroll_offset.genre, "genre")
        draw_metadata_field("Length:", metadata.length, metadata_scroll_offset.length, "length")

        
        love.graphics.setScissor()

        text_y = text_y + 10

        
        love.graphics.print("Play Queue:", text_x, text_y)
        text_y = text_y + 20

        local max_queue_width = box_width - 20
        for i, song in ipairs(play_queue) do
            local song_width = font:getWidth(song)

            if song_width > max_queue_width then
                
                love.graphics.setScissor(text_x, text_y, max_queue_width, 20)
                love.graphics.print(song, text_x - play_queue_scroll_offset, text_y)
                love.graphics.setScissor()

                
                play_queue_scroll_timer = play_queue_scroll_timer + love.timer.getDelta()
                if play_queue_scroll_timer > play_queue_scroll_delay then
                    play_queue_scroll_offset = play_queue_scroll_offset + play_queue_scroll_speed * love.timer.getDelta()
                    if play_queue_scroll_offset > song_width + 20 then
                        play_queue_scroll_offset = -max_queue_width 
                    end
                end
            else
                
                love.graphics.print(song, text_x, text_y)
            end

            text_y = text_y + 20
            if text_y > box_y + box_height - 20 then
                break
            end
        end
    end


    push:finish()
end