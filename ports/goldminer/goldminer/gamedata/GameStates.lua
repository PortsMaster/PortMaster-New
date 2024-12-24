levels = require 'levels'
require 'props'

menu = {}
showHighScore = {}
showNewHighScore = {}
showNextGoal = {}
showMadeGoal = {}
shop = {}
game = {}
gameOver = {}

local start = 0
local highScore = 1

function menu:init()
    self.arrowPos = {
        x = 0,
        y = 0
    }
    self.startPos = {
        x = 5,
        y = 152
    }
    self.highScorePos = {
        x = 5,
        y = 172
    }
    -- Init persistentData
    persistentData = {}
    persistentData.highScore = 0
    persistentData.highLevel = 1

    -- Load saved data to persistentData if file exists.
    if love.filesystem.getInfo("savedata.txt") then
        file = love.filesystem.read("savedata.txt")
        persistentData = lume.deserialize(file)
    end
end

function menu:enter()
    player = Player(idleAnimation)
    self.arrowState = start
end 

function menu:keypressed(key)
    if key == 'up' then self.arrowState = math.max(start, self.arrowState - 1)
    elseif key == 'down' then self.arrowState = math.min(self.arrowState + 1, highScore)
    elseif key == 'return' or key == 'enter' or key == 'k' then
        if self.arrowState == start then
            -- Start game
            Gamestate.switch(showNextGoal)
        elseif self.arrowState == highScore then
            -- Show high score
            Gamestate.switch(showHighScore)
        end
    end
end

function menu:update()
    -- Update arrow state
    if self.arrowState == start then
        self.arrowPos = self.startPos
    elseif self.arrowState == highScore then
        self.arrowPos = self.highScorePos
    end
end

function menu:draw()
    push:start()
    -- Draw BG
    love.graphics.draw(backgrounds['Menu'])

    -- Draw menu text
    local startGameText = love.graphics.newText(uiFont, {COLOR_YELLOW, 'Start Game'})
    local highScoreText = love.graphics.newText(uiFont, {COLOR_YELLOW, 'High Score'})
    local devInfoText = love.graphics.newText(infoFont, {COLOR_YELLOW, 'Made with LÖVE. Developed by Lazy_V.'})
    love.graphics.draw(startGameText, 30, 150)
    love.graphics.draw(highScoreText, 30, 170)
    love.graphics.draw(devInfoText, 75, 225)

    -- Draw arrow
    love.graphics.draw(sprites['MenuArrow'], self.arrowPos.x, self.arrowPos.y)
    push:finish()
end

function showHighScore:keypressed(key)
    Gamestate.switch(menu)
end

function showHighScore:draw()
    push:start()
    -- Draw BG
    love.graphics.draw(backgrounds['Goal'])

    -- Draw title
    love.graphics.draw(sprites['Title'], VIRTUAL_WIDTH / 2 - sprites['Title']:getWidth() / 2, 20)

    -- Draw panel
    love.graphics.draw(sprites['Panel'], VIRTUAL_WIDTH / 2 - sprites['Panel']:getWidth() / 2, 80)

    -- Draw high score text
    local highScoreText = love.graphics.newText(uiFont, {COLOR_YELLOW, 'High Score:', COLOR_GREEN, '\n\n$' .. persistentData.highScore, COLOR_YELLOW, ' at Level' .. persistentData.highLevel })
    love.graphics.draw(highScoreText, 70, 100)
    push:finish()
end

function showNewHighScore:keypressed(key)
    Gamestate.switch(menu)
end

function showNewHighScore:draw()
    push:start()
    -- Draw BG
    love.graphics.draw(backgrounds['Goal'])
    
    -- Draw title
    love.graphics.draw(sprites['Title'], VIRTUAL_WIDTH / 2 - sprites['Title']:getWidth() / 2, 20)
    
    -- Draw panel
    love.graphics.draw(sprites['Panel'], VIRTUAL_WIDTH / 2 - sprites['Panel']:getWidth() / 2, 80)
    
    -- Draw high score text
    local newHighScoreText = love.graphics.newText(uiFont, {COLOR_YELLOW, 'New High Score:', COLOR_GREEN, '\n\n$' .. persistentData.highScore, COLOR_YELLOW, ' at Level' .. persistentData.highLevel })
    love.graphics.draw(newHighScoreText, 70, 100)
    push:finish()
end

function showNextGoal:init()
    self.firstInit = true
end

function showNextGoal:enter()
    -- Set goal text
    if self.firstInit then 
        self.goalTextContent = 'Your First Goal is'
        self.firstInit = false
    else 
        self.goalTextContent = 'Your Next Goal is'
    end

    player:updateGoal()

    -- Play goal bgm
    musics['Goal']:play()
end 

function showNextGoal:update()
    if not musics['Goal']:isPlaying() then
		Gamestate.switch(game)
	end
end 

function showNextGoal:draw()
    push:start()
    -- Draw BG
    love.graphics.draw(backgrounds['Goal'])

    -- Draw title
    love.graphics.draw(sprites['Title'], VIRTUAL_WIDTH / 2 - sprites['Title']:getWidth() / 2, 20)

    -- Draw panel
    love.graphics.draw(sprites['Panel'], VIRTUAL_WIDTH / 2 - sprites['Panel']:getWidth() / 2, 80)

    -- Draw next goal text
    local nextGoalText = love.graphics.newText(uiFont, {COLOR_YELLOW, self.goalTextContent, COLOR_GREEN, '\n\n$' .. player.goal})
    love.graphics.draw(nextGoalText, 70, 100)
    push:finish()
end

function showMadeGoal:enter()
    -- Init timer
    self.timer = 0.5
    -- Increase player level
    player.level = player.level + 1
    local realLevel = 0
    if player.level <= 3 then
        realLevel = player.level
    else
        realLevel = (player.level - 3) % 7 + 3
    end
    player.realLevelStr = 'L' .. realLevel .. '_' .. math.random(1, 3)
    -- Init goal text
    self.goalTextContent = 'You made it to\nthe next Level!'
    -- Play goal bgm
    musics['MadeGoal']:play()
end 

function showMadeGoal:update(dt)
    if not musics['MadeGoal']:isPlaying() then
        self.timer = self.timer - dt
	end

    if self.timer <= 0 then
        Gamestate.switch(shop)
    end
end

function showMadeGoal:draw()
    push:start()
    -- Draw BG
    love.graphics.draw(backgrounds['Goal'])

    -- Draw title
    love.graphics.draw(sprites['Title'], VIRTUAL_WIDTH / 2 - sprites['Title']:getWidth() / 2, 20)

    -- Draw panel
    love.graphics.draw(sprites['Panel'], VIRTUAL_WIDTH / 2 - sprites['Panel']:getWidth() / 2, 80)

    -- Draw made goal text
    local madeGoalText = love.graphics.newText(uiFont, {COLOR_YELLOW, self.goalTextContent})
    love.graphics.draw(madeGoalText, 90, 110)
    push:finish()
end 

function shop:enter()
    -- Init items and start pos
    self.items = {}
    self.itemsStartBottomPos = vector(30, 176)

    -- Init selector
    self.selectorInfo = {}
    self.selectorIndex = 1

    -- Generate random shop items(props)
    local itemIndex = 1
    for propIndex, prop in ipairs(props) do
        -- Random price
        propsConfig[prop].price = propsConfig[prop].getPrice(player.level)
        propsConfig[prop].pos = self.itemsStartBottomPos + vector((propIndex - 1) * SHOP_ITEM_PADDING, 0)
        local add = (math.random(1, 3) >= 2)
        if add then
            self.selectorInfo[itemIndex] = prop
            table.insert(self.items, prop)
            itemIndex = itemIndex + 1
        end
    end
    -- Ensure the shop has items.
    if #self.items == 0 then
        propsConfig['Dynamite'].price = propsConfig['Dynamite'].getPrice(player.level)
        propsConfig['Dynamite'].pos = self.itemsStartBottomPos
        self.selectorInfo[1] = 'Dynamite'
        table.insert(self.items, 'Dynamite')
    end

    -- Init shopkeeper's animation state
    self.shopkeeperAnimation = shopkeeperIdleAnimation

    -- Init dialogue text
    self.defaultDialogueTextContent = 'Press Left and Right to select.\nPress A/Start to buy.\nPress Select when you are ready.'
    self.dialogueTextContent = self.defaultDialogueTextContent

    -- Init finish shopping timer
    self.finishShoppingTimer = 1.5

    -- Init misc state
    self.isPlayerFinishShopping = false
    self.isPlayerBought = false
end

function shop:keypressed(key)
    if key == 'space' then
        -- Finish shopping
        self.isPlayerFinishShopping = true
    elseif key == 'k' or key == 'return' or key == 'enter' then
        -- Buy prop
        local prop = self.items[self.selectorIndex]
        if prop  ~= nil and not self.isPlayerFinishShopping then
            if player.money >= propsConfig[prop].price then
                self.isPlayerBought = true
                if sounds['Money']:isPlaying() then
                    sounds['Money']:stop()
                end
                sounds['Money']:play()
                -- Decrease player's money
                player.money = player.money - propsConfig[prop].price
                player.money4View = player.money4View - propsConfig[prop].price
                -- Take effect
                propsConfig[prop].effect(player)
                -- Remove
                table.remove(self.items, self.selectorIndex)
                table.remove(self.selectorInfo, self.selectorIndex)
                self.selectorIndex = 1
            else
                self.dialogueTextContent = "You don't seem to have any money\n:("
            end
        end
    elseif key == 'left' then
        self.selectorIndex = math.max(1, self.selectorIndex -1) 
    elseif key == 'right' then
        self.selectorIndex = math.min(self.selectorIndex + 1, #self.items)
    end
end

function shop:update(dt)
    self.shopkeeperAnimation:update(dt)

    if #self.items <= 0 then
        self.isPlayerFinishShopping = true
    end

    if self.isPlayerFinishShopping then
        if not self.isPlayerBought then
            self.dialogueTextContent = '  :('
            self.shopkeeperAnimation = shopkeeperSadAnimation
        else
            self.dialogueTextContent = 'Thank you for your patronage!\nGood luck!'
        end
        -- Start timer
        self.finishShoppingTimer = self.finishShoppingTimer - dt

        -- Times up, then switch to ShowNextGoal state.
        if self.finishShoppingTimer <= 0 then
            Gamestate.switch(showNextGoal)
        end
    end 
end 

function shop:draw()
    push:start()
    -- Draw BG
    love.graphics.draw(backgrounds['Shop'])

    -- Draw title
    love.graphics.draw(sprites['Title'], VIRTUAL_WIDTH / 2 - sprites['Title']:getWidth() / 2, 5)

    -- Draw dialogue bubble and texts
    love.graphics.draw(sprites['DialogueBubble'], 25, 70)
    local dialogueText = love.graphics.newText(gameFont, {COLOR_BLACK, self.dialogueTextContent})
    love.graphics.draw(dialogueText, 30, 75)

    -- Draw Shopkeeper
    love.graphics.draw(shopkeeperSheet, shopkeeperQuads[self.shopkeeperAnimation:getCurrentFrame()], 220, 100)

    -- Draw Table
    love.graphics.draw(sprites['Table'], 7, 176)

    -- Draw shop items
    for itemIndex, item in ipairs(self.items) do 
        love.graphics.draw(sprites[item], propsConfig[item].pos.x, propsConfig[item].pos.y, 0, 1, 1, sprites[item]:getWidth() / 2, sprites[item]:getHeight())
        local itemPriceText = love.graphics.newText(gameFont, {COLOR_GREEN, '$' .. propsConfig[item].price})
        love.graphics.draw(itemPriceText, tointeger(propsConfig[item].pos.x - sprites[item]:getWidth() / 2), propsConfig[item].pos.y + 3)
    end

    -- Draw selector and description
    if self.selectorInfo[self.selectorIndex] ~= nil and not self.isPlayerFinishShopping then
        local prop = propsConfig[self.selectorInfo[self.selectorIndex]]
        love.graphics.draw(sprites['Selector'], prop.pos.x, 130, 0, 1, 1, sprites['Selector']:getWidth() / 2, sprites['Selector']:getHeight())
        local propDescriptionText = love.graphics.newText(infoFont, {COLOR_YELLOW, prop.description})
        love.graphics.draw(propDescriptionText, 25, 195)
    end
    push:finish()
end

function game:enter()
    -- Init entities
    self.entities = {}
    
    -- Init timers
    self.timer = 61

    -- Init hook
    hook = Hook()

    -- Reset player animation
    player.currentAnimation = playerIdleAnimation

    -- Sync player state
    player:syncView()

    -- Load level
    levels.loadLevel(player.realLevelStr, self.entities)

    -- Init misc
    self.isShowBonus = false
    self.isShowStrength = false
    self.showBonusTimer = 1
    self.showStrengthTimer = 1
end

function game:leave()
    player:reset()
end 

function game:keypressed(key)
    if key == 'down' or key == 'k' then
        if not hook.isShowBonus and not hook.isGrabing then
            hook.isGrabing = true
            sounds['GrabStart']:play()
        end
    elseif key == 'up' or key == 'u' then
        player:tryUseDynamite()
    elseif key == 'space' then
        if player:reachGoal()  then
            Gamestate.switch(showMadeGoal)
        elseif DEBUG_MODE then
            Gamestate.switch(gameOver)
        end
    -- Cheat
    elseif DEBUG_MODE then
        if key == 'v' then
            player.money4View = player.goal
            player.money = player.goal
        elseif key == '1' then
            player:addDynamite()
        elseif key == '2' then
            player.hasStrengthDrink = not player.hasStrengthDrink
        elseif key == '3' then
            player.hasLuckyClover = not player.hasLuckyClover
        elseif key == '4' then
            player.hasRockCollectorsBook = not player.hasRockCollectorsBook
        elseif key == '5' then
            player.hasGemPolish = not player.hasGemPolish
        elseif key == 'c' then
            persistentData.highScore = 0
            persistentData.highLevel = 1
            love.filesystem.remove("savedata.txt")
        end
    end
end

function game:update(dt)
    -- Update player
    player:update(dt)

    -- Update hook
    hook:update(dt)

    -- Update entities
    for entityIndex, entity in ipairs(self.entities) do
        entity:update(dt)
    end 

    -- Update timer
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.timer = 0
        -- Times up, if player doesn't reach goal, then game over.
        -- Otherwise player reaches goal, switch to ShowMadeGoal state.
        if player:reachGoal() then
            Gamestate.switch(showMadeGoal)
        else
            Gamestate.switch(gameOver)
        end
    end

    if self.isShowBonus then
        self.showBonusTimer = self.showBonusTimer - dt
        if self.showBonusTimer <= 0 then
            self.showBonusTimer = 1
            self.isShowBonus = false
        end
    end

    if self.isShowStrength then
        player.currentAnimation = playerStrengthenAnimation
        self.showStrengthTimer = self.showStrengthTimer - dt
        if self.showStrengthTimer <= 0 then
            self.showStrengthTimer = 1
            self.isShowStrength = false
            player.currentAnimation = playerIdleAnimation
        end
    end
end

function game:draw()
    push:start()
    -- Draw BGs
    love.graphics.draw(backgrounds['LevelCommonTop'])
    love.graphics.draw(backgrounds[levels[player.realLevelStr].type], 0, 40)

    -- Draw UI texts
    local moneyText = love.graphics.newText(gameFont, {COLOR_DEEP_ORANGE, 'Money', COLOR_GREEN, ' $' .. player.money4View})
    love.graphics.draw(moneyText, 5, 5)
    local goalText = love.graphics.newText(gameFont, {COLOR_DEEP_ORANGE, 'Goal', COLOR_GREEN, ' $' .. player.goal})
    love.graphics.draw(goalText, 11, 15)
    local timeText = love.graphics.newText(gameFont, {COLOR_DEEP_ORANGE, 'Time: ', COLOR_ORANGE, tointeger(self.timer)})
    love.graphics.draw(timeText, 260, 15)
    local levelText = love.graphics.newText(gameFont, {COLOR_DEEP_ORANGE, 'Level: ', COLOR_ORANGE, player.level})
    love.graphics.draw(levelText, 250, 25)
    if player:reachGoal() then
        local reachGoalTipText = love.graphics.newText(gameFont, {COLOR_ORANGE, 'Press Select to Exit'})
        love.graphics.draw(reachGoalTipText, 200, 5)
    end
    if self.isShowBonus then
        local bonusText = love.graphics.newText(gameFontBig, {COLOR_GREEN, '$' .. player.currentBonus})
        love.graphics.draw(bonusText, 90, 18)
    end
    if self.isShowStrength then
        love.graphics.draw(sprites['Strength!'], 80, 10)
    end
    -- Render player
    player:render()

    -- Render entities
    for entityIndex, entity in ipairs(self.entities) do
        entity:render()
    end 

    -- Render dynamites
    if player.dynamiteCount >= 1 then
        for i = 1, player.dynamiteCount do
            love.graphics.draw(sprites['DynamiteUI'], propsConfig['Dynamite'].uiPos[i].x, propsConfig['Dynamite'].uiPos[i].y)
        end
    end

    -- Render hook
    hook:render()
    push:finish()
end

function gameOver:enter()
    -- Init game over text
    self.gameOverTextContent = "You didn't reach the goal!"
end 

function gameOver:keypressed(key)
    if player.money > persistentData.highScore then
        persistentData.highScore = player.money
        persistentData.highLevel = player.level
        serialized = lume.serialize(persistentData)
        love.filesystem.write("savedata.txt", serialized)
        Gamestate.switch(showNewHighScore)
    else
        Gamestate.switch(menu)
    end
end

function gameOver:draw()
    push:start()
    -- Draw BG
    love.graphics.draw(backgrounds['Goal'])

    -- Draw title
    love.graphics.draw(sprites['Title'], VIRTUAL_WIDTH / 2 - sprites['Title']:getWidth() / 2, 20)

    -- Draw panel
    love.graphics.draw(sprites['Panel'], VIRTUAL_WIDTH / 2 - sprites['Panel']:getWidth() / 2, 80)

    -- Draw gameOver text
    local gameOverText = love.graphics.newText(uiFont, {COLOR_YELLOW, self.gameOverTextContent})
    love.graphics.draw(gameOverText, 50, 130)
    push:finish()
end 