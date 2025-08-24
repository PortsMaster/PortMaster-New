function localization_init()
{
    global.language = "";
    global.languageDefaultFontScaling = 1;
    global.localizationMap = -4;
    global.fontMap = ds_map_create();
    font_add_enable_aa(false);
    global.defaultFont = font_load_from_csv("en", "medium");
    global.supportedLanguages = ds_map_create();
    var langGrid = load_csv("localization_data.csv");
    var gridWidth = ds_grid_width(langGrid);
    
    for (var col = 0; col < gridWidth; col++)
    {
        var langKey = ds_grid_get(langGrid, col, 0);
        ds_map_add(global.supportedLanguages, langKey, true);
    }
    
    ds_grid_destroy(langGrid);
}

function localization_load_language(arg0)
{
    if (is_undefined(arg0))
    {
        arg0 = "";
        localization_log("Error: Undefined language key.");
    }
    
    if (arg0 == "")
    {
        arg0 = os_get_language();
        
        if (!language_supported(arg0))
            arg0 = "en";
    }
    
    if (arg0 != global.language || global.language == "")
    {
        if (ds_exists(global.localizationMap, ds_type_map))
        {
            ds_map_destroy(global.localizationMap);
            global.localizationMap = -4;
        }
        
        if (arg0 != "en")
        {
            var map = ds_map_create();
            var langGrid = load_csv("localization_data.csv");
            var gridWidth = ds_grid_width(langGrid);
            var gridHeight = ds_grid_height(langGrid);
            var enCol = grid_find_col_num("en", langGrid);
            var newLangCol = grid_find_col_num(arg0, langGrid);
            
            if (is_undefined(newLangCol) || newLangCol < 1)
            {
                arg0 = "en";
                newLangCol = 1;
            }
            
            for (var row = 0; row < gridHeight; row++)
            {
                var enValue = ds_grid_get(langGrid, enCol, row);
                var newLangValue = ds_grid_get(langGrid, newLangCol, row);
                ds_map_add(map, enValue, newLangValue);
            }
            
            ds_grid_destroy(langGrid);
            ds_map_add(map, "current_language_index", newLangCol - 2);
            global.localizationMap = map;
            save_system_settings("language");
        }
        
        global.language = arg0;
        global.languageDefaultFontScaling = lang_get_default_scale(global.language);
        
        if (ds_exists(global.fontMap, ds_type_map))
        {
            var key = ds_map_find_first(global.fontMap);
            
            while (!is_undefined(key))
            {
                var font = ds_map_find_value(global.fontMap, key);
                
                if (font_exists(font))
                    font_delete(font);
                
                key = ds_map_find_next(global.fontMap, key);
            }
            
            ds_map_clear(global.fontMap);
        }
        
        font_setup(arg0);
        in_game_text_setup();
    }
}

function language_supported(arg0)
{
    return ds_map_exists(global.supportedLanguages, arg0);
}

function font_setup(arg0)
{
    var fontSmall = font_load_from_csv(arg0, "small");
    var fontMed = font_load_from_csv(arg0, "medium");
    var fontMedBold = font_load_from_csv(arg0, "medium_bold");
    var fontLarge = font_load_from_csv(arg0, "large");
    font_add_to_font_map("small", fontSmall);
    font_add_to_font_map("medium", fontMed);
    font_add_to_font_map("medium_bold", fontMedBold);
    font_add_to_font_map("large", fontLarge);
}

function font_load_from_csv(arg0, arg1)
{
    var fontKey = arg0 + "_" + arg1;
    var loadedFont = undefined;
    var bold = false;
    var italic = false;
    var currentCol = 1;
    var fontGrid = load_csv("localization_fonts.csv");
    var rowNum = grid_find_row_num(fontKey, fontGrid);
    
    if (rowNum > 0)
    {
        var fontName = ds_grid_get(fontGrid, currentCol++, rowNum);
        var fontSize = real(ds_grid_get(fontGrid, currentCol++, rowNum));
        var fontBold = ds_grid_get(fontGrid, currentCol++, rowNum);
        var fontItalic = ds_grid_get(fontGrid, currentCol++, rowNum);
        var fontScale = ds_grid_get(fontGrid, currentCol++, rowNum);
        
        if (is_bool(fontBold))
            bold = fontBold;
        
        if (is_bool(fontItalic))
            italic = fontItalic;
        
        loadedFont = font_add(fontName, fontSize, bold, italic, 0, 99999999);
    }
    
    ds_grid_destroy(fontGrid);
    return loadedFont;
}

function font_add_to_font_map(arg0, arg1)
{
    if (ds_map_exists(global.fontMap, arg0))
    {
        var oldFont = ds_map_find_value(global.fontMap, arg0);
        
        if (!is_undefined(oldFont) && font_exists(oldFont))
            font_delete(oldFont);
        
        ds_map_replace(global.fontMap, arg0, arg1);
    }
    else
    {
        ds_map_add(global.fontMap, arg0, arg1);
    }
}

function font_get(arg0)
{
    var font = ds_map_find_value(global.fontMap, arg0);
    
    if (is_undefined(font) && !ds_map_empty(global.fontMap))
        font = font_debug_text_norm;
    
    return font;
}

function text_translate(arg0)
{
    if (global.language != "en")
    {
        if (global.localizationMap != -4)
        {
            if (arg0 != "" && arg0 != "???")
            {
                var key = string_replace(arg0, "\n", " ");
                var translatedStr = ds_map_find_value(global.localizationMap, key);
                
                if (!is_undefined(translatedStr) && translatedStr != "")
                {
                    arg0 = translatedStr;
                    arg0 = string_replace(arg0, "\\n", "\n");
                }
                else
                {
                    var errorMarker = global.developerMode ? "!" : "";
                    arg0 = errorMarker + arg0 + errorMarker;
                    
                    if (global.debugLogMissingTranslations)
                        localization_log(arg0);
                }
            }
        }
        else
        {
            error_log("Localization map does not exist for language: " + global.language);
        }
    }
    
    return arg0;
}

function localization_get_all_language_names()
{
    var langGrid = load_csv("localization_data.csv");
    var langArray = grid_get_row_as_array(langGrid, 1, 2);
    ds_grid_destroy(langGrid);
    return langArray;
}

function localization_get_all_language_keys()
{
    var langGrid = load_csv("localization_data.csv");
    var langArray = grid_get_row_as_array(langGrid, 0, 2);
    ds_grid_destroy(langGrid);
    return langArray;
}

function localization_get_all_fonts(arg0)
{
    if (!is_undefined(arg0))
        arg0 = "small";
    
    var keyArray = localization_get_all_language_keys();
    var len = array_length(keyArray);
    var fontArray = undefined;
    fontArray[len - 1] = -1;
    
    for (var i = 0; i < len; i++)
        fontArray[i] = font_load_from_csv(keyArray[i], arg0);
    
    return fontArray;
}

