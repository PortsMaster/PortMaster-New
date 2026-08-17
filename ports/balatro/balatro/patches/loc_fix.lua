-- Force Español (España) wording for the score popup mult string when Balatro
-- ships the Russian typo "множ." (seen in es_419). Also patched into the
-- localization file at build time; this is a runtime safety net.

local ES_ES_A_MULT = '+#1# Multi.'

local function looks_russian_mult(s)
    if type(s) ~= 'string' then return false end
    -- UTF-8 for "множ" (U+043C U+043D U+043E U+0436)
    return string.find(s, '\208\188\208\189\208\190\208\182', 1, true) ~= nil
end

local function fix_a_mult()
    local lang = G and G.SETTINGS and G.SETTINGS.language
    local vd = G and G.localization and G.localization.misc and G.localization.misc.v_dictionary
    if not vd then return end

    if lang == 'es_419' or looks_russian_mult(vd.a_mult) then
        vd.a_mult = ES_ES_A_MULT
        if G.localization.misc.v_dictionary_parsed and loc_parse_string then
            G.localization.misc.v_dictionary_parsed.a_mult = loc_parse_string(vd.a_mult)
        end
    end
end

-- set_language may already have run before this module is required.
fix_a_mult()

local original_set_language = Game.set_language
function Game:set_language(...)
    local result = original_set_language(self, ...)
    fix_a_mult()
    return result
end

-- init_localization rebuilds v_dictionary_parsed; keep the fix applied.
if type(init_localization) == 'function' then
    local original_init_localization = init_localization
    function init_localization(...)
        local result = original_init_localization(...)
        fix_a_mult()
        return result
    end
end
