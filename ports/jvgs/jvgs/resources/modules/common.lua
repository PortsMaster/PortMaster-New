module("common", package.seeall)

function isPlayer(entity)
    return entity:getId() == "player"
end

function isDead(entity)
    if entity:isSet("health") then
        return tonumber(entity:get("health")) <= 0
    else
        return false
    end
end

function damage(entity, amount)
    if entity:isSet("health") then
        entity:set("health", entity:get("health") - amount)
    end
end

function gameOver()
    local lm = jvgslua.LevelManager_getInstance()
    lm:queueLevel("resources/level-main-menu/main-menu.xml")
end

function nextLevel(fileName)
    local pm = jvgslua.PersistenceManager_getInstance()
    pm:set("level", fileName)
    local lm = jvgslua.LevelManager_getInstance()
    lm:queueLevel(fileName)
end

function continue()
    local pm = jvgslua.PersistenceManager_getInstance()
    local fileName
    if pm:isSet("level") then
        fileName = pm:get("level")
    else
        fileName = "resources/level-intro/level.xml"
    end

    local lm = jvgslua.LevelManager_getInstance()
    lm:queueLevel(fileName)
end

function dispose(entity)
    entity:setPosition(jvgslua.Vector2D(-100000, -100000)) 
end
