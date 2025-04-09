Gamestate = require 'hump.gamestate'
Class = require 'hump.class'
vector = require 'hump.vector'
lume = require 'lume'
tick = require 'tick'
push = require 'push'
require 'Util'
require 'GameStates'
require 'Animation'

function love.load()
    -- Get our actual screen size.
    local actualWidth = love.graphics.getWidth()
    local actualHeight = love.graphics.getHeight()

    -- Initialize our nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Set FPS
    tick.framerate = 60

    -- Initialize our virtual resolution with pixel perfect scaling
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, actualWidth, actualHeight, {
        vsync = false,
        fullscreen = true,
        resizable = false,
        pixelperfect = false -- Enable pixel perfect scaling
    })
    
    -- Init fonts
    defaultFont = love.graphics.getFont()
    infoFont = love.graphics.newFont('fonts/Pixel-Square-10-1.ttf', 10)
    uiFont = love.graphics.newFont('fonts/Kurland.ttf', 20)
    uiFontMini = love.graphics.newFont('fonts/Kurland.ttf', 10)
    gameFont = love.graphics.newFont('fonts/visitor1.ttf', 10)
    gameFontBig = love.graphics.newFont('fonts/Kurland.ttf', 16)

    love.graphics.setFont(infoFont)

    -- Init Sounds
    sounds = {
        ['Money'] = love.audio.newSource('audios/money.wav', 'static'),
        ['HookReset'] = love.audio.newSource('audios/hook_reset.wav', 'static'),
        ['GrabStart'] = love.audio.newSource('audios/grab_start.mp3', 'static'),
        ['GrabBack'] = love.audio.newSource('audios/grab_back.wav', 'static'),
        ['Explosive'] = love.audio.newSource('audios/explosive.wav', 'static'),
        ['High'] = love.audio.newSource('audios/high_value.wav', 'static'),
        ['Normal'] = love.audio.newSource('audios/normal_value.wav', 'static'),
        ['Low'] = love.audio.newSource('audios/low_value.wav', 'static'),
    }

    -- Init musics
    musics = {
        ['Goal'] = love.audio.newSource('audios/goal.mp3', 'stream'),
        ['MadeGoal'] = love.audio.newSource('audios/made_goal.mp3', 'stream'),
    }

    -- Init backgrounds and sprites with nearest filter applied
    backgrounds = {
        ['Menu'] = love.graphics.newImage('images/bg_start_menu.png'),
        ['LevelCommonTop'] = love.graphics.newImage('images/bg_top.png'),
        ['LevelA'] = love.graphics.newImage('images/bg_level_A.png'),
        ['LevelB'] = love.graphics.newImage('images/bg_level_B.png'),
        ['LevelC'] = love.graphics.newImage('images/bg_level_C.png'),
        ['LevelD'] = love.graphics.newImage('images/bg_level_D.png'),
        ['LevelE'] = love.graphics.newImage('images/bg_level_E.png'),
        ['Goal'] = love.graphics.newImage('images/bg_goal.png'),
        ['Shop'] = love.graphics.newImage('images/bg_shop.png')
    }

    sprites = {
        -- Entities
        ['MiniGold'] = love.graphics.newImage('images/gold_mini.png'),
        ['NormalGold'] = love.graphics.newImage('images/gold_normal.png'),
        ['NormalGoldPlus'] = love.graphics.newImage('images/gold_normal_plus.png'),
        ['BigGold'] = love.graphics.newImage('images/gold_big.png'),
        ['MiniRock'] = love.graphics.newImage('images/rock_mini.png'),
        ['NormalRock'] = love.graphics.newImage('images/rock_normal.png'),
        ['BigRock'] = love.graphics.newImage('images/rock_big.png'),
        ['QuestionBag'] = love.graphics.newImage('images/question_bag.png'),
        ['Diamond'] = love.graphics.newImage('images/diamond.png'),
        ['Skull'] = love.graphics.newImage('images/skull.png'),
        ['Bone'] = love.graphics.newImage('images/bone.png'),
        ['TNT'] = love.graphics.newImage('images/tnt.png'),
        ['TNT_Destroyed'] = love.graphics.newImage('images/tnt_destroyed.png'),
        -- UI
        ['MenuArrow'] = love.graphics.newImage('images/menu_arrow.png'),
        ['Panel'] = love.graphics.newImage('images/panel.png'),
        ['DialogueBubble'] = love.graphics.newImage('images/ui_dialogue_bubble.png'),
        ['Title'] = love.graphics.newImage('images/text_goldminer.png'),
        ['Selector'] = love.graphics.newImage('images/ui_selector.png'),
        ['DynamiteUI'] = love.graphics.newImage('images/ui_dynamite.png'),
        ['Strength!'] = love.graphics.newImage('images/text_strength.png'),
        -- Shop
        ['Table'] = love.graphics.newImage('images/shop_table.png'),
        ['Dynamite'] = love.graphics.newImage('images/dynamite.png'),
        ['StrengthDrink'] = love.graphics.newImage('images/strength_drink.png'),
        ['LuckyClover'] = love.graphics.newImage('images/lucky_clover.png'),
        ['RockCollectorsBook'] = love.graphics.newImage('images/rock_collectors_book.png'),
        ['GemPolish'] = love.graphics.newImage('images/gem_polish.png'),
    }

    -- Set filter for each background and sprite to ensure nearest
    for _, image in pairs(backgrounds) do
        image:setFilter('nearest', 'nearest')
    end

    for _, image in pairs(sprites) do
        image:setFilter('nearest', 'nearest')
    end

    -- Init player's sheet and animations.
    playerSheet = love.graphics.newImage('images/miner_sheet.png')
    playerSheet:setFilter('nearest', 'nearest') -- Set filter for player sheet
    playerQuads = generateQuads(playerSheet, PLAYER_WIDTH, PLAYER_HEIGHT)
    playerIdleAnimation = Animation {
        frames = {1},
        interval = 1
    }
    playerGrabAnimation = Animation {
        frames = {3},
        interval = 1
    }
    playerGrabBackAnimation = Animation {
        frames = {1, 2, 3},
        interval = 0.13
    }
    playerUseDynamiteAnimation = Animation {
        frames = {4, 5, 6},
        interval = 0.13
    }
    playerStrengthenAnimation = Animation {
        frames = {7, 8, 7, 8},
        interval = 0.13
    }

    -- Init shopkeeper's sheet and animations
    shopkeeperSheet = love.graphics.newImage('images/shopkeeper_sheet.png')
    shopkeeperSheet:setFilter('nearest', 'nearest') -- Set filter for shopkeeper sheet
    shopkeeperQuads = generateQuads(shopkeeperSheet, SHOPKEEPER_WIDTH, SHOPKEEPER_HEIGHT)
    shopkeeperIdleAnimation = Animation {
        frames = {1},
        interval = 1
    }
    shopkeeperSadAnimation = Animation {
        frames = {2},
        interval = 1
    }

    -- Init hook's sheet and animations
    hookSheet = love.graphics.newImage('images/hook_sheet.png')
    hookSheet:setFilter('nearest', 'nearest') -- Set filter for hook sheet
    hookQuads = generateQuads(hookSheet, HOOK_WIDTH, HOOK_HEIGHT)
    hookIdleAnimation = Animation {
        frames = {1},
        interval = 1
    }
    hookGrabNormalAnimation = Animation {
        frames = {2},
        interval = 1
    }
    hookGrabMiniAnimation = Animation {
        frames = {3},
        interval = 1
    }

    -- Init mole's sheet and animations
    moleSheet = love.graphics.newImage('images/mole_sheet.png')
    moleSheet:setFilter('nearest', 'nearest') -- Set filter for mole sheet
    moleQuads = generateQuads(moleSheet, MOLE_WIDTH, MOLE_HEIGHT)
    moleIdleAnimation = Animation {
        frames = {1},
        interval = 1
    }
    moleMoveAnimation = Animation {
        frames = {1, 2, 3, 4, 5, 6, 7},
        interval = 0.15
    }
    entityConfig['Mole'].sheet = moleSheet
    entityConfig['Mole'].quads = moleQuads
    entityConfig['Mole'].idleAnimation = moleIdleAnimation
    entityConfig['Mole'].moveAnimation = moleMoveAnimation

    moleWithDiamondSheet = love.graphics.newImage('images/mole_with_diamond_sheet.png')
    moleWithDiamondSheet:setFilter('nearest', 'nearest') -- Set filter for mole with diamond sheet
    moleWithDiamondQuads = generateQuads(moleWithDiamondSheet, MOLE_WIDTH, MOLE_HEIGHT)
    moleWithDiamondIdleAnimation = Animation {
        frames = {1},
        interval = 1
    }
    moleWithDiamondMoveAnimation = Animation {
        frames = {1, 2, 3, 4, 5, 6, 7},
        interval = 0.15
    }
    entityConfig['MoleWithDiamond'].sheet = moleWithDiamondSheet
    entityConfig['MoleWithDiamond'].quads = moleWithDiamondQuads
    entityConfig['MoleWithDiamond'].idleAnimation = moleWithDiamondIdleAnimation
    entityConfig['MoleWithDiamond'].moveAnimation = moleWithDiamondMoveAnimation

    -- Init FXs
    bigGoldFXSheet = love.graphics.newImage('images/gold_big_fx_sheet.png')
    bigGoldFXSheet:setFilter('nearest', 'nearest') -- Set filter for big gold FX sheet
    bigGoldFXQuads = generateQuads(bigGoldFXSheet, BIG_GOLD_FX_WIDTH, BIG_GOLD_FX_HEIGHT)
    bigGoldFXDefaultAnimation = Animation {
        frames = {1, 2, 3, 4, 5, 6, 7, 8, 9},
        interval = 0.2
    }

    explosiveFXSheet = love.graphics.newImage('images/explosive_fx_sheet.png')
    explosiveFXSheet:setFilter('nearest', 'nearest') -- Set filter for explosive FX sheet
    explosiveFXQuads = generateQuads(explosiveFXSheet, EXPLOSIVE_FX_WIDTH, EXPLOSIVE_FX_HEIGHT)
    explosiveFXDefaultAnimation = Animation {
        frames = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
        interval = 0.2
    }

    biggerExplosiveFXSheet = love.graphics.newImage('images/bigger_explosive_fx_sheet.png')
    biggerExplosiveFXSheet:setFilter('nearest', 'nearest') -- Set filter for bigger explosive FX sheet
    biggerExplosiveFXQuads = generateQuads(biggerExplosiveFXSheet, BIGGER_EXPLOSIVE_FX_WIDTH, BIGGER_EXPLOSIVE_FX_HEIGHT)
    biggerExplosiveFXDefaultAnimation = Animation {
        frames = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
        interval = 0.2
    }

    -- Init RNG.
    math.randomseed(os.time())

    -- Init game states.
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end
