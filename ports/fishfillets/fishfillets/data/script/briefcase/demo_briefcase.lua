
codename = "briefcase"
file_include("script/share/level_dialog.lua")
dialogLoad("script/"..codename.."/brief_")

local function planDelay(delay)
    if delay > 0 then
        game_planAction(function(count)
            --NOTE: count starts from 0
            return count >= delay - 1
        end)
    end
end

local picture_counter = 0
local function nextPicture()
    game_planAction(function(count)
        local number = picture_counter
        if picture_counter < 100 then
            number = "0"..number
            if picture_counter < 10 then
                number = "0"..number
            end
        end
        local lang = string.sub(options_getParam("lang") or "", 1, 2)
        local fpath = "images/demo_briefcase/demo_"..number.."_"..lang..".png"
        if file_exists(fpath) then
          demo_display(fpath, 135, 25)
        else
          demo_display("images/demo_briefcase/demo_"..number..".png", 135, 25)
        end

        picture_counter = picture_counter + 1
        return true
    end)
end

local actor_index = 1
local function talk(dialog_name)
    game_planAction(function(count)
        model_talk(actor_index, dialog_name)
        return true
    end)
end
local function waitForTalker(dialog_name)
    game_planAction(function(count)
        return not model_isTalking(actor_index)
    end)
end

local function planAnim(count)
    for i = 1, count do
        nextPicture()
    end
end


-- -----------------------------------------------------------------
-- start
game_planAction(function(count)
    sound_playMusic("music/kufrik.ogg")
    demo_display("images/demo_briefcase/kufr256.png", 0, 0)
    return true
end)

planDelay(7)
-- rotating logo
nextPicture()
planDelay(1)
planAnim(3)

talk("kd-uvod")
planAnim(48)
planDelay(9)
nextPicture()
planDelay(2)
nextPicture()
planDelay(2)
nextPicture()
planDelay(2)
nextPicture()
planDelay(8)
waitForTalker()

talk("kd-ufo")
planDelay(6)
-- a bird
nextPicture()
planDelay(12)
nextPicture()
planDelay(12)
nextPicture()
planDelay(12)
nextPicture()
planDelay(12)
nextPicture()
planDelay(12)
nextPicture()
planDelay(13)
-- the map
nextPicture()
planDelay(23)
-- planets
planAnim(9) 
planDelay(3)
-- triangle
nextPicture()
nextPicture()
planDelay(2)
-- circle
nextPicture()
planDelay(1)
nextPicture()
planDelay(1)
-- hatch
nextPicture()
planDelay(1)
nextPicture()
planDelay(2)
-- conformity
planAnim(4)
-- E=mc^2
nextPicture()
planDelay(3)
nextPicture()
planDelay(1)
nextPicture()
planDelay(1)
-- square root
nextPicture()
planDelay(1)
-- angle
nextPicture()
-- buy list
nextPicture()
planDelay(1)
nextPicture()
planDelay(2)
-- equation
planAnim(5)
planDelay(2)
-- strike
nextPicture()
waitForTalker()

talk("kd-mesto")
planDelay(14)
-- table
nextPicture()
planDelay(31)
-- city
nextPicture()
planDelay(23)
planAnim(28)
-- map
nextPicture()
waitForTalker()

talk("kd-bermudy")
planDelay(4)
nextPicture()
planDelay(31)
planAnim(43)
waitForTalker()

talk("kd-silver")
planDelay(9)
-- ship
nextPicture()
planDelay(14)
nextPicture()
planDelay(2)
-- nothing
nextPicture()
planDelay(13)
-- Silver
nextPicture()
planDelay(11)
-- animals
nextPicture()
planDelay(8)
nextPicture()
planDelay(8)
nextPicture()
planDelay(7)
nextPicture()
planDelay(7)
nextPicture()
planDelay(6)
nextPicture()
planDelay(6)
nextPicture()
planDelay(5)
nextPicture()
planDelay(5)
nextPicture()
planDelay(5)
nextPicture()
planDelay(3)
nextPicture()
planDelay(2)
nextPicture()
waitForTalker()

talk("kd-pocitac")
planDelay(14)
nextPicture()
planDelay(4)
planAnim(6)
planDelay(15)
nextPicture()
planDelay(1)
nextPicture()
planDelay(1)
nextPicture()
planDelay(1)
nextPicture()
planDelay(28)
nextPicture()
planDelay(17)
planAnim(11)
waitForTalker()

talk("kd-zelva")
planDelay(2)
planAnim(12)
planDelay(9)
nextPicture()
planDelay(25)
nextPicture()
planDelay(25)
planAnim(24)
waitForTalker()

talk("kd-elektr")
planDelay(6)
nextPicture()
planDelay(19)
planAnim(10)
planDelay(10)
nextPicture()
planDelay(14)
waitForTalker()

talk("kd-gral")
planAnim(21)
waitForTalker()

talk("kd-zaver")
planDelay(3)
planAnim(11)
planDelay(26)
nextPicture()
planDelay(34)
nextPicture()
waitForTalker()

talk("kd-znici")
planDelay(27)
