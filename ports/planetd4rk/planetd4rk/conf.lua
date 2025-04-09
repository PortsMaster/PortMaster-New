windowWidth = 960
windowHeight = 540
canvasWidth = 960
canvasHeight = 540
referenceDT = 1/60
maxDT = 1/15 -- lowest framerate allowed is 15 fps. If you get a lag spike that goes over 15 fps, it should clamp to this

scaleX = windowWidth / canvasWidth
scaleY = windowHeight / canvasHeight

web = false -- true if web version, false if not web version. Set this before you build
itch = false -- true if exporting to the itch version, in which controller support should be enabled
manualGC = false -- enable manual garbage collection at the start of each room
manualGCPerFrame = false -- enable manual garbage collection every frame
logGC = false -- enable logging of garbage collection
showFPS = false -- turn on fps counter

enableTiles = true

function love.conf(t)
    t.window.title = "PLANET D4RK"
    t.window.width = windowWidth
    t.window.height = windowHeight
t.window.resizable = true  -- !!! MAKE WINDOW RESIZABLE
    if web and not itch then
        t.modules.joystick = false
    end
end
