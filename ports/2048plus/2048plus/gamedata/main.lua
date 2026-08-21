-- 2048 Plus — Main entry point
-- A feature-packed implementation of the classic 2048 game

require("globals")

local Game     = require("game")
local input    = require("input")
local renderer = require("renderer")
local save     = require("save")
local splash   = require("splash")
local sound    = require("sound")

_G.appState = "MENU" -- "MENU", "GAME", "ARCADE_MENU", "SERVER_ACTIVE", etc.
local menuSelection = 1 -- 1: Classic, 2: Plus, 3: Theme Selection, 4: Achievements, 5: Tutorial, 6: Text, 7: About, 8: Quit
_G.arcade_selection = 1
_G.play_select_selection = 1
_G.store_selection = 1

local game

_G.cheats_unlocked = false
local konami_sequence = { "up", "up", "down", "down", "left", "right", "left", "right", "backspace", "return", "space" }

-- Screen Transition System
local last_app_state = nil
local screen_transition_timer = 0
local screen_transition_duration = 0.20
local screen_canvas = nil       -- canvas of the NEW (incoming) screen
local old_screen_canvas = nil   -- canvas of the OLD (outgoing) screen
local transition_direction = 1  -- +1 = forward (new slides in from right), -1 = backward (from left)
local konami_progress = 1

local transition_delay_timer = 0
local transition_delay_action = nil
local transition_delay_key = nil
-- Direction hint set before queueing a transition: +1 forward, -1 backward
local transition_next_direction = 1
local arcade_menu_closing_action = nil

-- Hierarchy order for determining forward/backward direction
local STATE_DEPTH = {
    MENU          = 0,
    PLAY_SELECT   = 1,
    ARCADE_MENU   = 1,
    GAME          = 2,
    TUTORIAL      = 1,
    ABOUT         = 1,
    ACHIEVEMENTS  = 1,
    THEME_SELECT  = 1,
    CHEATS_MENU   = 1,
    SETTINGS      = 1,
}

-- Forward declaration (defined later in the file, after love.update's helper logic)
local drawCurrentScreen

local function captureOldScreen()
    local w, h = love.graphics.getDimensions()
    if not old_screen_canvas then
        old_screen_canvas = love.graphics.newCanvas(w, h)
    end
    love.graphics.setCanvas({old_screen_canvas, stencil = true})
    love.graphics.clear()
    drawCurrentScreen()
    love.graphics.setCanvas()
end

local function queueTransitionAction(key, delay, action, direction)
    if not _G.screen_transitions then
        transition_next_direction = direction or 1
        transition_delay_key = key
        transition_delay_timer = 0.08 -- short delay to let the button tactile animation render
        transition_delay_action = action
        return
    end
    transition_next_direction = direction or 1
    transition_delay_key = key
    transition_delay_timer = 0.12 -- Extended visual hold duration for a satisfying physical button click
    transition_delay_action = action
end

function love.load(args)
    love.math.setRandomSeed(os.time())

    -- Handle resolution arguments (same pattern as Scrappy)
    if args and #args > 0 then
        local w, h = 640, 480
        if #args >= 2 then
            w = tonumber(args[1]) or 640
            h = tonumber(args[2]) or 480
            _G.resolution = w .. "x" .. h
        else
            local parts = {}
            for part in args[1]:gmatch("[^x]+") do
                table.insert(parts, part)
            end
            w = tonumber(parts[1]) or 640
            h = tonumber(parts[2]) or 480
            _G.resolution = args[1]
        end
        love.window.setMode(w, h)
        update_ui_scale()
    end

    update_ui_scale()

    -- Initialize save system (high scores stored in static/ dir)
    if love.system.getOS() == "Web" then
        save.init("/tmp")
    else
        _G.WORK_DIR = love.filesystem.getWorkingDirectory() or "."
        save.init(_G.WORK_DIR .. "/static")
    end

    sound.init()
    _G.board_skin = save.loadBoardSkin and save.loadBoardSkin() or "default"
    _G.active_companion = save.loadCompanion and save.loadCompanion() or "none"
    _G.active_dog_breed = save.loadDogBreed and save.loadDogBreed() or "roxy"

    -- Load achievements
    local loadedAchievements = save.loadAchievements()
    if loadedAchievements then
        -- Merge loaded achievements to avoid overwriting new ones in future updates
        for k, v in pairs(loadedAchievements) do
            _G.achievements[k] = v
        end
    end
    function _G.rebuildUnlockedThemes()
        if _G.cheat_unlock_all_themes then
            _G.unlocked_themes = {"light", "dark"}
            local all_names = renderer.getAllThemeNames()
            for _, t in ipairs(all_names) do
                local found = false
                for _, existing in ipairs(_G.unlocked_themes) do
                    if existing == t then found = true break end
                end
                if not found then table.insert(_G.unlocked_themes, t) end
            end
            return
        end

        _G.unlocked_themes = {"light", "dark"}
        _G.achievements = _G.achievements or {}
        if _G.achievements.ach_first_game then table.insert(_G.unlocked_themes, "ocean") end
        if _G.achievements.ach_score_1k then table.insert(_G.unlocked_themes, "forest") end
        if _G.achievements.ach_score_5k then table.insert(_G.unlocked_themes, "sunset") end
        if _G.achievements.ach_merge_512 then table.insert(_G.unlocked_themes, "candy") end
        if _G.achievements.ach_2048 then table.insert(_G.unlocked_themes, "oled") end
        if _G.achievements.ach_score_10k then table.insert(_G.unlocked_themes, "neon") end
        if _G.achievements.ach_demolition then table.insert(_G.unlocked_themes, "retro") end
        if _G.achievements.ach_untouchable then table.insert(_G.unlocked_themes, "peach") end
        if _G.achievements.ach_merge_1024 then table.insert(_G.unlocked_themes, "midnight") end
        if _G.achievements.ach_score_2k then table.insert(_G.unlocked_themes, "volcano") end
        if _G.achievements.ach_score_7k then table.insert(_G.unlocked_themes, "abyss") end
        if _G.achievements.ach_first_bomb then table.insert(_G.unlocked_themes, "eclipse") end

        if _G.achievements.ach_2048_plus then table.insert(_G.unlocked_themes, "cyberpunk") end
        if _G.achievements.ach_4096 then table.insert(_G.unlocked_themes, "glitch") end
        if _G.achievements.ach_score_25k then table.insert(_G.unlocked_themes, "vaporwave") end
        if _G.achievements.ach_score_50k then table.insert(_G.unlocked_themes, "dracula") end
        if _G.achievements.ach_score_100k then table.insert(_G.unlocked_themes, "gold") end
        if _G.achievements.ach_untouchable_2048 then table.insert(_G.unlocked_themes, "matcha") end
        if _G.achievements.ach_secret_menu then table.insert(_G.unlocked_themes, "matrix") end
        if _G.achievements.ach_timeattack_2048 then table.insert(_G.unlocked_themes, "aurora") end
        if _G.achievements.ach_huge_2048 then table.insert(_G.unlocked_themes, "nebula") end
        if _G.achievements.ach_nomercy_512 then table.insert(_G.unlocked_themes, "inferno") end
        if _G.achievements.ach_goose_2048 then table.insert(_G.unlocked_themes, "honk") end
        if _G.achievements.ach_merge_8192 then table.insert(_G.unlocked_themes, "quantum") end
        if _G.achievements.ach_score_250k then table.insert(_G.unlocked_themes, "hyperdrive") end
        if _G.achievements.ach_speedrun_2048 then table.insert(_G.unlocked_themes, "retrogold") end
        if _G.achievements.ach_hardcore_2048 then table.insert(_G.unlocked_themes, "spectrum") end
        if _G.achievements.ach_tactician then table.insert(_G.unlocked_themes, "steel") end
        if _G.achievements.ach_melody_maker then table.insert(_G.unlocked_themes, "lofi") end
        if _G.achievements.ach_big_spender then table.insert(_G.unlocked_themes, "platinum") end
        if _G.achievements.ach_first_shield then table.insert(_G.unlocked_themes, "guardian") end
        if _G.achievements.ach_coin_hoarder then table.insert(_G.unlocked_themes, "pastel") end
        if _G.achievements.ach_best_friend then table.insert(_G.unlocked_themes, "pawprint") end
        if _G.achievements.ach_purrfect_run then table.insert(_G.unlocked_themes, "neko_night") end
        if _G.stats and _G.stats.purchased_items then
            for item_id, purchased in pairs(_G.stats.purchased_items) do
                if purchased and purchased ~= 0 and item_id:match("^theme_") then
                    local t_name = item_id:gsub("^theme_", "")
                    if t_name == "cherry_blossom" then t_name = "cherry" end
                    local found = false
                    for _, existing in ipairs(_G.unlocked_themes) do
                        if existing == t_name then found = true break end
                    end
                    if not found then table.insert(_G.unlocked_themes, t_name) end
                end
            end
        end
    end
    _G.rebuildUnlockedThemes()

    function _G.saveCheatSettings()
        if save and save.saveCheatOptions then
            save.saveCheatOptions({
                unlock_all_themes = _G.cheat_unlock_all_themes,
                max_powerups = _G.cheat_max_powerups,
                start_1024_classic = _G.cheat_start_1024_classic,
                start_1024_plus = _G.cheat_start_1024_plus,
                debug_layout = _G.cheat_debug_layout,
            })
        end
    end

    function _G.unlockAchievement(id)
        if _G.game and _G.game.mode == "huge" and id ~= "ach_huge_2048" then
            return
        end
        if not _G.achievements[id] then
            _G.achievements[id] = true
            save.saveAchievements(_G.achievements)

            local theme_map = {
                ach_first_game = "ocean",
                ach_score_1k = "forest",
                ach_score_5k = "sunset",
                ach_merge_512 = "candy",
                ach_2048 = "oled",
                ach_score_10k = "neon",
                ach_demolition = "retro",
                ach_untouchable = "peach",
                ach_merge_1024 = "midnight",
                ach_score_2k = "volcano",
                ach_score_7k = "abyss",
                ach_first_bomb = "eclipse",
                ach_2048_plus = "cyberpunk",
                ach_4096 = "glitch",
                ach_secret_menu = "matrix",
                ach_score_25k = "vaporwave",
                ach_score_50k = "dracula",
                ach_score_100k = "gold",
                ach_untouchable_2048 = "matcha",
                ach_timeattack_2048 = "aurora",
                ach_huge_2048 = "nebula",
                ach_nomercy_512 = "inferno",
                ach_goose_2048 = "honk",
                ach_merge_8192 = "quantum",
                ach_score_250k = "hyperdrive",
                ach_speedrun_2048 = "retrogold",
                ach_hardcore_2048 = "spectrum",
                ach_tactician = "steel",
                ach_melody_maker = "lofi",
                ach_big_spender = "platinum",
                ach_first_shield = "guardian",
                ach_coin_hoarder = "pastel",
                ach_best_friend = "pawprint",
                ach_purrfect_run = "neko_night"
            }
            if theme_map[id] then
                local already = false
                for _, existing in ipairs(_G.unlocked_themes) do
                    if existing == theme_map[id] then already = true; break end
                end
                if not already then
                    table.insert(_G.unlocked_themes, theme_map[id])
                end
            end

            local names = {
                ach_first_game = "First Steps",
                ach_score_1k = "Getting Started",
                ach_score_5k = "Rising Star",
                ach_merge_512 = "Half Way There",
                ach_2048 = "2048 Master",
                ach_score_10k = "High Roller",
                ach_demolition = "Demolition Expert",
                ach_untouchable = "Untouchable",
                ach_merge_1024 = "Almost There",
                ach_score_2k = "Gaining Momentum",
                ach_score_7k = "High Scorer",
                ach_first_bomb = "Boom!",
                ach_2048_plus = "Plus Mode Master",
                ach_4096 = "The One",
                ach_secret_menu = "Secret Discovery",
                ach_score_25k = "Aesthetic",
                ach_score_50k = "Vampire Lord",
                ach_score_100k = "Midas Touch",
                ach_untouchable_2048 = "Zen Master",
                ach_timeattack_2048 = "Aurora",
                ach_huge_2048 = "Spacious Giant",
                ach_nomercy_512 = "No Escape",
                ach_goose_2048 = "Honk Honk!",
                ach_merge_8192 = "The Chosen One",
                ach_score_250k = "Infinity Legend",
                ach_speedrun_2048 = "Speed Demon",
                ach_hardcore_2048 = "Hardcore Gamer",
                ach_tactician = "Tactician",
                ach_melody_maker = "Melody Maker",
                ach_big_spender = "Big Spender",
                ach_first_shield = "Second Chance",
                ach_coin_hoarder = "Coin Hoarder",
                ach_best_friend = "Best Friend",
                ach_purrfect_run = "Purrfect Run"
            }
            local coin_reward = 0
            if renderer and renderer.getAchievementsList then
                for _, ach in ipairs(renderer.getAchievementsList()) do
                    if ach.id == id then coin_reward = ach.coins or 0; break end
                end
            end
            if coin_reward > 0 then
                if _G.stats and _G.stats.purchased_items and _G.stats.purchased_items["coin_multiplier"] then
                    coin_reward = coin_reward * 2
                end
                if game and game.coin_rush_active then
                    coin_reward = coin_reward * 2
                end
                _G.stats = _G.stats or {}
                _G.stats.coins = (_G.stats.coins or 0) + coin_reward
                _G.stats.claimed_achievements = _G.stats.claimed_achievements or {}
                _G.stats.claimed_achievements[id] = true
                save.saveStats(_G.stats)
            end
            renderer.showToast("Unlocked: " .. (names[id] or id) .. "!", 2.2, id)
            if coin_reward > 0 and renderer and renderer.queueHeaderLogoMorph then
                renderer.queueHeaderLogoMorph("+" .. tostring(coin_reward) .. " COINS")
            end
            sound.playAchievement()
        end
    end

    function _G.recordDogBreedPlayed(breed_id)
        if _G.game and _G.game.mode == "huge" then return end
        breed_id = breed_id or _G.active_dog_breed or "roxy"
        _G.stats = _G.stats or {}
        _G.stats.played_dog_breeds = _G.stats.played_dog_breeds or {}

        if _G.active_companion == "dog" and breed_id then
            _G.stats.played_dog_breeds[breed_id] = true
            save.saveStats(_G.stats)
        end

        if _G.achievements and not _G.achievements["ach_best_friend"] then
            local all_played = true
            local breeds_list = _G.DOG_BREEDS or {
                { id = "roxy" }, { id = "milo" }, { id = "bruno" }, { id = "coco" }
            }
            for _, bd in ipairs(breeds_list) do
                if not _G.stats.played_dog_breeds[bd.id] then
                    all_played = false
                    break
                end
            end
            if all_played and _G.unlockAchievement then
                _G.unlockAchievement("ach_best_friend")
            end
        end
    end

    function _G.cycleStoreSortMode()
        _G.store_sort_mode = ((_G.store_sort_mode or 0) + 1) % 11
        _G.store_selection = 1
        _G.store_scroll = 0
        if _G.stats then
            _G.stats.store_sort_mode = _G.store_sort_mode
            if save and save.saveStats then save.saveStats(_G.stats) end
        end
        if sound and sound.playMenuMove then sound.playMenuMove() end
    end

    function _G.cycleTheme()
        local function getCurrentDrawTarget()
            if _G.appState == "GAME" and game then
                return game
            elseif _G.appState == "ACHIEVEMENTS" then
                return function() renderer.drawAchievements(_G.achievements_scroll or 0, true) end
            elseif _G.appState == "TUTORIAL" then
                return function() renderer.drawTutorial(_G.tutorial_page or 1, true) end
            elseif _G.appState == "ABOUT" then
                return function() renderer.drawAbout(true) end
            elseif _G.appState == "CHEATS_MENU" then
                return function() renderer.drawSecretMenu(_G.cheats_selection or 1, true) end
            elseif _G.appState == "THEME_SELECT" then
                return function() renderer.drawThemeSelect(true) end
            elseif _G.appState == "SETTINGS" then
                return function() renderer.drawSettings(_G.settings_selection or 1, true) end
            elseif _G.appState == "PLAY_SELECT" or _G.appState == "ARCADE_MENU" then
                return function() renderer.drawPlaySelectMenu(_G.play_select_selection or 1, _G.arcade_selection or 1, true, menuSelection) end
            elseif _G.appState == "STORE" then
                return function() renderer.drawStoreMenu(_G.store_selection or 1, true) end
            elseif _G.appState == "JUKEBOX" then
                return function() renderer.drawJukebox(_G.jukebox_selection or 1, true) end
            end
            return function() end
        end

        local drawTarget = getCurrentDrawTarget()
        renderer.startThemeTransition(drawTarget)

        local current_idx = 1
        for i, t in ipairs(_G.unlocked_themes or {"light", "dark"}) do
            if t == _G.theme then
                current_idx = i
                break
            end
        end
        local next_idx = (current_idx % #_G.unlocked_themes) + 1
        _G.theme = _G.unlocked_themes[next_idx]
        if renderer and renderer.applyTheme then renderer.applyTheme() end
        if _G.appState ~= "THEME_SELECT" then
            if save and save.saveTheme then save.saveTheme(_G.theme) end
            if game then game:saveGameState() end
        end
    end

    -- Load theme from dedicated file
    local savedTheme = save.loadTheme()
    if savedTheme then
        _G.theme = savedTheme
    end

    _G.cheats_unlocked = save.loadCheats()
    local cheat_opts = save.loadCheatOptions and save.loadCheatOptions() or {}
    _G.cheat_unlock_all_themes = cheat_opts.unlock_all_themes or false
    _G.cheat_max_powerups = cheat_opts.max_powerups or false
    _G.cheat_start_1024_classic = cheat_opts.start_1024_classic or false
    _G.cheat_start_1024_plus = cheat_opts.start_1024_plus or false
    _G.cheat_debug_layout = cheat_opts.debug_layout or "None"
    if _G.cheat_unlock_all_themes and _G.rebuildUnlockedThemes then
        _G.rebuildUnlockedThemes()
    end
    _G.text_size = save.loadTextSize() or "normal"
    _G.animation_speed = save.loadAnimationSpeed() or "normal"
    _G.screen_transitions = save.loadScreenTransitions()
    _G.undo_mode = save.loadUndoMode() or "classic"
    _G.time_attack_time = save.loadTimeAttackTime() or 60
    _G.vibration = save.loadVibration()
    _G.crt_filter = save.loadCrtFilter()
    _G.merge_fx = save.loadMergeFX() or "default"
    _G.board_skin = save.loadBoardSkin() or "default"

    -- Load and initialize global stats
    _G.stats = save.loadStats() or {}
    if _G.stats.merge_coins ~= nil then
        _G.stats.coins = (_G.stats.coins or 0) + _G.stats.merge_coins
        _G.stats.merge_coins = nil
    end
    _G.stats.coins = _G.stats.coins or 0
    _G.stats.purchased_items = _G.stats.purchased_items or {}
    _G.stats.claimed_achievements = _G.stats.claimed_achievements or {}
    _G.store_sort_mode = _G.stats.store_sort_mode or 0

    -- Check Coin Hoarder & Best Friend on startup
    if _G.stats.coins >= 10000 and _G.unlockAchievement then
        _G.unlockAchievement("ach_coin_hoarder")
    end
    if _G.recordDogBreedPlayed then
        _G.recordDogBreedPlayed(_G.active_dog_breed)
    end

    -- Retroactively award coins for already unlocked achievements
    if renderer and renderer.getAchievementsList then
        local all_achievements = renderer.getAchievementsList()
        local awarded_retroactive = false
        for _, ach in ipairs(all_achievements) do
            if _G.achievements[ach.id] and not _G.stats.claimed_achievements[ach.id] then
                _G.stats.coins = _G.stats.coins + (ach.coins or 0)
                _G.stats.claimed_achievements[ach.id] = true
                awarded_retroactive = true
            end
        end
        if awarded_retroactive then
            save.saveStats(_G.stats)
        end
    end

    if _G.rebuildUnlockedThemes then
        _G.rebuildUnlockedThemes()
    end

    local defaults = {
        games_played = 0,
        moves_made = 0,
        tiles_merged = 0,
        highest_score = 0,
        highest_tile = 0,
        time_played = 0,
        undos_used = 0,
        bombs_used = 0,
        swaps_used = 0,
        classic_games = 0,
        plus_games = 0,
        arcade_games = 0,
    }
    for k, v in pairs(defaults) do
        if _G.stats[k] == nil then
            _G.stats[k] = v
        end
    end

    -- Crucially apply the loaded theme to the renderer NOW
    renderer.applyTheme()

    -- Initialize input
    input.load()

    -- Initialize renderer (compute layout, load fonts)
    renderer.init()
    local w, h = love.graphics.getDimensions()
    screen_canvas = love.graphics.newCanvas(w, h)

    -- Load splash screen
    splash.load()
end

function love.update(dt)
    -- Cap dt to prevent animation glitches on frame drops
    dt = math.min(dt, 0.05)

    -- Trigger screen transitions on appState change (smooth slide animation)
    if _G.appState ~= last_app_state then
        if splash.finished and last_app_state ~= nil then
            -- ARCADE_MENU & PLAY_SELECT have their own panel slide animation; skip global slide for them
            -- Exception: PLAY_SELECT → GAME uses the normal circle-wipe so the game doesn't flash
            local going_to_game_from_play = (last_app_state == "PLAY_SELECT" or last_app_state == "ARCADE_MENU") and _G.appState == "GAME"
            local skip_slide = not going_to_game_from_play and
                (_G.appState == "ARCADE_MENU" or last_app_state == "ARCADE_MENU" or _G.appState == "PLAY_SELECT" or last_app_state == "PLAY_SELECT")
            if not skip_slide and _G.screen_transitions then
                -- Determine direction from hierarchy depth
                local old_depth = STATE_DEPTH[last_app_state] or 0
                local new_depth = STATE_DEPTH[_G.appState] or 0
                if new_depth > old_depth then
                    transition_direction = 1   -- deeper = slide from right
                elseif new_depth < old_depth then
                    transition_direction = -1  -- back = slide from left
                else
                    transition_direction = transition_next_direction
                end
                transition_next_direction = 1
                screen_transition_timer = screen_transition_duration
            end
        end
        renderer.resetMenuAnimation()
        last_app_state = _G.appState
    end

    if screen_transition_timer > 0 then
        screen_transition_timer = math.max(0, screen_transition_timer - dt)
    end

    -- Check for global exit combo (MENU + START)
    -- Only trigger if MENU and BACK are distinct keys (avoids false quit when pressing Back on PC)
    if input.events.MENU ~= input.events.BACK then
        if input.state[input.events.MENU] and input.state[input.events.START] then
            love.event.quit()
            return
        end
    end

    -- Update timer system (drives splash animations)
    timer.update(dt)

    -- Update BGM playback and playlist states
    sound.update(dt)

    -- Handle visual transition delays to show key badge animations
    if transition_delay_timer > 0 then
        transition_delay_timer = transition_delay_timer - dt
        if transition_delay_key then
            input.state[transition_delay_key] = true
        end
        if transition_delay_timer <= 0 then
            transition_delay_timer = 0
            if transition_delay_action then
                -- Capture the current (old) screen BEFORE state changes
                if _G.screen_transitions then
                    captureOldScreen()
                end
                local action = transition_delay_action
                transition_delay_action = nil
                action()
            end
            if transition_delay_key then
                input.state[transition_delay_key] = false
                transition_delay_key = nil
            end
        end
        if game then
            game:update(dt)
        end
        renderer.updateTransition(dt)
        input.update(dt)
        return
    end

    -- Smooth scroll interpolation for achievements
    if _G.achievements_scroll == nil then _G.achievements_scroll = 0 end
    if _G.achievements_scroll_target == nil then _G.achievements_scroll_target = 0 end
    if not _G.screen_transitions then
        _G.achievements_scroll = _G.achievements_scroll_target
    else
        if _G.achievements_scroll ~= _G.achievements_scroll_target then
            local diff = _G.achievements_scroll_target - _G.achievements_scroll
            _G.achievements_scroll = _G.achievements_scroll + diff * 15 * dt
            if math.abs(_G.achievements_scroll - _G.achievements_scroll_target) < 0.01 then
                _G.achievements_scroll = _G.achievements_scroll_target
            end
        end
    end

    -- Smooth scroll interpolation for About screen
    if _G.about_scroll == nil then _G.about_scroll = 0 end
    if _G.about_scroll_target == nil then _G.about_scroll_target = 0 end
    if not _G.screen_transitions then
        _G.about_scroll = _G.about_scroll_target
    else
        if _G.about_scroll ~= _G.about_scroll_target then
            local diff = _G.about_scroll_target - _G.about_scroll
            _G.about_scroll = _G.about_scroll + diff * 15 * dt
            if math.abs(_G.about_scroll - _G.about_scroll_target) < 0.01 then
                _G.about_scroll = _G.about_scroll_target
            end
        end
    end

    -- Don't process game input during splash
    if not splash.finished then
        -- Allow skipping splash with any button
        input.update(dt)
        input.processEvents(function(event)
            if event == input.events.CONFIRM or event == input.events.SELECT or event == input.events.START then
                splash.skip()
            end
        end)
        return
    end

    -- Update game animations
    if game then
        game:update(dt)
    end
    renderer.updateTransition(dt)

    -- If arcade menu is closing, wait until it is fully closed, then trigger the action
    if arcade_menu_closing_action and renderer.isArcadeMenuClosed() then
        local action = arcade_menu_closing_action
        arcade_menu_closing_action = nil
        if _G.screen_transitions then
            captureOldScreen()
        end
        action()
    end

    -- Update input (hold-to-repeat)
    input.update(dt)

    -- Process input events
    input.processEvents(function(event)
        if event == input.events.Y then
            local function getCurrentDrawTarget()
                if _G.appState == "MENU" then
                    return function() renderer.drawMainMenu(menuSelection, true) end
                elseif _G.appState == "GAME" and game then
                    return game
                elseif _G.appState == "ACHIEVEMENTS" then
                    return function() renderer.drawAchievements(_G.achievements_scroll or 0, true) end
                elseif _G.appState == "TUTORIAL" then
                    return function() renderer.drawTutorial(_G.tutorial_page or 1, true) end
                elseif _G.appState == "ABOUT" then
                    return function() renderer.drawAbout(true) end
                elseif _G.appState == "CHEATS_MENU" then
                    return function() renderer.drawSecretMenu(_G.cheats_selection or 1, true) end
                elseif _G.appState == "THEME_SELECT" then
                    return function() renderer.drawThemeSelect(true) end
                elseif _G.appState == "SETTINGS" then
                    return function() renderer.drawSettings(_G.settings_selection or 1, true) end
                elseif _G.appState == "PLAY_SELECT" then
                    return function() renderer.drawPlaySelectMenu(_G.play_select_selection or 1, _G.arcade_selection or 1, true, menuSelection) end
                elseif _G.appState == "ARCADE_MENU" then
                    return function() renderer.drawPlaySelectMenu(_G.play_select_selection or 1, _G.arcade_selection or 1, true, menuSelection) end
                elseif _G.appState == "STORE" then
                    return function() renderer.drawStoreMenu(_G.store_selection or 1, true) end
                elseif _G.appState == "JUKEBOX" then
                    return function() renderer.drawJukebox(_G.jukebox_selection or 1, true) end
                end
                return function() end
            end

            local drawTarget = getCurrentDrawTarget()
            renderer.startThemeTransition(drawTarget)

            local current_idx = 1
            for i, t in ipairs(_G.unlocked_themes) do
                if t == _G.theme then
                    current_idx = i
                    break
                end
            end
            local next_idx = (current_idx % #_G.unlocked_themes) + 1
            _G.theme = _G.unlocked_themes[next_idx]
            renderer.applyTheme()
            if _G.appState ~= "THEME_SELECT" then
                save.saveTheme(_G.theme)
                if game then game:saveGameState() end
            end
            return
        end

        if _G.appState == "MENU" then
            if not _G.cheats_unlocked then
                local target = konami_sequence[konami_progress]
                local matches = (event == target)
                if target == "backspace" and (event == "escape" or event == "backspace" or event == input.events.BACK) then
                    matches = true
                elseif target == "return" and (event == "return" or event == "a" or event == input.events.CONFIRM) then
                    matches = true
                elseif target == "space" and (event == "space" or event == "x" or event == input.events.X or event == input.events.START) then
                    matches = true
                end

                if matches then
                    konami_progress = konami_progress + 1
                    if konami_progress == 7 then
                        renderer.showToast("What you think this is a Konami game?")
                    elseif konami_progress == 9 then
                        renderer.showToast("Wait, what are you doing?")
                    elseif konami_progress > #konami_sequence then
                        renderer.showToast("You weren't supposed to do this. But OK.")
                        _G.cheats_unlocked = true
                        save.saveCheats(true)
                        konami_progress = 1
                    end
                    if event == input.events.BACK or event == input.events.CONFIRM or event == input.events.START then
                        return
                    end
                else
                    if event == konami_sequence[1] then
                        konami_progress = 2
                    else
                        konami_progress = 1
                    end
                end
            end

            local options = renderer.getMainMenuOptions()
            menuSelection = math.max(1, math.min(#options, menuSelection))
            local max_menu = #options
            if event == input.events.UP then
                menuSelection = menuSelection > 1 and (menuSelection - 1) or max_menu
                sound.playMenuMove()
            elseif event == input.events.DOWN then
                menuSelection = menuSelection < max_menu and (menuSelection + 1) or 1
                sound.playMenuMove()
            elseif event == input.events.CONFIRM then
                sound.playMenuSelect()
                queueTransitionAction(event, 0.08, function()
                    local sel = options[menuSelection]
                    if sel == "Continue" then
                        local mode = save.loadLastMode()
                        if mode then
                            _G.appState = "GAME"
                            game = Game.new(mode)
                        end
                    elseif sel == "Play Game" then
                        _G.appState = "PLAY_SELECT"
                        _G.play_select_selection = 1
                        _G.arcade_selection = 1
                        renderer.setArcadeMenuOpen(true)
                    elseif sel:match("^Select Theme") then
                        _G.themeSelectPrevState = "MENU"
                        _G.themeSelectInitialTheme = _G.theme
                        _G.appState = "THEME_SELECT"
                    elseif sel == "Achievements" or sel == "Achievements & Stats" then
                        _G.appState = "ACHIEVEMENTS"
                        _G.achievements_tab = 1
                    elseif sel == "Tutorial" then
                        _G.appState = "TUTORIAL"
                        _G.tutorial_page = 1
                    elseif sel == "Secret Menu" then
                        _G.unlockAchievement("ach_secret_menu")
                        _G.appState = "CHEATS_MENU"
                        _G.cheats_selection = 1
                    elseif sel == "Settings" then
                        _G.appState = "SETTINGS"
                        _G.settings_selection = 1
                        _G.settings_page = "main"
                    elseif sel == "About" then
                        _G.appState = "ABOUT"
                        _G.about_scroll = 0
                        _G.about_scroll_target = 0
                    elseif sel == "Quit" or sel == "Exit the Game" then
                        love.event.quit()
                    end
                end)
            elseif event == input.events.L1 then
                if _G.stats and _G.stats.purchased_items and _G.stats.purchased_items["jukebox"] then
                    sound.playMenuSelect()
                    queueTransitionAction(event, 0.08, function()
                        _G.appState = "JUKEBOX"
                        if sound.enterJukebox then
                            sound.enterJukebox()
                        end
                    end)
                end
            elseif event == input.events.R1 then
                sound.playMenuSelect()
                queueTransitionAction(event, 0.08, function()
                    _G.appState = "STORE"
                    _G.store_selection = 1
                    _G.store_scroll = 0  -- always open at top
                end)
            end
            return
        elseif _G.appState == "STORE" then
            local items = renderer.getStoreItems()
            local items_count = math.max(1, #items)
            if _G.store_selection > items_count then _G.store_selection = items_count end

            if event == input.events.SELECT or event == input.events.X then
                if _G.cycleStoreSortMode then
                    _G.cycleStoreSortMode()
                end
            elseif event == input.events.Y then
                if _G.cycleTheme then
                    _G.cycleTheme()
                end
            elseif event == input.events.UP then
                _G.store_selection = _G.store_selection > 1 and (_G.store_selection - 1) or items_count
                sound.playMenuMove()
            elseif event == input.events.DOWN then
                _G.store_selection = _G.store_selection < items_count and (_G.store_selection + 1) or 1
                sound.playMenuMove()
            elseif event == input.events.LEFT or event == input.events.RIGHT then
                local sel_item = items[_G.store_selection or 1]
                if sel_item and sel_item.id == "mascot_dog" then
                    local is_owned = _G.stats and _G.stats.purchased_items and _G.stats.purchased_items["mascot_dog"]
                    if is_owned then
                        local breeds = _G.DOG_BREEDS or {}
                        local current = _G.active_dog_breed or "roxy"
                        local cur_idx = 1
                        for idx, b in ipairs(breeds) do
                            if b.id == current then cur_idx = idx break end
                        end
                        if event == input.events.LEFT then
                            cur_idx = (cur_idx > 1) and (cur_idx - 1) or #breeds
                        else
                            cur_idx = (cur_idx < #breeds) and (cur_idx + 1) or 1
                        end
                        local new_b = breeds[cur_idx]
                        if new_b then
                            _G.active_dog_breed = new_b.id
                            if save and save.saveDogBreed then save.saveDogBreed(new_b.id) end
                            sound.playMenuMove()
                        end
                    end
                end
            elseif event == input.events.BACK then
                sound.playMenuSelect()
                queueTransitionAction(event, 0.08, function()
                    _G.appState = "MENU"
                end)
            elseif event == input.events.CONFIRM then
                sound.playMenuSelect()
                queueTransitionAction(event, 0.08, function()
                    local sel_item = items[_G.store_selection or 1]
                    if not sel_item then return end

                    if sel_item.id == "mascot_cat" then
                        local is_owned = _G.stats and _G.stats.purchased_items and _G.stats.purchased_items["mascot_cat"]
                        if is_owned then
                            if _G.active_companion == "cat" then
                                _G.active_companion = "none"
                                if save and save.saveCompanion then save.saveCompanion("none") end
                                renderer.showToast("Unequipped Cat Companion")
                            else
                                _G.active_companion = "cat"
                                if save and save.saveCompanion then save.saveCompanion("cat") end
                                renderer.showToast("Equipped Cat Companion!")
                            end
                        elseif (_G.stats.coins or 0) >= sel_item.cost then
                            _G.stats.coins = _G.stats.coins - sel_item.cost
                            _G.stats.purchased_items["mascot_cat"] = 1
                            _G.stats.total_spent_coins = (_G.stats.total_spent_coins or 0) + sel_item.cost
                            save.saveStats(_G.stats)
                            _G.active_companion = "cat"
                            if save and save.saveCompanion then save.saveCompanion("cat") end
                            renderer.showToast("Purchased & Equipped Cat Companion!")
                        else
                            renderer.showToast("Not enough Coins!")
                        end
                        return
                    end

                    if sel_item.id == "mascot_dog" then
                        local is_owned = _G.stats and _G.stats.purchased_items and _G.stats.purchased_items["mascot_dog"]
                        if is_owned then
                            if _G.active_companion == "dog" then
                                _G.active_companion = "none"
                                if save and save.saveCompanion then save.saveCompanion("none") end
                                renderer.showToast("Unequipped Dog Companion")
                            else
                                _G.active_companion = "dog"
                                if save and save.saveCompanion then save.saveCompanion("dog") end
                                renderer.showToast("Equipped Dog Companion!")
                            end
                        elseif (_G.stats.coins or 0) >= sel_item.cost then
                            _G.stats.coins = _G.stats.coins - sel_item.cost
                            _G.stats.purchased_items["mascot_dog"] = 1
                            _G.stats.total_spent_coins = (_G.stats.total_spent_coins or 0) + sel_item.cost
                            save.saveStats(_G.stats)
                            _G.active_companion = "dog"
                            if save and save.saveCompanion then save.saveCompanion("dog") end
                            renderer.showToast("Purchased & Equipped Dog Companion!")
                        else
                            renderer.showToast("Not enough Coins!")
                        end
                        return
                    end

                    -- Consumables (boosters, powerup charges, shields)
                    if sel_item.consumable then
                        local stat_key = sel_item.ckey or (sel_item.id .. "_count")
                        local current = _G.stats[stat_key] or 0
                        if current >= 99 then
                            renderer.showToast("Max 99 charges reached!")
                        elseif (_G.stats.coins or 0) >= sel_item.cost then
                            _G.stats.coins = _G.stats.coins - sel_item.cost
                            _G.stats[stat_key] = current + 1
                            _G.stats.total_spent_coins = (_G.stats.total_spent_coins or 0) + sel_item.cost
                            if _G.stats.total_spent_coins >= 5000 and _G.unlockAchievement then
                                _G.unlockAchievement("ach_big_spender")
                            end
                            if sel_item.id == "coin_rush" and game and not game.coin_rush_active then
                                game.coin_rush_active = true
                                _G.stats[stat_key] = math.max(0, (_G.stats[stat_key] or 1) - 1)
                                if game.saveGameState then game:saveGameState() end
                            end
                            save.saveStats(_G.stats)
                            renderer.showToast("Purchased! " .. sel_item.name .. " (" .. _G.stats[stat_key] .. " owned)")
                        else
                            renderer.showToast("Not enough Coins!")
                        end
                        return
                    end

                    local is_already_purchased = _G.stats.purchased_items[sel_item.id] or (sel_item.id == "theme_cherry" and _G.stats.purchased_items["theme_cherry_blossom"])
                    if is_already_purchased then
                        if sel_item.id == "secret_key" then
                            renderer.showToast("Secret Code: UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT B A START")
                        elseif sel_item.id:match("^skin_") then
                            local s_name = sel_item.id:gsub("^skin_", "")
                            if _G.board_skin == s_name then
                                _G.board_skin = "default"
                                save.saveBoardSkin("default")
                                renderer.showToast("Unequipped " .. sel_item.name)
                            else
                                _G.board_skin = s_name
                                save.saveBoardSkin(s_name)
                                renderer.showToast("Equipped " .. sel_item.name)
                            end
                        else
                            renderer.showToast("Already purchased!")
                        end
                    elseif (_G.stats.coins or 0) >= sel_item.cost then
                        _G.stats.coins = _G.stats.coins - sel_item.cost
                        _G.stats.purchased_items[sel_item.id] = 1
                        _G.stats.total_spent_coins = (_G.stats.total_spent_coins or 0) + sel_item.cost
                        if _G.stats.total_spent_coins >= 5000 and _G.unlockAchievement then
                            _G.unlockAchievement("ach_big_spender")
                        end
                        save.saveStats(_G.stats)
                        if sel_item.id == "secret_key" then
                            renderer.showToast("Secret Code: UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT B A START")
                        elseif sel_item.id:match("^skin_") then
                            local s_name = sel_item.id:gsub("^skin_", "")
                            _G.board_skin = s_name
                            save.saveBoardSkin(s_name)
                            renderer.showToast("Purchased & Equipped " .. sel_item.name .. "!")
                        else
                            renderer.showToast("Purchased " .. sel_item.name .. "!")
                        end
                        if sel_item.id:match("^theme_") then
                            local t_name = sel_item.id:gsub("^theme_", "")
                            if _G.rebuildUnlockedThemes then _G.rebuildUnlockedThemes() end
                            if renderer and renderer.startThemeTransition then
                                renderer.startThemeTransition(function()
                                    _G.theme = t_name
                                    if renderer and renderer.applyTheme then renderer.applyTheme() end
                                    if save and save.saveTheme then save.saveTheme(_G.theme) end
                                    return function() renderer.drawStoreMenu(_G.store_selection or 1, true) end
                                end)
                            else
                                _G.theme = t_name
                                if renderer and renderer.applyTheme then renderer.applyTheme() end
                                if save and save.saveTheme then save.saveTheme(_G.theme) end
                            end
                        end
                    else
                        renderer.showToast("Not enough Coins!")
                    end
                end)
            end
            return
        elseif _G.appState == "JUKEBOX" then
            local playlist = sound.getBgmPlaylist and sound.getBgmPlaylist() or {}
            local total_tracks = math.max(1, #playlist)
            _G.jukebox_selection = _G.jukebox_selection or 1

            if event == input.events.UP then
                _G.jukebox_selection = _G.jukebox_selection > 1 and (_G.jukebox_selection - 1) or total_tracks
                sound.playMenuMove()
            elseif event == input.events.DOWN then
                _G.jukebox_selection = _G.jukebox_selection < total_tracks and (_G.jukebox_selection + 1) or 1
                sound.playMenuMove()
            elseif event == input.events.LEFT then
                if sound.seekBgm then
                    local seeked = sound.seekBgm(-10)
                    if seeked then sound.playMenuMove() end
                end
            elseif event == input.events.RIGHT then
                if sound.seekBgm then
                    local seeked = sound.seekBgm(10)
                    if seeked then sound.playMenuMove() end
                end
            elseif event == input.events.CONFIRM then
                sound.playMenuSelect()
                local curr_idx = sound.getCurrentBgmIndex and sound.getCurrentBgmIndex() or 0
                if curr_idx == _G.jukebox_selection and curr_idx > 0 then
                    -- Same active track: toggle pause/play
                    sound.toggleBgmPause()
                else
                    -- Different track or fresh start: play selected track
                    sound.playBgmIndex(_G.jukebox_selection)
                end
            elseif event == input.events.Y then
                if _G.cycleTheme then
                    _G.cycleTheme()
                end
            elseif event == input.events.X then
                sound.playMenuSelect()
                sound.playNextBgm()
                -- sync selection to now-playing track
                local new_idx = sound.getCurrentBgmIndex and sound.getCurrentBgmIndex() or 1
                _G.jukebox_selection = new_idx
            elseif event == input.events.BACK then
                sound.playMenuSelect()
                queueTransitionAction(event, 0.08, function()
                    _G.appState = "MENU"
                    if sound.exitJukebox then
                        sound.exitJukebox()
                    end
                end)
            end
            return
        elseif _G.appState == "PLAY_SELECT" then
            if arcade_menu_closing_action then return end
            if event == input.events.LEFT then
                _G.play_select_selection = _G.play_select_selection > 1 and (_G.play_select_selection - 1) or 3
                sound.playMenuMove()
            elseif event == input.events.RIGHT then
                _G.play_select_selection = _G.play_select_selection < 3 and (_G.play_select_selection + 1) or 1
                sound.playMenuMove()
            elseif event == input.events.CONFIRM then
                sound.playMenuSelect()
                queueTransitionAction(event, 0.08, function()
                    if _G.play_select_selection == 1 then
                        _G.appState = "GAME"
                        game = Game.new("classic")
                    elseif _G.play_select_selection == 2 then
                        _G.appState = "GAME"
                        game = Game.new("plus")
                    elseif _G.play_select_selection == 3 then
                        _G.appState = "ARCADE_MENU"
                        _G.arcade_selection = 1
                    end
                end)
            elseif event == input.events.BACK then
                sound.playMenuBack()
                queueTransitionAction(event, 0.08, function()
                    renderer.setArcadeMenuOpen(false)
                    arcade_menu_closing_action = function()
                        _G.appState = "MENU"
                    end
                end)
            end
            return
        elseif _G.appState == "ARCADE_MENU" then
            if arcade_menu_closing_action then return end
            local row = math.floor((_G.arcade_selection - 1) / 2) + 1
            local col = ((_G.arcade_selection - 1) % 2) + 1
            local old_sel = _G.arcade_selection
            if event == input.events.UP then
                row = math.max(1, row - 1)
            elseif event == input.events.DOWN then
                row = math.min(2, row + 1)
            elseif event == input.events.LEFT then
                col = math.max(1, col - 1)
            elseif event == input.events.RIGHT then
                col = math.min(2, col + 1)
            elseif event == input.events.CONFIRM then
                sound.playMenuSelect()
                queueTransitionAction(event, 0.08, function()
                    _G.appState = "GAME"
                    local mode = "timeattack"
                    if _G.arcade_selection == 2 then
                        mode = "huge"
                    elseif _G.arcade_selection == 3 then
                        mode = "nomercy"
                    elseif _G.arcade_selection == 4 then
                        mode = "goose"
                    end
                    game = Game.new(mode)
                end)
            elseif event == input.events.BACK then
                sound.playMenuBack()
                queueTransitionAction(event, 0.08, function()
                    _G.appState = "PLAY_SELECT"
                    _G.arcade_selection = 1
                end)
            end
            _G.arcade_selection = (row - 1) * 2 + col
            if _G.arcade_selection ~= old_sel then
                sound.playMenuMove()
            end
            return
        elseif _G.appState == "TUTORIAL" then
            local cur_page = _G.tutorial_page or 1
            if event == input.events.BACK then
                sound.playMenuBack()
                queueTransitionAction(event, 0.08, function()
                    _G.appState = "MENU"
                end)
            elseif event == input.events.RIGHT then
                local max_p = renderer.getTutorialPageCount and renderer.getTutorialPageCount() or 11
                if cur_page < max_p then
                    sound.playMenuMove()
                    if _G.screen_transitions then
                        renderer.captureOldTutorialSlide(cur_page)
                        _G.tutorial_slide_dir = 1
                        _G.tutorial_slide_timer = 0.20
                        _G.tutorial_slide_ready = false
                    end
                    _G.tutorial_page = cur_page + 1
                end
            elseif event == input.events.LEFT then
                if cur_page > 1 then
                    sound.playMenuMove()
                    if _G.screen_transitions then
                        renderer.captureOldTutorialSlide(cur_page)
                        _G.tutorial_slide_dir = -1
                        _G.tutorial_slide_timer = 0.20
                        _G.tutorial_slide_ready = false
                    end
                    _G.tutorial_page = cur_page - 1
                end
            end
            return
        elseif _G.appState == "ABOUT" then
            local max_scroll = _G.about_max_scroll or 0
            local step = math.floor(35 * (_G.scale or 1))
            if event == input.events.UP then
                if (_G.about_scroll_target or 0) > 0 then
                    _G.about_scroll_target = math.max(0, (_G.about_scroll_target or 0) - step)
                    sound.playMenuMove()
                end
            elseif event == input.events.DOWN then
                if (_G.about_scroll_target or 0) < max_scroll then
                    _G.about_scroll_target = math.min(max_scroll, (_G.about_scroll_target or 0) + step)
                    sound.playMenuMove()
                end
            elseif event == input.events.BACK or event == input.events.CONFIRM then
                if event == input.events.BACK then
                    sound.playMenuBack()
                else
                    sound.playMenuSelect()
                end
                queueTransitionAction(event, 0.08, function()
                    _G.appState = "MENU"
                end)
            end
            return
        elseif _G.appState == "ACHIEVEMENTS" then
            if event == input.events.BACK then
                sound.playMenuBack()
                queueTransitionAction(event, 0.08, function()
                    _G.appState = "MENU"
                    _G.achievements_scroll = 0
                    _G.achievements_scroll_target = 0
                end)
            elseif event == input.events.LEFT or event == input.events.L1 then
                if _G.achievements_tab == 2 then
                    sound.playMenuMove()
                    queueTransitionAction(event, 0.08, function()
                        if _G.screen_transitions then
                            renderer.captureOldAchievementsSlide(2)
                            _G.achievements_slide_dir = -1
                            _G.achievements_slide_timer = 0.20
                            _G.achievements_slide_ready = false
                        end
                        _G.achievements_tab = 1
                    end)
                end
            elseif event == input.events.RIGHT or event == input.events.R1 then
                if _G.achievements_tab == 1 then
                    sound.playMenuMove()
                    queueTransitionAction(event, 0.08, function()
                        if _G.screen_transitions then
                            renderer.captureOldAchievementsSlide(1)
                            _G.achievements_slide_dir = 1
                            _G.achievements_slide_timer = 0.20
                            _G.achievements_slide_ready = false
                        end
                        _G.achievements_tab = 2
                    end)
                end
            elseif event == input.events.UP and _G.achievements_tab == 1 then
                local old_target = _G.achievements_scroll_target or 0
                _G.achievements_scroll_target = math.max(0, old_target - 1)
                if _G.achievements_scroll_target ~= old_target then
                    sound.playMenuMove()
                end
            elseif event == input.events.DOWN and _G.achievements_tab == 1 then
                -- 31 achievements total, allow scrolling only if items overflow visible area
                local w, h = love.graphics.getDimensions()

                local scale = _G.scale
                local item_h = math.floor(85 * scale)
                local header_h = math.floor(115 * scale)
                local footer_h = math.floor(55 * scale)
                local visible_area = h - header_h - footer_h
                local total_items = (renderer.getAchievementsCount and renderer.getAchievementsCount()) or 22
                local total_height = total_items * item_h
                local max_scroll = math.max(0, math.ceil((total_height - visible_area) / item_h))
                local old_target = _G.achievements_scroll_target or 0
                _G.achievements_scroll_target = math.min(max_scroll, old_target + 1)
                if _G.achievements_scroll_target ~= old_target then
                    sound.playMenuMove()
                end
            end
            return
        elseif _G.appState == "CHEATS_MENU" then
            local max_sel = 7
            if event == input.events.BACK then
                sound.playMenuBack()
                queueTransitionAction(event, 0.08, function()
                    _G.appState = "MENU"
                end)
            elseif event == input.events.UP then
                _G.cheats_selection = _G.cheats_selection > 1 and (_G.cheats_selection - 1) or max_sel
                sound.playMenuMove()
            elseif event == input.events.DOWN then
                _G.cheats_selection = _G.cheats_selection < max_sel and (_G.cheats_selection + 1) or 1
                sound.playMenuMove()
            elseif event == input.events.CONFIRM then
                sound.playMenuSelect()
                if _G.cheats_selection == 1 then
                    _G.cheat_unlock_all_themes = not _G.cheat_unlock_all_themes
                    _G.rebuildUnlockedThemes()
                    if _G.cheat_unlock_all_themes then
                        renderer.showToast("All Themes Unlocked!")
                    else
                        renderer.showToast("All Themes Cheat: OFF")
                    end
                    _G.saveCheatSettings()
                elseif _G.cheats_selection == 2 then
                    _G.cheat_max_powerups = not _G.cheat_max_powerups
                    _G.saveCheatSettings()
                    renderer.showToast("Max Powerups: " .. (_G.cheat_max_powerups and "ON" or "OFF"))
                elseif _G.cheats_selection == 3 then
                    local both_on = _G.cheat_start_1024_classic and _G.cheat_start_1024_plus
                    _G.cheat_start_1024_classic = not both_on
                    _G.cheat_start_1024_plus = not both_on
                    _G.saveCheatSettings()
                    if not both_on then
                        renderer.showToast("Start with 1024 (All Modes) is ON. Start a new game to apply.")
                    else
                        renderer.showToast("Start with 1024 (All Modes) is OFF.")
                    end
                elseif _G.cheats_selection == 4 then
                    _G.stats = _G.stats or {}
                    _G.stats.coins = (_G.stats.coins or 0) + 9999
                    save.saveStats(_G.stats)
                    renderer.showToast("Added 9999 Coins! Total: " .. _G.stats.coins)
                    if _G.stats.coins >= 10000 and _G.unlockAchievement then
                        _G.unlockAchievement("ach_coin_hoarder")
                    end
                elseif _G.cheats_selection == 5 then
                    if _G.cheat_debug_layout == "None" or _G.cheat_debug_layout == nil then
                        _G.cheat_debug_layout = "Two 1024s"
                    elseif _G.cheat_debug_layout == "Two 1024s" then
                        _G.cheat_debug_layout = "Fill Board"
                    else
                        _G.cheat_debug_layout = "None"
                    end
                    _G.saveCheatSettings()
                    renderer.showToast("Debug Layout: " .. _G.cheat_debug_layout .. ". Start new game to apply.")
                elseif _G.cheats_selection == 6 then
                    queueTransitionAction(event, 0.08, function()
                        _G.cheats_unlocked = false
                        save.saveCheats(false)
                        _G.appState = "MENU"
                        renderer.showToast("Secret Menu Locked. Enter the code to unlock again.", 4.0)
                    end)
                elseif _G.cheats_selection == 7 then
                    queueTransitionAction(event, 0.08, function()
                        _G.appState = "MENU"
                    end)
                end
            end
            return
        elseif _G.appState == "THEME_SELECT" then
            if event == input.events.CONFIRM then
                sound.playMenuSelect()
                queueTransitionAction(event, 0.08, function()
                    save.saveTheme(_G.theme)
                    if game then game:saveGameState() end
                    _G.appState = _G.themeSelectPrevState or "MENU"
                end)
            elseif event == input.events.BACK then
                sound.playMenuSelect()
                queueTransitionAction(event, 0.08, function()
                    _G.theme = _G.themeSelectInitialTheme or "light"
                    renderer.applyTheme()
                    _G.appState = _G.themeSelectPrevState or "MENU"
                end)
            end
            return
        elseif _G.appState == "SETTINGS" then
            local options = renderer.getSettingsOptions()
            local max_sel = #options
            if event == input.events.UP then
                _G.settings_selection = (_G.settings_selection or 1) > 1 and (_G.settings_selection - 1) or max_sel
                sound.playMenuMove()
            elseif event == input.events.DOWN then
                _G.settings_selection = (_G.settings_selection or 1) < max_sel and (_G.settings_selection + 1) or 1
                sound.playMenuMove()
            elseif event == input.events.CONFIRM then
                local sel = options[_G.settings_selection or 1]
                if _G.settings_page == "audio" then
                    if sel:match("^Sound Effects") then
                        sound.playMenuSelect()
                        sound.toggle()
                    elseif sel:match("^Music") then
                        sound.playMenuSelect()
                        sound.toggleBgm()
                    elseif sel:match("^Vibration") then
                        _G.vibration = not _G.vibration
                        save.saveVibration(_G.vibration)
                        sound.playMenuSelect()
                        sound.vibrate(0.1)
                    elseif sel == "Back" then
                        sound.playMenuBack()
                        if _G.screen_transitions then
                            local w, h = love.graphics.getDimensions()
                            if not old_screen_canvas then
                                old_screen_canvas = love.graphics.newCanvas(w, h)
                            end
                            love.graphics.setCanvas({old_screen_canvas, stencil = true})
                            love.graphics.clear()
                            drawCurrentScreen()
                            love.graphics.setCanvas()
                            _G.screen_canvas_ready = false
                        end
                        queueTransitionAction(event, 0.08, function()
                            _G.settings_page = "main"
                            _G.settings_selection = 1
                            renderer.resetMenuAnimation()
                            if _G.screen_transitions then
                                transition_direction = -1
                                screen_transition_timer = screen_transition_duration
                            end
                        end)
                    end
                else
                    if sel == "Audio & Haptics" then
                        sound.playMenuSelect()
                        if _G.screen_transitions then
                            local w, h = love.graphics.getDimensions()
                            if not old_screen_canvas then
                                old_screen_canvas = love.graphics.newCanvas(w, h)
                            end
                            love.graphics.setCanvas({old_screen_canvas, stencil = true})
                            love.graphics.clear()
                            drawCurrentScreen()
                            love.graphics.setCanvas()
                            _G.screen_canvas_ready = false
                        end
                        queueTransitionAction(event, 0.08, function()
                            _G.settings_page = "audio"
                            _G.settings_selection = 1
                            renderer.resetMenuAnimation()
                            if _G.screen_transitions then
                                transition_direction = 1
                                screen_transition_timer = screen_transition_duration
                            end
                        end)
                    elseif sel:match("^Text Size") then
                        sound.playMenuSelect()
                        _G.text_size = (_G.text_size == "large") and "normal" or "large"
                        save.saveTextSize(_G.text_size)
                        renderer.init()
                        renderer.flashTextSize()
                    elseif sel:match("Animation Speed") then
                        sound.playMenuSelect()
                        if _G.animation_speed == "normal" then
                            _G.animation_speed = "fast"
                        elseif _G.animation_speed == "fast" then
                            _G.animation_speed = "instant"
                        elseif _G.animation_speed == "instant" then
                            _G.animation_speed = "slow"
                        else
                            _G.animation_speed = "normal"
                        end
                        save.saveAnimationSpeed(_G.animation_speed)
                    elseif sel:match("^Transitions") then
                        sound.playMenuSelect()
                        _G.screen_transitions = not _G.screen_transitions
                        save.saveScreenTransitions(_G.screen_transitions)
                    elseif sel:match("^Undo Limit") then
                        sound.playMenuSelect()
                        if _G.undo_mode == "classic" then
                            _G.undo_mode = "unlimited"
                        elseif _G.undo_mode == "unlimited" then
                            _G.undo_mode = "disabled"
                        else
                            _G.undo_mode = "classic"
                        end
                        save.saveUndoMode(_G.undo_mode)
                    elseif sel:match("^Time Attack") then
                        sound.playMenuSelect()
                        if _G.time_attack_time == 30 then
                            _G.time_attack_time = 60
                        elseif _G.time_attack_time == 60 then
                            _G.time_attack_time = 90
                        else
                            _G.time_attack_time = 30
                        end
                        save.saveTimeAttackTime(_G.time_attack_time)
                    elseif sel:match("^CRT Shader") then
                        _G.crt_filter = not _G.crt_filter
                        save.saveCrtFilter(_G.crt_filter)
                        sound.playMenuSelect()
                    elseif sel:match("^Merge Visual FX") then
                        sound.playMenuSelect()
                        local bounce_unlocked = _G.stats and _G.stats.purchased_items and _G.stats.purchased_items["anim_bounce"]
                        local glow_unlocked = _G.stats and _G.stats.purchased_items and _G.stats.purchased_items["anim_glow"]
                        if not bounce_unlocked and not glow_unlocked then
                            renderer.showToast("Unlock Bounce Pop or Glow Pulse in Store first!")
                        else
                            local options_list = {"default"}
                            if bounce_unlocked then table.insert(options_list, "bounce") end
                            if glow_unlocked then table.insert(options_list, "glow") end
                            local curr_idx = 1
                            for i, opt in ipairs(options_list) do
                                if opt == _G.merge_fx then curr_idx = i break end
                            end
                            local next_idx = (curr_idx % #options_list) + 1
                            _G.merge_fx = options_list[next_idx]
                            save.saveMergeFX(_G.merge_fx)
                        end
                    elseif sel == "Back" then
                        sound.playMenuBack()
                        queueTransitionAction(event, 0.08, function()
                            _G.appState = "MENU"
                        end)
                    end
                end
            elseif event == input.events.BACK then
                sound.playMenuBack()
                if _G.settings_page == "audio" then
                    if _G.screen_transitions then
                        local w, h = love.graphics.getDimensions()
                        if not old_screen_canvas then
                            old_screen_canvas = love.graphics.newCanvas(w, h)
                        end
                        love.graphics.setCanvas({old_screen_canvas, stencil = true})
                        love.graphics.clear()
                        drawCurrentScreen()
                        love.graphics.setCanvas()
                        _G.screen_canvas_ready = false
                    end
                    queueTransitionAction(event, 0.08, function()
                        _G.settings_page = "main"
                        _G.settings_selection = 1
                        renderer.resetMenuAnimation()
                        if _G.screen_transitions then
                            transition_direction = -1
                            screen_transition_timer = screen_transition_duration
                        end
                    end)
                else
                    queueTransitionAction(event, 0.08, function()
                        _G.appState = "MENU"
                    end)
                end
            end
            return
        end

        -- GAME inputs below
        if game.state == Game.STATE_TARGETING_BOMB or game.state == Game.STATE_TARGETING_SWAP_1 or game.state == Game.STATE_TARGETING_SWAP_2 then
            if event == input.events.UP then
                game:moveCursor(0, -1)
            elseif event == input.events.DOWN then
                game:moveCursor(0, 1)
            elseif event == input.events.LEFT then
                game:moveCursor(-1, 0)
            elseif event == input.events.RIGHT then
                game:moveCursor(1, 0)
            elseif event == input.events.CONFIRM then
                game:confirmTarget()
            elseif event == input.events.BACK then
                game:cancelTargeting()
            end
        elseif game.state == Game.STATE_TARGETING_SHIELD then
            if event == input.events.UP then
                game:moveShieldSelection("up")
            elseif event == input.events.DOWN then
                game:moveShieldSelection("down")
            elseif event == input.events.LEFT then
                game:moveShieldSelection("left")
            elseif event == input.events.RIGHT then
                game:moveShieldSelection("right")
            elseif event == input.events.CONFIRM then
                game:confirmShieldTarget()
            elseif event == input.events.BACK then
                game:cancelShieldTargeting()
            end
        elseif game:isPlaying() then
            -- Directional moves
            if event == input.events.UP then
                game:move(Game.DIR_UP)
            elseif event == input.events.RIGHT then
                game:move(Game.DIR_RIGHT)
            elseif event == input.events.DOWN then
                game:move(Game.DIR_DOWN)
            elseif event == input.events.LEFT then
                game:move(Game.DIR_LEFT)
            -- Powerups
            elseif event == input.events.L1 then
                if game.mode == "plus" and game.powerups.swap <= 0 then
                    renderer.showToast("No Swap Powerup!")
                else
                    queueTransitionAction(event, 0.08, function()
                        game:startSwapTargeting()
                    end)
                end
            elseif event == input.events.R1 or event == input.events.X then
                if game.mode == "plus" and game.powerups.bomb <= 0 then
                    renderer.showToast("No Bomb Powerup!")
                else
                    queueTransitionAction(event, 0.08, function()
                        game:startBombTargeting()
                    end)
                end
            elseif event == input.events.Y then
                sound.playMenuSelect()
                local un_themes = _G.unlocked_themes or {"light", "dark"}
                if #un_themes > 1 then
                    local cur_idx = 1
                    for i, t in ipairs(un_themes) do
                        if t == _G.theme then cur_idx = i; break end
                    end
                    local next_idx = (cur_idx % #un_themes) + 1
                    local next_theme = un_themes[next_idx]
                    renderer.startThemeTransition(function()
                        _G.theme = next_theme
                        if renderer.applyTheme then renderer.applyTheme() end
                        if save and save.saveTheme then save.saveTheme(_G.theme) end
                        return function() if game then renderer.draw(game) end end
                    end)
                end
            -- Undo
            elseif event == input.events.BACK then
                if game.mode == "timeattack" or game.mode == "nomercy" or game.mode == "goose" then
                    local modeName = "Time Attack"
                    if game.mode == "nomercy" then modeName = "No Mercy"
                    elseif game.mode == "goose" then modeName = "Goose Mode" end
                    renderer.showToast("No Undo in " .. modeName .. "!")
                elseif game.mode == "plus" and game.powerups.undo <= 0 then
                    renderer.showToast("No Undo Powerup!")
                else
                    queueTransitionAction(event, 0.08, function()
                        game:undo()
                    end)
                end
            -- Pause menu (START button)
            elseif event == input.events.START then
                queueTransitionAction(event, 0.08, function()
                    game:togglePause()
                end)
            -- Trigger footer coin notification (SELECT button)
            elseif event == input.events.SELECT then
                if renderer and renderer.triggerCoinFooterToast then
                    renderer.triggerCoinFooterToast()
                end
            end
        elseif game.state == Game.STATE_PAUSED then
            if event == input.events.START or event == input.events.BACK or event == input.events.SELECT then
                queueTransitionAction(event, 0.08, function()
                    game:cancelPause()
                end)
            elseif event == input.events.CONFIRM then
                queueTransitionAction(event, 0.08, function()
                    game:restart()
                end)
            elseif event == input.events.L1 or event == input.events.R1 then
                if sound.isBgmEnabled() then
                    sound.playNextBgm()
                end
            elseif event == input.events.X then
                queueTransitionAction(event, 0.08, function()
                    local is_arcade = game and (game.mode == "timeattack" or game.mode == "huge" or game.mode == "nomercy" or game.mode == "goose")
                    local arcade_idx = 1
                    if game then
                        if game.mode == "huge" then arcade_idx = 2
                        elseif game.mode == "nomercy" then arcade_idx = 3
                        elseif game.mode == "goose" then arcade_idx = 4 end
                        game:saveGameState()
                    end
                    if is_arcade then
                        _G.appState = "ARCADE_MENU"
                        _G.arcade_selection = arcade_idx
                        renderer.setArcadeMenuOpen(true)
                    else
                        _G.appState = "PLAY_SELECT"
                        _G.play_select_selection = (game and game.mode == "plus") and 2 or 1
                        _G.arcade_selection = 1
                        renderer.setArcadeMenuOpen(true)
                    end
                    game = nil
                end)
            end
        elseif game.state == Game.STATE_WON then
            if event == input.events.CONFIRM then
                queueTransitionAction(event, 0.08, function()
                    game:continueGame()
                end)
            elseif event == input.events.BACK then
                if game.mode == "timeattack" or game.mode == "nomercy" or game.mode == "goose" then
                    local modeName = "Time Attack"
                    if game.mode == "nomercy" then modeName = "No Mercy"
                    elseif game.mode == "goose" then modeName = "Goose Mode" end
                    renderer.showToast("No Undo in " .. modeName .. "!")
                else
                    queueTransitionAction(event, 0.08, function()
                        game:undo()
                    end)
                end
            elseif event == input.events.SELECT then
                queueTransitionAction(event, 0.08, function()
                    game:restart()
                end)
            elseif event == input.events.X then
                queueTransitionAction(event, 0.08, function()
                    local is_arcade = game and (game.mode == "timeattack" or game.mode == "huge" or game.mode == "nomercy" or game.mode == "goose")
                    local arcade_idx = 1
                    if game then
                        if game.mode == "huge" then arcade_idx = 2
                        elseif game.mode == "nomercy" then arcade_idx = 3
                        elseif game.mode == "goose" then arcade_idx = 4 end
                        game:saveGameState()
                    end
                    if is_arcade then
                        _G.appState = "ARCADE_MENU"
                        _G.arcade_selection = arcade_idx
                        renderer.setArcadeMenuOpen(true)
                    else
                        _G.appState = "PLAY_SELECT"
                        _G.play_select_selection = (game and game.mode == "plus") and 2 or 1
                        _G.arcade_selection = 1
                        renderer.setArcadeMenuOpen(true)
                    end
                    game = nil
                end)
            end
        elseif game.state == Game.STATE_LOST then
            if event == input.events.CONFIRM or event == input.events.SELECT then
                queueTransitionAction(event, 0.08, function()
                    game:restart()
                end)
            elseif event == input.events.BACK then
                if game.mode == "timeattack" or game.mode == "nomercy" or game.mode == "goose" then
                    local modeName = "Time Attack"
                    if game.mode == "nomercy" then modeName = "No Mercy"
                    elseif game.mode == "goose" then modeName = "Goose Mode" end
                    renderer.showToast("No Undo in " .. modeName .. "!")
                else
                    queueTransitionAction(event, 0.08, function()
                        game:undo()
                    end)
                end
            elseif event == input.events.Y then
                sound.playMenuSelect()
                local un_themes = _G.unlocked_themes or {"light", "dark"}
                if #un_themes > 1 then
                    local cur_idx = 1
                    for i, t in ipairs(un_themes) do
                        if t == _G.theme then cur_idx = i; break end
                    end
                    local next_idx = (cur_idx % #un_themes) + 1
                    local next_theme = un_themes[next_idx]
                    renderer.startThemeTransition(function()
                        _G.theme = next_theme
                        if renderer.applyTheme then renderer.applyTheme() end
                        if save and save.saveTheme then save.saveTheme(_G.theme) end
                        return function() if game then renderer.draw(game) end end
                    end)
                end
            elseif event == input.events.R1 or event == input.events.L1 then
                if game and (game.timesUp or (game.mode == "timeattack" and game.timeLeft and game.timeLeft <= 0)) then
                    renderer.showToast("Cannot use Shield when time is up!")
                else
                    local shield_cnt = _G.stats and (_G.stats.second_chance_count or 0) or 0
                    if shield_cnt > 0 then
                        queueTransitionAction(event, 0.08, function()
                            game:startShieldTargeting()
                        end)
                    else
                        renderer.showToast("No Second Chance Shield! Buy in Store.")
                    end
                end
            elseif event == input.events.X then
                queueTransitionAction(event, 0.08, function()
                    local is_arcade = game and (game.mode == "timeattack" or game.mode == "huge" or game.mode == "nomercy" or game.mode == "goose")
                    local arcade_idx = 1
                    if game then
                        if game.mode == "huge" then arcade_idx = 2
                        elseif game.mode == "nomercy" then arcade_idx = 3
                        elseif game.mode == "goose" then arcade_idx = 4 end
                        game:saveGameState()
                    end
                    if is_arcade then
                        _G.appState = "ARCADE_MENU"
                        _G.arcade_selection = arcade_idx
                        renderer.setArcadeMenuOpen(true)
                    else
                        _G.appState = "PLAY_SELECT"
                        _G.play_select_selection = (game and game.mode == "plus") and 2 or 1
                        _G.arcade_selection = 1
                        renderer.setArcadeMenuOpen(true)
                    end
                    game = nil
                end)
            end
        end
    end)

    if love.system.getOS() == "Web" then
        local current_state_str = "WEB_STATE:" .. tostring(_G.appState)
        if _G.appState == "GAME" and game then
            current_state_str = current_state_str .. ":" .. tostring(game.state) .. ":" .. tostring(game.mode)
            if game.mode == "plus" and game.powerups then
                current_state_str = current_state_str .. ":" .. tostring(game.powerups.undo) .. ":" .. tostring(game.powerups.swap) .. ":" .. tostring(game.powerups.bomb)
            end
        end
        if current_state_str ~= _G.last_web_state_str then
            _G.last_web_state_str = current_state_str
            print(current_state_str)
        end
    end
end

drawCurrentScreen = function()
    if _G.appState == "MENU" then
        renderer.drawMainMenu(menuSelection)
    elseif _G.appState == "PLAY_SELECT" then
        renderer.drawPlaySelectMenu(_G.play_select_selection or 1, _G.arcade_selection or 1, false, menuSelection)
    elseif _G.appState == "ARCADE_MENU" then
        renderer.drawPlaySelectMenu(_G.play_select_selection or 1, _G.arcade_selection or 1, false, menuSelection)
    elseif _G.appState == "TUTORIAL" then
        renderer.drawTutorial(_G.tutorial_page or 1)
    elseif _G.appState == "ABOUT" then
        renderer.drawAbout()
    elseif _G.appState == "CHEATS_MENU" then
        renderer.drawSecretMenu(_G.cheats_selection or 1)
    elseif _G.appState == "ACHIEVEMENTS" then
        renderer.drawAchievements(_G.achievements_scroll or 0)
    elseif _G.appState == "THEME_SELECT" then
        renderer.drawThemeSelect()
    elseif _G.appState == "SETTINGS" then
        renderer.drawSettings(_G.settings_selection or 1)
    elseif _G.appState == "STORE" then
        renderer.drawStoreMenu(_G.store_selection or 1)
    elseif _G.appState == "JUKEBOX" then
        renderer.drawJukebox(_G.jukebox_selection or 1)
    elseif _G.appState == "GAME" and game then
        renderer.draw(game)
    end
end

local crt_shader_code = [[
    extern vec2 screen_size;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        // 1. CRT Curved Glass Barrel Distortion with Auto-Fill (Zero Blank Space Outlines!)
        vec2 cc = texture_coords - 0.5;
        float dist = dot(cc, cc);
        
        // Curved screen profile scaled so UV coordinates stay strictly within [0, 1]
        // This eliminates all black blank corner cutouts while preserving retro glass curvature!
        vec2 distorted_coords = cc * (1.0 + dist * 0.05) * 0.965 + 0.5;
        distorted_coords = clamp(distorted_coords, 0.0, 1.0);

        // 2. Chromatic Aberration (Trinitron RGB glass separation near edges)
        float ca = 0.0012 * (1.0 + dist * 1.5);
        float r = Texel(texture, distorted_coords - vec2(ca, 0.0)).r;
        float g = Texel(texture, distorted_coords).g;
        float b = Texel(texture, distorted_coords + vec2(ca, 0.0)).b;
        vec4 tex_color = vec4(r, g, b, 1.0);

        // 3. Scanlines (subtle TV line raster effect)
        float scanline = sin(distorted_coords.y * screen_size.y * 1.2) * 0.045 + 0.955;

        // 4. Phosphor Mask (subtle RGB triad grille effect)
        float mask = sin(distorted_coords.x * screen_size.x * 1.5) * 0.025 + 0.975;

        // 5. Smooth CRT Glass Corner Vignette (replaces ugly black cutouts with soft vintage screen falloff)
        float vig = smoothstep(0.70, 0.30, length(cc));
        float vignette = 0.90 + 0.10 * vig;

        return tex_color * vec4(vec3(scanline * mask * vignette), 1.0) * color;
    }
]]

local crt_shader = nil
local crt_main_canvas = nil

function love.draw()
    local w, h = love.graphics.getDimensions()
    local old_setCanvas = love.graphics.setCanvas

    local apply_crt = _G.crt_filter
    if apply_crt then
        if not crt_shader then
            local success, err = pcall(function()
                crt_shader = love.graphics.newShader(crt_shader_code)
            end)
            if not success then
                print("Failed to compile CRT shader: " .. tostring(err))
                _G.crt_filter = false
                apply_crt = false
            end
        end
    end

    if apply_crt and crt_shader then
        if not crt_main_canvas or crt_main_canvas:getWidth() ~= w or crt_main_canvas:getHeight() ~= h then
            crt_main_canvas = love.graphics.newCanvas(w, h)
        end
        crt_shader:send("screen_size", {w, h})

        love.graphics.setCanvas = function(canvas, ...)
            if canvas == nil or canvas == crt_main_canvas then
                old_setCanvas({crt_main_canvas, stencil = true})
            else
                old_setCanvas(canvas, ...)
            end
        end
        love.graphics.setCanvas(crt_main_canvas)
        love.graphics.clear()
    end

    local function draw_internal()
        if not splash.finished then
            splash.draw()
            return
        end

        if screen_transition_timer > 0 then
            -- Cubic ease-out progress (0 → 1) - starts fast, slows down smoothly
            local t_progress = 1 - (screen_transition_timer / screen_transition_duration)
            local p = 1 - math.pow(1 - t_progress, 3)

            if not screen_canvas then
                screen_canvas = love.graphics.newCanvas(w, h)
            end

            -- Only render the new screen to the canvas ONCE at the start of the transition
            if not _G.screen_canvas_ready then
                love.graphics.setCanvas({screen_canvas, stencil = true})
                love.graphics.clear()
                drawCurrentScreen()
                love.graphics.setCanvas()
                _G.screen_canvas_ready = true
            end

            -- Draw background fill to avoid any gaps
            love.graphics.clear(0.05, 0.05, 0.08, 1.0)

            local dir = transition_direction or 1
            local shadow_w = math.floor(20 * (_G.scale or 1))

            if dir == 1 then
                -- Forward transition: New screen slides in on top from right (w -> 0)
                -- Old screen slides out underneath to the left at 30% speed (0 -> -0.3*w)
                local old_x = math.floor(-0.3 * w * p)
                local new_x = math.floor(w * (1 - p))

                -- 1. Draw old screen (underneath)
                if old_screen_canvas then
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.setBlendMode("replace", "premultiplied")
                    love.graphics.draw(old_screen_canvas, old_x, 0)
                    love.graphics.setBlendMode("alpha", "alphamultiply")

                    -- Dim the old screen (dimming fades in from 0% to 50% opacity)
                    love.graphics.setColor(0, 0, 0, 0.5 * p)
                    love.graphics.rectangle("fill", old_x, 0, w, h)
                end

                -- 2. Draw shadow to the left of the new screen
                for i = 0, shadow_w - 1 do
                    local alpha = 0.35 * math.pow((shadow_w - i) / shadow_w, 2)
                    love.graphics.setColor(0, 0, 0, alpha)
                    love.graphics.rectangle("fill", new_x - shadow_w + i, 0, 1, h)
                end

                -- 3. Draw new screen (on top)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(screen_canvas, new_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")
            else
                -- Backward transition: Old screen slides out on top to the right (0 -> w)
                -- New screen slides in underneath from the left at 30% speed (-0.3*w -> 0)
                local new_x = math.floor(-0.3 * w * (1 - p))
                local old_x = math.floor(w * p)

                -- 1. Draw new screen (underneath)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(screen_canvas, new_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")

                -- Dim the new screen (dimming fades out from 50% to 0% opacity)
                love.graphics.setColor(0, 0, 0, 0.5 * (1 - p))
                love.graphics.rectangle("fill", new_x, 0, w, h)

                if old_screen_canvas then
                    -- 2. Draw shadow to the left of the old screen (sliding on top)
                    for i = 0, shadow_w - 1 do
                        local alpha = 0.35 * math.pow((shadow_w - i) / shadow_w, 2)
                        love.graphics.setColor(0, 0, 0, alpha)
                        love.graphics.rectangle("fill", old_x - shadow_w + i, 0, 1, h)
                    end

                    -- 3. Draw old screen (on top)
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.setBlendMode("replace", "premultiplied")
                    love.graphics.draw(old_screen_canvas, old_x, 0)
                    love.graphics.setBlendMode("alpha", "alphamultiply")
                end
            end

            love.graphics.setColor(1, 1, 1, 1)
        else
            _G.screen_canvas_ready = false
            drawCurrentScreen()
        end
    end

    local success, err = pcall(draw_internal)
    if not success then
        if apply_crt then
            love.graphics.setCanvas = old_setCanvas
            love.graphics.setCanvas()
        end
        error(err)
    end

    if apply_crt and crt_shader and crt_main_canvas then
        love.graphics.setCanvas = old_setCanvas
        love.graphics.setCanvas()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setShader(crt_shader)
        love.graphics.draw(crt_main_canvas, 0, 0)
        love.graphics.setShader()
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        if _G.appState == "STORE" and _G.store_sort_btn_bounds then
            local b = _G.store_sort_btn_bounds
            if x >= b.x and x <= (b.x + b.w) and y >= b.y and y <= (b.y + b.h) then
                if _G.cycleStoreSortMode then
                    _G.cycleStoreSortMode()
                end
            end
        end
    end
end

function love.quit()
    if game then
        pcall(function() game:saveGameState() end)
    end
    pcall(function() love.audio.stop() end)
    if love.joystick then
        pcall(function()
            local joysticks = love.joystick.getJoysticks()
            for _, j in ipairs(joysticks) do
                if j:isVibrationSupported() then
                    j:setVibration(0, 0)
                end
            end
        end)
    end
    os.exit()
end
