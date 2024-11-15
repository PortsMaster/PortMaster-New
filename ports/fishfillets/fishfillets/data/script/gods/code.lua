
file_include("script/share/prog_border.lua")
file_include("script/"..codename.."/prog_ships.lua")

local function xor1(value)
    if odd(value) then
        return value - 1
    else
        return value + 1
    end
end
local function xor2(value)
    if isIn(value, {2, 3, 6}) then
        return value - 2
    else
        return value + 2
    end
end

local function shinkShip(ship)
    if objekty.afaze == -1 then
        objekty:setEffect("none")
        objekty.shiftY = 0
        objekty.shiftX = randint(10, 30)
        --TODO: lower speed
        objekty.speedY = 1
        objekty.speedX = randint(-1, 1)
        objekty.afaze = ship
        objekty:updateAnim()
    end
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky01.ogg")
    local pokus = getRestartCount()

    --NOTE: a final level
    small:setGoal("goal_alive")
    big:setGoal("goal_alive")
    buh2:setGoal("goal_out")

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.stavhry = 0
        room.posl = 0
        room.uvod = 0
        room.costim = randint(25, 100)
        room.oholi = 0
        room.opalce = 0
        room.omicich = randint(1200, 4000)
        room.shodit = -1

        return function()
            if stdBorderReport() then
                addm(random(10) + 5, "lod-m-bohove")
            end
            if isReady(small) and isReady(big) and no_dialog() then
                if room.costim > 0 then
                    room.costim = room.costim - 1
                end
                if room.omicich > 0 then
                    room.omicich = room.omicich - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    switch(random(3)){
                        [0] = function()
                            addv(randint(10, 20), "lod-v-silenost0")
                        end,
                        [1] = function()
                            addv(randint(10, 20), "lod-v-silenost1")
                        end,
                        [2] = function()
                            addv(randint(10, 20), "lod-v-silenost2")
                        end,
                    }
                    switch(random(3)){
                        [0] = function()
                            addm(random(5), "lod-m-pravda0")
                        end,
                        [1] = function()
                            addm(random(5), "lod-m-pravda1")
                        end,
                        [2] = function()
                            addm(random(5), "lod-m-pravda2")
                        end,
                    }
                elseif room.costim == 0 then
                    room.costim = -1
                    switch(random(2)){
                        [0] = function()
                            addm(random(5), "lod-m-costim")
                            addv(random(5), "lod-v-internovat")
                            addm(random(5), "lod-m-co")
                            addv(random(5), "lod-v-cvok")
                            addm(random(5), "lod-m-oba")
                            addv(random(5), "lod-v-golf")
                            addm(random(5), "lod-m-jednoho")
                        end,
                        [1] = function()
                            addm(random(5), "lod-m-costim")
                            addv(random(5), "lod-v-internovat")
                            addm(random(5), "lod-m-oba")
                            addv(random(5), "lod-v-golf")
                            addm(random(5), "lod-m-jednoho")
                        end,
                    }
                    addv(random(7), "lod-v-koho")
                    switch(random(2)){
                        [0] = function()
                            planSet(big, "hlaska", 1)
                            addm(random(3), "lod-m-zluty")
                        end,
                        [1] = function()
                            planSet(big, "hlaska", 2)
                            addm(random(3), "lod-m-modry")
                        end,
                    }
                    switch(random(2)){
                        [0] = function()
                            addm(random(5), "lod-m-hrac")
                        end,
                        [1] = function()
                            addv(random(5), "lod-v-hrac")
                        end,
                    }
                elseif room.oholi == 0 and hul.dir ~= dir_no and big ~= dir_no and random(100) < 1 then
                    room.oholi = 1
                    addv(0, "lod-v-hul")
                    addm(random(7), "lod-m-ozizlana")
                elseif room.opalce == 0 and random(1000) < 1 then
                    room.opalce = 1
                    addv(random(10), "lod-v-hravost")
                    if palka.X == 23 and palka.Y == 2 then
                        addm(random(7), "lod-m-palka")
                    end
                elseif room.omicich == 0 then
                    room.omicich = -1
                    if kriketak.X > 24 and kriketak.Y > 19 then
                        addv(random(5), "lod-v-micky")
                        addm(random(5), "lod-m-vyznam")
                        addv(random(5), "lod-v-kdovi")
                    end
                    addm(random(5), "lod-m-micek")
                    addv(random(5), "lod-v-rozliseni")
                end
            end
            switch(room.stavhry){
                [0] = function()
                    initLode()
                    buh1.lodi = getNShips()
                    buh2.lodi = getNShips()
                    room.hraje = 1
                    room.stavhry = room.stavhry + 1
                    room.cekani = random(10) + 5
                end,
                [1] = function()
                    if no_dialog() then
                        if room.cekani > 0 then
                            room.cekani = room.cekani - 1
                        else
                            switch(room.hraje){
                                [1] = function()
                                    buh1.cinnost = 1
                                end,
                                [2] = function()
                                    buh2.cinnost = 1
                                end,
                            }
                            room.stavhry = 2
                        end
                    end
                end,
                [2] = function()
                    room.stavhry = 1
                    if buh2.lodi == 0 then
                        planDialogSet(3, "b2-vyhral", 201, buh2, "mluveni")
                        room.stavhry = 3
                    end
                    if buh1.lodi == 0 then
                        planDialogSet(8, "b1-vyhral", 101, buh1, "mluveni")
                        room.stavhry = 3
                    end
                    if room.stavhry == 1 then
                        room.cekani = random(10) + 5
                    else
                        room.cekani = random(100) + 100
                        switch(random(2)){
                            [0] = function()
                                planDialogSet(random(30) + 10, "b2-znovu", 201, buh2, "mluveni")
                                planDialogSet(random(10) + 5, "b1-dobre", 101, buh1, "mluveni")
                            end,
                            [1] = function()
                                planDialogSet(random(30) + 10, "b1-znovu", 101, buh1, "mluveni")
                                planDialogSet(random(10) + 5, "b2-dobre", 201, buh2, "mluveni")
                            end,
                        }
                    end
                end,
                [3] = function()
                    if no_dialog() then
                        if room.cekani > 0 then
                            room.cekani = room.cekani - 1
                        else
                            planDialogSet(0, "b1-zacinam", 101, buh1, "mluveni")
                            room.stavhry = 0
                        end
                    end
                end,
            }
            if room.shodit >= 0 then
                shinkShip(room.shodit)
                room.shodit = -1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_buh2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        buh2.cinnost = 0
        buh2.mluveni = 0
        buh2.cinruky = 0
        buh2.ruka = 0
        buh2.px = 0
        buh2.py = 0
        buh2.lodi = getNShips()

        return function()
            switch(buh2.cinnost){
                [1] = function()
                    pom1, buh2.px, buh2.py = hrajlode(2)
                    buh2.cekat = random(10) + 5
                    local arg = buh2.px
                    planDialogSet(buh2.cekat, "b2-"..string.char(buh2.py - 1 + string.byte("a")).."@"..arg, 201, buh2, "mluveni")
                    buh2.cinnost = 2
                    buh2.cekat = buh2.cekat + random(4) + 9
                    switch(pom1){
                        [1] = function()
                            adddel(random(20) + 20)
                            planSet(buh1, "cinruky", random(3) + 1)
                            planDialogSet(0, "b1-voda"..(random(5) + 1), 102, buh1, "mluveni")
                            planSet(buh2, "cinruky", random(3) + 1)
                            room.hraje = 1
                        end,
                        [3] = function()
                            adddel(random(20) + 20)
                            planSet(buh1, "cinruky", random(3) + 3)
                            planDialogSet(0, "b1-zasah"..(random(4) + 1), 103, buh1, "mluveni")
                            planSet(buh2, "cinruky", random(3) + 3)
                        end,
                        [4] = function()
                            adddel(random(20) + 20)
                            planSet(buh1, "cinruky", random(3) + 1)
                            planDialogSet(0, "b1-potop"..(random(3) + 1), 104, buh1, "mluveni")
                            planSet(buh1, "cinruky", -random(10) - 5)
                            planSet(buh2, "cinruky", -random(10) - 5)
                            buh2.lodi = buh2.lodi - 1
                            planSet(room, "shodit", getLastHit())
                        end,
                        [5] = function()
                            planDialogSet(random(20) + 20, "b1-voda"..(random(5) + 1), 102, buh1, "mluveni")
                            adddel(5)
                            planSet(buh2, "mluveni", 3)
                            planDialogSet(10 + random(10), "b2-podvadis", 220, buh2, "mluveni")
                            planDialogSet(8, "b2-"..string.char(buh2.py - 1 + string.byte("a")).."@"..arg, 220, buh2, "mluveni")
                            planDialogSet(0, "b2-"..buh2.px, 220, buh2, "mluveni")
                            planDialogSet(0, "b2-nemuze", 220, buh2, "mluveni")
                            planDialogSet(random(30) + 10, "b1-spletl", 105, buh1, "mluveni")
                            planDialogSet(random(5) + 5, "b1-potop"..(random(3) + 1), 104, buh1, "mluveni")
                            buh2.lodi = buh2.lodi - 1
                            planSet(room, "shodit", getLastHit())
                        end,
                        [6] = function()
                            planDialogSet(random(20) + 20, "b1-zasah"..(random(4) + 1), 103, buh1, "mluveni")
                            planDialogSet(random(10), "b2-podvadis", 220, buh2, "mluveni")
                            planDialogSet(random(10), "b2-spatne", 220, buh2, "mluveni")
                            switch(random(2)){
                                [0] = function()
                                    planDialogSet(random(30) + 10, "b1-spletl", 105, buh1, "mluveni")
                                end,
                                [1] = function()
                                    planDialogSet(random(5) + 2, "b1-nepodvadim", 106, buh1, "mluveni")
                                end,
                            }
                        end,
                        [7] = function()
                            planDialogSet(random(20) + 20, "b1-potop"..(random(3) + 1), 104, buh1, "mluveni")
                            planDialogSet(random(10), "b2-podvadis", 220, buh2, "mluveni")
                            planDialogSet(random(10), "b2-spatne", 220, buh2, "mluveni")
                            switch(random(2)){
                                [0] = function()
                                    planDialogSet(random(30) + 10, "b1-spletl", 105, buh1, "mluveni")
                                end,
                                [1] = function()
                                    planDialogSet(random(5) + 2, "b1-nepodvadim", 106, buh1, "mluveni")
                                end,
                            }
                            buh2.lodi = buh2.lodi - 1
                            planSet(room, "shodit", getLastHit())
                        end,
                    }
                end,
                [2] = function()
                    if buh2.cekat > 0 then
                        buh2.cekat = buh2.cekat - 1
                    else
                        buh2:talk("b2-"..buh2.px, 201)
                        buh2.cinnost = 0
                    end
                end,
            }
            switch(buh2.mluveni){
                [0] = function()
                    if not isIn(buh2.xicht, {3, 4, 6, 7}) or random(100) < 4 then
                        buh2.xicht = random(6) + 3
                        if buh2.xicht == 5 or buh2.xicht == 8 then
                            buh2.xicht = 3
                        end
                    end
                end,
                [1] = function()
                    if not isIn(buh2.xicht, {8, 9}) or random(100) < 3 then
                        buh2.xicht = 8 + random(2)
                        buh2.afaze = buh2.xicht + buh2.ruka * 10
                    end
                end,
                [2] = function()
                    if not isIn(buh2.xicht, {0, 1}) or random(100) < 5 then
                        buh2.xicht = random(2)
                    end
                end,
                [3] = function()
                    if not isIn(buh2.xicht, {1, 2}) or random(100) < 5 then
                        buh2.xicht = random(2) + 1
                    end
                end,
                [220] = function()
                    if buh2.xicht == 5 then
                        buh2.xicht = 6
                    else
                        buh2.xicht = 5
                    end
                end,
                default = function()
                    if 200 <= buh2.mluveni and buh2.mluveni <= 219 then
                        if odd(game_getCycles()) then
                            buh2.xicht = random(3)
                        end
                    end
                end,
            }
            if buh2.mluveni == 0 or buh2.mluveni == 1 or (200 <= buh2.mluveni and buh2.mluveni <= 220) then
                if buh2.ruka > 3 then
                    buh2.ruka = random(4)
                end
                if buh2.cinruky == 0 then
                    if random(100) < 2 then
                        buh2.ruka = random(4)
                    end
                elseif buh2.cinruky > 0 then
                    if math.mod(game_getCycles(), 3) == 0 then
                        if random(100) < 30 then
                            buh2.ruka = xor1(buh2.ruka)
                        else
                            buh2.ruka = xor2(buh2.ruka)
                        end
                        buh2.cinruky = buh2.cinruky - 1
                    end
                else
                    if random(100) < 30 then
                        buh2.ruka = xor1(buh2.ruka)
                    else
                        buh2.ruka = xor2(buh2.ruka)
                    end
                    buh2.cinruky = buh2.cinruky + 1
                end
                buh2.afaze = buh2.ruka * 10 + buh2.xicht
            elseif buh2.mluveni == 2 or buh2.mluveni == 3 then
                if not isIn(buh2.ruka, {4, 5, 6}) or odd(game_getCycles()) and random(100) < 30 then
                    buh2.ruka = random(3) + 4
                end
                if buh2.ruka == 4 then
                    switch(buh2.xicht){
                        [0] = function()
                            buh2.afaze = 0
                        end,
                        [1] = function()
                            buh2.afaze = 6
                        end,
                        [2] = function()
                            buh2.afaze = 9
                        end,
                    }
                else
                    buh2.afaze = buh2.ruka * 3 + 25 + buh2.xicht
                end
            end
            buh2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_buh1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false


        buh1.cinnost = 0
        buh1.ruka = 0
        buh1.oci = 0
        buh1.pusa = 0
        buh1.mluveni = 0
        buh1.cinruky = 0
        buh1.px = 0
        buh1.py = 0
        buh1.lodi = getNShips()


        return function()
            switch(buh1.cinnost){
                [1] = function()
                    pom1, buh1.px, buh1.py = hrajlode(1)
                    buh1.cekat = random(10) + 5
                    local arg = buh1.px
                    planDialogSet(buh1.cekat, "b1-"..string.char(buh1.py - 1 + string.byte("a")).."@"..arg, 101, buh1, "mluveni")
                    buh1.cinnost = 2
                    buh1.cekat = buh1.cekat + random(4) + 9
                    switch(pom1){
                        [1] = function()
                            adddel(random(20) + 20)
                            planSet(buh2, "cinruky", random(2) + 1)
                            planDialogSet(0, "b2-voda"..(random(5) + 1), 202, buh2, "mluveni")
                            planSet(buh1, "cinruky", random(2) + 1)
                            room.hraje = 2
                        end,
                        [3] = function()
                            adddel(random(20) + 20)
                            planSet(buh2, "cinruky", random(3) + 2)
                            planDialogSet(0, "b2-zasah"..(random(4) + 1), 203, buh2, "mluveni")
                            if random(3) == 0 then
                                planSet(buh2, "mluveni", 1)
                            end
                            planSet(buh1, "cinruky", random(3) + 2)
                        end,
                        [4] = function()
                            adddel(random(20) + 20)
                            planSet(buh2, "cinruky", random(3) + 1)
                            planDialogSet(0, "b2-potop"..(random(3) + 1), 204, buh2, "mluveni")
                            if random(3) ~= 0 then
                                planSet(buh2, "mluveni", 1)
                            end
                            planSet(buh1, "cinruky", -random(7) - 5)
                            planSet(buh2, "cinruky", -random(7) - 5)
                            buh1.lodi = buh1.lodi - 1
                            planSet(room, "shodit", getLastHit())
                        end,
                        [8] = function()
                            adddel(10 + random(10))
                            planSet(buh2, "mluveni", 2)
                            planDialogSet(random(15) + 10, "b2-rikal"..(random(2) + 1), 205, buh2, "mluveni")
                            planDialogSet(1, "b2-voda1", 201, buh2, "mluveni")
                            room.hraje = 2
                        end,
                        [9] = function()
                            adddel(10 + random(10))
                            planSet(buh2, "mluveni", 2)
                            planDialogSet(random(15) + 10, "b2-rikal"..(random(2) + 1), 201, buh2, "mluveni")
                        end,
                    }
                end,
                [2] = function()
                    if buh1.cekat > 0 then
                        buh1.cekat = buh1.cekat - 1
                    else
                        buh1:talk("b1-"..buh1.px, 101)
                        buh1.cinnost = 0
                    end
                end,
            }
            if buh1.mluveni > 100 then
                if odd(game_getCycles()) and buh1.mluveni > 101 or math.mod(game_getCycles(), 4) == 1 then
                    if random(2) == 1 then
                        buh1.pusa = math.mod(buh1.pusa + 1, 3)
                    else
                        buh1.pusa = math.mod(buh1.pusa + 2, 3)
                    end
                end
            end
            switch(buh1.mluveni){
                [0] = function()
                    if buh2.mluveni > 0 then
                        buh1.pusa = 0
                    else
                        buh1.pusa = 0
                    end
                    if random(100) < 3 then
                        buh1.oci = random(2)
                    end
                end,
                [105] = function()
                    if room.posl ~= buh1.mluveni then
                        buh1.oci = 0
                    end
                    room.posl = buh1.mluveni
                end,
                [106] = function()
                    if room.posl ~= buh1.mluveni then
                        buh1.oci = 2
                    end
                    room.posl = buh1.mluveni
                end,
                default = function()
                    if isIn(buh1.mluveni, {101, 102}) then
                        if room.posl ~= buh1.mluveni then
                            buh1.oci = math.floor(random(3) / 2)
                        elseif random(100) < 3 then
                            buh1.oci = 1 - buh1.oci
                        end
                        room.posl = buh1.mluveni
                    elseif isIn(buh1.mluveni, {103, 104}) then
                        if room.posl ~= buh1.mluveni then
                            buh1.oci = 2 - math.floor(random(3) / 2)
                        elseif random(100) < 3 then
                            buh1.oci = 3 - buh1.oci
                        end
                        room.posl = buh1.mluveni
                    end
                end,
            }
            if buh1.cinruky == 0 then
                if random(100) < 4 then
                    buh1.ruka = random(4)
                end
            elseif buh1.cinruky > 0 then
                if math.mod(game_getCycles(), 2) == 0 then
                    pom1 = random(3)
                    if pom1 == buh1.ruka then
                        pom1 = 3
                    end
                    buh1.ruka = pom1
                    buh1.cinruky = buh1.cinruky - 1
                end
            else
                pom1 = random(3)
                if pom1 == buh1.ruka then
                    pom1 = 3
                end
                buh1.ruka = pom1
                buh1.cinruky = buh1.cinruky + 1
            end
            buh1.afaze = buh1.ruka * 12 + buh1.oci * 4 + buh1.pusa
            buh1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        big.hlaska = 0

        return function()
            switch(big.hlaska){
                [1] = function()
                    big:talk("lod-v-modry")
                end,
                [2] = function()
                    big:talk("lod-v-zluty")
                end,
            }
            big.hlaska = 0
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_objekty()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        objekty.afaze = -1
        objekty:setEffect("invisible")

        return function()
            if objekty.afaze >= 0 then
                model_setViewShift(objekty.index,
                        objekty.shiftX, objekty.shiftY)
                objekty.shiftY = objekty.shiftY + objekty.speedY
                objekty.shiftX = objekty.shiftX + objekty.speedX

                if objekty.shiftY >= room:getH() then
                    objekty.afaze = -1
                    objekty:setEffect("invisible")
                end
            end
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_buh2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_buh1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_big()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_objekty()
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

