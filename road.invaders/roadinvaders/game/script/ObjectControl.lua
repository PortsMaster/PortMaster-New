local invaders = require("script/Invaders")

local CUBE_INIT_SPEED = 1
local CUBE_REVERSE_SPEED = 2
local CUBE_FALL_SPEED = 4
local SPAWN_Y = 0 - CUBE_HEI
local FLASH_COUNT = 5

local MOVE_RZ = {
    NONE = 0,
    PUNCH = 1,
    BLOCK = 2,
    MOVE = 3
}

local ObjectControl = {}

ObjectControl.reverseMode = false
local _cubeMap = {}
local _sortFlagMap = {false, false, false, false}
local _lastColorIdx = 0

local _carData
local delayTimer, indieTimer
local carSP, blockSP, patternSP

function ObjectControl:init()
    carSP = newSprite("car_main_love")
    blockSP = newSprite("cube_sheet_love", "red")
    delayTimer = Timer.new()
    indieTimer = Timer.new()
end

function ObjectControl:enter()
    ObjectControl.update = ObjectControl.updateNM
    ObjectControl.reverseMode = false
    delayTimer:clear()
    indieTimer:clear()
    self:resetCarData(4, 4)
    ObjectControl:playCar("org",true)
    self:clearMaps()
    self:cubeMapping({
        {col = 1, row = 1, color = 1, isStatic = true},
        {col = 2, row = 1, color = 2, isStatic = true},
        {col = 3, row = 1, color = 3, isStatic = true},
        {col = 4, row = 1, color = 4, isStatic = true},
        {col = 4, row = 8, color = 4, hold = true},
        {col = 3, row = 8, color = 4, hold = true},
        {col = 2, row = 8, color = 1, hold = true},
        {col = 1, row = 8, color = 2, hold = true},
    })
    self:checkInsertCube()
end

function ObjectControl:pauseUpdate()
    ObjectControl.update = function()
    end
end

function ObjectControl:toggleReverse()
    ObjectControl.reverseMode = not ObjectControl.reverseMode
    local cubeNewSpeed = CUBE_INIT_SPEED
    if ObjectControl.reverseMode == true then
        ObjectControl.update = ObjectControl.updateRV
        cubeNewSpeed = CUBE_REVERSE_SPEED
    else
        ObjectControl.update = ObjectControl.updateNM
        cubeNewSpeed = CUBE_INIT_SPEED
    end
    for col, cubes in pairs(_cubeMap) do
        for _, cb in ipairs(cubes) do
            if cb.isStatic then
                cb.isStatic = false
                cb.hold = true
            elseif cb.hold then
                cb.isStatic = true
                cb.hold = false
            end
            cb.speed = cubeNewSpeed
            cb.matched = false
            cb.isFlashing = false
            cb.beingTarget = false
        end
    end
end

function ObjectControl:updateRV(dt)
    carSP:update(dt)
    delayTimer:update(dt)
    indieTimer:update(dt)
    -- logic
    self:_sortCubeUpdate()
    self:_moveCubeUpdateRV()
    -- self:_checkMatchedUpdateRV()
    -- self:_removeMatchedUpdate()
    -- self:_awakeCubesUpdateRV()
    self:_removeOutsideCubesUpdateRV()
    self:_checkCarCrashUpdate()
    self:_checkCubeHitInvadersUpdate()
    self:_checkCarHitInvadersUpdate()
end

function ObjectControl:updateNM(dt)
    carSP:update(dt)
    delayTimer:update(dt)
    indieTimer:update(dt)
    -- logic
    self:_sortCubeUpdate()
    self:_moveCubeUpdate()
    self:_checkMatchedUpdate()
    self:_removeMatchedUpdate()
    self:_awakeCubesUpdate()
    self:_removeOutsideCubesUpdate()
    self:_checkCarCrashUpdate()
end

function ObjectControl:draw()
    resetColor()
    -- draw cube
    for col, cubes in pairs(_cubeMap) do
        for _, cb in ipairs(cubes) do
            blockSP:setTag(cb.color)
            blockSP:draw(cb.posX + CUBE_WID*0.5 + cb.offsetX, cb.posY + CUBE_HEI*0.5 + cb.offsetY, 0,
                    cb.scaleX, cb.scaleY, CUBE_WID*0.25, CUBE_HEI*0.25)
        end
    end
    -- car
    if _carData.draw then
        carSP:draw(_carData.posX + CAR_SHEET_WID, _carData.posY + CAR_SHEET_HEI, 0,
                _carData.scaleX, _carData.scaleY, CAR_SHEET_WID*0.5, CAR_SHEET_HEI*0.5)
    end
end

function ObjectControl.getNewCubeData(column, colorIdx)
    local pattern = randi(4)
    return {
        uid = getUID(),
        color = COLOR[colorIdx],
        colorIdx = colorIdx,
        pattern = COLOR[pattern],
        patternIdx = pattern,
        row = 1,
        speed = CUBE_INIT_SPEED,
        col = column,
        posY = SPAWN_Y,
        posX = getPosX(column),
        scaleX = 2,
        scaleY = 2,
        offsetX = 0,
        offsetY = 0,
        isStatic = false,
        matched = false,
        isFlashing = false,
        beingTarget = false,
        hold = false,
    }
end

function ObjectControl:spawnBlockCube(shakeDelay)
    local col = _carData.col
    if col == 0 or col == 5 then
        local newCubeData = self.getNewCubeData(col, randi(4))
        newCubeData.posY = getPosY(8)
        newCubeData.hold = true
        newCubeData.isStatic = false
        self._addToMap(newCubeData, col)
        self:shakeAndReleaseCube(newCubeData,2,8)
    end
end

function ObjectControl:cubeMapping(infos)
    for k, info in pairs(infos) do
        local newCubeData = self.getNewCubeData(info.col, info.color)
        newCubeData.posY = getPosY(info.row)
        newCubeData.hold = info.hold or false
        newCubeData.isStatic = info.isStatic or false
        self._addToMap(newCubeData, info.col)
    end
end

function getColList(targetColumn)
    if not _cubeMap[targetColumn] then
        _cubeMap[targetColumn] = {}
    end
    return _cubeMap[targetColumn]
end

function ObjectControl:sideMoveCube(cubeData, side)
    local targetColumn = cubeData.col + side
    local checkUpper = cubeData.posY - CUBE_HEI
    local checkLower = cubeData.posY + CUBE_HEI
    for rowIdx, cube in ipairs(getColList(targetColumn)) do
        if cube.posY > checkUpper and cube.posY < checkLower then
            return false
        end
    end
    Signal.emit(SG.PUNCH_CUBE, cubeData.posX, cubeData.posY)
    cubeData.speed = CUBE_FALL_SPEED
    self:moveCubeTo(cubeData, targetColumn)
    self:strechCubeV(cubeData)
    self:playCar("punch")
    self:carSpriteSide(side)
    if targetColumn <= 0 or targetColumn > LIMIT_COL then
        Signal.emit(SG.OUTSIDE_PUNCH, targetColumn)
    end
    return true
end

function ObjectControl:carSpriteSide(side)
    _carData.scaleX = math.abs(_carData.scaleX)*(-side)
end

function ObjectControl:playCar(anima, loop)
    carSP:setTag(anima)
    carSP:setFrame(1)
    if loop then return end
    carSP:onLoop(function()
        if ObjectControl.reverseMode then
            carSP:setTag("idle")
        else
            carSP:setTag("org")
        end
        carSP:onLoop(nil)
    end)
end

local stFactor = 0.65
function ObjectControl:strechCubeV(cubeData)
    cubeData.scaleX = 2 * stFactor
    cubeData.scaleY = 2/ stFactor
    delayTimer:script(function(wait)
        delayTimer:tween(0.1, cubeData, {scaleY = 2 * stFactor, scaleX = 2/ stFactor}, "out-quart")
        wait(0.1)
        delayTimer:tween(0.1, cubeData, {scaleX = 2, scaleY = 2}, "out-quart")
    end)
end

function ObjectControl:strechCubeH(cubeData)
    local stFactor = 0.75
    cubeData.scaleY = 2 * stFactor
    cubeData.scaleX = 2/ stFactor
    delayTimer:script(function(wait)
        delayTimer:tween(0.1, cubeData, {scaleX = 2 * stFactor, scaleY = 2/ stFactor}, "out-quart")
        wait(0.1)
        delayTimer:tween(0.1, cubeData, {scaleY = 2, scaleX = 2}, "out-quart")
    end)
end

function ObjectControl:moveCubeTo(cubeData, targetColumn)
    -- dirty flag
    _sortFlagMap[targetColumn] = true
    -- update data
    local orgColumn = cubeData.col
    table.insert(getColList(targetColumn), cubeData)
    cubeData.posX = getPosX(targetColumn)
    cubeData.col = targetColumn
    -- delete legacy data
    for rowIdx, cb in ipairs(getColList(orgColumn)) do
        if cb.uid == cubeData.uid then
            table.remove(getColList(orgColumn), rowIdx)
            return
        end
    end
end

function ObjectControl:explodeUpperCubes()
    delayTimer:clear()
    -- explode cubes
    local delay
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cb in ipairs(cubes) do
            -- holding cubes
            if cb.hold == true then
                self:delayExplodeCube(cb)
            -- falling cubes
            elseif cb.isStatic == false then
                self:delayExplodeCube(cb)
            -- higher than cubes
            elseif cb.posY <= _carData.gridPosY then
                self:delayExplodeCube(cb)
            end
        end
    end
end

function ObjectControl:delayExplodeCube(cb)
    local delay = math.random() * 0.26
    delayTimer:after(delay, function()
        self:_removeCube(cb.uid)
        Signal.emit(SG.CUBE_EXPLODE, cb.posX, cb.posY)
    end)
end

function ObjectControl.clearMaps()
    _cubeMap = {}
    delayTimer:clear()
end

function ObjectControl._addToMap(cubeData, column)
    local tempTable = getColList(column)
    table.insert(tempTable, 1, cubeData)
end

function ObjectControl._addToMapRV(cubeData, column)
    local tempTable = getColList(column)
    tempTable[#tempTable+1] = cubeData
end

function ObjectControl:_carBecomeInvin()
    _carData.invincible = true
    indieTimer:after(2, function()
        _carData.draw = true
        _carData.invincible = false
    end)
    delayTimer:every(FRM*4, function()
        if _carData.invincible then
            _carData.draw = not _carData.draw
        else
            return false
        end
    end)
end

function ObjectControl:checkInsertCubeRV()
    for col, cubes in pairs(_cubeMap) do
        -- if col >= 1 and col <= LIMIT_COL then
            local cube = cubes[#cubes]
            if not cube then
                for _ = 1, 3 do
                    self:insertHoldCubesRV()
                end
                return
            elseif cube.posY < (BOTTOM_Y + CUBE_HEI*3)then
                for _ = 1, 3 do
                    self:insertHoldCubesRV()
                end
                return
            end
        -- end
    end
end

function ObjectControl:checkInsertCube()
    for col, cubes in pairs(_cubeMap) do
        if col >= 1 and col <= LIMIT_COL then
            local cube = cubes[1]
            if not cube then
                for _ = 1, 3 do
                    self:insertHoldCubes()
                end
                return
            elseif cube.posY > (0 - CUBE_HEI*3)then
                for _ = 1, 3 do
                    self:insertHoldCubes()
                end
                return
            end
        end
    end
end

function ObjectControl:_checkCarHitInvadersUpdate()
    local posX = getCarPosX(_carData.col) + CAR_SP_OFFSET.X
    local posY = _carData.gridPosY
    invaders:checkAttackCar(posX, posY)
end

function ObjectControl:_checkCubeHitInvadersUpdate()
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cube in pairs(cubes) do
            local result = invaders:checkHitInvaders(cube.col, cube.posY)
            if result then
                self:_removeCube(cube.uid)
                Signal.emit(SG.CUBE_EXPLODE, cube.posX, cube.posY)
            end
        end
    end
end

function ObjectControl:checkCubeCollapse()
    for col, cubes in pairs(_cubeMap) do
        -- row
        for rowIdx = #cubes, 1, -1 do
            local cb = cubes[rowIdx]
            if cb.hold == true then
                local canFall = self:_canCubeFall(cb, rowIdx)
                if canFall == false then
                    Signal.emit(SG.CUBE_COLLAPSE)
                    return
                end
                break
            end
        end
    end
end

function ObjectControl:_checkCarCrashUpdate()
    if _carData.invincible == true then
        return
    end
    local checkColumn = _carData.col
    local rangeUpper = _carData.gridPosY + CAR_COLLIDE_SIZE.UPPER
    local rangeLower = _carData.gridPosY + CAR_COLLIDE_SIZE.LOWER
    -- cube crash
    local checkCol = getColList(checkColumn)
    if checkCol then
        for rowIdx, cb in ipairs(checkCol) do
            if cb.posY >= rangeUpper and cb.posY <= rangeLower then
                self:_removeCube(cb.uid)
                self:_carBecomeInvin()
                Signal.emit(SG.CUBE_EXPLODE, cb.posX, cb.posY)
                Signal.emit(SG.CAR_CRASH)
                return
            end
        end
    end
end

function ObjectControl:_removeOutsideCubesUpdateRV()
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cb in ipairs(cubes) do
            if (cb.posY + CUBE_SP_HEI) < 0 then
                self:_removeCube(cb.uid)
            end
        end
    end
end

function ObjectControl:_removeOutsideCubesUpdate()
    for col, cubes in pairs(_cubeMap) do
        if col < 1 or col > LIMIT_COL then
            for rowIdx, cb in ipairs(cubes) do
                if cb.posY > BOTTOM_Y then
                    self:_removeCube(cb.uid)
                end
            end
        end
    end
end

function ObjectControl:_awakeCubesUpdate()
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cb in ipairs(cubes) do
            if cb.isStatic and self:_canCubeAwake(cb, rowIdx) then
                cb.speed = CUBE_FALL_SPEED
                cb.isStatic = false
            end
        end
    end
end

function ObjectControl:_awakeCubesUpdateRV()
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cb in ipairs(cubes) do
            if cb.isStatic and self:_canCubeAwakeRV(cb, rowIdx) then
                cb.speed = CUBE_FALL_SPEED
                cb.isStatic = false
            end
        end
    end
end

function ObjectControl:_removeCube(uid)
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cb in ipairs(cubes) do
            if cb.uid == uid then
                table.remove(cubes, rowIdx)
            end
        end
    end
end

function ObjectControl:explodeAllCube()
    local delay
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cb in ipairs(cubes) do
            delay = math.random() * 0.26
            delayTimer:after(delay, function()
                self:_removeCube(cb.uid)
                Signal.emit(SG.CUBE_EXPLODE, cb.posX, cb.posY)
            end)
        end
    end
end

function ObjectControl:_removeMatchedUpdate()
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cb in ipairs(cubes) do
            if cb.matched and (not cb.isFlashing) and (not cb.isShaking)then
                self:_flashAndRemoveCube(cb)
            end
        end
    end
end

function ObjectControl:_flashAndRemoveCube(cb, noMatchSignal)
    if cb.isFlashing then return end
    cb.isFlashing = true
    delayTimer:every(FRM * 4, function()
        cb.color = Flip.get(cb.uid) and COLOR[cb.colorIdx] or "flash"
    end, FLASH_COUNT)
    delayTimer:after(FRM * 4 * FLASH_COUNT, function()
        self:_removeCube(cb.uid)
        Signal.emit(SG.CUBE_EXPLODE,cb.posX,cb.posY)
        if not noMatchSignal then
            Signal.emit(SG.CUBE_MATCH,cb.posX,cb.posY)
        end
    end)
end

function ObjectControl:_checkMatchedUpdate()
    -- check same column
    local nextCB
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cb in ipairs(cubes) do
            if cb.isStatic then
                nextCB = cubes[rowIdx+1]
                if nextCB and nextCB.isStatic then
                    if nextCB.colorIdx == cb.colorIdx then
                        if math.abs(nextCB.posY - cb.posY) <= CUBE_HEI then
                            nextCB.matched = true
                            cb.matched = true
                        end
                    end
                end
            end
        end
    end
    -- check same row
    for colIdx = 1, (LIMIT_COL-1) do
        for _, cubeA in ipairs(getColList(colIdx)) do
            if cubeA.isStatic then
                -- nextColmnCubes
                for _, cubeB in ipairs(getColList(colIdx+1)) do
                    if cubeB.isStatic then
                        if cubeA.colorIdx == cubeB.colorIdx then
                            if (cubeA.posY - cubeB.posY) == 0 then
                                cubeA.matched = true
                                cubeB.matched = true
                            end
                        end
                    end
                end
            end
        end
    end
end

function ObjectControl:_checkMatchedUpdateRV()
    -- check same column
    local nextCB
    for col, cubes in pairs(_cubeMap) do
        for rowIdx, cb in ipairs(cubes) do
            if cb.isStatic then
                nextCB = cubes[rowIdx+1]
                if nextCB and nextCB.isStatic then
                    if nextCB.colorIdx == cb.colorIdx then
                        if math.abs(nextCB.posY - cb.posY) <= CUBE_HEI then
                            nextCB.matched = true
                            cb.matched = true
                        end
                    end
                end
            end
        end
    end
    -- check same row
    for colIdx = 1, (LIMIT_COL-1) do
        for _, cubeA in ipairs(getColList(colIdx)) do
            if cubeA.isStatic then
                -- nextColmnCubes
                for _, cubeB in ipairs(getColList(colIdx+1)) do
                    if cubeB.isStatic then
                        if cubeA.colorIdx == cubeB.colorIdx then
                            if (cubeA.posY - cubeB.posY) == 0 then
                                cubeA.matched = true
                                cubeB.matched = true
                            end
                        end
                    end
                end
            end
        end
    end
end

function ObjectControl:_sortCubeUpdate()
    for colIdx, shouldSort in pairs(_sortFlagMap) do
        if shouldSort then
            table.sort(getColList(colIdx), function(a, b)
                return a.posY < b.posY
            end)
            _sortFlagMap[colIdx] = false
        end
    end
end

function ObjectControl:insertHoldCubes()
    for col = 1, LIMIT_COL do
        local cubes = _cubeMap[col]
        local topCube = cubes[1]
        local posY = topCube and (topCube.posY - CUBE_HEI)
        if (not posY) or posY >= 0 then
            posY = getPosY(9)
        end
        local colorIdx = self:getDiffColor(col)
        local newCubeData = self.getNewCubeData(col, colorIdx)
        newCubeData.posY = posY
        newCubeData.hold = true
        self._addToMap(newCubeData, col)
    end
end

function ObjectControl:insertHoldCubesRV()
    for col = 1, LIMIT_COL do
        local cubes = _cubeMap[col]
        local bottomCube = cubes[#cubes]
        local posY = bottomCube and (bottomCube.posY + CUBE_HEI)
        if (not posY) or posY <= 240 then
            posY = getPosY(0)
        end
        local colorIdx = self:getDiffColor(col)
        local newCubeData = self.getNewCubeData(col, colorIdx)
        newCubeData.posY = posY
        newCubeData.hold = true
        newCubeData.speed = CUBE_REVERSE_SPEED
        self._addToMapRV(newCubeData, col)
    end
end

function ObjectControl:getTargetCube()
    local cubeList = {}
    local lowerPosY = 0 - BOTTOM_Y
    -- column
    for col, cubes in pairs(_cubeMap) do
        -- row
        if col >= 1 and col <= 4 then
            for rowIdx = #cubes, 1, -1 do
                local cb = cubes[rowIdx]
                if cb.hold and (not cb.isFlashing) and (not cb.beingTarget) and (not cb.isShaking)then
                    cubeList[#cubeList+1] = cb
                    lowerPosY = math.max(lowerPosY, cb.posY)
                    break
                end
            end
        end
    end
    local newList = {}
    for idx, cb in pairs(cubeList) do
        if cb.posY >= lowerPosY then
            newList[#newList+1] = cb
        end
    end
    local rndNum = randi(#newList)
    return newList[rndNum]
end

function ObjectControl:getTargetCubeRV()
    local cubeList = {}
    local higherPosY = BOTTOM_Y + BOTTOM_Y
    -- column
    for col, cubes in pairs(_cubeMap) do
        -- row
        for rowIdx = 1, #cubes do
            local cb = cubes[rowIdx]
            if cb.hold and (not cb.isFlashing) and (not cb.beingTarget) and (not cb.isShaking)then
                cubeList[#cubeList+1] = cb
                higherPosY = math.min(higherPosY, cb.posY)
                break
            end
        end
    end
    local newList = {}
    for idx, cb in pairs(cubeList) do
        if cb.posY <= higherPosY then
            newList[#newList+1] = cb
        end
    end
    local rndNum = randi(#newList)
    return newList[rndNum]
end

function ObjectControl:fallRandomCube(shakeDelay)
    local cube = self:getTargetCube()
    if not cube then return end
    -- shake and release
    self:shakeAndReleaseCube(cube,shakeDelay)
end

function ObjectControl:shakeAndReleaseCube(cube,shakeDelay,speed)
    local samples = {}
    local sample_count = 500
    for i = 1, sample_count do samples[i] = 2*love.math.random()-1 end
    local idx = 1
    cube.isShaking = true
    cube.speed = speed or CUBE_INIT_SPEED
    delayTimer:every(FRM, function()
        cube.offsetX = (samples[idx] or 0) * 4
        idx = idx + 1
        cube.offsetY = (samples[idx] or 0) * 4
        idx = idx + 1
        return samples[idx]
    end)
    delayTimer:after(shakeDelay, function()
        cube.hold = false
        cube.isShaking = false
        idx = sample_count
    end)
end

function ObjectControl:shakeAndReleaseCubeRV(cube,shakeDelay)
    local samples = {}
    local sample_count = 500
    for i = 1, sample_count do samples[i] = 2*love.math.random()-1 end
    local idx = 1
    cube.isShaking = true
    cube.speed = CUBE_REVERSE_SPEED
    delayTimer:every(FRM, function()
        cube.offsetX = (samples[idx] or 0) * 4
        idx = idx + 1
        cube.offsetY = (samples[idx] or 0) * 4
        idx = idx + 1
        return samples[idx]
    end)
    delayTimer:after(shakeDelay, function()
        cube.hold = false
        cube.isShaking = false
        idx = sample_count
    end)
end

function ObjectControl:fallRandomCubeRV(shakeDelay)
    local cube = self:getTargetCubeRV()
    if not cube then return end
    -- shake and release
    self:shakeAndReleaseCubeRV(cube,shakeDelay)
end

function ObjectControl:moveAllHoldCubes()
    local lowestY = 0 - BOTTOM_Y
    -- column
    for col, cubes in pairs(_cubeMap) do
        -- row
        for rowIdx, cb in ipairs(cubes) do
            if cb.hold then
                lowestY = math.max(lowestY, cb.posY)
            end
        end
    end
    local moveDelta = 14
    if lowestY < 0 then
        -- moveDelta = 0 - lowestY
        moveDelta = 0 - CUBE_HEI*0.4 - lowestY
    end
    -- column
    for col, cubes in pairs(_cubeMap) do
        -- row
        for rowIdx, cb in ipairs(cubes) do
            if cb.hold then
                cb.posY = cb.posY + moveDelta
            end
        end
    end
end

function ObjectControl:moveAllHoldCubesRV()
    local highestY = BOTTOM_Y + BOTTOM_Y
    -- column
    for col, cubes in pairs(_cubeMap) do
        -- row
        for rowIdx, cb in ipairs(cubes) do
            if cb.hold then
                highestY = math.min(highestY, cb.posY)
            end
        end
    end
    local moveDelta = 6
    if highestY > BOTTOM_Y then
        moveDelta = highestY - (BOTTOM_Y - CUBE_HEI/2)
    end
    -- column
    for col, cubes in pairs(_cubeMap) do
        -- row
        for rowIdx, cb in ipairs(cubes) do
            if cb.hold then
                cb.posY = cb.posY - moveDelta
            end
        end
    end
end

function ObjectControl:_moveCubeUpdateRV()
    local canMove, lowerCube
    -- column
    for col, cubes in pairs(_cubeMap) do
        -- row
        for rowIdx, cb in ipairs(cubes) do
            if cb.hold ~= true then
                canMove, calibration, higherCube = self:_canCubeMoveUp(cb, rowIdx)
                if canMove then
                    cb.posY = cb.posY - cb.speed
                else
                    if cb.isStatic == false then
                        self:strechCubeH(cb)
                        Signal.emit(SG.CUBE_STATIC)
                    end
                    -- calibration
                    if higherCube then
                        cb.posY = higherCube.posY + CUBE_HEI
                        higherCube.speed = cb.speed
                    elseif calibration then
                        cb.posY = calibration
                    end
                    cb.isStatic = true
                end
            end
        end
    end
end

function ObjectControl:_moveCubeUpdate()
    local canMove, lowerCube
    -- column
    for col, cubes in pairs(_cubeMap) do
        -- row
        for rowIdx, cb in ipairs(cubes) do
            if cb.hold ~= true then
                canMove, calibration, lowerCube = self:_canCubeMoveDown(cb, rowIdx)
                if canMove then
                    cb.posY = cb.posY + cb.speed
                else
                    if cb.isStatic == false then
                        self:strechCubeH(cb)
                        Signal.emit(SG.CUBE_STATIC)
                    end
                    -- calibration
                    if lowerCube then
                        cb.posY = lowerCube.posY - CUBE_HEI
                        lowerCube.speed = cb.speed
                    elseif calibration then
                        cb.posY = calibration
                    end
                    cb.isStatic = true
                end
            end
        end
    end
end

function ObjectControl:_canCubeMoveUp(cubeData, rowIdx)
    if cubeData.col < 1 or cubeData.col > LIMIT_COL then
        return true
    elseif cubeData.matched then
        return false
    elseif cubeData.isStatic then
        return false
    -- elseif cubeData.posY <= 0 then
    --     return false, 0
    else
        local higherIdx = rowIdx - 1
        local colList = getColList(cubeData.col)
        local higherCube = colList and colList[higherIdx]
        if higherCube then
            if cubeData.posY - CUBE_HEI <= higherCube.posY then
                return false, higherCube.posY + CUBE_HEI, higherCube
            end
        end
    end
    return true
end

function ObjectControl:_canCubeFall(cube, rowIdx)
    local lowerIdx = rowIdx + 1
    local colList = getColList(cube.col)
    local lowerCube = colList and colList[lowerIdx]
    if lowerCube and lowerCube.isStatic then
        if cube.posY + CUBE_HEI >= lowerCube.posY then
            return false
        end
    end
    return true
end

function ObjectControl:_canCubeMoveDown(cubeData, rowIdx)
    if cubeData.col < 1 or cubeData.col > LIMIT_COL then
        return true
    elseif cubeData.matched then
        return false
    elseif cubeData.isStatic then
        return false
    elseif cubeData.posY + CUBE_HEI >= BOTTOM_Y then
        return false, BOTTOM_Y - CUBE_HEI
    else
        local lowerIdx = rowIdx + 1
        local colList = getColList(cubeData.col)
        local lowerCube = colList and colList[lowerIdx]
        if lowerCube then
            if cubeData.posY + CUBE_HEI >= lowerCube.posY then
                return false, lowerCube.posY - CUBE_HEI, lowerCube
            end
        end
    end
    return true
end

function ObjectControl:_canCubeAwakeRV(cubeData, rowIdx)
    if cubeData.matched then
        return false
    elseif cubeData.posY - CUBE_HEI < 0 then
        return false
    else
        local higherIdx = rowIdx - 1
        local colList = getColList(cubeData.col)
        local higherCube = colList and colList[higherIdx]
        if higherCube then
            if cubeData.posY - CUBE_HEI <= higherCube.posY then
                return false
            end
        end
    end
    return true
end

function ObjectControl:_canCubeAwake(cubeData, rowIdx)
    if cubeData.matched then
        return false
    elseif cubeData.posY + CUBE_HEI >= BOTTOM_Y then
        return false
    else
        local lowerIdx = rowIdx + 1
        local colList = getColList(cubeData.col)
        local lowerCube = colList and colList[lowerIdx]
        if lowerCube then
            if cubeData.posY + CUBE_HEI >= lowerCube.posY then
                return false
            end
        end
    end
    return true
end

function ObjectControl:getDiffColor(column)
    local basket = {1,2,3,4}
    local colList = getColList(column)
    local cubeData = colList[1]
    basket[_lastColorIdx] = nil
    if cubeData then
        basket[cubeData.colorIdx] = nil
    end
    local newBasket = {}
    for _, v in pairs(basket) do
        newBasket[#newBasket+1] = v
    end
    
    _lastColorIdx = newBasket[randi(#newBasket)]
    return _lastColorIdx
end

function ObjectControl:sideMoveCar(side)
    local targetCol = _carData.col + side
    local looping = false
    if targetCol < 0 then
        looping = true
        targetCol = 5
    elseif targetCol > 5 then
        looping = true
        targetCol = 0
    end

    local result = self:checkPunchCube(_carData.gridPosY, targetCol, side)
    if result ~= MOVE_RZ.MOVE then
        return
    end
    if looping then
        Signal.emit(SG.CAR_LOOP, side)
    end
    Signal.emit(SG.CAR_MOVE, getCarPosX(_carData.col) + CAR_SP_OFFSET.X, _carData.gridPosY)
    self:playCar("move")
    self:carSpriteSide(side)
    _carData.col = targetCol
    _carData.posX = getCarPosX(targetCol)
end

function ObjectControl:checkPunchCube(gridPosY, targetCol, side)
    local colList = getColList(targetCol)
    local rangeUpper = gridPosY + CAR_COLLIDE_SIZE.UPPER
    local rangeLower = gridPosY + CAR_COLLIDE_SIZE.LOWER
    if colList then
        for rowIdx, cube in ipairs(colList) do
            if cube.posY >= rangeUpper and cube.posY <= rangeLower then
                if cube.isStatic then
                    self:sideMoveCube(cube, side)
                    return MOVE_RZ.BLOCK
                else
                    self:sideMoveCube(cube, side)
                    return MOVE_RZ.PUNCH
                end
            end
        end
    end
    return MOVE_RZ.MOVE
end

function ObjectControl:resetCarData(inputC,inputR)
    local col = inputC or 4
    local row = inputR or 4
    _carData = {
        col = col,
        row = row,
        posX = getCarPosX(col),
        posY = getCarPosY(row),
        gridPosY = getPosY(row),
        invincible = false,
        draw = true;
        scaleX = 2,
        scaleY = 2,
    }
end

function ObjectControl:getCarData()
    return _carData
end

return ObjectControl