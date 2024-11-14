local command = require("command")
local tables = require("tables")
local input = require("input")
local draw = require("draw")
local osk = require("osk")
local splashlib = require("splash")
local soundmanager = require("soundmanager")
local push = require "push"
local Talkies = require('talkies')

love.graphics.setDefaultFilter("nearest", "nearest")
local gameWidth, gameHeight = 640, 480 -- Fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
-- windowHeight = 1280, 720 -- Uncomment this when using on desktop to show windows
push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})

-- Access the modes, settings, and menu from the tables module
settings = tables.settings
menu = tables.menu

-- Fade variables
local fadeDuration = 0.4 -- Duration of the fade
local fadeTimer = 0
local fading = false

-- Timer variables for periodic process check
local checkInterval = 3 -- Interval in seconds
local timeSinceLastCheck = 0

-- Initialize state
function love.load()
    setupFont()  -- Set up fonts with the virtual dimensions
    currentSelection = 1
    -- Initialize sound manager
    soundmanager.load()

    -- Initialize the splash
        splash = splashlib()
        splash.onDone = function() -- Splash is done, continue loading the game
        splash = nil -- Set splash to nil to stop drawing it
        loadSettings()
        input.load()
        draw.load()
        osk.load()
		
		 -- Load Talkies assets and configuration
        loadTalkies()
		
        updateProcessStatus()
        loadInfoData()
        fading = true -- Fade in effect
		
		
        FirstBootCheck()
		
    end
end

function love.update(dt)
	Talkies.update(dt)
    if splash then
        splash:update(dt)
    else
        input.update(dt)

        -- Check if OSK is visible and update it
        if osk.isVisible() then
            osk.update(dt)
        end

        -- Update timer for periodic process check
        timeSinceLastCheck = timeSinceLastCheck + dt
        if timeSinceLastCheck >= checkInterval then
            timeSinceLastCheck = 0
            updateProcessStatus()
            loadInfoData()
        end

	
        if fading then
            fadeTimer = fadeTimer + dt
            if fadeTimer >= fadeDuration then
                fadeTimer = fadeDuration
                fading = false
            end
        end
    end
end

function love.draw()
    push:start()  -- Begin virtual resolution
	
    if splash then
        splash:draw()
    else
        draw.render()
        
        -- Apply the fade effect if fading is active
        if fading then
            local fadeAlpha = 1 - (fadeTimer / fadeDuration)
            love.graphics.setColor(0, 0, 0, fadeAlpha)
            love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
            love.graphics.setColor(1, 1, 1)  -- Reset color to white
        end
        
        -- Draw OSK if visible
        if osk.isVisible() then
            osk.draw()
        end
    end
	Talkies.draw()
    push:finish()  -- End virtual resolution
end

-- Function to set up the fonts and colors
function setupFont()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Define font sizes
    local regularFontSize = 32
    local smallFontSize = 16

    -- Define font colors
    local regularFontColor = {1, 1, 1} -- White
    local smallFontColor = {0.7, 0.7, 0.7} -- Grey

    -- Load and set up the custom font for regular and small sizes
    fonts = {
        regular = love.graphics.newFont("assets/fonts/Peaberry-Base.otf", regularFontSize),
        small = love.graphics.newFont("assets/fonts/Peaberry-Base.otf", smallFontSize)
    }

    -- Apply nearest filter to both fonts
    fonts.regular:setFilter("nearest", "nearest")
    fonts.small:setFilter("nearest", "nearest")

    -- Store font colors separately
    fontColors = {
        regular = regularFontColor,
        small = smallFontColor
    }
end

-- Function to check if the process is running
function isProcessRunning()
    local lovedir = love.filesystem.getSourceBaseDirectory()
        print("LOVEDIR IS SET TO: " .. lovedir)
      --  os.exit(1)
   

    local command = "pgrep -f '" .. lovedir .. "/librespot' "
    local success = os.execute(command)
    print("Command executed: " .. command)
    print("Command success code: " .. tostring(success))
    return success == 0
end

-- Function to update the process status
function updateProcessStatus()
    if isProcessRunning() then
        settings.mode = true
    else
        settings.mode = false
    end
    print("Current mode after checking process: " .. tostring(settings.mode))
end

-- Function to load and parse the settings file
function loadSettings()
    local settingsFile = "settings.txt"

    if love.filesystem.getInfo(settingsFile) then
        local contents = love.filesystem.read(settingsFile)
        if contents then
            parseSettings(contents)
        else
            print("Failed to read settings file.")
        end
    else
        print("Settings file not found. Setting default values.")
        -- Save the default settings
        saveSettings()
    end
end

-- Save the settings to a file
function saveSettings()
    local autoplayValue = settings.autoplay and 1 or 0  

    local settingsData = string.format(
        "autoplay=%d\nbitrate=%d\ndeviceName=%s",
        autoplayValue,
        settings.bitrate,
        settings.deviceName
    )
    love.filesystem.write("settings.txt", settingsData)
end

-- Parse the settings content from a file
function parseSettings(contents)
    for line in contents:gmatch("[^\r\n]+") do
        local key, value = line:match("(%w+)=(.+)")
        if key and value then
            if key == "deviceName" then
                settings[key] = value
            elseif key == "autoplay" then
                settings[key] = tonumber(value) == 1  -- Convert 1/0 to true/false
            else
                settings[key] = tonumber(value)
            end
        end
    end
end

-- Function to read and parse the info.txt file
function loadInfoData()
    -- Determine the process status
    local status = isProcessRunning() and "Online" or "Offline"
    
  -- Initialize infoData with default values based on process status
    infoData = {
        host = "Unknown",
       country = "Unknown",
        status = status
    }

    local filePath = "info.txt"
    local file = io.open(filePath, "r")
    
    if not file then
        print("Error: Unable to open file at path: " .. filePath)
        return
    end

    print("Reading info.txt file: " .. filePath)
    
    -- Read the file line by line
    for line in file:lines() do
        print("Info line: " .. line) -- Debugging line

        -- Parse the line for host or country information
        if line:find("Authenticated as") then
            local hostMatch = line:match('Authenticated as "([^"]+)"')
            if hostMatch then
                infoData.host = hostMatch
                print("Updated host: " .. infoData.host) -- Debugging line
            end
        elseif line:find("Country") then
            local countryMatch = line:match('Country: "([^"]+)"')
            if countryMatch then
                infoData.country = countryMatch
                print("Updated country: " .. infoData.country) -- Debugging line
            end
        end
    end
    
    file:close()
    print("Current info data: Host = " .. infoData.host .. ", Country = " .. infoData.country .. ", Status = " .. infoData.status)
end









-- Function to load Talkies assets
function loadTalkies()
    -- Load images
    jantrueno = love.graphics.newImage("assets/sprites/jantrueno.jpg")
    jantrueno:setFilter("nearest", "nearest")

    -- Load sounds
    Talkies.talkSound = love.audio.newSource("assets/sounds/typeSound.ogg", "static")
    Talkies.optionOnSelectSound = love.audio.newSource("assets/sounds/optionSelect.ogg", "static")
    Talkies.optionSwitchSound = love.audio.newSource("assets/sounds/optionSwitch.ogg", "static")

    -- Set Talkies configuration
    Talkies.font = fonts.small
    Talkies.characterImage = jantrueno
    Talkies.textSpeed = "fast"
    Talkies.inlineOptions = true
	Talkies.messageBackgroundColor = {0.078, 0.078, 0.078}
	Talkies.messageBorderColor = {1, 1, 1}
end

-- Function to check for first boot
function FirstBootCheck()
    local firstBootFile = "firstbootcomplete"

    -- Check if the file exists in the save directory
    if not love.filesystem.getInfo(firstBootFile) then
        -- Show first boot complete dialog
        FirstBoot()

        -- Create the firstbootcomplete file after the dialog
        love.filesystem.write(firstBootFile, "done")
    end
end

-- Function to display the first boot dialog
function FirstBoot()
    Talkies.say("", {
        "Thank you for using my Spotify port! It looks like this is your first time here. There are a couple of requirements for this port. --",
        "Requirements:\n" ..
        "1. If you're using the MUOS custom firmware, you need to be on the \"Banana\" version or newer.\n" ..
        "2. You need Spotify Premium.",
		"To start using the port you simply turn the \"Mode\" to \"On\", after that your device will show up in your Spotify app under the \"Connect to a device\" tab.",
		"In this app you can turn on or off Autoplay, change the bitrate to low or high quality and change the name of your device.",
		"Proceed to port by pressing A."
    }, {
        textSpeed = "fast",  -- You can adjust the speed as needed
        talkSound = Talkies.talkSound,
        thickness = 4,
        rounding = 4,
        image = jantrueno
    })
end




function love.gamepadpressed(joystick, button)
    if button == "a" then
            Talkies.onAction() 
    end
end

