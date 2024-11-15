
local DialogState = {
    SOUND_PREFIX = "",
    DEFAULT_LANG = "",
    filename = nil,
    lang = "",
    name = "",
    font = "",
    dialogs = {},
}

-- Return path to .ogg file or empty string.
local function dataPathSound(lang, basename)
    local soundFile = DialogState.SOUND_PREFIX..lang.."/"..basename..".ogg"
    if not file_exists(soundFile) then
        soundFile = ""
    end
    return soundFile
end

-- Loads localized dialogs from prefix.."dialogs_*.lua"
-- @param prefix prefix of dialogs_<lang>.lua files
-- @param soundPrefix prefix of <lang>/<dialogCodename>.ogg files
-- Default soundPrefix is "sound/<levelCodename>/"
function dialogLoad(prefix, soundPrefix)
    DialogState.SOUND_PREFIX = "sound/"..codename.."/"
    if soundPrefix then
        DialogState.SOUND_PREFIX = soundPrefix
    end
    -- NOTE: uses select_lang.lua to determine avaiable languages
    local langs = {}
    local oldfunc = select_addFlag
    function select_addFlag(lang, flag)
        table.insert(langs, lang)
    end
    file_include("script/select_lang.lua")
    select_addFlag = oldfunc

    for key, lang in pairs(langs) do
        local dialogFile = prefix.."dialogs_"..lang..".lua"
        if file_exists(dialogFile) then
            if "" == DialogState.DEFAULT_LANG then
                DialogState.DEFAULT_LANG = lang
            end
            DialogState.lang = lang
            DialogState.filename = dialogFile
            file_include(dialogFile)
        else
            if string.len(lang) <= 2 and lang == options_getParam("lang") then
                print(string.format("DEBUG: missing translation"..
                    "; lang=%q; file=%q", lang, dialogFile))
            end
        end
    end
end

--- Prepares localized dialog and checks for consistency.
-- @param dialogName dialog codename
-- @param fontName font codename (e.g. font_elk, font_parrot, ...)
-- @param defaultSubtitle prime subtitle to translate
function dialogId(dialogName, fontName, defaultSubtitle)
    DialogState.name = dialogName
    DialogState.font = fontName
    local primeDialog = DialogState.dialogs[dialogName]
    if not primeDialog then
        if DialogState.lang == DialogState.DEFAULT_LANG then
            dialogStr(defaultSubtitle)
            DialogState.dialogs[dialogName] = {
                font = fontName,
                subtitle = defaultSubtitle,
            }
        else
            print(string.format("WARNING: extra foreign dialog"..
                "; file=%q; name=%q; subtitle=%q",
                DialogState.filename, dialogName, defaultSubtitle or ""))
        end
    else
        if primeDialog.font ~= fontName then
            print(string.format("WARNING: bad font for foreign dialog"..
                "; file=%q; name=%q; primeFont=%q; font=%q",
                DialogState.filename, dialogName,
                primeDialog.font or "", fontName or ""))
        end
        if primeDialog.subtitle ~= defaultSubtitle then
            print(string.format(
                "WARNING: bad defaultSubtitle for foreign dialog"..
                "; file=%q; name=%q; primeSubtitle=%q; defaultSubtitle=%q",
                DialogState.filename, dialogName,
                primeDialog.subtitle or "", defaultSubtitle or ""))
        end
    end
end

--- Defines text for localizated dialog
-- @param subtitle localized text
function dialogStr(subtitle)
    dialog_addDialog(DialogState.name, DialogState.lang,
        dataPathSound(DialogState.lang, DialogState.name),
        DialogState.font, subtitle)
end

