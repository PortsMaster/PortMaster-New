function scrSetDisplayDefaults(arg0)
{
    var _defaultDispBordered = false;
    var _defaultFullscreen = true;
    var _defaultIntegerScale = false;
    var _defaultScanlines = 0;
    _defaultFilter = true;
    
    if (arg0)
    {
        scrOpenConfig();
        global.dispBordered = scrReadConfig("dispBordered", _defaultDispBordered);
        global.fullscreen = scrReadConfig("fullscreen", _defaultFullscreen);
        global.integerScale = scrReadConfig("integerScale", _defaultIntegerScale);
        global.dispFilter = scrReadConfig("filter", _defaultFilter);
        window_enable_borderless_fullscreen(!global.dispBordered);
        window_set_fullscreen(global.fullscreen);
        global.scale = scrReadConfig("scale", global.scaleMax);
        
        if (!global.fullscreen)
        {
            window_set_size(384 * global.scale, 216 * global.scale);
            window_set_showborder(global.dispBordered);
        }
        
        global.scanlines = scrReadConfig("scanlines", _defaultScanlines);
        scrCloseConfig();
    }
    else
    {
        global.dispBordered = _defaultDispBordered;
        global.fullscreen = _defaultFullscreen;
        global.integerScale = _defaultIntegerScale;
        global.dispFilter = _defaultFilter;
        window_enable_borderless_fullscreen(!global.dispBordered);
        window_set_fullscreen(global.fullscreen);
        prevFullScreen = window_get_fullscreen();
        global.scale = global.scaleMax;
        
        if (!global.fullscreen)
        {
            window_set_size(384 * global.scale, 216 * global.scale);
            window_set_showborder(global.dispBordered);
        }
        
        global.scanlines = _defaultScanlines;
    }
}
