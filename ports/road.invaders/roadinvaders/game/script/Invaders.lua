local Invaders = {}

local triTimer
local triSP1, triRedSP1, triSP2, triRedSP2, warnLine
local objList = { }
local isAttacking = false
local drawWarn = false
local flashing = false

function Invaders:enter()
    triTimer:clear()
    objList = {}
    isAttacking = false
    drawWarn = false
    flashing = false
end

function Invaders:init()
    triSP1 = newSprite("tri_sheet_love","org")
    triRedSP1 = newSprite("tri_sheet_love","org")
    triSP2 = newSprite("tri_sheet_love","org")
    triSP2:setFrame(2)
    triRedSP2 = newSprite("tri_sheet_love","org")
    triRedSP2:setFrame(2)
    triTimer = Timer.new()
    warnLine = love.graphics.newImage("image/warn_line.png")
end

function Invaders:new(col, row)
    local UID = getUID()
    local obj = {
        col = col,
        row = row,
        posX = getPosX(col),
        posY = getPosY(row),
        scaleX = 2,
        scaleY = 2,
        tag = "org",
        uid = UID,
        hp = 2,
        spIdx = col%2==0 and 1 or 2,
    }
    return obj
end

local blockDelay = 2
function Invaders:block(col)
    local row = 8
    local newObj = self:new(col, 11)
    objList[newObj.uid] = newObj
    triTimer:after(love.math.random() * 0.3, function()
        triTimer:tween(blockDelay, newObj, {row = row, posY = getPosY(row)}, 'out-elastic')
    end)
    triTimer:after(blockDelay, function()
        triTimer:tween(blockDelay, newObj, {row = row, posY = getPosY(0)}, 'out-elastic')
    end)
end

function Invaders:uprising(col)
    local delay = 3
    local row = 11
    local newObj = self:new(col, 0)
    objList[newObj.uid] = newObj
    triTimer:after(love.math.random() * 0.1, function()
        triTimer:tween(delay, newObj, {row = row, posY = getPosY(row)}, 'in-expo')
        triTimer:after(delay, function()
            objList[newObj.uid] = nil
        end)
    end)
end

local showDelay = 1.5
function Invaders:attack(col, row)
    local newObj = self:new(col, row + 1)
    objList[newObj.uid] = newObj
    triTimer:after(love.math.random() * 0.3, function()
        triTimer:tween(showDelay, newObj, {row = row, posY = getPosY(row)}, 'out-elastic')
    end)
    local startCol = row
    triTimer:every(6.4, function()
        triTimer:tween(showDelay, newObj, {row = startCol, posY = getPosY(startCol)}, 'out-elastic')
        startCol = startCol - 0.5
        if newObj.posY > 40 then
            self:warningLine()
        end
        return objList[newObj.uid]
    end)
end

function Invaders:warningLine()
    if drawWarn then return end
    drawWarn = true
    triTimer:every(0.2, function()
        flashing = not flashing
        return drawWarn
    end)
end

function Invaders:checkHitInvaders(col, posY)
    for _, obj in pairs(objList) do
        if obj.hp > 0 and obj.col == col then
            local rangeUpper = obj.posY - CUBE_HEI
            local rangeLower = obj.posY + CUBE_HEI
            if posY >= rangeUpper and posY <= rangeLower then
                if obj.hp == 2 then
                    obj.hp = obj.hp - 1
                    obj.tag = "red"
                    Signal.emit(SG.HIT_MONSTER, obj.posX+8, obj.posY)
                elseif obj.hp == 1 then
                    triTimer:after(0.1, function()
                        self:removeObj(obj)
                    end)
                end
                return true
            end
        end
    end
    return false
end

function Invaders:removeObj(obj)
    Signal.emit(SG.TRI_EXPLODE, obj.posX+8, obj.posY)
    objList[obj.uid] = nil
    -- clear all
    if not next(objList) then
        if isAttacking == false then
            Signal.emit(SG.CLEAR_ALL_INVADERS)
        end
    end
end

function Invaders:draw()
    resetColor()
    if drawWarn and flashing then
        love.graphics.draw(warnLine,0,-20,0,2,2)
    end
    for i, obj in pairs(objList) do
        if obj.spIdx == 1 then
            if obj.tag == "red" then
                triRedSP1:setTag(obj.tag)
                triRedSP1:draw(obj.posX, obj.posY, 0,
                        obj.scaleX, obj.scaleY)
            else
                triSP1:setTag(obj.tag)
                triSP1:draw(obj.posX, obj.posY, 0,
                        obj.scaleX, obj.scaleY)
            end
        else
            if obj.tag == "red" then
                triRedSP2:setTag(obj.tag)
                triRedSP2:draw(obj.posX, obj.posY, 0,
                        obj.scaleX, obj.scaleY)
            else
                triSP2:setTag(obj.tag)
                triSP2:draw(obj.posX, obj.posY, 0,
                        obj.scaleX, obj.scaleY)
            end
        end
    end
end

function Invaders:checkAttackCar(posX, posY)
    if isAttacking then return end
    local goAttack = false
    for _, obj in pairs(objList) do
        if obj.posY > (posY-35) then
            goAttack = true
            break
        end
    end
    if not goAttack then return end
    isAttacking = true
    Signal.emit(SG.PRE_GAME_OVER)
    triTimer:clear()
    for _, obj in pairs(objList) do
        triTimer:after(love.math.random()*0.5, function()
            triTimer:tween(1.3, obj, {posX = posX, posY = posY}, 'in-expo')
            triTimer:after(1.3, function()
                objList[obj.uid] = nil
                Signal.emit(SG.CUBE_EXPLODE, obj.posX, obj.posY)
            end)
        end)
    end
    triTimer:after(1.7, function()
        Signal.emit(SG.CAR_CRASH)
    end)
end

function Invaders:update(dt)
    triTimer:update(dt)
    triSP1:update(dt)
    triSP2:update(dt)
    triRedSP1:update(dt)
    triRedSP2:update(dt)
end

return Invaders