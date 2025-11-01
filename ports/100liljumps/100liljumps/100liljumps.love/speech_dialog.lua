require("./ui")
require("./audio")

Audio.create_sound("sounds/brog_speak.ogg", "brog_speak_base", "static", 20, 0.5)
Audio.create_sound("sounds/brog_speak_1.ogg", "brog_speak", "static", 20, 0.5)

local Object = require("./classic")

SpeechDialog = Object.extend(Object)

SpeechDialog.Mode = {
    EXPAND = 0,
    DRAWN  = 1,
    SHRINK = 2,
}

function SpeechDialog.new(self, label, following_entity)
    self.initial_time = game_state.time
    self.time = 0
    self.label = label
    self.new_label = ""
    self.following_entity = following_entity
    self.mode = SpeechDialog.Mode.EXPAND
    self.is_done = false
    self.fade_is_done = false

    self.letters_to_draw = 3
    self.play_speech_sound_time = 0
    self.play_speech_sound_initial_time = 0
    self:play_dialog_spawn_sound()

    local r, g, b = lume.color("#2a186b")
    self.background = {r = r, g = g, b = b}

    r, g, b = lume.color("#ffffff")
    self.foreground = {r = r, g = g, b = b}

    self.dialog_width = 400
    self.dialog_height = 100
    self.dialog_min_width = 300
    self.dialog_max_width = 400
    self.dialog_min_height = 100
end

function SpeechDialog:draw()
    local width, height = love.graphics.getDimensions()
    local scale = resolution_scale()

    self.dialog_width = scale * (400 / 6)
    self.dialog_height = scale * (100 / 6)
    self.dialog_min_width = scale * (300 / 6)
    self.dialog_max_width = scale * (400 / 6)
    self.dialog_min_height = scale * (100 / 6)

    local font = UI.get_scaled_font("dialog")
    local padding = 16
    local v_space = math.floor(scale * (4 / 6))
    local anchor = self.following_entity:speech_anchor()

    self.time = game_state.time - self.initial_time

    local label_width = font:getWidth(self.label)
    local font_height = font:getHeight()
    if( (label_width + padding) <= self.dialog_max_width) then
        -- Clamp
        self.dialog_width = math.max(self.dialog_min_width, label_width + padding)
        self.dialog_height = font_height + 2*padding

        local w, wrapped_lines = font:getWrap(
            self.label, self.dialog_width - 2*padding
        )

        if #wrapped_lines > 1 then
            self.dialog_height = 2*font_height + v_space + 2*padding
        end
    else
        self.dialog_width = self.dialog_max_width
        local w, wrapped_lines = font:getWrap(
            self.label, self.dialog_width - 2*padding
        )
        self.dialog_height = font_height*(#wrapped_lines) + (#wrapped_lines - 1)*v_space + 2*padding
    end

    if(self.mode == SpeechDialog.Mode.EXPAND) then
        local expand_time = 0.3
        local time_t = self.time / expand_time
        local t = unclamped_lerp(0.8, 1, easeOutBack(time_t, 3))

        love.graphics.setFont(font)
        self:draw_dialog_container(t)

        if(time_t >= 1) then
            self.time = 0
            self.initial_time = game_state.time
            self.mode = SpeechDialog.Mode.DRAWN
            self.is_done = false
            self.fade_is_done = false

            self.letters_to_draw = 3
            self.play_speech_sound_time = 0
            self.play_speech_sound_initial_time = game_state.time
            self:play_scroll_sound()
        end

    elseif(self.mode == SpeechDialog.Mode.DRAWN) then
        self.play_speech_sound_time = game_state.time - self.play_speech_sound_initial_time

        local scale_offset = get_canvas_offset()

        local left_x = scale_offset.x + anchor.x*scale - self.dialog_width/2
        local top_y  = scale_offset.y + anchor.y*scale - self.dialog_height/2

        love.graphics.setFont(font)
        self:draw_dialog_container()

        local w, wrapped_lines = font:getWrap(
            self.label, self.dialog_width - 2*padding
        )

        local START_TIME_OFFSET = 0.032
        local FADE_DURATION = 0.16

        local SOUND_TIME_OFFSET = 0.14
        local label_size = #self.label
        local label_time_to_draw = (label_size-1) * START_TIME_OFFSET

        -- TODO: change to sound time
        if(self.play_speech_sound_time >= SOUND_TIME_OFFSET and not self.is_done) then
            self:play_scroll_sound()
            self.play_speech_sound_time = 0
            self.play_speech_sound_initial_time = game_state.time
            self.letters_to_draw = self.letters_to_draw + 1
        end

        if(self.time > label_time_to_draw) then
            self.is_done = true
        end

        for dy, line in pairs(wrapped_lines) do
            for line_i = 1, #line do
                local character = line:sub(line_i, line_i)

                local left_string       = line:sub(0, (line_i-1))
                local left_string_width = font:getWidth(left_string)
                local left_kerning      = 0
                if line_i > 1 then
                    local prev_char = line:sub(line_i-1, line_i-1)
                    left_kerning = font:getKerning(prev_char, character)
                end

                local sum = 0
                for j = 1, dy-1 do
                    sum = sum + #wrapped_lines[j]
                end
                local i = line_i + sum

                local start_time = (i-1) * START_TIME_OFFSET
                local adjusted_time = self.time - start_time
                local end_time = start_time + FADE_DURATION
                local t = lume.clamp(adjusted_time / end_time, 0, 1)
                if self.fade_is_done then
                    t = 1
                end

                local alpha = t
                local y_offset = -6*(1 - math.min(1, t*4))

                local x = left_x + padding + left_string_width + left_kerning
                local y = top_y + padding + (dy-1)*(font_height + v_space) + y_offset

                love.graphics.setColor(self.foreground.r, self.foreground.g, self.foreground.b, alpha)
                love.graphics.print(character, x, y)
            end
        end

    elseif(self.mode == SpeechDialog.Mode.SHRINK) then
        local shrink_time = 0.1
        local time_t = self.time / shrink_time
        local t = lume.lerp(1, 0.9, time_t)
        local scale_offset = get_canvas_offset()

        local left_x = scale_offset.x + anchor.x*scale - t*(self.dialog_width/2)
        local top_y  = scale_offset.y + anchor.y*scale + self.dialog_height/2 - t*(self.dialog_height)

        love.graphics.setFont(font)
        self:draw_dialog_container(t)

        local w, wrapped_lines = font:getWrap(
            self.label, self.dialog_width - 2*padding
        )
        love.graphics.setColor(self.foreground.r, self.foreground.g, self.foreground.b, 1 - time_t)
        for dy, line in pairs(wrapped_lines) do
            love.graphics.print(
                line,
                left_x + padding, top_y + padding + (dy-1)*(font_height + v_space)
            )
        end

        if(time_t >= 1) then
            self.time = 0
            self.initial_time = game_state.time
            self.mode = SpeechDialog.Mode.EXPAND
            self.letters_to_draw = 0
            self.play_speech_sound_time = 0
            self.play_speech_sound_initial_time = game_state.time

            self.label = self.new_label
            self.new_label = ""
        end
    end
end

function SpeechDialog:close()
end

function SpeechDialog:change_label(new_label)
    self.new_label = new_label
    self.time = 0
    self.initial_time = game_state.time
    self.mode = SpeechDialog.Mode.SHRINK
end

function SpeechDialog:play_scroll_sound()
    Audio.play_sound("brog_speak_base", 0.8, 1.2)
    Audio.play_sound("brog_speak", 0.9, 1.4)
end

function SpeechDialog:play_dialog_spawn_sound()
    Audio.play_sound("brog_speak_base")
end

function SpeechDialog:complete_triggered()
    self.letters_to_draw = #self.label
    self.is_done = true
    self.fade_is_done = true
    self:play_scroll_sound()
end

function SpeechDialog:draw_dialog_container(offset_t)
    local anchor = self.following_entity:speech_anchor()
    local offset_t = offset_t or 1
    local left_x = anchor.x*scale - offset_t*(self.dialog_width/2)
    local top_y  = anchor.y*scale + self.dialog_height/2 - offset_t*(self.dialog_height)

    local scale_offset = get_canvas_offset()
    love.graphics.setColor(self.background.r, self.background.g, self.background.b, 0.8)
    love.graphics.rectangle(
        "fill",
        left_x + scale_offset.x, top_y + scale_offset.y,
        offset_t*self.dialog_width, offset_t*self.dialog_height,
        15, 15
    )
end
