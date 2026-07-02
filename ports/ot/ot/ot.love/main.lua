require "drawables"
require "functions"
require "maps"
require "movement"
require "camara"
require "animation"
require "kUI"
require "audio"
require "pausa"

----------------------------------------- ADDED START

love.joystickpressed = function() end
love.joystickreleased = function() end
love.gamepadaxis = function() end
love.gamepadpressed = function() end
love.gamepadreleased = function() end
love.mouse.setVisible(false)

----------------------------------------- ADDED END

if arg[#arg] == "-debug" then
    require("mobdebug").start()
end --(ZeroBrane IDE)

--getmetatable('').__index = function(str,i) return string.sub(str,i,i) end

----------------------------------------- ADDED START

local function recalcZoomToFit()
    -- map size in tiles
    local mapW = #map[1]
    local mapH = #map

    -- map size in pixels (at base scale)
    local mapWpx = mapW * tile_size
    local mapHpx = mapH * tile_size

    -- how much we can scale to fit the window
    local sx = width / mapWpx
    local sy = height / mapHpx
    local finalScale = math.min(sx, sy)

    -- you draw with (zoom/2), so store double
    zoom = finalScale * 2

    -- recenter
    x_offset = (width - (mapW / 2) * tile_size * zoom) / 2
    y_offset = (height - (mapH / 2) * tile_size * zoom) / 2
end

local function rebuildScreenStuff()
    -- screen-sized
    general_canvas = love.graphics.newCanvas(width, height)
    love.graphics.setCanvas(general_canvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()

    -- these are your existing calls
    drawFloorCanvas(map)
    drawBackgroundCanvas()

    -- map-sized canvases
    top_canvas = love.graphics.newCanvas(#map[1] * tile_size, #map * tile_size)
    love.graphics.setCanvas(top_canvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()

    bottom_canvas = love.graphics.newCanvas(#map[1] * tile_size, #map * tile_size)
    love.graphics.setCanvas(bottom_canvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

----------------------------------------- ADDED END

function love.load()
    levels_complete = {}

    for i = 1, 22 do
        levels_complete[i] = false
    end

    local test = "1234"
    zoom = 4
    global_count = 0
    fps_timer = 1
    draw_frame = true
    OS = love.system.getOS()

    assets = {
        {
            {"jugador.png", 0, 128, 0, 2, 1}
        }
    }
    --name, x, y, rotation, scale, alpha---

    loaded_drawables = {}
    tile_size = 2 * 32
    n = 4
    border_width = tile_size / n

    --width = 1366;
    --height = 768;

    love.window.setMode(0, 0)
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    save_file = "Ot_save.txt"
    --Load save data
    local save_file, size = love.filesystem.read(save_file)
    print(size)
    local err = false
    if (save_file and #save_file > 4) then
        local map_name = ""

        local str = ""
        local ind = 1
        str = string.sub(save_file, ind, ind)
        while (str ~= "," and ind < 500) do
            map_name = map_name .. str
            ind = ind + 1
            str = string.sub(save_file, ind, ind)
        end
        ind = ind + 1

        local saveTileX = ""
        local saveTileY = ""

        str = string.sub(save_file, ind, ind)
        print(str)
        while (str ~= "," and ind < 500) do
            saveTileX = saveTileX .. str
            ind = ind + 1
            str = string.sub(save_file, ind, ind)
        end
        saveTileX = tonumber(saveTileX)

        ind = ind + 1
        str = string.sub(save_file, ind, ind)
        while (str ~= "," and ind < 500) do
            saveTileY = saveTileY .. str
            ind = ind + 1
            str = string.sub(save_file, ind, ind)
        end
        saveTileY = tonumber(saveTileY)

        local saveFacing = ""
        ind = ind + 1
        str = string.sub(save_file, ind, ind)
        while (str ~= "," and ind < 500) do
            saveFacing = saveFacing .. str
            ind = ind + 1
            str = string.sub(save_file, ind, ind)
        end
        saveFacing = tonumber(saveFacing)

        local saveCompleteLevels = {}
        ind = ind + 1
        str = string.sub(save_file, ind, ind)
        while (str ~= "e" and ind < 500) do
            local saveLevel = ""
            while (str ~= "-" and ind < 500) do
                saveLevel = saveLevel .. str
                ind = ind + 1
                str = string.sub(save_file, ind, ind)
            end
            table.insert(saveCompleteLevels, tonumber(saveLevel))
            ind = ind + 1
            str = string.sub(save_file, ind, ind)
        end

        while (str == "e" or str == "\n" or str == "\r" and ind < 500) do
            ind = ind + 1
            str = string.sub(save_file, ind, ind)
        end

        local load_volume = ""
        while (str ~= "e" and ind < 500) do
            load_volume = load_volume .. str
            ind = ind + 1
            str = string.sub(save_file, ind, ind)
        end

        local map_files = love.filesystem.getDirectoryItems("")

        local found = false
        for i = 1, #map_files do
            if (map_files[i] == map_name) then
                found = true
                break
            end
        end

        if (tonumber(load_volume) > 100) then
            load_volume = "100"
        end
        if (tonumber(load_volume) < 0) then
            load_volume = "0"
        end

        if (ind >= 500 or (not found)) then
            err = true
            map_file = "mid0.csv"
            map, doors_info, assets = loadMap("mid0.csv")
            level_complete = false

            tileX = 2
            tileY = 4
            playerX = (tileX - 1) * tile_size
            playerY = (tileY - 1) * tile_size
            facing = 1
            undo = {{tileX, tileY, facing}}
        else
            load_volume = tonumber(load_volume)
            print(load_volume)
            map_file = map_name
            tileX = saveTileX
            tileY = saveTileY
            facing = saveFacing
            master_volume = load_volume / 100
            love.audio.setVolume(master_volume)

            for i = 1, #saveCompleteLevels do
                levels_complete[saveCompleteLevels[i]] = true
            end

            map, doors_info, assets = loadMap(map_file)
            level_complete = false
            playerX = (tileX - 1) * tile_size
            playerY = (tileY - 1) * tile_size
            undo = {{tileX, tileY, facing}}
        end
    else
        map_file = "mid0.csv"
        map, doors_info, assets = loadMap("mid0.csv")
        level_complete = false

        tileX = 2
        tileY = 4
        playerX = (tileX - 1) * tile_size
        playerY = (tileY - 1) * tile_size
        facing = 1
        undo = {{tileX, tileY, facing}}
    end

    if (map_file == "credits.csv") then
        table.insert(audio_transition, {nil, "song2", 0})
    end
    --x_offset = (width - #map[1]*tile_size)/2;
    --y_offset = (height - #map*tile_size)/2;

    offset_destination_x = x_offset
    offset_destination_y = y_offset

    -- print(type(assets[1][1][2]));

    print("\n" .. OS)
    change = false
    --src1 = love.audio.newSource("click.mp3", "stream");
    -- love.audio.play(src1);

    love.graphics.setDefaultFilter("nearest", "nearest")
    tile_img = {}
    tile_img[1] = love.graphics.newImage("test_floor.png") -- plain.png
    tile_img[2] = love.graphics.newImage("test_floor2.png")
    tile_img[3] = love.graphics.newImage("test_floor3.png")
    tile_img[4] = love.graphics.newImage("puerta_b.png")
    tile_img[5] = love.graphics.newImage("puerta_c.png")
    tile_img[6] = love.graphics.newImage("puerta_a.png")
    tile_img[7] = love.graphics.newImage("pozo_tapado.png")
    tile_img[8] = love.graphics.newImage("barrera.png")
    tile_img[9] = love.graphics.newImage("pozo.png")
    tile_img[10] = love.graphics.newImage("pozo_floor_1.png")
    tile_img[11] = love.graphics.newImage("pozo_floor_2.png")
    tile_img[12] = love.graphics.newImage("pozo_floor_3.png")
    tile_img[13] = love.graphics.newImage("pozo_half_1.png")
    tile_img[14] = love.graphics.newImage("pozo_half_2.png")
    tile_img[15] = love.graphics.newImage("lvl_incomplete.png")
    tile_img[16] = love.graphics.newImage("lvl_complete.png")
    tile_img[17] = love.graphics.newImage("gato.png")

    tut_img = {}
    tut_img[1] = love.graphics.newImage("teclas.png")
    tut_img[2] = love.graphics.newImage("teclaZ.png")
    tut_img[3] = love.graphics.newImage("teclaR.png")

    --214 237 116
    --225 237 174
    local gColor = {201, 211, 125}
    local gColor = {101, 133, 86}
    --local gColor = {183, 193, 104};
    --local gColor = {150, 165, 71};

    grass_color = {gColor[1] / 255, gColor[2] / 255, gColor[3] / 255}

    --anim = newAnimation(love.graphics.newImage("walking.png"), 8, 16, 1, 0.1); --Nota: Hacer en relacion a dt
    --anim = newAnimation(love.graphics.newImage("kl.png"), 64, 128, 1, 0.1); --Nota: Hacer en relacion a dt

    anim = newAnimation(love.graphics.newImage("walk_left.png"), 64, 128, 0.5, 0.2)

    player_img = {
        love.graphics.newImage("player_back.png"),
        love.graphics.newImage("player_right.png"),
        love.graphics.newImage("player_front.png"),
        love.graphics.newImage("player_left.png")
    }

    prev_x = 1
    prev_y = 1

    tile_normal = {1, 2, 3, 7, 8, 9, 10}
    tile_bloque = {}

    compare_map = copyArray(map)

    key_wait = 0
    key_pressed = false
    pKey = nil
    spam_lim = 1 / 60 * player_anim_base
    spam_wait = 0.2
    undo_wait = 0.2
    frame_pressed = 0

    gamepad_wait = 0.2
    gamepad_time = gamepad_wait
    gamepad_axis = false

    player_anim = {{tileX, tileY}}

    -- 0 : gameplay
    -- 1 : mapa
    -- 2 : editor

    game_mode = 0

    pausa = false

    --Cosas de debug
    debug_info = {
        "#map real X: " .. #map[1] * tile_size .. " - tile X: " .. #map[1],
        "#map Y: " .. #map * tile_size .. " - tile Y: " .. #map,
        "x_offset: " .. x_offset,
        "border_width: " .. border_width,
        "zoom: " .. zoom,
        "tile_size: " .. tile_size,
        "facing: " .. facing,
        "capa: " .. edit_drawable_capa
    }

    debug_fuente = love.graphics.newFont("monogram_extended.ttf", 20)

    --Variables de editor

    --Array con nombres de mapa al iniciar

    edit_map = {}

    require "editor_buttons"

    blink_color = {1, 0, 0.5}
    blink = 0

    path = "./"
    map_index = 9
    creating_map = false
    writing = false
    renaming_map = false
    edit_str = ""

    file = ""
    edit_map[1] = {}
    local nsum
    local line = 1
    edit_map, doors_info, assets = loadMap(map_file)

    door_clicked = 0
    door_x = 0
    door_y = 0
    DOOR_A = 6

    right_clicked = false

    --    0
    --  3   1
    --    2

    facX = 0
    facY = -40
    --1024 768

    love.graphics.setBackgroundColor(1, 1, 1)
    love.graphics.setBackgroundColor(245 / 255, 236 / 255, 218 / 255)
    love.graphics.setBackgroundColor(245 / 255, 245 / 255, 200 / 255)

    dbug = false

    ----------------------------------------- ADDED START
    
    love.window.setMode(
        640,
        480,
        {
            resizable = true,
            minwidth = 320,
            minheight = 240,
            fullscreen = false
         --false,
        }
    )
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    
    ----------------------------------------- ADDED END

    --    if(dbug) then
    --       width = 1366;
    --       height = 768;
    --       love.window.setMode(width, height);
    --       love.window.setFullscreen(false);
    --    else
    --       love.window.setMode(width, height);
    --       love.window.setFullscreen(true);
    --    end

    for i = 1, #map do
        for j = 1, #map[i] do
            if (map[i][j] == 6) then
                tileX = j
                tileY = i
            end
        end
    end

    playerX = (tileX - 1) * tile_size
    playerY = (tileY - 1) * tile_size

    undo = {{tileX, tileY, facing}}

    general_canvas = love.graphics.newCanvas(width, height)
    love.graphics.setCanvas(general_canvas)
    love.graphics.clear()
    -- love.graphics.setBlendMode();
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()

    drawFloorCanvas(map)

    drawBackgroundCanvas()
    top_canvas = love.graphics.newCanvas(#map[1] * tile_size, #map * tile_size)
    love.graphics.setCanvas(top_canvas)
    love.graphics.clear()
    -- love.graphics.setBlendMode();
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 400, 400, 100, 100)
    love.graphics.setCanvas()

    bottom_canvas = love.graphics.newCanvas(#map[1] * tile_size, #map * tile_size)
    love.graphics.setCanvas(bottom_canvas)
    love.graphics.clear()
    -- love.graphics.setBlendMode();
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 300, 300, 100, 100)
    love.graphics.setCanvas()
    x_offset = (width - (#map[1] / 2) * tile_size * zoom) / 2
    y_offset = (height - (#map / 2) * tile_size * zoom) / 2

    recalcZoomToFit() ----------------------------------------- ADDED
    rebuildScreenStuff() -------------------------------------- ADDED
end

----------------------------------------- ADDED START

function love.resize(w, h)
    width, height = w, h
    recalcZoomToFit()
    rebuildScreenStuff()
    map, doors_info, assets = loadMap(map_file)
    playSound("undo", 0.4, -10, -10)
    playSound("reset", 0.4, -10, -10)
    tileX = undo[1][1]
    tileY = undo[1][2]
    facing = undo[1][3]
    undo = {undo[1]}
end

----------------------------------------- ADDED END

function love.update(dt)
    global_count = global_count + dt

    fps_timer = fps_timer + dt

    -- if(#map) then
    --     x_offset = (1366/2) - ((#map[1]/2)*tile_size)
    --     y_offset = (768/2) - ((#map/2)*tile_size)

    -- else
    --     x_offset = 0;
    --     y_offset = 0;
    -- end
    -- print(#loaded_drawables)
    checkMovements()

    -- tile_size = tile_size + a;
    -- if(tile_size > 80 or tile_size < 40) then a = a * -1; end

    update_buttons()
    camara()
    transition(dt)
    animate_tiles(dt)
    audioTransition()
    checkSound()
    --print(love.joystick.getJoysticks()[1]:isGamepadDown("a"))

    if (game_mode == 0) then
        if (key_pressed) then
            key_wait = key_wait + dt
        else
            frame_pressed = 0
            undo_wait = 0.2
            spam_wait = spam_lim + spam_lim / 2
            key_wait = 0.05
        end

        if (gamepad_axis) then
            gamepad_time = gamepad_time + dt
        else
            gamepad_time = 0.05
            gamepad_wait = spam_lim + spam_lim / 2
        end
        if
            (key_wait > spam_wait and key_pressed and
                (pKey == "left" or pKey == "right" or pKey == "up" or pKey == "down" or pKey == "w" or pKey == "a" or
                    pKey == "s" or
                    pKey == "d" or
                    pKey == "h" or
                    pKey == "j" or
                    pKey == "k" or
                    pKey == "l"))
         then --key mantenida, con delay aumentado hasta limite
            key_wait = 0
            love.keypressed(pKey)
            if (spam_wait > spam_lim) then
                spam_wait = spam_wait - spam_lim / 3
            elseif (spam_wait < spam_lim) then
                spam_wait = spam_lim
            end
        elseif (key_wait > undo_wait and key_pressed and pKey == "z") then
            key_wait = 0
            love.keypressed(pKey)

            if (undo_wait > 0.04) then
                undo_wait = undo_wait - 0.01
            end
        elseif (gamepad_time > gamepad_wait and gamepad_axis) then
            gamepad_time = 0

            checkGamepadAxis(gamepad_value_x, gamepad_value_y)
            if (gamepad_wait > spam_lim) then
                gamepad_wait = gamepad_wait - spam_lim / 3
            elseif (gamepad_wait < spam_lim) then
                gamepad_wait = spam_lim
            end
        end

        -- playerX = (tileX - 1) * tile_size;
        -- playerY = (tileY - 1) * tile_size;

        if (facing == 0) then
            facX = 0
            facY = -40
        elseif (facing == 1) then
            facX = 40
            facY = 0
        elseif (facing == 2) then
            facX = 0
            facY = 40
        elseif (facing == 3) then
            facX = -40
            facY = 0
        end
    elseif (game_mode == 2) then --Editor
        if (blink < math.pi * 2) then
            blink = blink + dt * 4
        else
            blink = 0
        end

        --edit_tileY

        --blink_color = {math.abs(math.cos(blink)), math.sin(blink), 0};
        local col = math.abs(blink)
        blink_color = {(math.cos(blink) + 1) / 2, (math.cos(blink + math.pi / 2) + 1) / 2, ((math.sin(blink) + 1) / 2)}
    end

    playerX = (tileX - 1) * tile_size
    playerY = (tileY - 1) * tile_size
end

function love.draw(dt)
    --x_offset = 0;
    --y_offset = 0;

    tmp_midx = #map[1] * tile_size
    tmp_midy = #map * tile_size

    if (fps_timer >= 0.016) then
        fps_timer = 0
        draw_frame = true
    end

    local canvas_x = (width - width * zoom / 2) / 2
    local canvas_y = (height - height * zoom / 2) / 2

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background_canvas, 0, 0)

    if (draw_frame) then
        draw_frame = false
        if (game_mode == 0) then -- Gameplay
            drawTiles(map)
        elseif (game_mode == 2) then -- Editor
            drawTiles(edit_map)
        elseif (game_mode == 1) then
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(floor_canvas, x_offset, y_offset, 0, zoom / 2)
    love.graphics.draw(general_canvas, canvas_x, canvas_y, 0, zoom / 2)

    if (map_file == "mid0.csv") then

    ----------------------------------------- COMMENTED START

    --    love.graphics.setColor(0, 0, 0, 0.8);
    --    love.graphics.draw(tut_img[1], width/2-96 - 200, 6*height/8, 0, 2);
    --    love.graphics.setFont(credits_fuente);
    --    love.graphics.printf("Move", width/2-96 - 200, 6*height/8 + 128, 194, "center");
    --    
    --    love.graphics.setColor(0, 0, 0, 0.8);
    --    love.graphics.draw(tut_img[2], width/2-16, 6*height/8 + 64, 0, 2);
    --    love.graphics.setFont(credits_fuente);
    --    love.graphics.printf("Undo", width/2 -26, 6*height/8 + 128, 86, "center");
    --
    --    love.graphics.setColor(0, 0, 0, 0.8);
    --    love.graphics.draw(tut_img[3], width/2-16 + 200, 6*height/8 + 64, 0, 2);
    --    love.graphics.setFont(credits_fuente);
    --    love.graphics.printf("Restart", width/2-16 + 150, 6*height/8 + 128, 180, "center");

    ----------------------------------------- COMMENTED END

    end

    if (in_transition) then
        local transition_alpha = transition_time * 2
        if (transition_alpha > 1) then
            transition_alpha = 1 - (transition_time * 2 - 1)
        end
        love.graphics.setColor(245 / 255, 245 / 255, 200 / 255, transition_alpha)
        love.graphics.rectangle("fill", 0, 0, width, height)
    end

    if (game_mode == 2) then
        drawUI()
        drawButtons()
    end

    local anim_str = ""
    local aList = animation_list[#animation_list]
    if (#animation_list > 0) then
        anim_str =
            aList[1] .. "--" .. aList[2] .. "--" .. aList[3] .. "--" .. aList[4] .. "--" .. aList[5] .. "--" .. aList[6]
    end

    local tile_anim_str = ""
    local animAList = tile_animation_list[1]
    if (#tile_animation_list > 0) then
        tile_anim_str =
            animAList[1] ..
            "--" ..
                animAList[2] ..
                    "--" .. animAList[3] .. "--" .. animAList[4] .. "--" .. animAList[5] .. "--" .. animAList[6]
    end

    local movement_list_str = listToString(movement_list)

    local lev_com = ""

    for i = 1, #levels_complete do
        if (levels_complete[i]) then
            lev_com = lev_com .. "1"
        else
            lev_com = lev_com .. "0"
        end
        lev_com = lev_com .. " "
    end

    debug_info = {
        "#map real X: " .. #map[1] * tile_size .. " - #map tiles X: " .. #map[1],
        "#map Y: " .. #map * tile_size .. " - #map tiles Y: " .. #map,
        "x_offset: " .. x_offset,
        "border_width: " .. border_width,
        "zoom: " .. zoom,
        "tile_size: " .. tile_size,
        "facing: " .. facing,
        "tileX: " .. tileX,
        "tileY: " .. tileY,
        "map_name: " .. map_file,
        "capa: " .. edit_drawable_capa,
        "edit_capa: " .. edit_drawable_selected_capa,
        "last_anim: " .. anim_str,
        "tile_anim: " .. tile_anim_str,
        "movement_list: " .. movement_list_str,
        "rot_time: " .. player_rot_anim_time,
        "levels_com: " .. lev_com,
        "volume: " .. master_volume
    }

    --love.graphics.polygon("fill", x_offset, y_offset, tile_size/2 + x_offset, tile_size/2 + y_offset, tile_size + x_offset, y_offset)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setColor(0, 0, 0, 0.5)
    --love.graphics.rectangle("fill", x_offset + border_width*zoom/2, y_offset + border_width*zoom/2, tile_size, tile_size)
    local isDebug = false
    if (isDebug) then
        love.graphics.rectangle("fill", 0, 200, 400, #debug_info * 40)
        love.graphics.setFont(debug_fuente)
        for i = 1, #debug_info do
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(debug_info[i], 20, i * 30 + 230)
        end
    end

    if (map_file == "credits.csv") then
        local rect_x = width / 4
        local rect_y = height / 4
        love.graphics.setColor(221 / 255, 221 / 255, 90 / 255)
        love.graphics.setLineWidth(6)
        love.graphics.rectangle("line", rect_x, 10, rect_x * 2, rect_y)

        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.rectangle("fill", rect_x, 10, rect_x * 2, rect_y)

        love.graphics.setFont(credits_fuente)
        love.graphics.setColor(245 / 255, 245 / 255, 200 / 255)
        local credits_text = "Thanks for playing!\nOt, a game by Koliao\nAssets used:"
        love.graphics.printf(credits_text, rect_x, rect_y / 6, rect_x * 2 / (rect_y / 270), "center", 0, rect_y / 270)

        love.graphics.setFont(assets_fuente)
        local assets_credit =
            "https://opengameart.org/content/bird-song-1-second\nhttps://opengameart.org/content/breeze\nhttps://opengameart.org/content/20-rustles-dry-leaves\nhttps://datagoblin.itch.io/monogram\nhttps://soundcloud.com/koliao/ott"
        love.graphics.printf(
            assets_credit,
            rect_x,
            5 * rect_y / 8,
            rect_x * 2 / (rect_y / 270),
            "center",
            0,
            rect_y / 270
        )
    end

    if (pausa) then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, width, height)

        love.graphics.setFont(menu_fuente)
        love.graphics.setColor(1, 1, 1)

        dHeight = height / 8

        dMenuX = (#menu_pausa[menu_selected + 1] * 180) / 8
        dMenuY = 86
        love.graphics.setColor(221 / 255, 221 / 255, 90 / 255)
        love.graphics.setLineWidth(6)
        love.graphics.rectangle("line", width / 2 - dMenuX, dHeight * (menu_selected + 2), 2 * dMenuX - 10, dMenuY)
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", width / 2 - dMenuX, dHeight * (menu_selected + 2), 2 * dMenuX - 10, dMenuY)

        if (menu_selected == 2) then
            local str_volume = master_volume * 100 .. "%"
            love.graphics.setColor(245 / 255, 245 / 255, 200 / 255)
            love.graphics.printf(
                str_volume,
                width / 2 + dMenuX + 40,
                dHeight * (menu_selected + 2),
                10 * 180 / 8,
                "center"
            )

            love.graphics.setLineWidth(4)
            local v1 = {width / 2 - dMenuX - dMenuX / 2 + 50, dHeight * (menu_selected + 2) - dHeight / 4 + dMenuY / 2}
            local v2 = {width / 2 - dMenuX - dMenuX / 2 + 50, dHeight * (menu_selected + 2) + dHeight / 4 + dMenuY / 2}
            local v3 = {width / 2 - dMenuX - dMenuX / 2, dHeight * (menu_selected + 2) + dMenuY / 2}
            love.graphics.setColor(221 / 255, 221 / 255, 90 / 255)
            love.graphics.polygon("line", v1[1], v1[2], v2[1], v2[2], v3[1], v3[2])

            local v4 = {width / 2 + dMenuX + dMenuX / 8 - 10, dHeight * (menu_selected + 2) - dHeight / 4 + dMenuY / 2}
            local v5 = {width / 2 + dMenuX + dMenuX / 8 - 10, dHeight * (menu_selected + 2) + dHeight / 4 + dMenuY / 2}
            local v6 = {width / 2 + dMenuX + dMenuX / 8 + 40, dHeight * (menu_selected + 2) + dMenuY / 2}
            love.graphics.setColor(221 / 255, 221 / 255, 90 / 255)
            love.graphics.polygon("line", v4[1], v4[2], v5[1], v5[2], v6[1], v6[2])
            love.graphics.setColor(0, 0, 0, 0.8)
        end

        for i = 1, #menu_pausa do
            --love.graphics.setColor(1, 1, 0);
            --love.graphics.rectangle("fill", width/2 - 200, (menu_selected)*dHeight + dHeight*2 + 20, 50, 50);

            love.graphics.setColor(245 / 255, 245 / 255, 200 / 255)
            love.graphics.printf(menu_pausa[i], 0, (i - 1) * dHeight + dHeight * 2, width, "center")
            --love.graphics.print(menu_pausa[i], width/2, (i-1)*dHeight + dHeight*2);
        end
    end
end

