require("./utils");
require("./math");
require("./tile_map")
require("./physics")
require("./transition")
require("./audio")
require("./particles")
require("./saves")
require("./speedrun_timer")
require("./scene_animations/start_animation")
require("./scene_animations/end_animation")

local BASE_RESOLUTION = {
    width = 320,
    height = 180
}

local Object = require("./classic")

GameState = Object.extend(Object)

-- TODO: compute or get from files
function get_level_names()
    local res = {}
    local level_names = love.filesystem.getDirectoryItems("./levels")
    for _, lvl in pairs(level_names) do
        if(string.find(lvl, ".lua")) then
            table.insert(res, lvl)
        end
    end

    return res
end

level_names = get_level_names()
local BASE_LEVEL_X_RES = 320

GameMode = {
    SIMULATING = 0,
    EDITING = 1,
    PAUSE = 2,
    GAME_OVER = 3,
    ANIMATING = 4,
};

local OBTAINED_MEDAL_KEY = {
    ["YELLOW"] = "yellow_medal_obtained",
    ["RED"]    = "red_medal_obtained",
    ["GREEN"]  = "green_medal_obtained",
    ["ORANGE"] = "orange_medal_obtained",
    ["PURPLE"] = "purple_medal_obtained",
    ["BLUE"]   = "blue_medal_obtained"
}

GameState.QUICK_RESTART_WAIT_TIME = 1

function GameState.new(self)
    local save_data = load_game_data()
    Audio.load_data(save_data)
    if not is_mobile_os() then
        if(save_data.is_fullscreen ~= nil) then
            love.window.setFullscreen(save_data.is_fullscreen)
        end
    end

    self.has_finished_the_game = save_data.has_finished_the_game or false
    self.has_watched_start_animation = save_data.has_watched_start_animation or false

    self.map_index = 1

    scale = resolution_scale()

    self.entering_door = nil
    self.respawn_door = nil
    self.level_has_changed_at_transition = false
    self.level_has_reset_at_transition   = false

    self.time = 0
    self.delta_time = 0

    self.death_transition_time = 0
    self.in_death_animation    = false 

    self.lowest_jumps_record = save_data.lowest_jumps_record or 1
    self.door_required_jumps = {}
    self.locked_puzzle_doors_info = {}

    self.jump_counter_broken = false
    self.should_count_jumps = true
    self.already_played_game = false
    self.player_eaten_light_fly = false
    self.eaten_light_fly_time = 0
    self.player_is_wearing_hat = save_data.player_is_wearing_hat

    self.caves_challenge_completed = save_data.caves_challenge_completed or false
    self.temple_challenge_completed = save_data.temple_challenge_completed or false
    self.jungle_challenge_completed = save_data.jungle_challenge_completed or false
    self.puzzle_challenge_completed = save_data.puzzle_challenge_completed or false

    self.prev_game_mode = nil
    if(self.already_played_game) then
        self.game_mode = GameMode.SIMULATING
    else
        self.current_scene_animation = nil
        self.game_mode = GameMode.SIMULATING
        self.animation = nil
    end

    for k, v in pairs(OBTAINED_MEDAL_KEY) do
        self[v] = save_data[v] or false
    end

    --Audio.create_sound("sounds/change_level.ogg", "change_level")
    Audio.create_sound("sounds/portal.mp3", "change_level", "static", 4)
    Audio.create_sound("sounds/change_level.ogg", "old_change_level", "static", 4)

    self.animations_triggered = {
        end_animation_trigger = false,
    }

    self.speedrun_timer = initialize_timer()
    self.best_time_record_in_seconds = save_data.best_time_record_in_seconds or nil 
    self.config_show_speedrun_timer  = if_not_nil_else(save_data.config_show_speedrun_timer, false)
    self.config_vibration_disabled   = if_not_nil_else(save_data.config_vibration_disabled, false)
    self.config_particles_disabled   = if_not_nil_else(save_data.config_particles_disabled, false)
    self.config_screenshake_disabled = if_not_nil_else(save_data.config_screenshake_disabled, false)
    self.config_effects_disabled     = if_not_nil_else(save_data.config_effects_disabled, false)

    local w, h = love.window.getMode()
    self.resolution_width    = if_not_nil_else(save_data.resolution_width, w)
    self.resolution_height   = if_not_nil_else(save_data.resolution_height, h)

    self.show_speedrun_timer = false

    -- Debug flags
    self.show_audio_triggers = false

    self.quick_restart_timer = 0
    self.already_restarted = false
end

function GameState:update_timers(dt)
    self.time = self.time + dt
end

function GameState:update(dt)
    self.door_required_jumps = {}
    self.locked_puzzle_doors_info = {}

    self.delta_time = dt

    self:update_eaten_light_fly_state(dt)

    local w, h = love.window.getMode()
    if w ~= self.resolution_width or h ~= self.resolution_height then
        self.resolution_width  = w
        self.resolution_height = h

        save_game_data(self)
    end

    self:handle_transitions(dt)
    -- scale is a global variable, TODO: explain it better
    -- if resolution changes it should change

    if(dev_mode and input.toggle_jumps_counting.is_pressed) then
        Audio.play_sound("ui_change_value")
        self.should_count_jumps = not self.should_count_jumps
    end

    if(dev_mode and input.toggle_audio_triggers.is_pressed) then
        Audio.play_sound("ui_change_value")
        self.show_audio_triggers = not self.show_audio_triggers
    end

    if(self.game_mode == GameMode.SIMULATING) then
        if(not self.transition) then
            self.player:update(dt)
            check_collisions(self.tile_map, self.player, self)
            self.player:adjust_required_collisions()
            if(self.player.broom) then
                self.player.broom:adjust_required_collisions()
            end
            self.tile_map:update(dt)
        end
        if(input.pause.is_pressed) then
            self.game_mode = GameMode.PAUSE
            self.prev_game_mode = GameMode.SIMULATING
        end
        if(input.restart.is_down) then
            if not self.already_restarted then
                self.quick_restart_timer = self.quick_restart_timer + dt

                if self.quick_restart_timer > self.QUICK_RESTART_WAIT_TIME then
                    self.already_restarted = true
                    self.quick_restart_timer = 0

                    local is_quick_restart = true
                    self:restart_game_state(is_quick_restart)
                end
            end
        else
            self.quick_restart_timer = 0
            self.already_restarted = false
        end

    elseif(self.game_mode == GameMode.PAUSE) then
        UI.handle_pause_input(self)

    elseif(self.game_mode == GameMode.EDITING and love.keyboard.isDown("q")) then
        self.game_mode = GameMode.SIMULATING

    elseif(self.game_mode == GameMode.GAME_OVER) then
        if(input.restart.is_down) then
            self.game_mode = GameMode.SIMULATING
            self:restart_game_state()
        end
        check_collisions(self.tile_map, self.player, self)
        self.tile_map:update(dt)
    elseif(self.game_mode == GameMode.ANIMATING) then
        self.current_scene_animation:update(dt)
        if(input.pause.is_pressed) then
            self.game_mode = GameMode.PAUSE
            self.prev_game_mode = GameMode.ANIMATING
        end
    end

    scale = resolution_scale()
end

function GameState:draw()
    if(self.transition) then
        self.transition:draw()
    end
end

function GameState:player_touched_spikes()
    self:player_died()
end

function GameState:player_died()
    if not self.in_death_animation then
        if(self.respawn_door) then
            self.player:set_die_state()
        end

        self.in_death_animation = true
        self:apply_screenshake()
        self:apply_shockwave()
        self:apply_exploding_particles()
        self:apply_chromatic_aberration()
        self.player:die()
    end
end

function GameState:handle_setup_editing_mode()
    -- reset level for editing
    self.game_mode = GameMode.EDITING
    if(self.tile_map) then
        self.tile_map:handle_unload()
    end
    self.tile_map = load_tile_map(self.map_name)
    resync_accumulator()
end

function GameState:load_map(door)
    if(self.tile_map) then
        self.tile_map:handle_unload()
    end
    self.next_map      = load_tile_map(door.target_level_name)
    resync_accumulator()
    self.next_map_name = door.target_level_name

    if self.player then
        if self.player.broom then
            self.next_map:remove_brog_if_exists()
        end
    end

    self:handle_songs_transition()
    Audio.play_sound("change_level")
    self.transition = Transition()
    if door.visible then
        self.player:set_transition_fade_out(v2_add(door.world_pos, V2(TILE_SIZE/2, TILE_SIZE/2)))
    end
end

function GameState:reset_map()
    if(self.tile_map) then
        self.tile_map:handle_unload()
    end
    self.tile_map      = load_tile_map(self.tile_map.name)
    resync_accumulator()
end

function GameState:change_level_at_transition()
    local should_show_counting_jumps_from_start = {
        "challenge_01_01",
        "challenge_01_05",
        "challenge_01_09",
    }

    if(table_contains(should_show_counting_jumps_from_start, self.next_map_name)) then
        UI.show_jumps_counter()
    end

    self.tile_map      = self.next_map
    self.map_name      = self.next_map_name
    self.next_map      = nil
    self.next_map_name = nil

    local target_door_name = self.entering_door.target_door_name
    local target_lvl = self.entering_door.target_level_name

    local target_door = nil
    for _, d in pairs(self.tile_map.doors) do
        if d.name == target_door_name then
            target_door = d
            break
        end
    end

    if(not target_door) then
        print("Error, target door not found for door name " .. target_door_name)
    end

    if(target_door) then
        -- TODO: move to player
        self:set_respawn_door(target_door)
        self.player:spawn_at_door(target_door, self)
    end

    if self.player then
        if target_door.visible then
            self.player:set_transition_none()--self.player:set_transition_fade_in(v2_add(target_door.world_pos, V2(TILE_SIZE/2, TILE_SIZE/2)))
        else
            self.player:set_transition_none()
        end
    end

    self.level_has_changed_at_transition = true
end

function GameState:reset_level_on_respawn()
    self.level_has_reset_at_transition = true
    self:reset_map()
    if(self.respawn_door) then
        self.player:spawn_at_door(self.respawn_door, self)
    end
end

function GameState:set_respawn_door(door)
    self.respawn_door = door
end

function GameState:set_entering_door(door)
    self.entering_door = door
end

function GameState:apply_shockwave(pos)
    local center_position = pos or self.player:center_position()
    game_state.tile_map:add_effect(EFFECT_TYPE.shockwave, 4, {
        shockwave_origin = {center_position.x, center_position.y}
    } )
end

function GameState:apply_screenshake()
    game_state.tile_map:add_effect(EFFECT_TYPE.screenshake, 0.3)
end

function GameState:apply_chromatic_aberration()
    self.tile_map:add_effect(EFFECT_TYPE.chromatic_aberration, 0.3)
end

function GameState:apply_exploding_particles()
    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 2.0, {
        particle_emitter = ParticleEmitter( {
            pos = self.player.pos,
            particle_type = ParticleType.exploding,
            particle_variant = ParticleVariant.nara
        } ),
    })
end

function GameState:handle_transitions(dt)
    if(self.transition) then
        if(self.transition.type == TransitionType.LEVEL_CHANGE) then
            self.transition:advance_step()
            if(self.transition:fade_out_has_finished() and not self.level_has_changed_at_transition) then
                Render.clear_effects()
                Render.clear_lights()
                self:change_level_at_transition()
            end

            if(self.transition:is_done()) then
                if self.should_start_timer_after_animation then
                    self.should_start_timer_after_animation = false
                    start_timer(self.speedrun_timer)
                end
                self.level_has_changed_at_transition = false
            end
        else
            self.transition:advance_step()
            self.transition:advance_step()
            if(self.transition:fade_out_has_finished() and not self.level_has_reset_at_transition) then
                Render.clear_effects()
                Render.clear_lights()
                self:reset_level_on_respawn()
            end

            if(self.transition:is_done()) then
                self.level_has_reset_at_transition = false
                self.in_death_animation = false
            end
        end

        if(self.transition:is_done()) then
            if(appleCake) then
                appleCake.mark("Finish last transition")
            end
            self.transition = nil
            resync_accumulator()
        end
    end

    if(self.in_death_animation and not self.transition) then
        self.death_transition_time = self.death_transition_time + dt

        local death_transition_total_time = 1.0
        -- apply tranistions and reset map
        if self.death_transition_time > death_transition_total_time then
            self.death_transition_time = 0
            self.transition = Transition(TransitionType.PLAYER_DIED)
        end
    end
end

function GameState:reached_max_jump_count()
    self.game_mode = GameMode.GAME_OVER

    self.player:set_die_state()
    self:apply_screenshake()
    self:apply_shockwave()
    self:apply_exploding_particles()
    self:apply_chromatic_aberration()
    self.player:die()
end

function GameState:reached_map_max_jump_count()
    self:player_died()
end

function GameState:restart_game_state(is_quick_restart)
    Audio.reset_state()
    self.already_restarted = true
    self.jump_counter_broken = false
    self.transition = nil
    if self.player then
        self.player:set_transition_none()
    end
    Audio.remove_underwater_filter()

    UI.reset_ui_state()
    if(self.tile_map) then
        -- TODO: Fade out or some transition
        -- NOTE: If directly fade out, same song cancels
        Audio.stop_song(self.tile_map:song_key())
        Render.clear_effects()
    end

    local should_animate = false
    if(self.has_finished_the_game) then
        if(self.tile_map) then
            self.tile_map:handle_unload()
        end
        if is_quick_restart then
            self.tile_map = load_tile_map("level_01")
            resync_accumulator()
        else
            self.tile_map = load_tile_map("lobby")
            resync_accumulator()
        end
        self.should_count_jumps = false
    else
        if(self.tile_map) then
            self.tile_map:handle_unload()
        end
        self.tile_map = load_tile_map("level_01")
        self.should_count_jumps = true
        should_animate = true
        resync_accumulator()
    end

    if(self.tile_map:song_key()) then
        Audio.fade_in_song(self.tile_map:song_key(), 6)
    end

    self.next_map = nil
    self.next_map_name = nil
    self:reset_eaten_light_fly_state()
    self.animations_triggered = {
        end_animation_trigger = false,
    }
    self:spawn_player()

    if(should_animate and not self.has_watched_start_animation) then
        self.has_watched_start_animation = true
        self.game_mode = GameMode.ANIMATING
        self.current_scene_animation = StartAnimation.Animation(self)

        save_game_data(self)
    else
        if(self.game_mode == GameMode.SIMULATING) then
            start_timer(self.speedrun_timer)
        end
    end
end

function GameState:exit_game()
    if(Steam) then
        Steam.shutdown()
    end
    love.event.quit(0)
end

function GameState:add_door_required_jumps(tile_pos_x, tile_pos_y, current, total)
    table.insert(self.door_required_jumps, {
        tile_pos_x = tile_pos_x,
        tile_pos_y = tile_pos_y,
        current = current,
        total = total
    } )
end

function GameState:spawn_player()
    local target_door = nil
    for _, d in pairs(self.tile_map.doors) do
        if(d.name == "initial") then
            target_door = d
            break
        end
    end

    self.player = Player(V2(TILE_SIZE*4, TILE_SIZE*8))
    if self.player_eaten_light_fly then
        self.player:create_fly_light()
    end
    self.player.is_wearing_hat = self.player_is_wearing_hat
    if(target_door) then
        self:set_respawn_door(target_door)
        self.player:spawn_at_door(target_door, self)
    end
end

function GameState:end_reached()
    if(STEAM_BUILD and not self.has_finished_the_game) then
        unlock_achievement(ACHIEVEMENT_KEYS.END_REACHED)
    end

    -- Save high score if reached
    self.lowest_jumps_record = math.max(self.lowest_jumps_record, 100 - self.player.jumps_counter)

    -- Save high time if reached
    pause_timer(self.speedrun_timer)
    if(self.has_finished_the_game) then
        if not self.best_time_record_in_seconds then
            self.best_time_record_in_seconds = time_difference(self.speedrun_timer)
        else
            self.best_time_record_in_seconds = math.min(self.best_time_record_in_seconds, time_difference(self.speedrun_timer)) 
        end
    else
        self.best_time_record_in_seconds = time_difference(self.speedrun_timer)
    end

    -- Mark end reached flag
    self.has_finished_the_game = true

    save_game_data(self)
end

function GameState:jumps_left_to_show()
    if(self.tile_map.allowed_jumps) then
        return math.max(self.tile_map.allowed_jumps - self.player.jumps_counter, 0)
    else
        return math.max(100 - self.player.jumps_counter, 0)
    end
end

function GameState:handle_songs_transition()
    local prev_song_key = self.tile_map:song_key()
    local next_song_key = self.next_map:song_key()
    if(prev_song_key ~= next_song_key) then
        if(prev_song_key) then
            Audio.fade_out_song(prev_song_key)
        end
        if(next_song_key) then
            Audio.fade_in_song(next_song_key)
        end
    end

end

function GameState:pause_continue_pressed()
    Audio.update_playing_songs_audio()
    game_state.game_mode = self.prev_game_mode
    self.prev_game_mode = nil
end

function GameState:pause_restart_pressed()
    self:fade_out_current_song()
    game_state.game_mode = self.prev_game_mode
    self.prev_game_mode = nil
    game_state:restart_game_state() -- TODO: add confirm modal
    self.current_scene_animation = nil
    UI.clear_speech_dialog()
    Render.clear_cinematic()
    self.game_mode = GameMode.SIMULATING
    self:restart_and_start_timer()
end

function GameState:pause_new_game_pressed()
    Render.clear_cinematic()
    UI.clear_speech_dialog()
    self.current_scene_animation = nil

    self:fade_out_current_song()
    self:delete_save_data()

    game_state.game_mode = self.prev_game_mode
    self.prev_game_mode = nil
    self:restart_game_state()
end

function GameState:start_screen_pressed()
    local current_song_key = self.tile_map:song_key()

    if current_song_key ~= "lobby" then
        Audio.fade_out_song("lobby")
        Audio.fade_in_song(current_song_key)
    end

    self:restart_and_start_timer()
end

function GameState:delete_save_data()
    save_game_data({
        config_show_speedrun_timer = self.config_show_speedrun_timer,
    })

    self.has_finished_the_game = false
    self.has_watched_start_animation = false

    self.lowest_jumps_record = 1

    self.player_is_wearing_hat = false

    for k, v in pairs(OBTAINED_MEDAL_KEY) do
        self[v] = false
    end

    self.caves_challenge_completed = false
    self.temple_challenge_completed = false
    self.jungle_challenge_completed = false
    self.puzzle_challenge_completed = false

    self.best_time_record_in_seconds = nil 
end

function GameState:pause_exit_pressed()
    self:exit_game() -- TODO: add confirm modal
end

function GameState:pause_fullscreen_pressed()
    love.window.setFullscreen(not love.window.getFullscreen())
end

function GameState:toggle_speedrun_timer_pressed()
    self.config_show_speedrun_timer = not self.config_show_speedrun_timer
end

function GameState:is_dark()
    return self.tile_map.is_dark
end

function GameState:trigger_animation_map(id)
    local animation_map = {
        end_animation_trigger = EndAnimation.Animation,
    }

    return animation_map[id]
end

function GameState:trigger_animation(id)
    local is_end_animation = id == "end_animation_trigger"
    local should_ignore = is_end_animation and self.player.broom

    if should_ignore then return end

    local animation_triggered = self.animations_triggered[id]
    if(self.game_mode ~= GameMode.ANIMATING and not animation_triggered) then
        self.animations_triggered[id] = true
        self.game_mode = GameMode.ANIMATING
        self.current_scene_animation = self:trigger_animation_map(id)(self)
    end
end

function GameState:are_all_medals_obtained()
    local all_medals_obtained = true
    for medal_color, medal in pairs(OBTAINED_MEDAL_KEY) do
        local is_obtained = self:is_medal_obtained(medal_color)
        all_medals_obtained = all_medals_obtained and is_obtained
    end

    return all_medals_obtained
end

function GameState:obtain_medal(medal)
    self[OBTAINED_MEDAL_KEY[medal.color_name]] = true
    save_game_data(self)

    if self:are_all_medals_obtained() then
        unlock_achievement(ACHIEVEMENT_KEYS.ALL_MEDALS)
    end
end

function GameState:are_all_trophies_unlocked()
    local all_trophies_unlocked = true
    for _, trophy_unlocked_key in pairs(Trophy.key_to_completed_flag) do
        all_trophies_unlocked = all_trophies_unlocked and game_state[trophy_unlocked_key]
    end

    return all_trophies_unlocked
end

function GameState:obtained_medals_amount()
    local result = 0
    for _, obtained_medal_key in pairs(OBTAINED_MEDAL_KEY) do
        if self[obtained_medal_key] then
            result = result + 1
        end
    end

    return result
end

function GameState:is_medal_obtained(medal_color)
    local medal_key = OBTAINED_MEDAL_KEY[medal_color]

    if medal_key then
        return self[medal_key]
    end
end

function GameState:add_locked_puzzle_door_info(tile_pos_x, tile_pos_y)
    table.insert(self.locked_puzzle_doors_info, {
        tile_pos_x = tile_pos_x,
        tile_pos_y = tile_pos_y,
        obtained_medals = self:obtained_medals_amount(),
        medals_to_unlock = Door.MEDALS_NEEDED_FOR_PUZZLE_DOOR
    } )
end

function GameState:reset_to_lobby()
    UI.hide_jumps_counter()

    if(self.player) then
        self.player:reset_state_to_lobby()
    end

    self:reset_eaten_light_fly_state()
    self.jump_counter_broken = false
    self.should_count_jumps = false

    restart_timer(self.speedrun_timer)
    self.show_speedrun_timer = false
    self.animations_triggered = {
        end_animation_trigger = false,
    }
end

function GameState:start_counting_jumps()
    self.should_count_jumps = true
end

function GameState:starting_first_level()
    if(self.player) then
        game_state.player.jumps_counter = 0
    end
    self:start_counting_jumps()
    if (self.transition) then
        self.should_start_timer_after_animation = true
    end

    restart_timer(self.speedrun_timer)
    self.show_speedrun_timer = true
end

function GameState:restart_and_start_timer()
    if self.game_mode == GameMode.SIMULATING then
        restart_timer(self.speedrun_timer)
        start_timer(self.speedrun_timer)
    end
end

function GameState:finising_start_animation()
    start_timer(self.speedrun_timer)
end

function GameState:computah_broken_stage()
    local computah = self.tile_map.computahs[1]

    if computah then
        return computah.broken_stage
    else
        return 0
    end
end

function GameState:check_for_challenge_level_completion()
    if not self.tile_map then return end

    local CAVES_CHALLENGE_FINAL_LEVEL_NAME = "challenge_01_04"
    local TEMPLE_CHALLENGE_FINAL_LEVEL_NAME = "challenge_01_08"
    local JUNGLE_CHALLENGE_FINAL_LEVEL_NAME = "challenge_01_12"
    local PUZZLE_CHALLENGE_FINAL_LEVEL_NAME = "puzzle_final"

    if self.tile_map.name == CAVES_CHALLENGE_FINAL_LEVEL_NAME then
        self.caves_challenge_completed = true
        save_game_data(self)

    elseif self.tile_map.name == TEMPLE_CHALLENGE_FINAL_LEVEL_NAME then
        self.temple_challenge_completed = true
        save_game_data(self)

    elseif self.tile_map.name == JUNGLE_CHALLENGE_FINAL_LEVEL_NAME then
        self.jungle_challenge_completed = true
        save_game_data(self)

    elseif self.tile_map.name == PUZZLE_CHALLENGE_FINAL_LEVEL_NAME then
        self.puzzle_challenge_completed = true
        save_game_data(self)
    end

    if self:are_all_trophies_unlocked() then
        unlock_achievement(ACHIEVEMENT_KEYS.LOBBY_COMPLETE)
    end
end

function GameState:fade_out_current_song()
    local current_song_key = self.tile_map:song_key()

    if current_song_key then
        Audio.fade_out_song(current_song_key)
    end
end

function GameState:reset_eaten_light_fly_state()
    self.player_eaten_light_fly = false
    self.eaten_light_fly_time = 0
end

GameState.EATEN_LIGHT_FLY_TRANSITION_TIME = 1.5
function GameState:update_eaten_light_fly_state(dt)
    if self.player_eaten_light_fly then
        local transition_dt = dt / GameState.EATEN_LIGHT_FLY_TRANSITION_TIME
        self.eaten_light_fly_time = math.min(self.eaten_light_fly_time + transition_dt, 1)
    end
end

function GameState:toggle_vibration_pressed()
    self.config_vibration_disabled = not self.config_vibration_disabled
end

function GameState:toggle_particles_pressed()
    self.config_particles_disabled = not self.config_particles_disabled
end

function GameState:toggle_screenshake_pressed()
    self.config_screenshake_disabled = not self.config_screenshake_disabled
end

function GameState:toggle_effects_pressed()
    self.config_effects_disabled = not self.config_effects_disabled
end
