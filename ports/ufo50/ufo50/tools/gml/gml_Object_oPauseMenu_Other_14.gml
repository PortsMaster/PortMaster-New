SUB_INIT = 0;
SUB_NAV = 1;
SUB_DELAY = 2;
SUB_RESET = 3;
global.needToSaveConfig = true;

if (substate == SUB_INIT)
{
    prevFullScreen = window_get_fullscreen();
    drawMenu = true;
    scrMenuCreate(scrString("menu_head_video_settings"), 0);
    delayLenShort = 8;
    delayLenLong = 22;
    delayCenterWindow = 20;
    delayLen = delayLenShort;
    var _dispIndex = 0;
    _dispFilter = global.dispFilter;
    
    if (global.dispBordered && global.integerScale)
        _dispIndex = 1;
    else if (global.dispBordered && !global.integerScale)
        _dispIndex = 0;
    else
        _dispIndex = 2;
    
    OP_DISPLAY = scrMenuItem(TYPE_DUAL, scrString("menu_item_display"), _dispIndex, "MAINTAIN ASPECT", "INTEGER SCALE", "STRETCH TO FIT");
    trace("SCALE", global.scale);
    OP_SCALE = false;
    OP_CRT = false;
    OP_FILTER = scrMenuItem(TYPE_DUAL, "BILINEAR FILTER", _dispFilter, "OFF", "ON");
    scrMenuSpacer(MENU_MEDIUM_SPACER);
    scrMenuSpacer(MENU_MEDIUM_SPACER);
    scrMenuSpacer(MENU_MEDIUM_SPACER);
    scrMenuSpacer(MENU_MEDIUM_SPACER);
    scrMenuSpacer(MENU_MEDIUM_SPACER);
    scrMenuSpacer(MENU_MEDIUM_SPACER);
    OP_BACK = scrMenuItem(TYPE_SINGLE, scrString("menu_item_back_to_settings"));
    menuSel = OP_DISPLAY;
    scrSwitchSub(SUB_NAV);
}
else if (substate == SUB_NAV)
{
    var choice = scrMenuNavigation();
    
    if (prevFullScreen != window_get_fullscreen())
    {
        scrSwitchSub(SUB_INIT);
        exit;
    }
    
    if (choice == -2)
    {
        scrSfxLibrary(soundSubExit[currentSoundSet]);
        scrSwitchState(statePrev);
        exit;
    }
    
    if (pressStart)
    {
        scrSwitchState(STATE_UNPAUSE);
        exit;
    }
    
    if (keyboard_check_pressed(vk_f1))
    {
        scrSfxLibrary(soundSet[currentSoundSet]);
        scrSwitchSub(SUB_RESET);
        exit;
    }
    
    if (choice >= 0)
    {
        switch (menuSel)
        {
            case OP_DISPLAY:
                scrSfxLibrary(soundToggle[currentSoundSet]);
                global.fullscreen = true;
                
                if (choice == 0)
                {
                    global.dispBordered = true;
                    global.integerScale = false;
                }
                else if (choice == 1)
                {
                    global.dispBordered = true;
                    global.integerScale = true;
                }
                else if (choice == 2)
                {
                    global.dispBordered = false;
                    global.integerScale = false;
                }
                
                window_enable_borderless_fullscreen(!global.dispBordered);
                window_set_fullscreen(global.fullscreen);
                prevFullScreen = window_get_fullscreen();
                delayLen = delayLenLong;
                scrSwitchSub(SUB_DELAY);
                break;
            
            case OP_FILTER:
                scrSfxLibrary(soundToggle[currentSoundSet]);
                global.dispFilter = (choice == 1) ? true : false;
                delayLen = delayLenShort;
                scrSwitchSub(SUB_DELAY);
                break;
            
            case OP_SCALE:
                scrSfxLibrary(soundToggle[currentSoundSet]);
                global.scale = 1;
                var _trueScale = min(global.scale, global.scaleFill);
                window_set_size(384, 216);
                delayLen = delayLenShort;
                scrSwitchSub(SUB_DELAY);
                break;
            
            case OP_CRT:
                scrSfxLibrary(soundToggle[currentSoundSet]);
                global.scanlines = choice;
                delayLen = delayLenShort;
                scrSwitchSub(SUB_DELAY);
                break;
            
            case OP_BACK:
                scrSfxLibrary(soundSubExit[currentSoundSet]);
                scrSwitchState(statePrev);
                break;
        }
    }
}
else if (substate == SUB_DELAY)
{
    stateCounter++;
    
    if (stateCounter == 1)
    {
        oldSel = menuSel;
        menuSel = -1;
    }
    
    if ((delayLen == delayLenShort && stateCounter == 2) || (delayLen == delayLenLong && stateCounter == delayCenterWindow))
    {
        if (!window_get_fullscreen())
            window_center();
    }
    
    if (stateCounter >= delayLen)
    {
        menuSel = oldSel;
        scrSwitchSub(SUB_NAV);
    }
}
else if (substate == SUB_RESET)
{
    if (stateCounter == 0)
    {
        scrSetDisplayDefaults(false);
        stateCounter++;
    }
    else if (stateCounter == 1)
    {
        if (!window_get_fullscreen())
            window_center();
        
        stateCounter++;
    }
    else if (stateCounter == 2)
    {
        var _okay = scrGetOkay("menu_misc_defaults_restored");
        
        if (_okay == true)
            scrSwitchSub(SUB_INIT);
    }
}
