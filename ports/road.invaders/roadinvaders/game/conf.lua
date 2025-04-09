inspect = require('helper/inspect')
Timer = require("helper/timer")
Peachy = require("helper/peachy")
Signal = require("helper/signal")
Camera = require("helper/camera")
Flip = require("script/Flip")

function love.conf(t)
    t.window.title = "Road Invaders"
    t.window.icon = "image/icon.png"
    t.window.width = 320
    t.window.height = 240
    -- t.window.borderless = true
    t.window.vsync = 1
    t.modules.touch = false
    t.modules.joystick = false
    t.accelerometerjoystick = false
end

-- btn cfg
BTN = {}
BTN.UP = "up"
BTN.DOWN = "down"
BTN.LEFT = "left"
BTN.RIGHT = "right"
BTN.Y = "i"
BTN.X = "u"
BTN.A = "j"
BTN.B = "k"
BTN.SELECT = "space"
BTN.START = "return"
BTN.MENU = "escape"
BTN.L1 = "h"
BTN.L2 = "y"
BTN.R1 = "l"
BTN.R2 = "o"

ANY_BTNS = {
    [BTN.L1] = true,
    [BTN.L2] = true,
    [BTN.R1] = true,
    [BTN.R2] = true,
    [BTN.UP] = true,
    [BTN.DOWN] = true,
    [BTN.LEFT] = true,
    [BTN.RIGHT] = true,
    [BTN.Y] = true,
    [BTN.X] = true,
    [BTN.A] = true,
    [BTN.B] = true,
    [BTN.START] = true,
}

-- signal
SG = {}
SG.SHIFT_MONSTER = "SHIFT_MONSTER"
SG.CAR_CRASH = "CAR_CRASH"
SG.CUBE_MATCH = "CUBE_MATCH"
SG.PUNCH_CUBE = "PUNCH_CUBE"
SG.OUTSIDE_PUNCH = "OUTSIDE_PUNCH"
SG.HIT_MONSTER = "HIT_MONSTER"
SG.CUBE_STATIC = "CUBE_STATIC"
SG.TIMES_UP = "TIMES_UP"
SG.CUBE_EXPLODE = "CUBE_EXPLODE"
SG.TRI_EXPLODE = "TRI_EXPLODE"
SG.CAR_LOOP = "CAR_LOOP"
SG.GET_ENERGY = "GET_ENERGY"
SG.CAR_MOVE = "CAR_MOVE"
SG.CUBE_COLLAPSE = "CUBE_COLLAPSE"
SG.SHIFT_UP_GEAR = "SHIFT_UP_GEAR"
SG.DOT_COMPLETE = "DOT_COMPLETE"
SG.CLEAR_ALL_INVADERS = "CLEAR_ALL_INVADERS"
SG.PRE_GAME_OVER = "PRE_GAME_OVER"

-- define
FPS = 60
FRM = 1/FPS
START_X = 88
BOTTOM_Y = 240
CUBE_WID = 36
CUBE_HEI = 30
CUBE_SP_HEI = 38
MAX_COL = 4
LIMIT_COL = 4
CAR_SP_WID = 36
CAR_SP_HEI = 36
CAR_SHEET_WID = 80
CAR_SHEET_HEI = 81
CAR_SP_OFFSET = {X = 62, Y = 62 + 12 -26}
CAR_COLLIDE_SIZE = {UPPER = -55+26, LOWER = -2+26}
COLOR = {
    "blue", "red", "green", "yellow"
}

PCOLOR = {}
PCOLOR.BLACK = {0/255, 0/255, 0/255, 1}
PCOLOR.WHITE = {255/255, 241/255, 232/255, 1}
PCOLOR.D_BLUE = {29/255, 43/255, 83/255, 1}
PCOLOR.D_PURPLE = {126/255, 37/255, 83/255, 1}
PCOLOR.D_GREEN = {0/255, 135/255, 81/255, 1}
PCOLOR.BROWN = {171/255, 82/255, 54/255, 1}
PCOLOR.D_GREY = {95/255, 87/255, 79/255, 1}
PCOLOR.L_GREY = {194/255, 195/255, 199/255, 1}
PCOLOR.RED = {255/255, 0/255, 77/255, 1}
PCOLOR.ORANGE = {255/255, 163/255, 0/255, 1}
PCOLOR.YELLOW = {255/255, 236/255, 39/255, 1}
PCOLOR.GREEN = {0/255, 228/255, 54/255, 1}
PCOLOR.BLUE = {41/255, 173/255, 255/255, 1}
PCOLOR.INDIGO = {131/255, 118/255, 156/255, 1}
PCOLOR.PINK = {255/255, 119/255, 168/255, 1}
PCOLOR.PEACH = {255/255, 204/255, 170/255, 1}

-- help func
local font1, font2
function initFont()
    font2 = love.graphics.newFont("helper/PICO-8.ttf", 16)
    font2:setFilter("nearest", "nearest")
    font2:setLineHeight(1.4)
    font1 = love.graphics.newFont("helper/PICO-8.ttf", 8)
    font1:setFilter("nearest", "nearest")
    font1:setLineHeight(1.2)
end

function setFont(idx)
    if idx == 1 then
        love.graphics.setFont(font1)
    else
        love.graphics.setFont(font2)
    end
end


function resetColor(color)
    love.graphics.setColor(color or {1,1,1,1})
end

function randi(num)
    return math.ceil(love.math.random(num))
end

function dump(t)
    print(inspect(t))
end

function gdump(t)
    love.graphics.print(inspect(t), 0, 0)
end

function getPosX(column)
    return START_X + (column - 1) * CUBE_WID
end

function getPosY(row)
    return BOTTOM_Y - row*CUBE_HEI
end

function getCarPosY(row)
    return BOTTOM_Y - row * CAR_SP_HEI - CAR_SP_OFFSET.Y
end

function getCarPosX(column)
    return START_X + (column - 1) * CAR_SP_WID - CAR_SP_OFFSET.X
end

function getMonsterX(col)
    return START_X + (col - 1) * CUBE_WID - 10
end

local _uid = 0
function getUID(isLast)
    if isLast then
        return _uid
    else
        _uid = _uid + 1
        return _uid
    end
end

function newSprite(fileName, aniam)
    local jsonPath = string.format("image/%s.json", fileName)
    local imgPath = string.format("image/%s.png", fileName)
    local newImg = love.graphics.newImage(imgPath)
    return Peachy.new(jsonPath, newImg, aniam or "org")
end