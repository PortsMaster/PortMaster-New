local bitser = require("helper/bitser")
local dotTransition = require("script/DotTransition")
local fileExist = love.filesystem.getInfo
local SceneScore = {}

local printf = love.graphics.printf
local timer, resetString
local rawList = {}
local showList = {}
local fileName = "highscore.data"
local transitioning = false

function SceneScore:init()
    timer = Timer.new()
end

function SceneScore:enter(prevoious, score)
    timer:clear()
    transitioning = false
    self:readFile()
    self:getHighScore(score or 0)
end

function SceneScore:readFile()
    if fileExist(fileName) then
        rawList = bitser.loadLoveFile(fileName)
    else
        self:makeFakeHighScore()
    end
end

function SceneScore:makeFakeHighScore()
    rawList = {
        {score = 01000, time = "19/09/13\n23:22 AM"},
        {score = 00000, time = "19/09/13\n23:22 AM"},
        {score = 00000, time = "19/09/13\n23:22 AM"},
        {score = 00000, time = "19/09/13\n23:22 AM"},
        {score = 00000, time = "19/09/13\n23:22 AM"},
    }
    bitser.dumpLoveFile(fileName, rawList)
end

function SceneScore:saveHighScore(score)
    score = score or 0
    local findIdx
    for idx, entry in pairs(rawList) do
        if score >= entry.score then
            findIdx = idx
            break
        end
    end
    if not findIdx then
        findIdx = #rawList + 1
    end
    local scoreString = string.format("%05d", score)
    local dateString = os.date("%y/%m/%d\n%I:%M %p")
    local entry = {score = score, time = dateString}
    table.insert(rawList, findIdx, entry)
    bitser.dumpLoveFile(fileName, rawList)
    -- for i = 101, #rawList do
    --     rawList[i] = nil
    -- end
    return findIdx
end

function SceneScore:updateShowList(insertList)
    showList = {}
    for idx, rank in pairs(insertList) do
        local rawEntry = rawList[rank]
        local entry = {color = PCOLOR.WHITE, rank = rank, score = string.format("%05d", rawEntry.score), time = rawEntry.time}
        showList[idx] = entry
    end
end

function SceneScore:getHighScore(score)
    local idx = self:saveHighScore(score)
    if idx <= 5 then
        local insertList = {1,2,3,4,5}
        self:updateShowList(insertList)
    else
        local insertList = {1,2,3,idx - 1,idx}
        self:updateShowList(insertList)
        idx = 5
    end
    timer:clear()
    timer:every(0.5, function()
        showList[idx].color = Flip.get("SceneScore") and PCOLOR.WHITE or PCOLOR.RED
    end)
end

function SceneScore:draw()
    -- resPush:start()
    resetColor(PCOLOR.D_BLUE)
    love.graphics.rectangle("fill",0,0,320,240)
    resetColor()
    setFont(2)
    printf({PCOLOR.D_PURPLE, "HIGH SCORE"}, 0, 20+4, 320, "center")
    printf({PCOLOR.D_PURPLE, "rank"}, 22, 50+4, 320)
    printf({PCOLOR.D_PURPLE, "score"}, 110+4+4, 50+4, 320)
    printf({PCOLOR.D_PURPLE, "date"}, 230+8, 50+4, 320)
    printf({PCOLOR.RED, "HIGH SCORE"}, 0, 20, 320, "center")
    printf({PCOLOR.RED, "rank"}, 22, 50, 320)
    printf({PCOLOR.RED, "score"}, 110+4+4, 50, 320)
    printf({PCOLOR.RED, "date"}, 230+8, 50, 320)
    for i, info in pairs(showList) do
        local posY = 80 + ((i-1) * 30)
        setFont(2)
        printf({PCOLOR.D_PURPLE, info.rank}, 40, posY + 4, 320)
        printf({PCOLOR.D_PURPLE, info.score}, -130+4+4, posY + 4, 320, "right")
        printf({info.color, info.rank}, 40, posY, 320)
        printf({info.color, info.score}, -130+4+4, posY, 320, "right")
        setFont(1)
        printf({PCOLOR.D_PURPLE, info.time}, 230+8, posY-2+2, 320, "left")
        printf({info.color, info.time}, 230+8, posY-2, 320, "left")
    end
    if resetString then
        printf({PCOLOR.BLUE, resetString}, 0, 0, 320, "center")
    end
    dotTransition:draw()
    -- resPush:finish()
end

local tt = 0
function SceneScore:keypressed(key)
    if key == BTN.SELECT then
        tt = tt + 1
        if tt == 15 then
            resetString = "RESET"
            love.filesystem.remove(fileName)
        end
    elseif ANY_BTNS[key] then
        if transitioning then return end
        transitioning = true
        dotTransition:show()
        soundMgr:playPressBtn()
        Timer.after(0.3, function()
            timer:clear()
            Gamestate.pop()
            Gamestate.push(SceneMenu)
        end)
    end
end

function SceneScore:update(dt)
    timer:update(dt)
    dotTransition:update(dt)
end

return SceneScore