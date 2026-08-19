-- Stop Love2D Text object leaks from DynaText.
-- Stock creates love.graphics.newText per glyph and drops them without
-- :release() when the string rebuilds. With Nunito that accumulates native
-- GPU text and FPS decays even when mv stays flat.
--
-- This replaces DynaText:update_text so unchanged glyphs reuse their Text
-- object instead of allocating a new one.
--
-- Disable with BALATRO_PM_SKIP_TEXT_CLEANUP=1.

local SKIP = G.BALATRO_PM_SKIP_TEXT_CLEANUP
if SKIP == nil then
    SKIP = os.getenv('BALATRO_PM_SKIP_TEXT_CLEANUP') == '1'
end
if SKIP then return end

local function release_text(obj)
    if obj and obj.release then
        pcall(function() obj:release() end)
    end
end

local function release_dyna_letters(dyna)
    if not dyna or not dyna.strings then return end
    for _, s in ipairs(dyna.strings) do
        for _, let in ipairs(s.letters or {}) do
            release_text(let.letter)
            let.letter = nil
        end
    end
end

function DynaText:update_text(first_pass)
    self.config.W = 0
    self.config.H = 0

    for k, v in ipairs(self.config.string) do
        if (type(v) == 'table' and v.ref_table) or first_pass then
            local part_a, part_b = 0, 1000000
            local new_string = v
            local outer_colour = nil
            local inner_colour = nil
            local part_scale = 1
            if type(v) == 'table' and (v.ref_table or v.string) then
                new_string = (v.prefix or '')..tostring(v.ref_table and v.ref_table[v.ref_value] or v.string)..(v.suffix or '')
                part_a = #(v.prefix or '')
                part_b = #new_string - #(v.suffix or '')
                if v.scale then part_scale = v.scale end
                if first_pass then
                    outer_colour = v.outer_colour or nil
                    inner_colour = v.colour or nil
                end
                v = new_string
            end

            self.strings[k] = self.strings[k] or {}
            local old_string = self.strings[k].string
            if old_string ~= new_string or first_pass then
                if self.start_pop_in then self.reset_pop_in = true end
                self.reset_pop_in = self.reset_pop_in or self.config.reset_pop_in
                if not self.reset_pop_in then
                    self.config.pop_out = nil
                    self.config.pop_in = nil
                else
                    self.config.pop_in = self.config.pop_in or 0
                    self.created_time = G.TIMERS.REAL
                end
                self.strings[k].string = v
                local old_letters = self.strings[k].letters
                local tempW = 0
                local tempH = 0
                local current_letter = 1
                self.strings[k].letters = {}

                for _, c in utf8.chars(v) do
                    local old_letter = old_letters and old_letters[current_letter] or nil
                    local letter_obj
                    if old_letter and old_letter.char == c and old_letter.letter then
                        letter_obj = old_letter.letter
                        old_letter.letter = nil
                    else
                        letter_obj = love.graphics.newText(self.font.FONT, c)
                    end
                    local let_tab = {
                        letter = letter_obj,
                        char = c,
                        scale = old_letter and old_letter.scale or part_scale,
                    }
                    self.strings[k].letters[current_letter] = let_tab
                    local tx = self.font.FONT:getWidth(c)*self.scale*part_scale*G.TILESCALE*self.font.FONTSCALE + 2.7*(self.config.spacing or 0)*G.TILESCALE*self.font.FONTSCALE
                    local ty = self.font.FONT:getHeight(c)*self.scale*part_scale*G.TILESCALE*self.font.FONTSCALE*self.font.TEXT_HEIGHT_SCALE
                    let_tab.offset = old_letter and old_letter.offset or {x = 0, y = 0}
                    let_tab.dims = {x = tx/(self.font.FONTSCALE*G.TILESCALE), y = ty/(self.font.FONTSCALE*G.TILESCALE)}
                    let_tab.pop_in = first_pass and (old_letter and old_letter.pop_in or (self.config.pop_in and 0 or 1)) or 1
                    let_tab.prefix = current_letter <= part_a and outer_colour or nil
                    let_tab.suffix = current_letter > part_b and outer_colour or nil
                    let_tab.colour = inner_colour or nil
                    if k > 1 then let_tab.pop_in = 0 end
                    tempW = tempW + tx/(G.TILESIZE*G.TILESCALE)
                    tempH = math.max(ty/(G.TILESIZE*G.TILESCALE), tempH)
                    current_letter = current_letter + 1
                end

                if old_letters then
                    for _, ol in ipairs(old_letters) do
                        if ol.letter then release_text(ol.letter) end
                    end
                end

                self.strings[k].W = tempW
                self.strings[k].H = tempH
            end
        end

        if self.strings[k] then
            if self.strings[k].W > self.config.W then self.config.W = self.strings[k].W; self.strings[k].W_offset = 0 end
            if self.strings[k].H > self.config.H then self.config.H = self.strings[k].H; self.strings[k].H_offset = 0 end
        end
    end

    if self.T then
        if (self.T.w ~= self.config.W or self.T.h ~= self.config.H) and (not first_pass or self.reset_pop_in) then
            self.ui_object_updated = true
            self.non_recalc = self.config.non_recalc
        end
        self.T.w = self.config.W
        self.T.h = self.config.H
    end

    self.reset_pop_in = false
    self.start_pop_in = false

    for k, v in ipairs(self.strings) do
        v.W_offset = 0.5*(self.config.W - v.W)
        v.H_offset = 0.5*(self.config.H - v.H + (self.config.offset_y or 0))
    end
end

function DynaText:remove()
    release_dyna_letters(self)
    return Moveable.remove(self)
end
