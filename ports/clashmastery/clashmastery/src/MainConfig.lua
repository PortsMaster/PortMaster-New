windowTitle = "Clash Mastery"

-- Define any extra gameState parameters you need
startingState = {
    floorHeight = 36,
    practiceController = nil,
    plr = nil,
    boss = nil,
    justGotBackUp = false,
    bossHealthPreviousAttempt = 0,
    bossHealthOnDeath = 0,
    bossRegenOnDeath = 0.5,
    playerKnockdownXPosition = 0,
    bossKnockdownXPosition = 0,
    numDeaths = 0,
    bossStateIndex = -1,
    practiceGrades = {"N","N","N","N"}
}

-- Define all pause menu-related preferences and options here
gamePreferences = {
    particlesEnabled = true,
    cameraShakePreferenceMultiplier = 1,
    screenFlashIntensity = 1
}

-- Define all actual game save state data
-- These will probably be very similar to 'startingState'
gameSaveData = {

}

-- This is the resolution of the actual art in the game. Each unit = 1 pixel of your pixel art.
gameResolution = {
    width = 64,
    height = 64
}

-- This is the base resolution you want the game to render at. This also determines the camera's resolution.
-- Make this equal to gameResolution for a pixel perfect camera.
-- This also determines the minimum resolution of the game, and how it gets scaled on different monitors.
-- This should be an integer multiple of gameResolution.
renderResolution = {
    width = 64,
    height = 64
}

-- Define the names of all texture files to be loaded. These must be in your /Textures/ directory

mainTextures = {
    {filename = "player12x12_v3-Sheet.png", slice=36},
    {filename = "boss12x12-Sheet.png", slice=36},
    {filename = "iconsAndObjects12x12-Sheet.png", slice=12},
    {filename = "hurtvignette.png", slice=64},
    {filename = "backgroundv3-Sheet.png", slice=68},
}

-- Define names of all .obj mesh files to be loaded. Must be in your /Models/ directory
mainMeshes = {

}
-- Map meshes to names so we can easily change the ordering of stuff
mainMeshMapping = {

}

-- Define the names of your music tracks. These must be .ogg files in your /Music/ directory
mainMusics = {
    "CalmTrackDay2V2",
    "BattleTrackDay2V1",
    "CalmTrack_TutorialArr"
}

mainDefaultControls = {
    {buttonName="deflect", keyboard={"x","k"}, gamepad={"b","leftshoulder"}},
    {buttonName="attack", keyboard={"z","j"}, gamepad={"x", "rightshoulder"}},
    {buttonName="moveleft", keyboard={"left", "a"}, gamepad={"dpleft"}},
    {buttonName="moveright", keyboard={"right", "d"}, gamepad={"dpright"}},
    {buttonName="jump", keyboard={"space","up","w", "c"}, gamepad={"a"}},
    {buttonName="select", keyboard={"space","z","return"}, gamepad={"a"}},
    {buttonName="pause", keyboard={"escape"}, gamepad={"start"}},
    {buttonName="navleft", keyboard={"a","left"}, gamepad={"dpleft"}},
    {buttonName="navright", keyboard={"d","right"}, gamepad={"dpright"}},
    {buttonName="navup", keyboard={"w","up"}, gamepad={"dpup"}},
    {buttonName="navdown", keyboard={"s","down"}, gamepad={"dpdown"}},
}

-- Define collision layers
Collision.Layers = {
    PLAYER = 1,
    PLAYER_ATTACK = 2,
    BOSS = 3,
    HURTER = 4
}

-- Define draw layers. You must define exactly one POSTCAMERA layer and one PARTICLES layer
GameObjects.DrawLayers = {
    BACKGROUND = 1,
    TILES = 2,
    ENEMIES = 3,
    PLAYER = 4,
    BOSS = 5,
    BULLETS = 6,
    PARTICLES = 7,
    DEATHLAYER_1 = 8,
    DEATHLAYER_2 = 9,
    POSTCAMERA = 10,
    IGNORE_DT = 11
}
-- Define a default layer
mainDefaultDrawLayer = 1 -- By default things will be in the 'background' layer

-- Define the order of functions in Levels.lua
mainLevelOrder = {
    loadingScreen,
    titleScreen,
    preTutorialScene,
    tutorialIntro,
    tutorialStage,
    prePracticeCutscene,
    practiceModeIntro,
    practiceModeStage,
    prePhase1Cutscene,
    bossPhase1Intro,
    bossFightPhase1,
    prePhase2Cutscene,
    bossPhase2Intro,
    bossFightPhase2,
    finalCutscene,
    postGameScreen
}