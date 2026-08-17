-- Stop Love2D Text object leaks from DynaText.
-- Stock creates love.graphics.newText per glyph and drops them without
-- :release() when the string rebuilds or the DynaText is removed. With Nunito
-- that accumulates native memory and FPS decays even when mv stays flat.
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

local original_update_text = DynaText.update_text
function DynaText:update_text(first_pass)
    local old_by_index = {}
    for k, s in ipairs(self.strings or {}) do
        old_by_index[k] = s.letters
    end

    local result = original_update_text(self, first_pass)

    for k, old_letters in pairs(old_by_index) do
        if old_letters and self.strings[k] and self.strings[k].letters ~= old_letters then
            local kept = {}
            for _, let in ipairs(self.strings[k].letters or {}) do
                if let.letter then kept[let.letter] = true end
            end
            for _, let in ipairs(old_letters) do
                if let.letter and not kept[let.letter] then
                    release_text(let.letter)
                end
            end
        end
    end

    return result
end

function DynaText:remove()
    release_dyna_letters(self)
    return Moveable.remove(self)
end
