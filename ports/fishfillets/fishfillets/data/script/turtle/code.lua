
file_include('script/share/prog_border.lua')

HYB_SMALL = 1
HYB_BIG = 2
local hybTable = {}
hybTable[HYB_SMALL] = small
hybTable[HYB_BIG] = big

-- -----------------------------------------------------------------
local function charAt(s, i)
    return string.sub(s, i, i)
end
-- -----------------------------------------------------------------
local function planHyb(unit, destX, destY)
    if not level_isShowing() then
        local symbols
        --NOTE: symbols order is as dir_up==1, ...
        if unit == small then
            symbols = "udlr"
        else
            symbols = "UDLR"
        end
        level_planShow(function(count)
                local result = false
                local dir = findDir(unit, destX, destY)
                if dir == dir_no then
                    room.natvrdo = 0
                    result = true
                else
                    level_action_move(charAt(symbols, dir))
                end
                return result
            end)
    end
end

-- -----------------------------------------------------------------
local function isCarring(model)
    -- whether fish is under a object
    --NOTE: wall and water does not count
    local locX, locY = model:getLoc()
    for x = locX, locX + model:getW() - 1 do
        local y = locY - 1
        if not model_equals(-1, x, y) and not model_equals(room.index, x, y) then
            return true
        end
    end
    return false
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky05.ogg")
    local pokus = getRestartCount()

    --NOTE: a final level
    small:setGoal("goal_alive")
    big:setGoal("goal_alive")
    zelva:setGoal("goal_out")

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false
        local boring = 0
        local roompole = createArray(1)

        room.natvrdo = 0
        room.tvrdaryba = 0
        room.blbnout = 300 + random(300)
        room.kolikrat = 0
        room.hlouposti = random(1000) + 500
        room.kolikhlouposti = 0
        room.poslhloupost = random(3)
        room.cosedelo = 0
        room.uvod = 0

        return function()
            if small:getAction() == "rest" and big:getAction() == "rest" then
                boring = boring + 1
            else
                boring = 0
            end
            if room.natvrdo == 1 then
                planHyb(hybTable[room.tvrdaryba], room.tvrdex, room.tvrdey)
            end

            if stdBorderReport() then
                addv(5, "zel-v-ukol")
            end
            if isReady(small) and isReady(big) and no_dialog() and room.natvrdo == 0 then
                for pom1 = 1, 5 do
                    if room.blbnout > 0 then
                        room.blbnout = room.blbnout - 1
                    end
                end
                if room.hlouposti > 0 then
                    room.hlouposti = room.hlouposti - 1
                end
                if room.blbnout == 0 and room.natvrdo == 0 and boring > 40 then
                    pomb1 = true
                    room.tvrdaryba = random(2) + 1
                    local hybFish = hybTable[room.tvrdaryba]
                    if not isCarring(hybFish) then
                        room.tvrdex = random(room:getW() - 2) + 1
                        room.tvrdey = random(room:getH() - 2) + 1
                        if math.abs(hybFish.X - room.tvrdex) + math.abs(hybFish.Y - room.tvrdey) > 8 and findDir(hybFish, room.tvrdex, room.tvrdey) ~= dir_no then
                            room.natvrdo = 1
                        end
                        if room.natvrdo == 1 then
                            room.blbnout = (room.kolikrat + 3) * (random(100) + 50)
                        end
                    end
                end
                if room.hlouposti > 0 then
                    room.hlouposti = room.hlouposti - 1
                end
                if room.natvrdo == 1 then
                    room.kolikrat = room.kolikrat + 1
                    if roompole[0] <= 1 then
                        pom1 = random(3)
                        if pom1 == 0 or pom1 == 2 then
                            if room.tvrdaryba == HYB_SMALL then
                                addv(random(10), "zel-v-coto"..pom1)
                            else
                                addm(random(10), "zel-m-coto"..pom1)
                            end
                            room.cosedelo = room.tvrdaryba + 2
                        else
                            room.cosedelo = room.tvrdaryba
                        end
                    elseif random(100) < 60 then
                        if room.tvrdaryba == HYB_SMALL then
                            addm(random(60), "zel-m-potvora"..random(2))
                        else
                            addv(random(60), "zel-v-stacit"..random(2))
                        end
                    end
                    if roompole[0] == 0 then
                        roompole[0] = roompole[0] + 1
                    end
                    if random(100) < room.kolikrat * 10 - 50 then
                        if roompole[0] == 1 then
                            roompole[0] = roompole[0] + 1
                            room.cosedelo = room.tvrdaryba + 4
                        end
                    end
                elseif room.cosedelo > 0 then
                    if room.cosedelo <= 2 then
                        if room.cosedelo == 1 then
                            addv(random(10), "zel-v-coto1")
                        else
                            addm(random(10), "zel-m-coto1")
                        end
                        room.cosedelo = room.cosedelo + 2
                    end
                    if room.cosedelo > 4 or random(100) < 50 or room.kolikrat <= 2 then
                        if odd(room.cosedelo) then
                            addm(random(3) + 3, "zel-m-nevim"..random(2))
                        else
                            addv(random(3) + 3, "zel-v-nevim"..random(2))
                        end
                    end
                    if room.cosedelo > 4 or random(100) < 40 and room.kolikrat >= 3 then
                        if odd(room.cosedelo) then
                            addv(random(30) + 10, "zel-v-cosedeje")
                        else
                            addm(random(30) + 10, "zel-m-cimtoje")
                        end
                    end
                    if room.cosedelo > 4 then
                        adddel(random(30) + 10)
                        big:planDialog(0, "zel-v-tazelva",
                                function() small:talk("zel-m-tazelva") end)
                        switch(random(2)){
                            [0] = function()
                                addm(random(20) + 4, "zel-m-jasne")
                            end,
                            [1] = function()
                                addv(random(20) + 4, "zel-v-pochyby")
                            end,
                        }
                    end
                    room.cosedelo = 0
                elseif room.uvod == 0 then
                    room.uvod = 1
                    if roompole[0] < 2 then
                        addv(10 + random(25), "zel-v-zelva"..random(2))
                        addm(randint(5, 20), "zel-m-fotky"..random(2))
                        addv(5, "zel-v-zmistnosti0")
                    elseif random(100) < 120 - pokus * 10 then
                        addv(random(60) + 10, "zel-v-zmistnosti1")
                    end
                elseif room.hlouposti == 0 then
                    room.kolikhlouposti = room.kolikhlouposti + 1
                    room.hlouposti = room.kolikhlouposti * (1500 + random(1500))
                    pom1 = random(2)
                    if pom1 == room.poslhloupost then
                        pom1 = 2
                    end
                    room.poslhloupost = pom1
                    switch(pom1){
                        [0] = function()
                            addv(50, "zel-v-bizarni")
                        end,
                        [1] = function()
                            addm(50, "zel-m-priroda")
                        end,
                        [2] = function()
                            addv(50, "zel-v-tvary")
                            if random(100) < 60 then
                                addm(50, "zel-m-jednoduse")
                            end
                        end,
                    }
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_zelva()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        zelva.stav = 4
        zelva.xicht = 0
        zelva.napad = 0
        zelva.pozadavek = 0

        return function()
            if room.natvrdo == 1 then
                zelva.pozadavek = 7
            end
            switch(zelva.pozadavek){
                [8] = function()
                    if zelva.stav == 8 then
                        zelva.pozadavek = 0
                    end
                end,
                [0] = function()
                    if zelva.dir ~= dir_no then
                        zelva.pozadavek = 8
                    end
                end,
                [7] = function()
                    if room.natvrdo == 0 then
                        zelva.pozadavek = 0
                    end
                end,
            }
            if zelva.anim ~= "" then
                goanim(zelva)
            else
                if zelva.pozadavek == 0 and zelva.napad == 0 then
                    switch(zelva.stav){
                        [8] = function()
                            if random(100) < 2 then
                                zelva.napad = 1
                            end
                        end,
                        [1] = function()
                            switch(random(400)){
                                [0] = function()
                                    zelva.napad = 8
                                end,
                                [1] = function()
                                    zelva.napad = 2
                                end,
                                [2] = function()
                                    zelva.napad = 2
                                end,
                                [3] = function()
                                    zelva.napad = 3
                                end,
                                [4] = function()
                                    zelva.napad = 3
                                end,
                                [5] = function()
                                    zelva.napad = 4
                                end,
                                [6] = function()
                                    zelva.napad = 4
                                end,
                                [7] = function()
                                    zelva.napad = 4
                                end,
                            }
                        end,
                        [2] = function()
                            if random(100) < 6 then
                                zelva.napad = 1
                            end
                        end,
                        [3] = function()
                            if random(100) < 6 then
                                zelva.napad = 1
                            end
                        end,
                        [4] = function()
                            switch(random(100)){
                                [0] = function()
                                    zelva.napad = 1
                                end,
                                [1] = function()
                                    zelva.napad = 5
                                end,
                                [2] = function()
                                    zelva.napad = 6
                                end,
                            }
                        end,
                        [5] = function()
                            if random(100) < 2 then
                                zelva.napad = 4
                            end
                        end,
                        [6] = function()
                            if random(100) < 2 then
                                zelva.napad = 4
                            end
                        end,
                    }
                elseif zelva.pozadavek ~= 0 and zelva.pozadavek ~= zelva.stav and zelva.napad == 0 then
                    switch(zelva.pozadavek){
                        [7] = function()
                            if isIn(zelva.stav, {2, 3, 8}) then
                                zelva.napad = 1
                            elseif isIn(zelva.stav, {1, 5, 6}) then
                                zelva.napad = 4
                            elseif zelva.stav == 4 then
                                zelva.napad = 7
                            end
                        end,
                        [8] = function()
                            if isIn(zelva.stav, {5, 6}) then
                                zelva.napad = 4
                            elseif isIn(zelva.stav, {4, 2, 3}) then
                                zelva.napad = 1
                            elseif zelva.stav == 1 then
                                zelva.napad = 8
                            end
                        end,
                    }
                end
                switch(zelva.stav){
                    [8] = function()
                        zelva.xicht = 27
                        switch(zelva.napad){
                            [1] = function()
                                setanim(zelva, "S[pozadavek],29S[napad],0S[stav],1")
                            end,
                        }
                    end,
                    [1] = function()
                        if random(100) < 5 then
                            if random(2) == 0 then
                                zelva.xicht = 29
                            else
                                zelva.xicht = randint(31, 33)
                            end
                        end
                        switch(zelva.napad){
                            [8] = function()
                                setanim(zelva, "S[pozadavek],27S[napad],0S[stav],8")
                            end,
                            [2] = function()
                                setanim(zelva, "s[pozadavek],36S[pozadavek],38S[napad],0S[stav],2")
                            end,
                            [3] = function()
                                setanim(zelva, "s[pozadavek],37S[pozadavek],42S[napad],0S[stav],3")
                            end,
                            [4] = function()
                                setanim(zelva, "s[pozadavek],34s[pozadavek],35S[pozadavek],0S[napad],0S[stav],4")
                            end,
                        }
                    end,
                    [2] = function()
                        if random(100) < 5 then
                            if random(2) == 0 then
                                zelva.xicht = 38
                            else
                                zelva.xicht = 40 + random(2)
                            end
                        end
                        switch(zelva.napad){
                            [1] = function()
                                setanim(zelva, "s[pozadavek],36S[pozadavek],29S[napad],0S[stav],1")
                            end,
                        }
                    end,
                    [3] = function()
                        if random(100) < 5 then
                            if random(2) == 0 then
                                zelva.xicht = 42
                            else
                                zelva.xicht = 44 + random(2)
                            end
                        end
                        switch(zelva.napad){
                            [1] = function()
                                setanim(zelva, "s[pozadavek],37S[pozadavek],29S[napad],0S[stav],1")
                            end,
                        }
                    end,
                    [4] = function()
                        if random(100) < 5 then
                            if random(2) == 0 then
                                zelva.xicht = 0
                            else
                                zelva.xicht = random(3) * 2 + 2
                            end
                        end
                        switch(zelva.napad){
                            [1] = function()
                                setanim(zelva, "s[pozadavek],35s[pozadavek],34S[pozadavek],29S[napad],0S[stav],1")
                            end,
                            [5] = function()
                                setanim(zelva, "s[pozadavek],13S[pozadavek],16S[napad],0S[stav],5")
                            end,
                            [6] = function()
                                setanim(zelva, "s[pozadavek],18S[pozadavek],19S[napad],0S[stav],6")
                            end,
                            [7] = function()
                                setanim(zelva, "S[pozadavek],8S[napad],0S[stav],7")
                            end,
                        }
                    end,
                    [5] = function()
                        if random(100) < 5 then
                            if random(2) == 0 then
                                zelva.xicht = 14
                            else
                                zelva.xicht = 16 + 7 * random(2)
                            end
                        end
                        switch(zelva.napad){
                            [4] = function()
                                setanim(zelva, "s[pozadavek],13S[pozadavek],0S[napad],0S[stav],4")
                            end,
                        }
                    end,
                    [6] = function()
                        if random(100) < 5 then
                            if random(2) == 0 then
                                zelva.xicht = 19
                            else
                                zelva.xicht = 21 + 4 * random(2)
                            end
                        end
                        switch(zelva.napad){
                            [4] = function()
                                setanim(zelva, "s[pozadavek],18S[pozadavek],0S[napad],0S[stav],4")
                            end,
                        }
                    end,
                    [7] = function()
                        if isRange(zelva.xicht, 8, 10) then
                            zelva.xicht = zelva.xicht + 1
                        else
                            zelva.xicht = 8
                        end
                        if zelva.pozadavek ~= 7 then
                            setanim(zelva, "s[pozadavek],12d4S[napad],0S[stav],4")
                        end
                    end,
                }
                goanim(zelva)
            end
            zelva.afaze = zelva.xicht
            if isIn(zelva.afaze, {0, 2, 4, 6, 14, 16, 19, 21, 23, 25, 27, 29, 38, 42}) then
                if random(100) < 5 then
                    zelva.afaze = zelva.afaze + 1
                end
            end
            zelva:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_perla()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        perla.anim = "a0d?0-90La1a2a3a2a1a0d?10-100G"

        return function()
            goanim(perla)
            perla:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false
    end

    -- -------------------------------------------------------------
    local function prog_init_rybka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        rybka.cinnost = 0

        return function()
            if rybka.dir ~= dir_no then
                rybka.cinnost = 1
                rybka.anim = ""
                for pom1 = 1, random(5) + 5 do
                    rybka.anim = rybka.anim.."a"..(random(3) + 1)
                end
                for pom1 = 1, random(5) + 5 do
                    rybka.anim = rybka.anim.."a"..(random(3) + 1).."d1"
                end
                for pom1 = 1, random(5) + 5 do
                    rybka.anim = rybka.anim.."a"..(random(3) + 1).."d2"
                end
                for pom1 = 1, random(5) + 5 do
                    rybka.anim = rybka.anim.."a"..(random(3) + 1).."d3"
                end
                rybka.anim = rybka.anim.."S[cinnost],0"
                resetanim(rybka)
            end
            switch(rybka.cinnost){
                [0] = function()
                    setanim(rybka, "a0d?30-200S[cinnost],2d?10-40s[cinnost],1r")
                    rybka.cinnost = 1
                end,
                [1] = function()
                    goanim(rybka)
                end,
                [2] = function()
                    goanim(rybka)
                    if math.mod(game_getCycles(), 3) == 0 then
                        rybka.afaze = random(3) + 1
                    end
                end,
            }
            rybka:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_zelva()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_perla()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_small()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_rybka()
    if subinit then
        table.insert(update_table, subinit)
    end
    return update_table
end
local update_table = prog_init()


-- -----------------------------------------------------------------
-- Update
-- -----------------------------------------------------------------
function prog_update()
    for key, subupdate in pairs(update_table) do
        subupdate()
    end
end

