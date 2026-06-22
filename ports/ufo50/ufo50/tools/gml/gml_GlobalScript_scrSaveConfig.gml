function scrSaveConfig()
{
    scrOpenConfig();
    scrWriteConfig("dispBordered", global.dispBordered);
    scrWriteConfig("fullscreen", window_get_fullscreen());
    scrWriteConfig("scale", global.scale);
    scrWriteConfig("scanlines", global.scanlines);
    scrWriteConfig("integerScale", global.integerScale);
    scrWriteConfig("filter", global.dispFilter);
    scrWriteConfig("volume", global.AUDIO_VOLUME);
    scrWriteConfig("sfxToggle", global.AUDIO_SFX_TOGGLE);
    scrWriteConfig("bgmToggle", global.AUDIO_BGM_TOGGLE);
    scrWriteConfig("inputFocus", global.inputFocus);
    
    for (var p = 0; p <= 1; p++)
    {
        for (var i = 0; i < 7; i++)
            scrWriteConfig("P" + string(p + 1) + "key" + string(i), global.keyMap[p][i]);

        for (var i = 0; i < 7; i++)
            scrWriteConfig("P" + string(p + 1) + "joy" + string(i), global.joyMap[p][i]);
    }
    
    scrWriteConfig("doubledUpButtonsP1", global.doubledUpButtons[0]);
    scrWriteConfig("doubledUpButtonsP2", global.doubledUpButtons[1]);
    scrWriteConfig("altFire1P1", global.altFire1[0]);
    scrWriteConfig("altFire1P2", global.altFire1[1]);
    scrWriteConfig("altFire2P1", global.altFire2[0]);
    scrWriteConfig("altFire2P2", global.altFire2[1]);
    scrWriteConfig("invertedButtonsP1", global.invertedButtons[0]);
    scrWriteConfig("invertedButtonsP2", global.invertedButtons[1]);
    scrWriteConfig("joyTypeP1", global.joyType[0]);
    scrWriteConfig("joyTypeP2", global.joyType[1]);
    scrWriteConfig("defaultLanguage", global.LANG_SAVE_ID[global.defaultLanguage]);
    scrCloseConfig();
}
