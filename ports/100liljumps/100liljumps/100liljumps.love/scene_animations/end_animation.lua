require("../scene_animation")

EndAnimation = {}

EndAnimation.Animation = function(game_state)
    local steps = {
        {
            time = 3,
            handle = EndAnimation.step_1_handle,
        },
        {
            time = 2,
            handle = EndAnimation.step_2_handle,
        },
        {
            time = 1,
            handle = EndAnimation.step_3_handle,
        },
        {
            time = 4,
            handle = EndAnimation.step_4_handle,
        },
        {
            controled = true,
            time = 4,
            handle = EndAnimation.step_5_handle,
            data = EndAnimation.initial_step_5_data(),
        },
        {
            controled = true,
            time = 100,
            handle = EndAnimation.step_6_handle,
        },
        {
            time = 3,
            handle = EndAnimation.step_7_handle,
        }
    }
    local scene_animation = SceneAnimation( game_state, steps )

    return scene_animation
end

EndAnimation.step_1_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local brog = game_state.tile_map.brogs[1]
    local offset = 3
    local speed = 2
    brog.pos.y = brog.anchor.y + lume.round(offset*math.sin(speed*game_state.time))

    game_state.player:animate()
    game_state.tile_map:animate_entities()
end

EndAnimation.step_2_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local brog = game_state.tile_map.brogs[1]
    local offset = 3
    local speed = 2
    brog.pos.y = brog.anchor.y + lume.round(offset*math.sin(speed*game_state.time))
    brog.state = Brog.State.TURNING
    game_state.player:animate()
    game_state.tile_map:animate_entities()

    if(brog:current_animation().has_looped) then
        self:next_step()
    end
end

EndAnimation.step_3_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local brog = game_state.tile_map.brogs[1]
    local offset = 3
    local speed = 2
    brog.pos.y = brog.anchor.y + lume.round(offset*math.sin(speed*game_state.time))
    brog.state = Brog.State.IDLE
    brog.direction = -1

    game_state.player:animate()
    game_state.tile_map:animate_entities()
end

EndAnimation.step_4_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local brog = game_state.tile_map.brogs[1]
    local offset = 3
    local speed = 2

    local initial_pos = brog.pos
    local end_pos = V2(80, 56)

    local t = easeInOut(self.scene_normal_time, 4)
    brog.pos.x = lume.lerp(initial_pos.x, end_pos.x, t)
    brog.pos.y = lume.lerp(initial_pos.y, end_pos.y, t)

    brog.state = Brog.State.IDLE
    brog.direction = -1

    game_state.player:animate()
    game_state.tile_map:animate_entities()
end

EndAnimation.initial_step_5_data = function()
    return {
        step_dialogs = false,
        step_dialog = 1,
        step_5_setup = false,
    }
end

EndAnimation.step_5_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local brog = game_state.tile_map.brogs[1]

    if(not data.step_5_setup) then
        brog.anchor.x = brog.pos.x
        brog.anchor.y = brog.pos.y
        data.step_5_setup = true
    end

    local dialogs = {
        "You finally made it",
        "What took you so long?",
        "Anyway, have your jumps back",
        "Goodbye"
    }

    if game_state.player_is_wearing_hat then
        dialogs = {
            "You fin...",
            "Nice hat!",
            "I recently lost mine and had to find another one",
            "Anyway, have your jumps back",
            "Goodbye"
        }
    end

    if game_state.jump_counter_broken then
        dialogs = {
            "Jung vf lbhe snibevgr sebt",
            "Zl snibevgrf va ab fcrpvsvp beqre ner",
            "Qnejva sebt",
            "Qrfreg enva sebt",
            "Zbffl sebt",
            "Chzcxva gbnqyrg, orpnhfr ubj gurl whzc"
        }
    end

    if(not data.step_dialogs) then
        data.step_dialogs = true
        UI.add_speech_dialog(dialogs[1], brog)
    end

    local initial_pos = brog.pos
    local end_pos = V2(80, 56)

    local offset = 3
    local speed = 2
    brog.pos.y = brog.anchor.y + lume.round(offset*math.sin(speed*game_state.time))

    brog.state = Brog.State.IDLE
    brog.direction = -1

    game_state.player:animate()
    game_state.tile_map:animate_entities()

    if(next_dialog_triggered) then
        if(data.step_dialog == 3) then
            UI.hide_jumps_counter()
            game_state.should_count_jumps = false
        end

        if(data.step_dialog == #dialogs and UI.speech_dialog.is_done) then
            UI.clear_speech_dialog()
            self:next_step()
        else
            if(UI.speech_dialog.is_done) then
                data.step_dialog = data.step_dialog + 1
                UI.speech_dialog:change_label(dialogs[data.step_dialog])
            else
                UI.speech_dialog:complete_triggered()
            end
        end
    end
end

EndAnimation.step_6_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local brog = game_state.tile_map.brogs[1]
    brog.state = Brog.State.TURNING
    game_state.player:animate()
    brog:animate()

    if(brog:current_animation().has_looped) then
        UI.clear_speech_dialog()
        self:next_step()
    end
end

EndAnimation.step_7_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local brog = game_state.tile_map.brogs[1]
    brog.direction = 1
    local offset = 3
    local speed = 2

    local initial_pos = brog.pos
    local end_pos = V2(400, 20)

    local t = easeInOut(self.scene_normal_time, 4)
    brog.pos.x = lume.lerp(initial_pos.x, end_pos.x, t)
    brog.pos.y = lume.lerp(initial_pos.y, end_pos.y, t)

    brog.state = Brog.State.IDLE

    game_state.player:animate()
    game_state.tile_map:animate_entities()
end
