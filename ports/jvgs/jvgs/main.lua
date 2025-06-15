require("resources/modules/common")
require("resources/modules/jlib")
require("resources/modules/events")
require("resources/modules/effects")

-- Parse options and set video mode from that.
function main()
    -- Get access to some managers.
    local persistenceManager = jvgslua.PersistenceManager_getInstance()
    local videoManager = jvgslua.VideoManager_getInstance()
    local inputConfiguration = jvgslua.InputConfiguration_getConfiguration()
    local fontManager = jvgslua.FontManager_getInstance()
    local levelManager = jvgslua.LevelManager_getInstance()

    -- First load configration from file, then set values from command line
    -- options.
    local saveFile = (os.getenv("HOME") or ".") .. "/.jvgs.xml"
    persistenceManager:load(saveFile)
    jlib.parseOptions()

    -- Parse and set video options.
    local width = persistenceManager:isSet("width")
            and persistenceManager:get("width") or nil
    local height = persistenceManager:isSet("height")
            and persistenceManager:get("height") or nil
    local fullscreen = persistenceManager:isSet("height")
            and persistenceManager:get("fullscreen") or nil
    if width and height and not (fullscreen == "yes") then
        videoManager:setVideoMode(jvgslua.Vector2D(width, height), "jvgs")
    else
        videoManager:setVideoMode("jvgs")
    end
        
    -- Warn when using global variables.
    setmetatable(_G, {
        __newindex = function(table, key, value)
            print("Warning - setting global " .. key .. " to a " .. type(value))
            rawset(table, key, value)
        end
    })

    -- Set key configuration.
    inputConfiguration:setKey("jump", jvgslua.KEY_SPACE)
    inputConfiguration:setKey("action", jvgslua.KEY_LCTRL)
    inputConfiguration:setKey("left", jvgslua.KEY_LEFT)
    inputConfiguration:setKey("right", jvgslua.KEY_RIGHT)
    inputConfiguration:setKey("up", jvgslua.KEY_UP)
    inputConfiguration:setKey("down", jvgslua.KEY_DOWN)

    -- Load a font
    local font = jvgslua.Font("resources/font.ttf", 36)
    fontManager:addFont("regular", font)

    levelManager:queueLevel("resources/level-main-menu/main-menu.xml")
    levelManager:run()

    -- Make sure everything is saved.
    persistenceManager:write(saveFile)
end

main()
