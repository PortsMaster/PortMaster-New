local music1Range = {3,14}
local music2Range = {14,33}
local music3Range = {33,41}

local tutorialMoveText = "Arrow Keys to Move\nor\na/d to move"
local tutorialJumpText = "Space or Z to Jump\nor\n\nU to jump"
local tutorialSlashText = "X or I to slash\nnearby enemies"
local tutorialDashText1 = "Press C or O to dash"
local tutorialDashText2 = "Dash while holding Up and Right arrow to dash diagonally"
local tutorialDashText3 = "Dash while holding\nup arrow to dash\nvertically"
local tutorialDashResetText = "Slashing refills your dash"

local controllerMoveText = "Left stick or\nd-pad to move"
local controllerJumpText = "A to Jump"
local controllerSlashText = "X or RB to slash\nnearby enemies"
local controllerDashText1 = "B or LB to dash"
local controllerDashText2 = "Dash while holding Up and Right to dash diagonally"
local controllerDashText3 = "Dash while holding\nupwards to dash\nvertically"

local levelTitleMapping = {
    {3,"1-0"},
    {4,"1-1"},
    {5,"1-2"},
    {6,"1-3"},
    {7,"1-4"},
    {8,"1-5"},
    {9,"1-6"},
    {10,"1-7"},
    {11,"1-8"},
    {12,"1-9"},
    {13,"2-0"},
    {14,"2-1"},
    {15,"2-2"},
    {16,"2-3"},
    {17,"2-4"},
    {18,"2-5"},
    {19,"2-6"},
    {20,"2-7"},
    {21,"2-8"},
    {22,"2-9"},
    {23,"2-10"},
    {24,"2-11"},
    {25,"3-0"},
    {26,"3-1"},
    {27,"3-2"},
    {28,"3-3"},
    {29,"3-4"},
    {30,"3-5"},
    {31,"3-6"},
    {32,"4-0"},
    {33,"4-1"},
    {34,"4-2"},
    {35,"4-3"},
    {38,"4-4"},
    {39,"4-5"},
    {40,"4-6"},
    {41,"Ending"}
}

function createLevelTitleDrawer(gameState)
    local levelIndex = gameState.levelIndex
    for k = 1,#levelTitleMapping do
        if levelTitleMapping[k][1] == levelIndex then
            -- Don't draw the mapping for cutscenes
            if levelTitleMapping[k][2] == "1-0" or levelTitleMapping[k][2]=="2-0" or levelTitleMapping[k][2]=="3-0"
                or levelTitleMapping[k][2] == "4-0" or levelTitleMapping[k][2] == "Ending" then
                    return
            end
            local titleDrawer = GameObjects.newGameObject(-1,8, windowHeight-8, 0, true, GameObjects.DrawLayers.POSTCAMERA)
            function titleDrawer:draw()
                love.graphics.setColor(0,0,0,0.5)
                love.graphics.rectangle('fill',titleDrawer.x-4, titleDrawer.y-8, 60, 16)
                love.graphics.setColor(1,1,1,0.75)
                love.graphics.print("Level "..levelTitleMapping[k][2], titleDrawer.x, titleDrawer.y)
            end
            break
        end
    end
end

function createFloor(x, y, width, height)
    local floor = GameObjects.newGameObject(-1, x, y, 0, true)
    Collision.addBoxCollider(floor, width, height, Collision.Layers.FLOOR, {})
    function floor:draw()
        love.graphics.setColor(1,1,1,1)
        if not enableTiles then
            love.graphics.rectangle('fill', x-width/2, y-height/2, width, height)
        end
    end
    return floor
end

function createEnemyDoor(x, y, width, height, enemy)
    local floor = GameObjects.newGameObject(-1, x, y, 0, true)
    Collision.addBoxCollider(floor, width, height, Collision.Layers.FLOOR, {})
    function floor:draw()
        love.graphics.setColor(1,0,1,1)
        love.graphics.rectangle('fill', x-width/2, y-height/2, width, height)
    end
    table.insert(enemy.deactivators, floor)
    return floor
end

function createKillbox(x, y, width, height)
    local killbox = GameObjects.newGameObject(-1, x, y, 0, true)
    killbox.reallyKill = true
    Collision.addBoxCollider(killbox, width, height, Collision.Layers.TRIGGER, {})
    function killbox:draw()
        love.graphics.setColor(1,0,0,1)
        if not enableTiles then
            love.graphics.rectangle('fill', x-width/2, y-height/2, width, height)
        end
    end
    killbox.onPlayerEnter = 
        function(plr)
            plr.die(true)
        end
    return killbox
end

function createNextRoomBox(x, y, width, height, gameState, transitionX, transitionY)
    local nextRoomBox = GameObjects.newGameObject(-1, x, y, 0, true)
    nextRoomBox.transitionDirection = {x=transitionX, y=transitionY}
    Collision.addBoxCollider(nextRoomBox, width, height, Collision.Layers.TRIGGER, {})
    nextRoomBox.entered = false
    nextRoomBox.onPlayerEnter = 
        function(plr)
            if not nextRoomBox.entered then
                plr.gameState.roomTransition.x = -nextRoomBox.transitionDirection.x
                plr.gameState.roomTransition.y = -nextRoomBox.transitionDirection.y
                nextRoomBox.entered = true
                nextRoomBox.plr = plr
                nextRoomBox:startCoroutine(nextRoomBox.entryFunction, "entryFunction")
            end
        end
    nextRoomBox.entryFunction =
        function()
            if nextRoomBox.plr then
                nextRoomBox.plr:setInactive()
            end
            levelTransitionRectangle(gameState, nextRoomBox.transitionDirection)
        end
    return nextRoomBox
end

function readMap(map, gameState)
    local player
    local nextRoomBox
    local spawnerDependent = {}
    local doors = {}
    -- get the player first always
    for i,layer in ipairs(map.layers) do
        if layer.name == "Player" then
            player = createPlayer(layer.objects[1].x, layer.objects[1].y, gameState)
        end
    end
    for i,layer in ipairs(map.layers) do
        if layer.name == "Floors" then
            for ii,floor in ipairs(layer.objects) do
                createFloor(floor.x+floor.width/2, floor.y+floor.height/2, floor.width, floor.height)
            end
        end
        if layer.name == "SpawnerDependent" then
            for iit,dep in ipairs(layer.objects) do
                local depObj
                if dep.type == "Floor" then
                    depObj = createFloor(dep.x+dep.width/2, dep.y+dep.height/2, dep.width, dep.height)
                elseif dep.type == "BasicEnemy" then
                    depObj = createBasicEnemy(dep.x, dep.y, gameState)
                    depObj.active = false
                end
                table.insert(spawnerDependent, depObj)
            end
        end
        if layer.name == "Enemies" then
            local enemyList = {}
            local launcherDirectionList = {}
            local enemyBounds = {}
            local shieldSources = {}
            for iii,enemy in ipairs(layer.objects) do
                if enemy.type == "BasicEnemy" then
                    if enemy.properties.directed then
                        enemyList[enemy.id] = createBasicEnemy(enemy.x, enemy.y, gameState, nil, enemy.properties.directed, {x=enemy.properties.dirX, y=enemy.properties.dirY})
                    else
                        enemyList[enemy.id] = createBasicEnemy(enemy.x, enemy.y, gameState)
                    end
                elseif enemy.type == "EnemyLauncherDirection" then
                    launcherDirectionList[enemy.id] = enemy
                elseif enemy.type == "ShooterEnemyBound" then
                    enemyBounds[enemy.id] = enemy
                elseif enemy.type == "ShieldSource" then
                    shieldSources[enemy.id] = createShieldingEnemy(enemy.x, enemy.y, nil, gameState)
                end
            end
            local enemyWaves = {}
            local alertedEnemies = {}
            -- Iterate over the enemies again to collect dependent items
            for iii,enemy in ipairs(layer.objects) do
                if enemy.type == "EnemyPath" then
                    local enemyToLink = enemyList[enemy.properties.LinkedEnemy.id]
                    local speed = enemy.properties.Speed
                    local bound1 = {x=enemy.polyline[1].x + enemy.x,y=enemy.polyline[1].y + enemy.y}
                    local bound2 = {x=enemy.polyline[2].x + enemy.x, y=enemy.polyline[2].y + enemy.y}
                    setMovementBetweenBounds(enemyToLink, speed, nil, bound1, bound2)
                elseif enemy.type == "EnemyLauncher" then
                    local launcherDir = launcherDirectionList[enemy.properties.direction.id]
                    local vx = launcherDir.x - enemy.x
                    local vy = launcherDir.y - enemy.y
                    createEnemyLauncher(enemy.x, enemy.y, vx, vy, enemy.properties.speed, gameState)
                elseif enemy.type == "ShooterEnemy" then
                    local leftBound = enemyBounds[enemy.properties.leftBound.id]
                    local rightBound = enemyBounds[enemy.properties.rightBound.id]
                    local centerBound = enemyBounds[enemy.properties.centerBound.id]
                    local currentShooter = createShooterEnemy(enemy.x, enemy.y, player, gameState, leftBound, rightBound, centerBound, enemy.properties.maxHP, enemy.properties.startingState)
                    if not enemyWaves[enemy.properties.waveIndex] then
                        enemyWaves[enemy.properties.waveIndex] = {}
                    end
                    table.insert(enemyWaves[enemy.properties.waveIndex], currentShooter)
                elseif enemy.type == "AlertedEnemy" then
                    local alertedEnemy = createAlertedEnemy(enemy.x, enemy.y, player, gameState)
                    alertedEnemy.shieldSource = shieldSources[enemy.properties.shieldSource.id]
                    alertedEnemy.shieldSource.parent = alertedEnemy
                    alertedEnemy.shieldVisuals = createEnemyShieldVisuals(alertedEnemy, alertedEnemy.shieldSource)
                    alertedEnemy.shieldVisuals:setActive()
                    alertedEnemies[enemy.id] = alertedEnemy
                elseif enemy.type == "MissileEnemy" then
                    local missileEnemy = createMissileEnemy(enemy.x, enemy.y, player, gameState)
                    alertedEnemies[enemy.id] = missileEnemy
                elseif enemy.type == "BlastingEnemy" then
                    local blastingEnemy = createBlastingEnemy(enemy.x, enemy.y, player, gameState)
                    blastingEnemy.shieldSource = shieldSources[enemy.properties.shieldSource.id]
                    blastingEnemy.shieldSource.parent = blastingEnemy
                    blastingEnemy.shieldVisuals = createEnemyShieldVisuals(blastingEnemy, blastingEnemy.shieldSource)
                    blastingEnemy.shieldVisuals:setActive()
                end
            end
            -- Iterate over the enemies ONCE MORE to find dependent things on enemies
            for iilol,enemy in ipairs(layer.objects) do
                if enemy.type == "EnemyDoor" then
                    local dependentEnemy = alertedEnemies[enemy.properties.dependentEnemy.id]
                    createEnemyDoor(enemy.x+enemy.width/2,enemy.y+enemy.height/2,enemy.width,enemy.height, dependentEnemy)
                end
            end
            if #enemyWaves > 0 then
                -- Create an enemy spawner
                createEnemySpawner(enemyWaves, spawnerDependent)
            end
            -- Iterate one more time to get thirdly dependent objects
            for iitt,enemy in ipairs(layer.objects) do
                if enemy.type == "AlertTrigger" then
                    createAlertEnemyTrigger(enemy.x+enemy.width/2, enemy.y+enemy.height/2, enemy.width, enemy.height, alertedEnemies[enemy.properties.alertedEnemy.id])
                end
            end
        end
        if layer.name == "NextRoom" then
            for iv,roomTrigger in ipairs(layer.objects) do
                nextRoomBox = createNextRoomBox(roomTrigger.x+roomTrigger.width/2, roomTrigger.y+roomTrigger.height/2, roomTrigger.width, roomTrigger.height, gameState,roomTrigger.properties.xTransition, roomTrigger.properties.yTransition)
            end
        end
        if layer.name == "Killboxes" then
            for v,killbox in ipairs(layer.objects) do
                createKillbox(killbox.x+killbox.width/2, killbox.y+killbox.height/2, killbox.width, killbox.height, gameState)
            end
        end
        if layer.name == "CameraTriggers" then
            local cameraTargets = {}
            for vi,trigger in ipairs(layer.objects) do
                if trigger.type == "CameraBiasTrigger" then
                    createCameraBiasTrigger(trigger.x+trigger.width/2,trigger.y+trigger.height/2,trigger.width,trigger.height,trigger.properties.xBias,trigger.properties.yBias)
                elseif trigger.type == "CameraTarget" then
                    cameraTargets[trigger.id] = GameObjects.newGameObject(-1,trigger.x, trigger.y, 0, true)
                elseif trigger.type == "CameraZoomer" then
                    createCameraZoomTrigger(trigger.x+trigger.width/2,trigger.y+trigger.height/2,trigger.width,trigger.height, trigger.properties.zoomLevel)
                elseif trigger.type == "MidpointFollower" then
                    cameraTargets[trigger.id] = createMidpointFollower(trigger.x, trigger.y, player)
                end
            end
            -- iterate again to get dependent triggers
            for vic,trigger in ipairs(layer.objects) do
                if trigger.type == "TargetChanger" then
                    createCameraTargetChangerTrigger(trigger.x+trigger.width/2,trigger.y+trigger.height/2,trigger.width,trigger.height, cameraTargets[trigger.properties.cameraTarget.id])
                end
            end
        end
        if layer.name == "SlashKeyDoors" then
            local door = nil
            local door2 = nil
            for vii,slashDoor in ipairs(layer.objects) do
                if slashDoor.type == "SlashDoor" then
                    door = createSlashDoor(slashDoor.x+slashDoor.width/2, slashDoor.y+slashDoor.height/2,slashDoor.width, slashDoor.height, slashDoor.properties.numLocks)
                    doors[1] = door
                end
            end
            for vii2,slashDoor in ipairs(layer.objects) do
                if slashDoor.type == "SlashDoor2" then
                    door2 = createSlashDoor(slashDoor.x+slashDoor.width/2, slashDoor.y+slashDoor.height/2,slashDoor.width, slashDoor.height, slashDoor.properties.numLocks)
                    doors[2] = door2
                end
            end
            for vii,slashKey in ipairs(layer.objects) do
                if slashKey.type == "SlashKey" then
                    createSlashKey(slashKey.x, slashKey.y, gameState, door, slashKey.properties.keyIndex, slashKey.properties.angle)
                end
            end
            for vii2,slashKey in ipairs(layer.objects) do
                if slashKey.type == "SlashKey2" then
                    createSlashKey(slashKey.x, slashKey.y, gameState, door2, slashKey.properties.keyIndex, slashKey.properties.angle)
                end
            end
        end
        -- -- Tile visuals
        if enableTiles then
            if layer.type == "tilelayer" then
                local textureIndex = 3
                local drawLayer = GameObjects.DrawLayers.BEHINDPLAYER
                local offsetIndex = 0 -- for the second tileset, it's -64 because the previous tileset has 64 tiles
                if layer.name == "Tile Layer 1" then
                    textureIndex = 3
                    drawLayer = GameObjects.DrawLayers.BEHINDPLAYER
                    offsetIndex = 0
                elseif layer.name == "BackgroundTiles" then
                    textureIndex = 6
                    drawLayer = GameObjects.DrawLayers.ABOVEBACKGROUND
                    offsetIndex = 64
                end
                local mapWidth = layer.width
                local tileXYSPR = {}
                mySpritebatch:clear()
                for i = 1,#layer.data do
                    if layer.data[i] ~= 0 then
                        local xCoordinate = ((i - 1) % mapWidth) * 8+4
                        local yCoordinate = math.floor((i-1)/mapWidth) * 8+4
                        table.insert(tileXYSPR, {x=xCoordinate, y=yCoordinate, spr=layer.data[i]-1 - offsetIndex})
                        mySpritebatch:add(tileQuads[layer.data[i]-1 - offsetIndex],xCoordinate, yCoordinate)
                    end
                end
                mySpritebatch:flush()
                local tilemapRenderer = GameObjects.newGameObject(textureIndex, 0, 0, 0, true, drawLayer)
                local tileQuad = love.graphics.newQuad(0,0,0,0,0,0)
                function tilemapRenderer:draw()
                    love.graphics.draw(mySpritebatch, math.floor(tilemapRenderer.x)-4, math.floor(tilemapRenderer.y)-4, 0, 1, 1)
                end
            end
        end
    end
    -- Configure the camera based on the level size
    local constrainX = true
    local constrainY = true
    local mapWidth = map.width * map.tilewidth
    local mapHeight = map.height * map.tileheight

    -- If the map is around the size of the camera in a given dimension,
    -- constrain the camera's movement in that dimension. Otherwise, free it.
    if mapWidth - Camera.width > 16 then
        constrainX = false
    end
    if mapHeight - Camera.height > 16 then
        constrainY = false
    end
    Camera.setTargetFollow(player, constrainX, constrainY)


    -- Since our levels are always right-down, our minX and Y will always be 0
    local minX = 0
    local minY = 0
    -- By default, if our level is exactly 1 screen, our max will also be 0
    local maxX = 0
    local maxY = 0
    if not constrainX then
        maxX = mapWidth - Camera.width
    end
    if not constrainY then
        maxY = mapHeight - Camera.height
    end

    Camera.setBounds(minX, minY, maxX, maxY)
    Camera.jumpToTarget()

    -- Add the starry background
    createStarryBackground()

    -- Do level transition stuff
    if gameState.flashRespawn then
        gameState.flashRespawn = false
        createScreenFlash({1,1,1,1}, 0.5, true, GameObjects.DrawLayers.TOPUI, true)
        Camera.x = player.x - Camera.width / 2
        Camera.y = player.y - Camera.height / 2
    elseif gameState.deathRespawn or (gameState.roomTransition.x == 0 and gameState.roomTransition.y == 0) then
        gameState.deathRespawn = false
        levelTransitionCircleIn(gameState)
    elseif (gameState.roomTransition.x ~= 0 or gameState.roomTransition.y ~= 0) then
        levelTransitionRectangle(gameState, gameState.roomTransition, true)
    end

    -- Play music
    if gameState.levelIndex >= music1Range[1] and gameState.levelIndex < music1Range[2] then
        MusicManager.playTrack("MainLevelsCalm", 0.5)
    elseif gameState.levelIndex >= music2Range[1] and gameState.levelIndex < music2Range[2] then
        MusicManager.playTrack("MainLevelsHype", 0.5)
    elseif gameState.levelIndex >= music3Range[1] and gameState.levelIndex < music3Range[2] then
        MusicManager.playTrack("BossTrack", 0.65)
    end

    -- Draw the level title
    createLevelTitleDrawer(gameState)

    return {player=player, doors=doors}
end

-- Utility function for drawing "hold to X" features
function holdDrawer(text)
    local textWidth = largePicoFont:getWidth(text)
    local holdDrawObj = GameObjects.newGameObject(-1, canvasWidth-textWidth-4, 10, 0, true, GameObjects.DrawLayers.POSTCAMERA)
    holdDrawObj.text = text
    holdDrawObj.holding = false
    holdDrawObj.holdAmount = 0

    function holdDrawObj:draw()
        if holdDrawObj.holding then
            local cachedFont = love.graphics.getFont()
            love.graphics.setFont(largePicoFont)
            love.graphics.setColor(1,1,1)
            love.graphics.print(holdDrawObj.text, holdDrawObj.x, holdDrawObj.y)
            love.graphics.rectangle('fill', holdDrawObj.x, holdDrawObj.y + 16, holdDrawObj.holdAmount * (canvasWidth - holdDrawObj.x), 4)
            love.graphics.setFont(cachedFont)
        end
    end

    return holdDrawObj
end

function createFakePlayer(x, y, gameState)
    local fakePlayer = GameObjects.newGameObject(1, x, y, 0, true, GameObjects.DrawLayers.PLAYER)
    local capeBaseRightOffsets = {
        {x=-1,y=0},
        {x=-1,y=0},
        {x=-1,y=1},
        {x=0,y=1},
        {x=-0,y=1}
    }
    fakePlayer.capeSegments = createFullCape(fakePlayer, capeBaseRightOffsets)
    fakePlayer.capeObj = createCapeObj(fakePlayer)
    Animation.addAnimator(fakePlayer)
    Animation.addAnimation(fakePlayer, {0,1,2,3}, 0.2, 1, true) -- idle
    Animation.addAnimation(fakePlayer, {4,5,6,7,8,9}, 0.1, 2, true) -- run
    fakePlayer.hideCape = 
        function()
            fakePlayer.capeObj:setInactive()
            for k = 1,#fakePlayer.capeSegments do
                fakePlayer.capeSegments[k]:setInactive()
            end
        end
    fakePlayer.showCape = 
        function()
            fakePlayer.capeObj:setActive()
            for k = 1,#fakePlayer.capeSegments do
                fakePlayer.capeSegments[k]:setActive()
            end
        end
    local holdKToSkip = holdDrawer("hold k to skip")
    local titleHolder = holdDrawer("hold t to return to title")
    function fakePlayer:update(dt)
        if fakePlayer.Animator.state == 1 then
            if fakePlayer.Animator.currFrame == 1 then
                fakePlayer.capeSegments[1].offset.y = 0
            elseif fakePlayer.Animator.currFrame == 3 then
                fakePlayer.capeSegments[1].offset.y = 1
            end
        elseif fakePlayer.Animator.state == 2 then
            if fakePlayer.Animator.currFrame == 3 or fakePlayer.Animator.currFrame == 6 then
                fakePlayer.capeSegments[1].offset.y = -1
                fakePlayer.capeSegments[5].offset.y = 0
            else
                fakePlayer.capeSegments[1].offset.y = 0
                fakePlayer.capeSegments[5].offset.y = 1
            end
        end
        if Input.getMappedButtonHeld("skip") then
            holdKToSkip.holding = true
            holdKToSkip.holdAmount = holdKToSkip.holdAmount + dt/3
            if holdKToSkip.holdAmount >= 1 and gameState then
                gameState.flashRespawn = true
                gameState.goToNextLevel()
            end
        else
            holdKToSkip.holding = false
            holdKToSkip.holdAmount = 0
        end
        if Input.getMappedButtonHeld("title") then
            titleHolder.holding = true
            titleHolder.holdAmount = titleHolder.holdAmount + dt/3
            if titleHolder.holdAmount >= 1 then
                gameState.levelIndex = 1
                gameState.loadLevel = true
            end
        else
            titleHolder.holding = false
            titleHolder.holdAmount = 0
        end
    end
    return fakePlayer
end

function createFakeFriend(x, y)
    local friend = GameObjects.newGameObject(4, x, y, 35, false, GameObjects.DrawLayers.PLAYER)
    local capeBaseLeftOffsets = {
        {x=1,y=0},
        {x=1,y=0},
        {x=1,y=1},
        {x=0,y=1},
        {x=-0,y=1}
    }
    friend.capeSegments = createFullCape(friend, capeBaseLeftOffsets)
    function friend:setInactive()
        for k = 1,#friend.capeSegments do
            friend.capeSegments[k]:setInactive()
        end
        friend.active = false
    end
    function friend:setActive()
        for k = 1,#friend.capeSegments do
            friend.capeSegments[k]:setActive()
        end
        friend.active = true
    end
    changeCapeColor(friend.capeSegments, {145/255, 0, 1})
    Animation.addAnimator(friend)
    Animation.addAnimation(friend, {31,32,33,34}, 0.2, 1, true)
    Animation.addAnimation(friend, {35,36,37,38,39,40},0.1,2,true)
    Animation.addAnimation(friend, {42}, 1, 3, true)
    friend.flip = -1
    friend.trailer = createDashTrailer(friend, 4, 10, 0.3, true)
    friend:setInactive()
    function friend:update(dt)
        if friend.Animator.state == 1 then
            if friend.Animator.currFrame == 1 then
                friend.capeSegments[1].offset.y = 0
            elseif friend.Animator.currFrame == 3 then
                friend.capeSegments[1].offset.y = 1
            end
        elseif friend.Animator.state == 2 then
            if friend.Animator.currFrame == 1 then
                friend.capeSegments[2].offset.x = 1
                friend.capeSegments[4].offset.x = 2
            elseif friend.Animator.currFrame == 4 then
                friend.capeSegments[2].offset.x = -1
                friend.capeSegments[4].offset.x = -2
            end
        end
    end
    return friend
end

function titleScreen(gameState)
    gameState.totalNumDeaths = 0
    gameState.learnedDash = false
    gameState.bossCheckpoint = false
    gameState.bossNumDeaths = 0
    MusicManager.playTrack("PostBossTrack", 0.7)
    createScreenFlash({1,1,1,1}, 0.5, true, GameObjects.DrawLayers.TOPUI, true)
    local sideWalls = {}
    local sideWallSprites = {8,16,24}
    for k = 1,60 do
        sideWalls[k] = GameObjects.newGameObject(3, 316, -32+k*8, sideWallSprites[k%3+1], true)
    end

    local sideWalls2 = {}
    local sideWallSprites2 = {12,20,28}
    for k = 1,60 do
        sideWalls2[k] = GameObjects.newGameObject(3, 4, -32+k*8, sideWallSprites2[k%3+1], true)
    end

    local scrollSpeed = -50
    local teleportPosition = -48
    local teleportToPosition = 192

    local sideWallScroller = GameObjects.newGameObject(-1,0,0,0,true)
    function sideWallScroller:update(dt)
        for k = 1,#sideWalls do
            sideWalls[k].y = sideWalls[k].y + dt * scrollSpeed
            sideWalls2[k].y = sideWalls2[k].y + dt * scrollSpeed
            sideWalls[k].y = math.floor(sideWalls[k].y)
            sideWalls2[k].y = math.floor(sideWalls2[k].y)
            if sideWalls[k].y < teleportPosition then
                sideWalls[k].y = teleportToPosition
            end
            if sideWalls2[k].y < teleportPosition then
                sideWalls2[k].y = teleportToPosition
            end
        end
    end

    local fakePlayer = createFakePlayer(320/2, 180 * 2/3 - 16, gameState)
    Animation.addAnimation(fakePlayer, {12,12}, 1.2, 2, true) -- Fall
    Animation.changeAnimation(fakePlayer, 2)
    fakePlayer.trailer = createDashTrailer(fakePlayer, 1, 50, 1, true)
    for k = 1,#fakePlayer.trailer.trailObjs do
        Physics.addRigidBody(fakePlayer.trailer.trailObjs[k], {x=0,y=-100})
    end
    fakePlayer.trailer:trailOnInterval(0.1)
    fakePlayer.capeObj:setInactive()
    function fakePlayer:update(dt)
        fakePlayer.rotation = fakePlayer.rotation + dt*3
        for k = 1,2 do
            fakePlayer.capeSegments[k].offset.x = math.cos(fakePlayer.rotation + math.rad(90)) * 2
            fakePlayer.capeSegments[k].offset.y = math.sin(fakePlayer.rotation + math.rad(90)) * 2
        end
    end
    createStarryBackground()

    gameState.speedrunModeEnabled = false
    gameState.speedrunClock.minutes = 0
    gameState.speedrunClock.seconds = 0
    gameState.speedrunClock.milliseconds = 0
    local titleObj = GameObjects.newGameObject(-1,28,30,0,true)
    titleObj.state = "initial"
    titleObj.selection = "none"
    local spaceToStartObj = createWorldSpaceText(138, 130, "Press Space")
    local startObj = createWorldSpaceText(0, 125, "Start Game", nil, true)
    local levelSelectObj = createWorldSpaceText(0, 145, "Level Select", nil, true)
    local levelSelector = createWorldSpaceText(0, 135, "Level 1-1", nil, true)
    local levelSelectorInstructions = createWorldSpaceText(0, 155, "Space to start\n\n  X to cancel", nil, true)
    local speedRunModeText = createWorldSpaceText(100, 165, "Speedrun Mode", nil, true)

    startObj.alpha = 0
    levelSelectObj.alpha = 0
    levelSelector.alpha = 0
    levelSelectorInstructions.alpha = 0
    speedRunModeText.alpha = 0
    titleObj.levelSelectIndex = 1
    function titleObj:draw()
        love.graphics.setFont(massivePicoFont)
        love.graphics.print("PLANET D4RK", titleObj.x,titleObj.y)
        love.graphics.setFont(picoFont)
        love.graphics.print("by Abhi Sundu", titleObj.x, titleObj.y + 34)
        if titleObj.state == "options" then
            if titleObj.selection == "start" then
                love.graphics.rectangle('line', 60, startObj.y-6, 200, 20)
            elseif titleObj.selection == "levelSelect" then
                love.graphics.rectangle('line', 60, levelSelectObj.y-6, 200, 20)
            elseif titleObj.selection == "speedrun" then
                love.graphics.rectangle('line', 60, speedRunModeText.y-6, 200, 20)
            end
        end
    end
    function titleObj:update(dt)
        if Input.controllerIsConnected then
            spaceToStartObj.text = "Press A"
            levelSelectorInstructions.text = "A to start\n\nX to cancel"
        else
            spaceToStartObj.text = "Press Space"
            levelSelectorInstructions.text = "Space to start\n\n  X to cancel"
        end
        if Input.getMappedButtonPressed("select") then
            SoundManager.playSound("PlayerTalk")
            if titleObj.state == "initial" then
                spaceToStartObj.fade = true
                startObj.fadeIn = true
                levelSelectObj.fadeIn = true
                speedRunModeText.fadeIn = true
                titleObj.state = "options"
                titleObj.selection = "start"
            elseif titleObj.state == "options" then
                if titleObj.selection == "start" then
                    gameState.flashRespawn = true
                    SoundManager.playSound("WhitenBackground")
                    gameState.goToNextLevel()
                elseif titleObj.selection == "levelSelect" then
                    titleObj.state = "levelSelect"
                    startObj.fade = true
                    levelSelectObj.fade = true
                    speedRunModeText.fade = true
                    levelSelectorInstructions:setActive()
                    levelSelector:setActive()
                    levelSelectorInstructions.fadeIn = true
                    levelSelector.fadeIn = true
                elseif titleObj.selection == "speedrun" then
                    gameState.flashRespawn = true
                    SoundManager.playSound("WhitenBackground")
                    gameState.speedrunModeEnabled = true
                    gameState.levelIndex = 4
                    gameState.loadLevel = true
                end
            elseif titleObj.state == "levelSelect" then
                gameState.flashRespawn = true
                SoundManager.playSound("WhitenBackground")
                gameState.levelIndex = levelTitleMapping[titleObj.levelSelectIndex][1]
                if gameState.levelIndex >= 13 then
                    gameState.learnedDash = true
                end
                gameState.loadLevel = true
            end
        end
        if titleObj.state == "options" then
            if Input.getMappedButtonPressed("moveup") then
                if titleObj.selection == "start" then
                    titleObj.selection = "speedrun"
                elseif titleObj.selection == "levelSelect" then
                    titleObj.selection = "start"
                elseif titleObj.selection == "speedrun" then
                    titleObj.selection = "levelSelect"
                end
            elseif Input.getMappedButtonPressed("movedown") then
                if titleObj.selection == "start" then
                    titleObj.selection = "levelSelect"
                elseif titleObj.selection == "levelSelect" then
                    titleObj.selection = "speedrun"
                elseif titleObj.selection == "speedrun" then
                    titleObj.selection = "start"
                end
            end
        end
        if titleObj.state == "levelSelect" then
            if Input.getMappedButtonPressed("moveleft") then
                titleObj.levelSelectIndex = titleObj.levelSelectIndex - 1
                if titleObj.levelSelectIndex <= 0 then
                    titleObj.levelSelectIndex = #levelTitleMapping
                end
            elseif Input.getMappedButtonPressed("moveright") then
                titleObj.levelSelectIndex = titleObj.levelSelectIndex + 1
                if titleObj.levelSelectIndex > #levelTitleMapping then
                    titleObj.levelSelectIndex = 1
                end
            elseif Input.getMappedButtonPressed("attack") then
                titleObj.state = "options"
                startObj:setActive()
                levelSelectObj:setActive()
                speedRunModeText:setActive()
                startObj.fadeIn = true
                levelSelectObj.fadeIn = true
                speedRunModeText.fadeIn = true
                levelSelectorInstructions.fade = true
                levelSelector.fade = true
            end
        end
        levelSelector.text = "Level "..levelTitleMapping[titleObj.levelSelectIndex][2]
    end
end

function fallingCutscene(gameState)
    MusicManager.fadeOut()
    local whiteBackground = createScreenFlash({1,1,1,1}, 30, false, GameObjects.DrawLayers.BACKGROUND, true)
    local plrSpeed = 500
    whiteBackground.coolRoutine = 
        function()
            coroutine.yield(0.5)
            SoundManager.playSound("WhitenBackground")
            local velocityLines = velocityLines(160, 90, math.rad(180), 1200)
            coroutine.yield(0.5)
            SoundManager.playSound("dash")
            local fakePlayer = createFakePlayer(320/2, 0, gameState)
            fakePlayer.hideCape()
            function fakePlayer:update(dt)
                fakePlayer.rotation = fakePlayer.rotation + dt * 10
            end
            fakePlayer.color = {0,0,0}
            Animation.addAnimation(fakePlayer, {11,11}, 0.4, 2, true) -- Fall
            Animation.changeAnimation(fakePlayer, 2)
            fakePlayer.trailer = createDashTrailer(fakePlayer, 1, 50, 1, true)
            fakePlayer.trailer:trailOnInterval(0.1)
            Physics.addRigidBody(fakePlayer, {x=0,y=plrSpeed})
            coroutine.yield(0.16)
            fakePlayer.RigidBody.velocity.y = 0
            for k = 1,#fakePlayer.trailer.trailObjs do
                Physics.addRigidBody(fakePlayer.trailer.trailObjs[k], {x=0,y=-400})
            end
            coroutine.yield(1.5)
            fakePlayer.RigidBody.velocity.y = plrSpeed
            coroutine.yield(0.16)
            fakePlayer.trailer.trailing = false
            coroutine.yield(0.4)
            velocityLines:setInactive()
            coroutine.yield(1)
            gameState.goToNextLevel()
        end
    
    whiteBackground:startCoroutine(whiteBackground.coolRoutine, "coolRoutine")
end



function introCutscene(gameState)
    gameState.flashRespawn = true
    local mapContents = readMap(require("src.Maps.introCutscene"), gameState)
    gameState.flashRespawn = true
    local plr = mapContents.player
    plr:setInactive()

    local fakePlayer = createFakePlayer(plr.x, plr.y, gameState)
    local trailer = createDashTrailer(fakePlayer, 1, 20, 0.4, true, GameObjects.DrawLayers.PLAYER)
    trailer:trailFromTo({x=plr.x, y=0}, {x=plr.x, y=plr.y}, 20)
    Camera.jiggle(0,4)
    ParticleSystem.burst(plr.x, plr.y, 20, 400, 900, {1,1,1,1}, 5, 0.95, 0.8, false, 0.7)

    local walkieTalkie = GameObjects.newGameObject(4, plr.x-12, plr.y - 130, 30, GameObjects.DrawLayers.PLAYER)
    Animation.addAnimator(walkieTalkie)
    Animation.addAnimation(walkieTalkie, {30}, 1, 1, true)
    Animation.addAnimation(walkieTalkie, {29,30}, 0.2, 2, true)

    function walkieTalkieOn()
        SoundManager.playSound("WalkieTalkieOn")
        Animation.changeAnimation(walkieTalkie, 2)
    end

    function walkieTalkieOff()
        Animation.changeAnimation(walkieTalkie, 1)
    end

    function walkieTalkieOver()
        coroutine.yield(3)
        walkieTalkie:setInactive()
        SoundManager.playSound("WalkieTalkieOff")
    end

    walkieTalkie.doOver = 
        function()
            walkieTalkieOn()
            walkieTalkie:startCoroutine(walkieTalkieOver, "over")
        end

    -- Cutscene between player and mission control
    local cutsceneLines = {
        {x=plr.x,y=plr.y - 120,text="find the module. bring it back.",speakerIndex = 2, totalDelay = 2.5, soundMod = 3, preFcn=walkieTalkieOn},
        {x=plr.x,y=plr.y - 20,text = "don't worry. i'll find him.",speakerIndex = 1, totalDelay = 2, preFcn=walkieTalkieOff},
        {x=plr.x,y=plr.y - 120,text = ". . . the module is the top priority.",speakerIndex = 2, totalDelay = 3, soundMod = 3, preFcn=walkieTalkie.doOver},
        {x=plr.x,y=plr.y - 20,text = ". . .",speakerIndex = 1, totalDelay = 1.5},
    }
    local numLines = 4
    local speakerColors = {
        {0,1,1},
        {0.8,0.8,0.8}
    }
    local speakerSounds = {
        "PlayerTalk",
        "MissionControlTalk"
    }
    local cutscene = DialogueSystem.createCutscene(gameState, cutsceneLines, numLines, speakerColors, speakerSounds, 1.5, 1)
    cutscene:runFullCutscene()
end

function introLevel(gameState)
    readMap(require("src.Maps.introCutscene"), gameState)
    createWorldSpaceText(16, 108, Input.controllerIsConnected and controllerMoveText or tutorialMoveText)
    createWorldSpaceText(144, 104, Input.controllerIsConnected and controllerJumpText or tutorialJumpText)
    createWorldSpaceText(80, 76, "Hold Q to enable up-arrow / w to jump")
end

function testLevel(gameState)
    local map = require("src.Maps.level1")
    readMap(map, gameState)
end

function testLevel2(gameState)
    createWorldSpaceText(216, 120, Input.controllerIsConnected and controllerSlashText or tutorialSlashText)
    readMap(require("src.Maps.level2"), gameState)
end

function testLevel3(gameState)
    readMap(require("src.Maps.level3"), gameState)
end

function testLevel4(gameState)
    readMap(require("src.Maps.level4"), gameState)
end

function testLevel5(gameState)
    readMap(require("src.Maps.level5"), gameState)
end

function testLevel6(gameState)
    readMap(require("src.Maps.level6"), gameState)
end

function testLevel7(gameState)
    readMap(require("src.Maps.level7"), gameState)
end

function testLevel8(gameState)
    readMap(require("src.Maps.level8"), gameState)
end

function secondCutscene(gameState)
    -- Skip cutscenes in speedrun mode
    if gameState.speedrunModeEnabled then
        gameState.levelIndex = gameState.levelIndex + 1
        levelOrder[gameState.levelIndex](gameState)
        return
    end
    local mapContents = readMap(require("src.Maps.level9"), gameState)
    mapContents.player:setInactive()
    local fakePlayer = createFakePlayer(mapContents.player.x, mapContents.player.y, gameState)

    local friend = createFakeFriend(160, 160)
    Animation.changeAnimation(friend, 2)
    fakePlayer.friendSpawn = 
        function()
            MusicManager.fadeOut()
            coroutine.yield(1)
            Camera.changeTarget(friend)
            enemySpawnerFX(friend.x, friend.y)
            coroutine.yield(0.8)
            MusicManager.playTrack("FriendEncounter", 0.5)
            friend:setActive()
            coroutine.yield(1.5)
            Camera.changeTarget(GameObjects.newGameObject(-1, (friend.x+fakePlayer.x)/2, (friend.y+fakePlayer.y)/2,0,true))
        end
    fakePlayer.passModule = 
        function()
            SoundManager.playSound("ProjectileShot")
            local text = createWorldSpaceText(24, 216, "Dash Module Acquired")
            text.alpha = 0
            local moduleProjectile = GameObjects.newGameObject(-1, friend.x, friend.y, 0, true)
            function moduleProjectile:draw()
                love.graphics.setColor(1,1,1,1)
                love.graphics.circle('fill', moduleProjectile.x, moduleProjectile.y, 6)
            end
            Physics.addRigidBody(moduleProjectile, {x=-120, y=-200}, {x=0, y=500})
            coroutine.yield(1.15)
            moduleProjectile:setInactive()
            ParticleSystem.burst(fakePlayer.x, fakePlayer.y, 15, 300, 600, {1,1,1,1}, 3, 0.9, 0.8, false, 0.5)
            SoundManager.playSound("unlock")
            text.fadeIn = true
            coroutine.yield(2)
            text.fade = true
        end
        
    function friendSpawnRoutine()
        fakePlayer:startCoroutine(fakePlayer.friendSpawn, "friendSpawn")
    end
    function modulePassRoutine()
        fakePlayer:startCoroutine(fakePlayer.passModule, "passModule")
    end
    function friendDashAway()
        friend.trailer:trailFromTo({x=friend.x,y=friend.y},{x=friend.x,y=friend.y-160},10)
        friend:setInactive()
        SoundManager.playSound("dash")
    end

    -- Cutscene between player and friend
    local cutsceneLines = {
        {x=fakePlayer.x,y=fakePlayer.y,text="",speakerIndex = 1, totalDelay = 4, preFcn=friendSpawnRoutine},
        {x=fakePlayer.x,y=fakePlayer.y - 20,text = "Dude, where have you been?",speakerIndex = 1, totalDelay = 2},
        {x=fakePlayer.x,y=fakePlayer.y - 20,text = "Come back, mission control needs you.",speakerIndex = 1, totalDelay = 3},
        {x=friend.x,y=friend.y - 20,text = "mission control?", letterDelay=0.08, speakerIndex = 2, soundMod=1, totalDelay = 2.5},
        {x=friend.x,y=friend.y - 20,text = "mission control sent\nus here", speakerIndex = 2, totalDelay = 1.5},
        {x=friend.x,y=friend.y - 20,text = "mission control sent\nus here to",speakerIndex = 2, totalDelay = 0.35, fx="shake"},
        {x=friend.x,y=friend.y - 20,text = "mission control sent\nus here to die!",speakerIndex = 2, totalDelay = 1.25, fx="shake"},
        {x=fakePlayer.x,y=fakePlayer.y - 20,text = "They sent me here to bring you back.",speakerIndex = 1, totalDelay = 3},
        {x=friend.x,y=friend.y - 20,text = "are you sure?", letterDelay=0.07, soundMod = 3, speakerIndex = 2, totalDelay = 3},
        {x=friend.x,y=friend.y - 20,text = " ", speakerIndex = 2, totalDelay = 3.5, preFcn = modulePassRoutine},
        {x=friend.x,y=friend.y - 20,text = "cause I think they sent you\nhere for that module.", speakerIndex = 2, totalDelay = 2.5},
        {x=fakePlayer.x,y=fakePlayer.y - 20,text = "we need you too, please.",speakerIndex = 1, totalDelay = 2.75},
        {x=friend.x,y=friend.y - 20,text = "take that dash module and go home.", speakerIndex = 2, totalDelay = 2.25},
        {x=friend.x,y=friend.y - 20,text = "forget about me.", speakerIndex = 2, totalDelay = 2},
        {x=friend.x,y=friend.y - 20,text = " ", speakerIndex = 2, totalDelay = 1, preFcn = friendDashAway},
        {x=fakePlayer.x,y=fakePlayer.y - 20,text = "wait!",speakerIndex = 1, totalDelay = 1.25, fx="shake"},
        {x=fakePlayer.x,y=fakePlayer.y - 20,text = ". . . no way.",speakerIndex = 1, totalDelay = 2.5, preFcn=MusicManager.fadeOut},
        {x=fakePlayer.x,y=fakePlayer.y - 20,text = "I'll bring you back.",speakerIndex = 1, totalDelay = 1.5},
    }
    local numLines = 18
    local speakerColors = {
        {0,1,1},
        {1,0,1}
    }
    local speakerSounds = {
        "PlayerTalk",
        "FriendTalk"
    }
    local cutscene = DialogueSystem.createCutscene(gameState, cutsceneLines, numLines, speakerColors, speakerSounds, 1, 1)
    cutscene:runFullCutscene()
    gameState.flashRespawn = true
end

function testLevel9(gameState)
    gameState.learnedDash = true
    readMap(require("src.Maps.level9"), gameState)
    local txtObj1 = createWorldSpaceText(24, 208, Input.controllerIsConnected and controllerDashText1 or tutorialDashText1)
    local txtObj2 = createWorldSpaceText(80, 164, Input.controllerIsConnected and controllerDashText2 or tutorialDashText2)
    local txtObj3 = createWorldSpaceText(228, 116, Input.controllerIsConnected and controllerDashText3 or tutorialDashText3)
    txtObj3.alpha = 0
    local fadeTrigger = GameObjects.newGameObject(-1, 192, 188, 0, true)
    Collision.addBoxCollider(fadeTrigger, 48, 24, Collision.Layers.TRIGGER, {})
    fadeTrigger.onPlayerEnter = 
        function()
            txtObj1.fade = true
            txtObj2.fade = true
            txtObj3.fadeIn = true
            fadeTrigger:setInactive()
        end
end

function testLevel10(gameState)
    readMap(require("src.Maps.level10"), gameState)
end

function testLevel11A(gameState)
    createWorldSpaceText(80, 272, tutorialDashResetText)
    readMap(require("src.Maps.level11A"), gameState)
end

function testLevel11(gameState)
    readMap(require("src.Maps.level11"), gameState)
end

function testLevel12(gameState)
    readMap(require("src.Maps.level12"), gameState)
end

function testLevel13(gameState)
    readMap(require("src.Maps.level13"), gameState)
end

function testLevel14(gameState)
    readMap(require("src.Maps.level14"), gameState)
end

function testLevel15(gameState)
    readMap(require("src.Maps.level15"), gameState)
end

function testLevel16(gameState)
    readMap(require("src.Maps.level16"), gameState)
end

function testLevel17(gameState)
    -- this level is defunct now, woohoo!
    readMap(require("src.Maps.level17"), gameState)
end

function testLevel17A(gameState)
    readMap(require("src.Maps.level17A"), gameState)
end

function testLevel17B(gameState)
    readMap(require("src.Maps.level17B"), gameState)
end

function thirdCutscene(gameState)
    -- Skip cutscenes in speedrun mode
    if gameState.speedrunModeEnabled then
        gameState.levelIndex = gameState.levelIndex + 1
        levelOrder[gameState.levelIndex](gameState)
        return
    end
    local mapContents = readMap(require("src.Maps.thirdCutscene"), gameState)
    mapContents.player:setInactive()
    local plr = mapContents.player
    local fakePlayer = createFakePlayer(plr.x, plr.y+8, gameState)
    local friend = createFakeFriend(254, 152)
    Animation.changeAnimation(friend, 2)
    local fakeEnemy = GameObjects.newGameObject(4, 208, 152, 10, false)
    Animation.addAnimator(fakeEnemy)
    Animation.addAnimation(fakeEnemy, {10,11,12,13,14,15}, 0.1, 1, true)

    friend.moveCamera =
        function()
            Camera.target = fakeEnemy
        end
    
    friend.moveCameraBack = 
        function()
            Camera.changeTarget(GameObjects.newGameObject(-1, (friend.x+fakePlayer.x)/2, (friend.y+fakePlayer.y)/2,0,true))
        end

    friend.friendDashAway =
        function ()
            friend.trailer:trailFromTo({x=friend.x,y=friend.y},{x=friend.x,y=friend.y-160},10)
            friend:setInactive()
            SoundManager.playSound("dash")
            MusicManager.fadeOut()
        end

    -- Cutscene between player and mission control
    local cutsceneLines = {
        {x=friend.x - 30,y=friend.y-20,text="ever seen these guys before?",speakerIndex = 2, totalDelay = 2.2},
        {x=plr.x - 30,y=plr.y-20,text = "dude get back, it looks dangerous!",speakerIndex = 1, totalDelay = 2.25},
        {x=friend.x - 30,y=friend.y-20,text = "oh yeah, it's dangerous alright.",speakerIndex = 2, totalDelay = 3},
        {x=friend.x - 40,y=friend.y-20,text = "these little guys are all over planet Dark.",speakerIndex = 2, totalDelay = 3.25, preFcn = friend.moveCamera},
        {x=friend.x - 40,y=friend.y-20,text = "mission control knew this place was hostile,\nand they still sent us here.",speakerIndex = 2, totalDelay = 4.5},
        {x=plr.x - 30,y=plr.y-20,text = ". . . that can't be right. . .",speakerIndex = 1, totalDelay = 3, preFcn = friend.moveCameraBack},
        {x=friend.x - 30,y=friend.y-20,text = "use that dash module to leave.",speakerIndex = 2, totalDelay = 2.5},
        {x=friend.x - 30,y=friend.y-20,text = "seriously. forget me.",speakerIndex = 2, totalDelay = 2.5},
        {x=friend.x - 30,y=friend.y-20,text = " ",speakerIndex = 2, totalDelay = 1, preFcn=friend.friendDashAway},
    }
    local numLines = 9
    local speakerColors = {
        {0,1,1},
        {1,0,1}
    }
    local speakerSounds = {
        "PlayerTalk",
        "FriendTalk"
    }
    local cutscene = DialogueSystem.createCutscene(gameState, cutsceneLines, numLines, speakerColors, speakerSounds, 1.5, 1)

    fakePlayer.friendSpawn =
        function()
            coroutine.yield(0.5)
            MusicManager.fadeOut()
            coroutine.yield(0.5)
            Camera.changeTarget(friend)
            Camera.zoomTarget = 2.5
            enemySpawnerFX(friend.x, friend.y)
            coroutine.yield(0.8)
            MusicManager.playTrack("FriendEncounter", 0.5)
            friend:setActive()
            coroutine.yield(0.5)
            enemySpawnerFX(fakeEnemy.x, fakeEnemy.y)
            fakeEnemy:setActive()
            coroutine.yield(1.5)
            Camera.changeTarget(GameObjects.newGameObject(-1, (friend.x+fakePlayer.x)/2, (friend.y+fakePlayer.y)/2,0,true))
            cutscene:runFullCutscene()
        end
    fakePlayer:startCoroutine(fakePlayer.friendSpawn, "friendSpawn")
end

function testLevel18(gameState)
    readMap(require("src.Maps.level18"), gameState)
end

function testLevel19(gameState)
    readMap(require("src.Maps.level19"), gameState)
end

function testLevel20(gameState)
    readMap(require("src.Maps.level20"), gameState)
end

function testLevel20B(gameState)
    readMap(require("src.Maps.level16B"), gameState)
end

function testLevel21(gameState)
    readMap(require("src.Maps.level21"), gameState)
end

function testLevel22(gameState)
    readMap(require("src.Maps.level22"), gameState)
end

function preFinalBossCutscene(gameState)
    -- Skip cutscenes in speedrun mode
    if gameState.speedrunModeEnabled then
        gameState.levelIndex = gameState.levelIndex + 1
        levelOrder[gameState.levelIndex](gameState)
        return
    end
    local mapContents = readMap(require("src.Maps.finalBossPhase0_cutscene"), gameState)
    local plr = mapContents.player
    plr:setInactive()

    local fakePlayer = createFakePlayer(plr.x, plr.y, gameState)
    local friend = createFakeFriend(224, 256)
    Animation.changeAnimation(friend, 2)

    local bossFightBaby = 
        function()
            local sickFX = GameObjects.newGameObject(-1,0,0,0,GameObjects.DrawLayers.UI)
            local whiteFlasher = createScreenFlash({1,1,1,1}, 30, false, GameObjects.DrawLayers.ABOVETILES, true)
            changeCapeColor(friend.capeSegments, {0,0,0})
            Camera.zoomTarget = 2
            SoundManager.playSound("WhitenBackground")
            fakePlayer.color = {0,0,0}
            friend.color = {0,0,0}
            coroutine.yield(1)
            love.graphics.setFont(massivePicoFont)
            local text1 = createWorldSpaceText(184, 192, "BOSS", {0,0,0})
            local rect = createScalingRectangle("horizontal", 224, 100, {0,0,0},0.2, GameObjects.DrawLayers.UI)
            rect.x = 200
            rect.width = 1000
            local lines = velocityLines(224, 192, math.rad(90), 800)
            SoundManager.playSound("DramaticText")
            MusicManager.playTrack("BossTrack", 0.85)
            Camera.shake(5)
            coroutine.yield(0.85)
            local text2 = createWorldSpaceText(176, 304, "FIGHT", {0,0,0})
            local lines2 = velocityLines(224, 304, math.rad(270), 800)
            local rect2 = createScalingRectangle("horizontal", 304, 100, {0,0,0},0.2, GameObjects.DrawLayers.UI)
            rect2.x = 200
            rect2.width = 1000
            SoundManager.playSound("DramaticText")
            Camera.shake(5)
            coroutine.yield(1.5)
            lines:setInactive()
            lines2:setInactive()
            coroutine.yield(0.5)
            fakePlayer.color = {1,1,1}
            friend.color = {1,1,1}
            changeCapeColor(friend.capeSegments, {145/255, 0, 1})
            whiteFlasher:setInactive()
            text1:setInactive()
            text2:setInactive()
            love.graphics.setFont(picoFont)
            Camera.changeTarget(GameObjects.newGameObject(-1, (friend.x+fakePlayer.x)/2, (friend.y+fakePlayer.y)/2,0,true))
            Camera.zoomTarget = 2.5
            createScreenFlash({1,1,1,1}, 0.2, true, GameObjects.DrawLayers.UI, true)
        end
    friend.doCoolSickFX = 
        function()
            friend:startCoroutine(bossFightBaby, "bossFightBaby")
        end

    -- Cutscene between player and friend
    local cutsceneLines = {
        {x=plr.x - 30,y=plr.y-20,text = "dude, stop running away!",speakerIndex = 1, totalDelay = 2.25},
        {x=plr.x - 30,y=plr.y-20,text = "you're being crazy!",speakerIndex = 1, totalDelay = 1.75},
        {x=friend.x - 30,y=friend.y-20,text="too crazy for mission control, huh?",speakerIndex = 2, totalDelay = 2.5},
        {x=plr.x - 30,y=plr.y-20,text = "please come back. i'll explain everything\nto mission control. they need you.",speakerIndex = 1, totalDelay = 4.5},
        {x=friend.x - 8,y=friend.y-20,text = ". . .",speakerIndex = 2, totalDelay = 2, fx="", preFcn=function() Camera.changeTarget(friend) end},
        {x=friend.x - 30,y=friend.y-20,text = "SCREW",speakerIndex = 2, totalDelay = 0.5, fx="shake"},
        {x=friend.x - 30,y=friend.y-20,text = "SCREW MISSION",speakerIndex = 2, totalDelay = 0.5, fx="shake"},
        {x=friend.x - 30,y=friend.y-20,text = "SCREW MISSION CONTROL!",speakerIndex = 2, totalDelay = 1.5, fx="shake"},
        {x=friend.x - 40,y=friend.y-20,text = "it's time for a",speakerIndex = 2, totalDelay = 1.5},
        {x=friend.x - 40,y=friend.y-20,text = " ",speakerIndex = 2, totalDelay = 5, preFcn=friend.doCoolSickFX},
        {x=plr.x - 30,y=plr.y-20,text = "Please, come back. . . I need you.",speakerIndex = 1, totalDelay = 3.25, preFcn = friend.moveCameraBack},
        {x=friend.x - 8,y=friend.y-20,text = ". . .",speakerIndex = 2, totalDelay = 2.05},
        {x=friend.x - 30,y=friend.y-20,text = "screw you too.", letterDelay=0.05, soundMod = 1, speakerIndex = 2, totalDelay = 2}
    }
    local numLines = 13
    local speakerColors = {
        {0,1,1},
        {1,0,1}
    }
    local speakerSounds = {
        "PlayerTalk",
        "FriendTalk"
    }
    local cutscene = DialogueSystem.createCutscene(gameState, cutsceneLines, numLines, speakerColors, speakerSounds, 1.5, 0.85)

    fakePlayer.friendSpawn =
        function()
            coroutine.yield(0.5)
            MusicManager.fadeOut()
            coroutine.yield(0.5)
            Camera.changeTarget(friend)
            Camera.zoomTarget = 2.5
            enemySpawnerFX(friend.x, friend.y)
            coroutine.yield(0.8)
            friend:setActive()
            coroutine.yield(1.5)
            Camera.changeTarget(GameObjects.newGameObject(-1, (friend.x+fakePlayer.x)/2, (friend.y+fakePlayer.y)/2,0,true))
            cutscene:runFullCutscene()
            gameState.flashRespawn = true
        end
    fakePlayer:startCoroutine(fakePlayer.friendSpawn, "friendSpawn")
end

function finalBossPhase1(gameState)
    MusicManager.setVolume(0.65)
    local mapContents = readMap(require("src.Maps.finalBossPhase1"), gameState)
    local boss = createFinalBossPhase1(224, 224, mapContents.player, gameState)
end

function finalBossPhase2(gameState)
    local mapContents = readMap(require("src.Maps.finalBossPhase2"), gameState)
    local boss = createFinalBossPhase2(224, 176, mapContents.player, gameState)
end

function finalBossPhase3(gameState)
    local mapContents = readMap(require("src.Maps.finalBossPhase3"), gameState)
    local boss = createFinalBossPhase3(224, 224, mapContents.player, gameState)
    
    function createSlashFakeDoor(x, y, width, height)
        local door = GameObjects.newGameObject(-1, x, y, 0, true)
        Collision.addBoxCollider(door, width, height, Collision.Layers.FLOOR, {})
        function door:draw()
            love.graphics.setColor(38/255,219/255,1)
            love.graphics.rectangle('line', door.x-width/2,door.y-height/2,width,height)
            love.graphics.setColor(0,0,0,1)
            love.graphics.rectangle('fill', door.x-width/2+1,door.y-height/2+1,width-2,height-2)
        end
        return door
    end
    mapContents.doors[1].dependent = createSlashFakeDoor(116, 104, 8, 48)
    mapContents.doors[2].dependent = createSlashFakeDoor(364, 104, 8, 48)
end

function finalBossPhase3Transition1(gameState)
    -- Skip cutscenes in speedrun mode
    if gameState.speedrunModeEnabled then
        gameState.levelIndex = gameState.levelIndex + 1
        levelOrder[gameState.levelIndex](gameState)
        return
    end
    local mapContents = readMap(require("src.Maps.finalBossPhase3Transition"), gameState)
    local plr = mapContents.player
    plr:setInactive()
    local fakePlayer = createFakePlayer(plr.x, plr.y, gameState)

    local fakeWalls = {}
    local sprites = {8,10,12}
    for k = 1,8 do
        for k2 = 1,3 do
            table.insert(fakeWalls, GameObjects.newGameObject(3, 412 + k2*8, 316+k*8,sprites[k2],true, GameObjects.DrawLayers.ABOVETILES))
        end
    end
    local friend = createFakeFriend(240, 200)
    Animation.changeAnimation(friend, 2)

    friend.escapeCutscene = 
        function()
            SoundManager.playSound("WhitenBackground")
            Camera.zoomTarget = 2
            Camera.changeTarget(GameObjects.newGameObject(-1,240,280,0,true))
            coroutine.yield(1)
            Camera.changeTarget(friend)
            coroutine.yield(1)
            friend.trailer:trailFromTo({x=friend.x,y=friend.y},{x=376,y=344},10)
            friend.x = 376
            friend.y = 344
            SoundManager.playSound("dash")
            coroutine.yield(1)
            Camera.changeTarget(GameObjects.newGameObject(-1,friend.x,friend.y,0,true))
            friend.trailer:trailFromTo({x=friend.x,y=friend.y},{x=friend.x+250,y=friend.y},10)
            friend.x = friend.x+250
            SoundManager.playSound("explosion")
            createCircularPop(424, 352, {1,1,1},30, 150, 1, 0.2, 0.15, true)
            ParticleSystem.burst(424, 352, 20, 400, 900, {1,1,1,1}, 5, 0.95, 0.85, false, 0.5)
            Camera.shake(5)
            for k = 1,#fakeWalls do
                fakeWalls[k]:setInactive()
            end
            coroutine.yield(1)
            Camera.resetTarget()
            Camera.zoomTarget = 3
            coroutine.yield(1)
            gameState.flashRespawn = true
            gameState.goToNextLevel()
        end
    friend:setActive()
    friend:startCoroutine(friend.escapeCutscene, "escapeCutscene")
end

function finalBossPhase3Transition2(gameState)
    readMap(require("src.Maps.finalBossPhase3Transition"), gameState)
end

function finalBossTalkingPhase(gameState)
    local mapContents = readMap(require("src.Maps.finalBossTalkingPhase"), gameState)
    local friend =  createBossObj(168,96,gameState)
    friend.trailer = createDashTrailer(friend, 4, 10, 0.3, true)
    friend.hitCount = 0

    local laserHitbox = GameObjects.newGameObject(-1, friend.x+150, -30, 0, true, GameObjects.DrawLayers.ABOVETILES)
    Collision.addBoxCollider(laserHitbox, 80, 600, Collision.Layers.TRIGGER, {})
    laserHitbox.onPlayerEnter =
        function(plr)
            plr.die(true)
        end
    laserHitbox.totalTime = 0
    laserHitbox.baseWidth = 80
    laserHitbox.width = laserHitbox.baseWidth
    function laserHitbox:update(dt)
        laserHitbox.totalTime = laserHitbox.totalTime + dt
        laserHitbox.width = laserHitbox.baseWidth + math.sin(laserHitbox.totalTime * 5) * 8
    end
    function laserHitbox:draw()
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle('fill', laserHitbox.x-laserHitbox.width/2, laserHitbox.y, laserHitbox.width, 600)
        love.graphics.setColor(1,0,1,1)
        love.graphics.rectangle('line', laserHitbox.x-laserHitbox.width/2, laserHitbox.y, laserHitbox.width, 600)
    end

    local friendLocations = {
        {352,56},
        {544,72},
        {752,88}
    }
    friend.locationIndex = 1

    local cutsceneLines = {
        {x=friend.x - 50, y=friend.y-30,text="this mission was a death sentence.",speakerIndex = 1, totalDelay = 2.5},
        {x=friendLocations[1][1] - 50, y=friendLocations[1][2] - 30,text = "they don't care about us.",speakerIndex = 1, totalDelay = 2},
        {x=friendLocations[2][1] - 50, y=friendLocations[2][2] - 30,text = "they sent us here to die",speakerIndex = 1, totalDelay = 3},
        {x=friendLocations[3][1] - 50, y=friendLocations[3][2] - 30,text = "YOU'RE",speakerIndex = 1, totalDelay = 1.5, fx="shake"},
        {x=friendLocations[3][1] - 50, y=friendLocations[3][2] - 30,text = "YOU'RE NOT",speakerIndex = 1, totalDelay = 1.5, fx="shake"},
        {x=friendLocations[3][1] - 50, y=friendLocations[3][2] - 30,text = "YOU'RE NOT LISTENING",speakerIndex = 1, totalDelay = 1.5, fx="shake"},
    }
    local numLines = 6
    local speakerColors = {
        {1,0,1}
    }
    local speakerSounds = {
        "FriendTalk"
    }
    local cutscene = DialogueSystem.createCutscene(gameState, cutsceneLines, numLines, speakerColors, speakerSounds, 1.5, 1)

    friend.go = 
        function()
            coroutine.yield(0.5)
            cutscene:typeNextLine()
        end
    
    friend.goNext =
        function()
            friend.trailer:trailFromTo({x=friend.x,y=friend.y},{x=friendLocations[friend.locationIndex][1],y=friendLocations[friend.locationIndex][2]},10)
            friend.x = friendLocations[friend.locationIndex][1]
            friend.y = friendLocations[friend.locationIndex][2]
            laserHitbox.x = friend.x + 150
            cutscene:typeNextLine()
            friend.locationIndex = friend.locationIndex + 1
        end
    friend.leave =
        function()
            laserHitbox:setInactive()
            friend.goNext()
            coroutine.yield(0.6)
            cutscene:typeNextLine()
            coroutine.yield(0.6)
            cutscene:typeNextLine()
            coroutine.yield(1.5)
            friend.trailer:trailFromTo({x=friend.x,y=friend.y},{x=friend.x+150,y=friend.y},10)
            friend.x = friend.x + 150
            cutscene:setInactive()
        end

    function friend:takeDamage()
        friend.hitCount = friend.hitCount + 1
        if friend.hitCount >= 3 then
            friend.canBeSlashed = false
            friend:startCoroutine(friend.leave, "leave")
        else
            friend.goNext()
        end
    end
    
    friend:startCoroutine(friend.go, "go")
end

function finalBossPhase4(gameState)
    local mapContents = readMap(require("src.Maps.finalBossPhase4"), gameState)
    local launcher1 = createEnemyLauncher(72, 110, 1, 0, 45, gameState)
    local launcher2 = createEnemyLauncher(30, 200, 1, 0, 45, gameState)
    local launcher3 = createEnemyLauncher(72, 290, 1, 0, 45, gameState)
    launcher1:setInactive()
    launcher2:setInactive()
    launcher3:setInactive()
    local bossOffset = 280
    local boss = createFinalBossPhase4(30+bossOffset, 200, mapContents.player, gameState)

    -- checkpoint
    local anchorCheckpointX = 1406
    if gameState.bossCheckpoint then
        -- Spawn the player at the checkpoint
        launcher1.x = anchorCheckpointX + launcher1.x
        launcher2.x = anchorCheckpointX + launcher2.x
        launcher3.x = anchorCheckpointX + launcher3.x
        boss.x = anchorCheckpointX + boss.x
        mapContents.player.x = 1664
        mapContents.player.y = 208
        boss.state = 3
        local checkpointText = createWorldSpaceText(1648, 180, "Checkpoint")
        checkpointText.fadeOutEventually =
        function()
            coroutine.yield(2)
            checkpointText.fade = true
        end
        checkpointText:startCoroutine(checkpointText.fadeOutEventually, "fadeEventually")
    else
        -- Create the checkpoint
        local checkpoint = GameObjects.newGameObject(-1, 1668, 200, 0, true)
        Collision.addBoxCollider(checkpoint, 56, 400, Collision.Layers.TRIGGER, {})
        local checkpointText = createWorldSpaceText(1648, 180, "Checkpoint")
        checkpointText.fadeOutEventually =
            function()
                coroutine.yield(2)
                checkpointText.fade = true
            end
        checkpointText.alpha = 0
        checkpoint.onPlayerEnter = 
            function(plr)
                checkpointText.fadeIn = true
                plr.gameState.bossCheckpoint = true
                checkpointText:startCoroutine(checkpointText.fadeOutEventually, "fadeEventually")
                checkpoint:setInactive()
            end
    end



    local coroutineObj = GameObjects.newGameObject(-1,0,0,0,true)
    function coroutineObj:update(dt)
        if coroutineObj.target then
            coroutineObj.x = coroutineObj.target.x + bossOffset
            coroutineObj.y = coroutineObj.target.y
            if Camera.target.midX then
                Camera.target.midX = coroutineObj.x
                Camera.target.midY = coroutineObj.y
            end
        end
        if coroutineObj.x > 2750 then
            if launcher1.currentEnemy then
                launcher1.currentEnemy:setInactive()
            end
            if launcher2.currentEnemy then
                launcher2.currentEnemy:setInactive()
            end
            if launcher3.currentEnemy then
                launcher3.currentEnemy:setInactive()
            end
        end
    end
    coroutineObj.start = 
        function()
            coroutine.yield(1)
            launcher1.takeDamage()
            launcher2.takeDamage()
            launcher3.takeDamage()
            coroutineObj.target = launcher2.currentEnemy
            Camera.target = createMidpointFollower(launcher2.currentEnemy.x + bossOffset, launcher2.currentEnemy.y, mapContents.player)
            boss:go()
        end
    coroutineObj:startCoroutine(coroutineObj.start, "start")
end

function finalBossPhase5(gameState)
    local mapContents = readMap(require("src.Maps.finalBossPhase5"), gameState)
    local plr = mapContents.player
    local boss = createFinalBossPhase5(284, 688, gameState, plr)
end

function postBossCutscene(gameState)
    MusicManager.stop()
    gameState.flashRespawn = true
    local mapContents = readMap(require("src.Maps.postBossCutscene"), gameState)
    Camera.zoomTarget = 2.75
    local plr = mapContents.player
    plr:setInactive()
    local fakePlayer = createFakePlayer(plr.x, plr.y, gameState)
    local friend = createFakeFriend(240, plr.y)
    local midpointTarget = GameObjects.newGameObject(-1, 200, plr.y, 0, true)
    Camera.changeTarget(midpointTarget)
    friend:setActive()
    SoundManager.playSound("WhitenBackground")
    createScreenFlash({1,1,1,1}, 4, true, GameObjects.DrawLayers.UI, true)

    fakePlayer.hug = 
        function()
            Camera.changeTarget(fakePlayer)
            coroutine.yield(1)
            Animation.changeAnimation(fakePlayer, 2)
            Physics.addRigidBody(fakePlayer)
            fakePlayer.RigidBody.velocity.x = 60
            coroutine.yield(1.25)
            fakePlayer.RigidBody.velocity.x = 0
            fakePlayer.alpha = 0
            Animation.changeAnimation(friend, 3)
            friend.flip = 1
            Animation.changeAnimation(fakePlayer, 1)
            SoundManager.playSound("land")
            fakePlayer.hideCape()
        end
    fakePlayer.endHug = 
        function()
            fakePlayer.alpha = 1
            fakePlayer.x = fakePlayer.x - 8
            Animation.changeAnimation(friend, 1)
            friend.flip = -1
            fakePlayer.showCape()
        end
    fakePlayer.hugRoutine = 
        function()
            fakePlayer:startCoroutine(fakePlayer.hug, "hug")
        end
    
    local cutsceneLines
    local numLines

    if gameState.speedrunModeEnabled then
        cutsceneLines = {
            {x=fakePlayer.x - 16,y=fakePlayer.y - 20,text = "what is this?",speakerIndex = 1, totalDelay = 2},
            {x=friend.x - 16,y=friend.y - 20,text = "i don't know, some kind of speedrun?", speakerIndex = 2, totalDelay = 3},
            {x=fakePlayer.x - 16,y=fakePlayer.y - 20,text = "I guess so.",speakerIndex = 1, totalDelay = 2},
            {x=fakePlayer.x - 16,y=fakePlayer.y - 20,text = "i'm hard-coded to hug you.",speakerIndex = 1, totalDelay = 2.5},
            {x=friend.x,y=friend.y - 20,text = "nice", speakerIndex = 2, totalDelay = 1},
            {x=fakePlayer.x - 16,y=fakePlayer.y - 20,text = " ",speakerIndex = 1, totalDelay = 3.5, preFcn=fakePlayer.hugRoutine},
            {x=friend.x,y=friend.y - 20,text = "good hug.", speakerIndex = 2, totalDelay = 1.5},
            {x=fakePlayer.x + 8,y=fakePlayer.y - 20,text = "yup. ",speakerIndex = 1, totalDelay = 2.5},
            {x=fakePlayer.x + 8,y=fakePlayer.y - 20,text = " ",speakerIndex = 1, totalDelay = 1, preFcn=function() MusicManager.fadeOut(1) end},
        }
        numLines = 9
    else
        cutsceneLines = {
            {x=fakePlayer.x - 16,y=fakePlayer.y - 20,text = "what are we doing?",speakerIndex = 1, totalDelay = 2},
            {x=friend.x - 16,y=friend.y - 20,text = "i don't know. . . ", speakerIndex = 2, totalDelay = 2},
            {x=fakePlayer.x - 16,y=fakePlayer.y - 20,text = "why are we fighting?",speakerIndex = 1, totalDelay = 2},
            {x=friend.x- 16,y=friend.y - 20,text = "I", speakerIndex = 2, totalDelay = 0.6, fx="shake"},
            {x=friend.x- 16,y=friend.y - 20,text = "I DON'T", speakerIndex = 2, totalDelay = 0.9, fx="shake"},
            {x=friend.x- 16,y=friend.y - 20,text = "I DON'T KNOW!", speakerIndex = 2, totalDelay = 1.5, fx="shake", preFcn=function() MusicManager.playTrack("PostBossTrack", 0.7) end},
            {x=fakePlayer.x - 16,y=fakePlayer.y - 20,text = ". . . ",speakerIndex = 1, totalDelay = 2},
            {x=fakePlayer.x - 16,y=fakePlayer.y - 20,text = "talk to me.",speakerIndex = 1, totalDelay = 1.5},
            {x=friend.x- 30,y=friend.y - 20,text = "i'm just. . . \nso angry all the time.", speakerIndex = 2, totalDelay = 3.5, preFcn=function() Camera.changeTarget(friend) end},
            {x=friend.x-30,y=friend.y - 20,text = "we took this job so we could\nhelp people. . . ", speakerIndex = 2, totalDelay = 3},
            {x=friend.x-30,y=friend.y - 20,text = "but we're on some random planet,\nlooking for stuff our boss can sell.", speakerIndex = 2, totalDelay = 4},
            {x=friend.x,y=friend.y - 20,text = "we're nothing.", speakerIndex = 2, totalDelay = 2},
            {x=fakePlayer.x - 16,y=fakePlayer.y - 20,text = " ",speakerIndex = 1, totalDelay = 3.5, preFcn=fakePlayer.hugRoutine},
            {x=fakePlayer.x + 8,y=fakePlayer.y - 20,text = "i'm sorry. . .",speakerIndex = 1, totalDelay = 2},
            {x=friend.x,y=friend.y - 20,text = "not your fault.", speakerIndex = 2, totalDelay = 1.5},
            {x=fakePlayer.x + 8,y=fakePlayer.y - 20,text = "you've been hurting\nthis whole time. . . ",speakerIndex = 1, totalDelay = 2.5},
            {x=fakePlayer.x + 8,y=fakePlayer.y - 20,text = "and i didn't even notice. ",speakerIndex = 1, totalDelay = 2},
            {x=friend.x - 16,y=friend.y - 20,text = ". . . we need to go home, don't we?", speakerIndex = 2, totalDelay = 3.5},
            {x=fakePlayer.x + 8,y=fakePlayer.y - 20,text = "yeah, we do. i'm sorry\ni wasn't there for you.",speakerIndex = 1, totalDelay = 3, preFcn=fakePlayer.endHug},
            {x=friend.x - 16,y=friend.y - 20,text = "if nothing's gonna change,\ni don't wanna to go back.", speakerIndex = 2, totalDelay = 3.5},
            {x=fakePlayer.x + 8,y=fakePlayer.y - 20,text = "things will change.",speakerIndex = 1, totalDelay = 2},
            {x=fakePlayer.x + 8,y=fakePlayer.y - 20,text = "this time, i'll be there for you.",speakerIndex = 1, totalDelay = 3},
            {x=fakePlayer.x + 8,y=fakePlayer.y - 20,text = "from now on,\ni'll always be there for you.",speakerIndex = 1, totalDelay = 3, preFcn=function() MusicManager.fadeOut(1) end},
        }
        numLines = 23
    end

    local speakerColors = {
        {0,1,1},
        {1,0,1}
    }
    local speakerSounds = {
        "PlayerTalk",
        "FriendTalk"
    }
    local cutscene = DialogueSystem.createCutscene(gameState, cutsceneLines, numLines, speakerColors, speakerSounds, 4.5, 1.5)
    cutscene:runFullCutscene()
end

function endingCutscene(gameState)
    -- Skip cutscenes in speedrun mode
    if gameState.speedrunModeEnabled then
        gameState.levelIndex = gameState.levelIndex + 1
        levelOrder[gameState.levelIndex](gameState)
        return
    end
    gameState.flashRespawn = true
    local mapContents = readMap(require("src.Maps.introCutscene"), gameState)
    local plr = mapContents.player
    plr:setInactive()
    local fakePlayer = createFakePlayer(plr.x, plr.y, gameState)
    fakePlayer.flip = -1
    local friend = createFakeFriend(plr.x + 32, plr.y)
    friend.flip = -1
    friend:setActive()
    MusicManager.playTrack("EndingTrack", 0.5)

    local walkieTalkie = GameObjects.newGameObject(4, plr.x-12, plr.y - 130, 30, GameObjects.DrawLayers.PLAYER)
    Animation.addAnimator(walkieTalkie)
    Animation.addAnimation(walkieTalkie, {30}, 1, 1, true)
    Animation.addAnimation(walkieTalkie, {29,30}, 0.2, 2, true)

    function walkieTalkieOn()
        SoundManager.playSound("WalkieTalkieOn")
        Animation.changeAnimation(walkieTalkie, 2)
    end

    function walkieTalkieOff()
        Animation.changeAnimation(walkieTalkie, 1)
    end

    function walkieTalkieOver()
        coroutine.yield(3.5)
        walkieTalkie:setInactive()
        SoundManager.playSound("WalkieTalkieOff")
    end

    walkieTalkie.doOver = 
        function()
            walkieTalkieOn()
            walkieTalkie:startCoroutine(walkieTalkieOver, "over")
        end

    local cutsceneLines = {
        {x=plr.x,y=plr.y - 120,text="well done securing the module.",speakerIndex = 2, totalDelay = 2.5, soundMod = 3, preFcn=walkieTalkieOn},
        {x=plr.x,y=plr.y - 120,text="when we return home, the thief's\nemployment will be terminated.",speakerIndex = 2, totalDelay = 3.5, soundMod = 3, preFcn=walkieTalkie.doOver},
        {x=plr.x,y=plr.y - 20,text = "when we get home. . .",speakerIndex = 1, totalDelay = 2, preFcn=walkieTalkieOff},
        {x=plr.x,y=plr.y - 20,text = "we're quitting.", letterDelay=0.09, soundMod = 1,  speakerIndex = 1, totalDelay = 2.5},
    }

    local numLines = 4
    local speakerColors = {
        {0,1,1},
        {0.8,0.8,0.8}
    }
    local speakerSounds = {
        "PlayerTalk",
        "MissionControlTalk"
    }
    local cutscene = DialogueSystem.createCutscene(gameState, cutsceneLines, numLines, speakerColors, speakerSounds, 2, 1)
    cutscene:runFullCutscene()
end

function endingScreen(gameState)
    MusicManager.playTrack("EndingTrack", 0.6)
    local finalObj = GameObjects.newGameObject(-1,0,0,0,true)
    finalObj.canGoToTitle = false
    finalObj.textScene = 
        function()
            coroutine.yield(1)
            local text1 = createWorldSpaceText(20, 20, "THE END", nil, true)
            text1.alpha = 0
            text1.fadeIn = true
            coroutine.yield(2)
            if gameState.speedrunModeEnabled then
                gameState.speedrunModeEnabled = false
                local text2 = createWorldSpaceText(20, 40, "you took . . . ", nil, true)
                text2.alpha = 0
                text2.fadeIn = true
                coroutine.yield(1)
                local text3 = createWorldSpaceText(20, 60, gameState.speedrunClock.minutes.." min "..gameState.speedrunClock.seconds.." sec "..gameState.speedrunClock.milliseconds.." ms", nil, true)
                text3.alpha = 0
                text3.fadeIn = true
                coroutine.yield(2)
                local text4 = createWorldSpaceText(20, 80, ". . to bring your friend back.", nil, true)
                text4.alpha = 0
                text4.fadeIn = true
            else
                if gameState.totalNumDeaths == 0 then
                    -- Fanfare babyyyy
                    local whiteFlasher = createScreenFlash({1,1,1,1}, 30, false, GameObjects.DrawLayers.ABOVETILES, true)
                    SoundManager.playSound("WhitenBackground")
                    coroutine.yield(1)
                    local lines = velocityLines(128, 60, math.rad(90), 800)
                    local flawlessText = createWorldSpaceText(112, 50, "", {0,0,0}, nil, true)
                    local str = "FLAWLESS"
                    for k = 1,8 do
                        flawlessText.text = string.sub(str, 1, k)
                        SoundManager.playSound("ProjectileShot", 0.5)
                        Camera.shake(3)
                        ParticleSystem.burst(112+k*12, 55, 10, 400, 600, {0,0,0}, 5, 0.9, 0.8, false, 0.2)
                        coroutine.yield(0.2)
                    end
                    coroutine.yield(1)
                    lines:setInactive()
                    local rect = createScalingRectangle("horizontal", 50, 100, {1,1,1},0.15, GameObjects.DrawLayers.UI)
                    rect.width = 1000
                    whiteFlasher:setInactive()
                    ParticleSystem.burst(160, 55, 30, 600, 800, {1,1,1}, 5, 0.95, 0.8, false, 0.6)
                    ParticleSystem.burst(112, 65, 30, 600, 800, {1,1,1}, 5, 0.95, 0.8, false, 0.6)
                    ParticleSystem.burst(208, 65, 30, 600, 800, {1,1,1}, 5, 0.95, 0.8, false, 0.6)
                    SoundManager.playSound("BossFinish1")
                    Camera.jiggle(5, 0)
                    local flawlessLightText = createWorldSpaceText(112, 50, "FLAWLESS", {1,1,1}, nil, true)
                    coroutine.yield(2)
                    local text4 = createWorldSpaceText(20, 90, "you brought your friend back flawlessly.", nil, true)
                    text4.alpha = 0
                    text4.fadeIn = true
                else
                    local text2 = createWorldSpaceText(20, 40, "fell down . .", nil, true)
                    text2.alpha = 0
                    text2.fadeIn = true
                    coroutine.yield(1)
                    local str = "times"
                    if gameState.totalNumDeaths == 1 then
                        str = "time"
                    end
                    local text3 = createWorldSpaceText(20, 60, "0 . . "..str, nil, true)
                    for k = 1,gameState.totalNumDeaths do
                        text3.text = k.." "..str.." . ."
                        SoundManager.playSound("ProjectileShot", 0.5)
                        Camera.shake(1)
                        ParticleSystem.burst(text3.x, text3.y, 5, 300, 600, {1,1,1}, 4, 0.9, 0.85, false, 0.25)
                        if gameState.totalNumDeaths > 50 then
                            coroutine.yield(0.07)
                        else
                            coroutine.yield(0.15)
                        end
                    end
                    text3.text = gameState.totalNumDeaths.." "..str.." . ."
                    coroutine.yield(2)
                    local text4 = createWorldSpaceText(20, 80, ". . to bring your friend back.", nil, true)
                    text4.alpha = 0
                    text4.fadeIn = true
                end
            end
            coroutine.yield(2)
            local textCredit = createWorldSpaceText(20, 110, "Thanks for playing!", nil, true)
            local textCredit2 = createWorldSpaceText(20, 130, "by Abhi Sundu", nil, true)
            if Input.controllerIsConnected then
                local textGo = createWorldSpaceText(20, 150, "press A to return to title", nil, true)
            else
                local textGo = createWorldSpaceText(20, 150, "press space to return to title", nil, true)
            end
            finalObj.canGoToTitle = true
        end

    function finalObj:update(dt)
        if Input.getMappedButtonPressed("select") and finalObj.canGoToTitle then
            gameState.levelIndex = 1
            gameState.loadLevel = true
        end
    end

    finalObj:startCoroutine(finalObj.textScene, "textScene")
end

function oldTestLevel(gameState)
    createPlayer(160, 64, gameState)
    createFloor(160, 180, 160, 16)
    createFloor(190, 160, 16, 40)
    createFloor(190, 60, 16, 40)
    createFloor(120, 140, 60, 16)
    createFloor(240, 120, 16, 200)
    createBasicEnemy(120, 90, gameState)
end