
function stdBlackJokeLoad()
    dialogLoad("script/share/black_", "sound/share/blackjokes/")
end

-- -----------------------------------------------------------------
local autoRestart = false
local restartCountDown = 0
local function initAutoRestart()
    autoRestart = true
    restartCountDown = 80
end
local function autoRestartTick()
    if autoRestart then
        restartCountDown = restartCountDown - 1
        if restartCountDown == 0 then
            autoRestart = false
            level_action_restart()
        end
    end
end

-- -----------------------------------------------------------------
local alive_time = 0
--TODO: remember values to the next restart
local PoslSmrtMale = -1
local PoslSmrtVelke = -1
local PoslSmrtObou = 0

-- NOTE: uses 'small' and 'big' names for fishes
function stdBlackJoke()
    local hzadna,hbezna,hzertik,hmiluji,hzahrobni,hobe,hauto
        = 1, 2, 3, 4, 5, 6, 7
    local hlaska
    local hlrestart
    local h

    if level_getDepth() == 2 then
        return
    end
    if small:isAlive() and big:isAlive() then
        alive_time = game_getCycles()
    else
        hlaska = hzadna
        hlrestart = false
        if (not small:isAlive() or not big:isAlive()) and alive_time + 8 == game_getCycles() then
            if isReady(big) or isReady(small) then
                local joke_table = {
                    [1] = function()
                        hlaska = hbezna
                        hlrestart = true
                    end,
                    [3] = function()
                        if random(100) < 70 then
                            hlaska = hbezna
                        end
                        if random(100) < 50 or PoslSmrtMale == -1 and PoslSmrtVelke == -1 then
                            hlrestart = true
                        end
                    end,
                    [4] = function()
                        if random(100) < 80 - 5 * level_getDepth() then
                            if small:isAlive() then
                                if random(100) < 5 then
                                    hlaska = hzertik
                                else
                                    hlaska = hbezna
                                end
                            elseif random(100) < 10 then
                                hlaska = hzertik
                            else
                                hlaska = hbezna
                            end
                        else
                            hlaska = hzadna
                        end
                        hlrestart = random(100) < 90 - 10 * level_getDepth()
                        if hlaska ~= hzadna then
                            if small:isAlive() and random(100) < 6 or big:isAlive() and random(100) < 10 then
                                hlaska = hzahrobni
                                hlrestart = false
                            end
                        end
                    end,
                    [9] = function()
                        if random(100) < 30 then
                            if small:isAlive() then
                                if random(100) < 8 then
                                    if random(8) < 5 then
                                        hlaska = hzertik
                                    else
                                        hlaska = hmiluji
                                    end
                                else
                                    hlaska = hbezna
                                end
                            elseif random(100) < 10 then
                                hlaska = hzertik
                            else
                                hlaska = hbezna
                            end
                        else
                            hlaska = hzadna
                        end
                        hlrestart = random(100) < 5
                        if hlaska ~= hzadna then
                            if small:isAlive() and random(100) < 10 or big:isAlive() and random(100) < 18 then
                                hlaska = hzahrobni
                                hlrestart = false
                            end
                        end
                    end,
                    [15] = function()
                        hlaska = hauto
                        hlrestart = false
                        initAutoRestart()
                    end,
                }

                joke_table[2] = joke_table[1]

                joke_table[5] = joke_table[4]
                joke_table[6] = joke_table[4]
                joke_table[7] = joke_table[4]
                joke_table[8] = joke_table[4]

                joke_table[10] = joke_table[9]
                joke_table[11] = joke_table[9]
                joke_table[12] = joke_table[9]
                joke_table[13] = joke_table[9]
                joke_table[14] = joke_table[9]

                switch(level_getDepth())(joke_table)
            elseif not small:isOut() and not big:isOut() then
                if level_getDepth() >= 9 and random(100) < 25 then
                    hlaska = hobe
                else
                    hlaska = hzadna
                end
                hlrestart = false
            end
        end
        if isReady(small) then
            switch(hlaska){
                [hzadna] = function()
                end,
                [hbezna] = function()
                    repeat
                        h = random(5) + 1
                    until h ~= PoslSmrtVelke
                    PoslSmrtVelke = h
                    addm(random(5), "smrt-m-"..h)
                end,
                [hzertik] = function()
                    PoslSmrtVelke = 0
                    addm(random(5), "smrt-m-0")
                end,
                [hmiluji] = function()
                    if PoslSmrtVelke == 6 then
                        h = 0
                    else
                        h = 6
                    end
                    PoslSmrtVelke = h
                    addm(random(5), "smrt-m-"..h)
                end,
                [hzahrobni] = function()
                    if PoslSmrtVelke ~= 10 then
                        PoslSmrtVelke = 10
                        addv(random(30) + 20, "smrt-v-zahrobi")
                    end
                end,
                [hauto] = function()
                    if PoslSmrtVelke ~= 20 or random(50) < 100 then
                        PoslSmrtVelke = 20
                        addm(0, "smrt-m-autorest")
                    end
                end,
            }
        elseif isReady(big) then
            switch(hlaska){
                [hzadna] = function()
                end,
                [hbezna] = function()
                    repeat
                        h = random(4) + 1
                    until h ~= PoslSmrtMale
                    PoslSmrtMale = h
                    addv(random(5), "smrt-v-"..h)
                end,
                [hzertik] = function()
                    repeat
                        h = random(4)
                        if h > 0 then
                            h = h + 4
                        end
                    until h ~= PoslSmrtMale
                    PoslSmrtMale = h
                    addv(random(5), "smrt-v-"..h)
                end,
                [hzahrobni] = function()
                    if PoslSmrtMale ~= 10 and (PoslSmrtMale == 11 or random(100) < 50) then
                        PoslSmrtMale = 10
                        addm(random(30) + 20, "smrt-m-zahrobi")
                    else
                        PoslSmrtMale = 11
                        addv(random(30) + 20, "smrt-v-posmrtny")
                        addm(random(30) + 20, "smrt-m-posmrtny")
                    end
                end,
                [hauto] = function()
                    if PoslSmrtMale ~= 20 or random(50) < 100 then
                        PoslSmrtMale = 20
                        addv(0, "smrt-v-autorest")
                    end
                end,
            }
        elseif hlaska == hobe and PoslSmrtObou ~= 1 then
            PoslSmrtObou = 1
            room:planDialog(0, "smrt-x-obe")
            addv(2, "smrt-v-obe")
            addm(0, "smrt-m-obe")
        end
        if hlrestart then
            if isReady(big) then
                addv(random(20) + 10, "smrt-v-restart")
            elseif isReady(small) then
                addm(random(20) + 10, "smrt-m-restart")
            end
        end
        autoRestartTick()
    end
end




