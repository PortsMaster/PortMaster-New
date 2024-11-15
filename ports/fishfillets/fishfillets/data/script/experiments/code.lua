
file_include("script/"..codename.."/prog_pld.lua")

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky05.ogg")
    local pokus = getRestartCount()

    local tubes = {}
    for i = 0, 15 do
        tubes[i] = getModelsTable()[zkum.index + i]
    end


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        if pokus > 15 then
            room.uvod = random(2)
        end
        room.pokusy = 0
        room.bojidole = 0
        room.nerus = math.floor(pokus / 2)
        room.hnerus = 0
        if random(10) < pokus then
            room.zij = 1
        else
            room.zij = 0
        end
        room.kdy = random(1000 * pokus)
        room.kdy2 = random(2000 * pokus)
        if random(20) < pokus then
            room.pldicim = 1
        else
            room.pldicim = 0
        end
        room.pldiciv = 0
        room.kouk = 0
        room.fuja = -42
        room.ruk = 0
        room.zku = 0
        room.nep = 0
        room.vic = 0
        room.mrt = 0
        if math.mod(pokus, 3) > 0 then
            room.nedobre = 0
        else
            room.nedobre = 1
        end
        room.jej = 0
        room.kolem = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.uvod == 0 then
                    room.uvod = 1
                    addm(random(42) + 14, "bank-m-labolator"..(1 + random(3)))
                    if pokus > random(5) and random(4) == 1 then
                        room.pokusy = 1
                        addv(10, "bank-v-pokusy"..(1 + random(2)))
                    end
                end
                if room.bojidole == 0 and small.Y > 26 and small.X < 20 then
                    room.bojidole = 1
                    addm(10, "bank-m-bojim")
                    if random(3) ~= 1 then
                        addm(10, "bank-m-ocicka")
                    end
                    if random(3) ~= 1 then
                        addv(15, "bank-v-pomoc")
                    end
                end
                if game_getCycles() == room.kdy2 then
                    if random(5) < 3 then
                        addm(20, "bank-m-prohlednout")
                        addv(22, "bank-v-vypad"..(1 + random(2)))
                    else
                        addm(20, "bank-m-tvorove")
                    end
                end
                if room.pldicim == 0 and small.X > 27 and small.Y < 17 then
                    addm(8, "bank-m-nesetkala")
                    room.pldicim = 1
                end
                if room.pldiciv == 0 and big.X > 27 and big.Y < 17 then
                    addv(25, "bank-v-mnozeni")
                    room.pldiciv = 1
                end
                if room.kouk == 0 and small.Y > 26 and small.X + 1 <= oka.X then
                    room.kouk = 1
                    addm(2, "bank-m-kouka")
                end
                if room.fuja + 50 < game_getCycles() then
                    if lahvac.rozbit == 10 and dist(small, lahvac) < 4 or oka.dir ~= dir_no and dist(small, oka) < 4 then
                        addm(5, "bank-m-fuj")
                        room.fuja = game_getCycles()
                    end
                end
                if room.ruk == 0 and ruka.cinnost == 2 then
                    room.ruk = 1
                    addm(12, "bank-m-nervozni")
                end
                if room.zku == 0 then
                    pom2 = 0
                    for key, tube in pairs(tubes) do
                        if dist(small, tube) < 2 then
                            pom2 = 1
                        end
                    end
                    if pom2 == 1 then
                        room.zku = 1
                        addm(7, "bank-m-zkumavka")
                    end
                end
                if room.kolem == 0 and no_dialog() and room.kouk + room.zku + room.ruk + room.pldicim + room.pldiciv + room.bojidole + room.jej + room.zij + room.uvod + room.pokusy + room.nep + room.mrt + room.nedobre > 7 then
                    room.kolem = 1
                    addm(42, "bank-m-hlavakolem")
                end
                if room.nep == 0 and big.X == 40 and big.Y > 13 then
                    room.nep = 1
                    addv(4, "bank-v-neproplavu"..(1 + random(2)))
                end
                if room.vic < 2 and math.mod(game_getCycles(), 8) == 1 then
                    pom2 = 0
                    for key, model in pairs(getModelsTable()) do
                        if model.Y < 21 and model.Y > 17 and model.X > 14 and model.X < 29 then
                            pom2 = pom2 + 1
                        end
                    end
                    if room.vic == 0 and pom2 == 5 then
                        addv(5, "bank-v-nahazet")
                        room.vic = room.vic + 1
                    end
                    if room.vic == 1 and pom2 == 7 then
                        addv(5, "bank-v-jeste")
                        room.vic = room.vic + 1
                    end
                end
                if room.mrt == 0 and dist(small, kostra) < 3 then
                    room.mrt = 1
                    if random(3) ~= 1 then
                        addm(1, "bank-m-mrtvolka")
                    end
                    switch(random(5)){
                        [1] = function()
                            addm(9, "bank-m-prehnal1")
                        end,
                        [2] = function()
                            addm(9, "bank-m-prehnal1")
                        end,
                        [3] = function()
                            addm(9, "bank-m-prehnal2")
                        end,
                        [4] = function()
                            addm(9, "bank-m-prehnal2")
                        end,
                    }
                end
                if room.nedobre == 0 and lahvac.dir ~= dir_no then
                    room.nedobre = 1
                    addv(10, "bank-v-flaska")
                end
                if lahvac.afaze == 25 then
                    if random(2) == 1 then
                        addm(5, "bank-m-rozbila")
                    end
                end
                if room.jej == 0 and (dolni1.zije == -4 and dist(dolni1, small) < 11 or dolni2.zije == -4 and dist(dolni2, small) < 11) then
                    room.jej = 1
                    addm(5, "bank-m-jejda")
                end
                if room.pokusy == 0 and (big.X > 32 or big.Y > 17) then
                    room.pokusy = 1
                    if random(3) ~= 1 then
                        addv(10, "bank-v-pokusy"..(1 + random(2)))
                        room.hnerus = 1
                    end
                end
                if room.zij == 0 and game_getCycles() > math.floor((10000 - room.kdy - room.kdy2) / 16) then
                    room.zij = 1
                    addv(random(50), "bank-v-zije")
                    room.hnerus = 1
                end
                if game_getCycles() == room.kdy then
                    if random(3) == 1 then
                        addv(20, "bank-v-potvory")
                        if random(3) == 1 then
                            room.hnerus = 1
                        end
                    else
                        addm(20, "bank-m-organismy")
                    end
                end
            end
            if room.hnerus == 1 then
                if random(5) + room.nerus < 4 then
                    room.nerus = room.nerus + 1
                    addm(10, "bank-m-nerus")
                end
            end
            room.hnerus = 0
            if game_getCycles() > room.kdy then
                room.kdy = room.kdy + 1000 + random(10000)
            end
            if game_getCycles() > room.kdy2 then
                room.kdy2 = room.kdy2 + 1000 + random(10000)
            end
            if math.mod(game_getCycles(), 800) == 777 then
                switch(random(10)){
                    [1] = function()
                        room.ruk = 0
                    end,
                    [2] = function()
                        room.kouk = 0
                    end,
                    [3] = function()
                        room.mrt = 0
                    end,
                    [4] = function()
                        room.nedobre = 0
                    end,
                    [5] = function()
                        room.jej = 0
                    end,
                    [6] = function()
                        room.kolem = 0
                    end,
                    [7] = function()
                        room.nerus = 0
                    end,
                    [8] = function()
                        room.pokusy = 0
                    end,
                    [9] = function()
                        room.zij = 0
                    end,
                    [0] = function()
                        room.bojidole = 0
                    end,
                }
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_klicka()
        return function()
            klicka.afaze = math.mod(game_getCycles(), 2)
            klicka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_zataras()
        return function()
            if zataras.dir ~= dir_no then
                room.nep = 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_horni1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        horni1.oci = 0

        return function()
            horni1.poloha = 0
            if dolni1.zije > 0 then
                if xdist(horni1, dolni1) == 0 then
                    horni1.poloha = 3
                elseif horni1.Y == dolni1.Y then
                    local diffdist = xdist(horni1, dolni1)
                    if 1 <= diffdist and diffdist <= 3 then
                        horni1.poloha = 1
                    elseif -3 <= diffdist and diffdist <= -1 then
                        horni1.poloha = 2
                    end
                end
            end
            if math.mod(game_getCycles(), 3) == 0 and random(100) < 40 then
                horni1.oci = random(5)
            end
            if random(100) < 2 then
                horni1.afaze = 5
            elseif horni1.poloha > 0 then
                horni1.afaze = horni1.poloha
            else
                horni1.afaze = horni1.oci
            end
            horni1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dolni1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dolni1.oci = 0
        dolni1.zije = -99

        return function()
            if horni1.X ~= dolni1.X and dolni1.zije == -99 then
                dolni1.zije = -7
            end
            if dolni1.zije == -99 then
            elseif dolni1.zije <= 0 then
                dolni1.zije = dolni1.zije + 1
                dolni1.afaze = 1
            else
                if math.mod(game_getCycles(), 3) == 0 and random(100) < 40 then
                    dolni1.oci = random(4) + 2
                end
                pom1 = horni1.poloha
                if random(100) < 2 then
                    dolni1.afaze = 1
                elseif pom1 > 0 then
                    if pom1 == 3 then
                        dolni1.afaze = 3
                    else
                        dolni1.afaze = 3 + pom1
                    end
                else
                    dolni1.afaze = dolni1.oci
                end
            end
            dolni1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_zkum()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        for key, tube in pairs(tubes) do
            tube.glob = random(100) + 10
            tube.afaze = 0
            if random(2) == 0 then
                tube.glob = -tube.glob
            end
        end

        return function()
            for key, tube in pairs(tubes) do
                if tube.glob > 0 then
                    tube.glob = tube.glob - 1
                    if tube.glob == 0 then
                        tube.glob = -random(100) - 10
                    end
                    if odd(game_getCycles() + key) then
                        if random(2) > 0 then
                            tube.afaze = math.mod(tube.afaze + 1, 3)
                        else
                            tube.afaze = math.mod(tube.afaze + 2, 3)
                        end
                    end
                else
                    tube.glob = tube.glob + 1
                    if tube.glob == 0 then
                        tube.glob = random(100) + 10
                    end
                    tube.afaze = 0
                end
                tube:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_horni2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        horni2.oci = 0

        return function()
            horni2.poloha = 0
            if dolni2.zije > 0 then
                if xdist(horni2, dolni2) == 0 then
                    horni2.poloha = 3
                elseif horni2.Y == dolni2.Y then
                    local diffdist = xdist(horni2, dolni2)
                    if 1 <= diffdist and diffdist <= 3 then
                        horni2.poloha = 1
                    elseif -3 <= diffdist and diffdist <= -1 then
                        horni2.poloha = 2
                    end
                end
            end
            if math.mod(game_getCycles(), 3) == 0 and random(100) < 40 then
                horni2.oci = random(5)
            end
            if random(100) < 2 then
                horni2.afaze = 5
            elseif horni2.poloha > 0 then
                horni2.afaze = horni2.poloha
            else
                horni2.afaze = horni2.oci
            end
            horni2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dolni2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dolni2.oci = 0
        dolni2.zije = -99

        return function()
            if horni2.X ~= X and dolni2.zije == -99 then
                dolni2.zije = -7
            end
            if dolni2.zije == -99 then
            elseif dolni2.zije <= 0 then
                dolni2.zije = dolni2.zije + 1
                dolni2.afaze = 1
            else
                if math.mod(game_getCycles(), 3) == 0 and random(100) < 40 then
                    dolni2.oci = random(4) + 2
                end
                pom1 = horni2.poloha
                if random(100) < 2 then
                    dolni2.afaze = 1
                elseif pom1 > 0 then
                    if pom1 == 3 then
                        dolni2.afaze = 3
                    else
                        dolni2.afaze = 3 + pom1
                    end
                else
                    dolni2.afaze = dolni2.oci
                end
            end
            dolni2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_kostra()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        kostra.citac = random(200) + 200

        return function()
            if kostra.afaze < 8 then
                if kostra.citac == 0 then
                    kostra.afaze = kostra.afaze + 1
                    kostra.citac = random(200) + 200
                else
                    kostra.citac = kostra.citac - 1
                end
            end
            kostra:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_oko()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        oko.cinnost = 0

        return function()
            local cinnost_table = {
                [0] = function()
                    if random(100) < 10 then
                        local rand8 = random(8)
                        switch(rand8){
                            [3] = function()
                                oko.citac = random(3) + 2
                                oko.cinnost = 2
                                oko.faze = random(2) * 2
                            end,
                            [7] = function()
                                oko.citac = random(10) + 2
                                oko.cinnost = 5
                            end,
                            default = function()
                                if 0 <= rand8 and rand8 <= 2 then
                                    oko.citac = random(5) + 5
                                    oko.cinnost = 1
                                    oko.faze = random(2) * 2
                                elseif 4 <= rand8 and rand8 <= 6 then
                                    oko.citac = random(12) + 12
                                    oko.cinnost = 3 + random(2)
                                end
                            end,
                        }
                    end
                end,
                [1] = function()
                    switch(oko.faze){
                        [0] = function()
                            if oko.cinnost == 1 then
                                oko.afaze = 1
                            else
                                oko.afaze = 3
                            end
                            if random(100) < 20 then
                                oko.faze = oko.faze + 1
                            end
                        end,
                        [1] = function()
                            oko.afaze = 0
                            oko.faze = oko.faze + 1
                        end,
                        [2] = function()
                            if oko.cinnost == 1 then
                                oko.afaze = 2
                            else
                                oko.afaze = 4
                            end
                            if random(100) < 20 then
                                oko.faze = oko.faze + 1
                            end
                        end,
                        [3] = function()
                            oko.afaze = 0
                            oko.citac = oko.citac - 1
                            if oko.citac == 0 then
                                oko.cinnost = 0
                            else
                                oko.faze = 0
                            end
                        end,
                    }
                end,
                [3] = function()
                    switch(oko.cinnost){
                        [3] = function()
                            switch(oko.afaze){
                                [0] = function()
                                    oko.afaze = random(4) + 1
                                end,
                                [1] = function()
                                    oko.afaze = 3
                                end,
                                [2] = function()
                                    oko.afaze = 4
                                end,
                                [3] = function()
                                    oko.afaze = 2
                                end,
                                [4] = function()
                                    oko.afaze = 1
                                end,
                            }
                        end,
                        [4] = function()
                            switch(oko.afaze){
                                [0] = function()
                                    oko.afaze = random(4) + 1
                                end,
                                [1] = function()
                                    oko.afaze = 4
                                end,
                                [2] = function()
                                    oko.afaze = 3
                                end,
                                [3] = function()
                                    oko.afaze = 1
                                end,
                                [4] = function()
                                    oko.afaze = 2
                                end,
                            }
                        end,
                        [5] = function()
                            if random(100) < 40 then
                                oko.afaze = random(5)
                            end
                        end,
                    }
                    oko.citac = oko.citac - 1
                    if oko.citac == 0 then
                        oko.cinnost = 0
                        oko.afaze = 0
                    end
                end,
            }

            cinnost_table[2] = cinnost_table[1]

            cinnost_table[4] = cinnost_table[3]
            cinnost_table[5] = cinnost_table[3]

            switch(oko.cinnost)(cinnost_table)
            oko:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_qldik1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        qldik1.afaze = 5
        qldik1.zije = 0
        qldik1.oci = 0

        return function()
            if qldik1.dir ~= dir_no then
                qldik1.zije = 1
            end
            if math.mod(game_getCycles(), 3) == 0 then
                if qldik1.zije > 0 then
                    if random(100) < 20 then
                        qldik1.oci = random(5)
                    end
                    if random(100) < 4 then
                        qldik1.afaze = 5
                    else
                        qldik1.afaze = qldik1.oci
                    end
                end
            end
            qldik1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_qldik2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        qldik2.afaze = 5
        qldik2.zije = 0
        qldik2.oci = 0

        return function()
            if qldik2.dir ~= dir_no then
                qldik2.zije = 1
            end
            if math.mod(game_getCycles(), 3) == 0 then
                if qldik2.zije > 0 then
                    if random(100) < 20 then
                        qldik2.oci = random(5)
                    end
                    if random(100) < 4 then
                        qldik2.afaze = 5
                    else
                        qldik2.afaze = qldik2.oci
                    end
                end
            end
            qldik2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_qldik3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        qldik3.oci = 0
        qldik3.skace = 0

        return function()
            if math.mod(game_getCycles(), 2) == 0 then
                if qldik3.skace == 0 then
                    if random(100) < 1 then
                        qldik3.skace = random(7) * 2 + 3
                    end
                    if random(100) < 4 then
                        qldik3.afaze = 5
                    else
                        if random(100) < 30 then
                            qldik3.oci = random(5)
                        end
                        qldik3.afaze = qldik3.oci
                    end
                else
                    if odd(qldik3.skace) then
                        qldik3.afaze = 6
                    else
                        qldik3.afaze = 7
                    end
                    qldik3.skace = qldik3.skace - 1
                end
            end
            qldik3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_lahvac()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        lahvac.rozbit = 0
        lahvac.vnitrek = random(4)
        lahvac.stav = 0
        lahvac.smer = random(2)
        lahvac.pada = 0

        return function()
            switch(lahvac.rozbit){
                [0] = function()
                    if math.mod(game_getCycles(), 4) == 0 then
                        switch(random(4)){
                            [0] = function()
                                lahvac.vnitrek = math.mod(lahvac.vnitrek + 1, 4)
                            end,
                            [1] = function()
                                lahvac.vnitrek = math.mod(lahvac.vnitrek + 3, 4)
                            end,
                        }
                    end
                    switch(lahvac.stav){
                        [0] = function()
                            if random(100) < 5 then
                                lahvac.stav = 10 + random(2) * 10
                                lahvac.smer = 1 - lahvac.smer
                                lahvac.afaze = 0
                            elseif random(100) < 7 then
                                lahvac.stav = 1 + random(2)
                                lahvac.afaze = 7 + lahvac.stav * 4 + math.mod(lahvac.vnitrek, 2)
                            else
                                lahvac.afaze = lahvac.vnitrek
                            end
                        end,
                        [3] = function()
                            if random(100) < 7 then
                                lahvac.stav = 2
                                lahvac.afaze = 15 + math.mod(lahvac.vnitrek, 2)
                            elseif random(100) < 7 then
                                lahvac.stav = 4
                                lahvac.afaze = 22 + math.mod(lahvac.vnitrek, 2)
                            elseif math.mod(lahvac.vnitrek, 2) == 1 and random(100) < 10 then
                                lahvac.afaze = 19
                            else
                                lahvac.afaze = 20 + math.mod(lahvac.vnitrek, 2)
                            end
                        end,
                        [4] = function()
                            if random(100) < 7 then
                                lahvac.stav = 3
                                lahvac.afaze = 20 + math.mod(lahvac.vnitrek, 2)
                            end
                        end,
                        default = function()
                            if 1 <= lahvac.stav and lahvac.stav <= 2 then
                                if random(100) < 7 then
                                    lahvac.afaze = 7 + lahvac.stav * 4 + math.mod(lahvac.vnitrek, 2)
                                    lahvac.stav = 0
                                elseif random(100) < 7 and lahvac.stav == 2 then
                                    lahvac.stav = 3
                                    lahvac.afaze = 19
                                else
                                    lahvac.afaze = 9 + 4 * lahvac.stav + math.mod(lahvac.vnitrek, 2)
                                    if random(100) < 5 then
                                        lahvac.afaze = lahvac.afaze - 2
                                    end
                                end
                            elseif 10 <= lahvac.stav and lahvac.stav <= 15 then
                                if lahvac.smer == 0 then
                                    lahvac.afaze = lahvac.stav - 5
                                else
                                    lahvac.afaze = 25 - lahvac.stav - 5
                                end
                                if lahvac.stav == 15 then
                                    lahvac.stav = 0
                                else
                                    lahvac.stav = lahvac.stav + 1
                                end
                            elseif 20 <= lahvac.stav and lahvac.stav <= 25 then
                                if math.mod(game_getCycles(), 3) == 0 then
                                    if lahvac.smer == 0 then
                                        lahvac.afaze = lahvac.stav - 15
                                    else
                                        lahvac.afaze = 45 - lahvac.stav - 15
                                    end
                                    if lahvac.stav == 25 then
                                        lahvac.stav = 0
                                    else
                                        lahvac.stav = lahvac.stav + 1
                                    end
                                end
                            end
                        end,
                    }
                    if lahvac.dir == dir_down then
                        lahvac.pada = 1
                    elseif lahvac.pada == 1 then
                        lahvac.rozbit = 1
                    end
                end,
                [5] = function()
                    lahvac.stav = random(30) + 30
                    lahvac.rozbit = lahvac.rozbit + 1
                end,
                [6] = function()
                    if lahvac.stav == 0 or lahvac.dir == dir_left or lahvac.dir == dir_right then
                        lahvac.rozbit = lahvac.rozbit + 1
                        lahvac.stav = 0
                    else
                        lahvac.stav = lahvac.stav - 1
                    end
                end,
                [7] = function()
                    if lahvac.dir ~= dir_no then
                        lahvac.stav = random(10) + 10
                        lahvac.rozbit = 10
                        lahvac.afaze = 31 + random(3)
                    else
                        switch(lahvac.stav){
                            [0] = function()
                                if random(100) < 7 then
                                    lahvac.stav = 1 + random(2)
                                    if lahvac.stav == 1 then
                                        lahvac.afaze = 28
                                    else
                                        lahvac.afaze = 30
                                    end
                                else
                                    lahvac.afaze = 27
                                end
                            end,
                            [1] = function()
                                if random(100) < 7 then
                                    lahvac.stav = 0
                                    lahvac.afaze = 28
                                elseif random(100) < 5 then
                                    lahvac.afaze = 28
                                else
                                    lahvac.afaze = 29
                                end
                            end,
                            [2] = function()
                                if random(100) < 7 then
                                    lahvac.stav = 0
                                end
                            end,
                        }
                    end
                end,
                [10] = function()
                    if lahvac.stav == 0 then
                        lahvac.stav = random(10) + 10
                        lahvac.rozbit = 6
                        lahvac.afaze = 27
                    else
                        if odd(game_getCycles()) then
                            if random(2) == 0 then
                                lahvac.afaze = math.mod(lahvac.afaze - 30, 3) + 31
                            else
                                lahvac.afaze = math.mod(lahvac.afaze - 29, 3) + 31
                            end
                        end
                        lahvac.stav = lahvac.stav - 1
                    end
                end,
                default = function()
                    if 1 <= lahvac.rozbit and lahvac.rozbit <= 4 then
                        lahvac.afaze = 23 + lahvac.rozbit
                        lahvac.rozbit = lahvac.rozbit + 1
                    end
                end,
            }
            lahvac:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_oka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        oka.impuls = 0
        oka.kuk = 0
        oka.smer = 4
        local smallActive = true

        return function()
            if oka.dir ~= dir_no then
                if oka.impuls == 0 then
                    oka.faze = 0
                end
                oka.impuls = 4
            end
            if oka.impuls > 0 then
                if oka.faze < oka.impuls then
                    oka.afaze = 7 + oka.faze
                else
                    oka.afaze = 15 - 2 * oka.impuls + oka.faze
                end
                oka.faze = oka.faze + 1
                if oka.faze == 2 * oka.impuls then
                    oka.faze = 0
                    oka.impuls = oka.impuls - 1
                end
            elseif oka.kuk > 0 then
                oka.afaze = 1
                oka.kuk = oka.kuk - 1
                oka.smer = 4
            else
                if big.dir ~= dir_no or not small:isAlive() then
                    smallActive = false
                elseif small.dir ~= dir_no or not big:isAlive() then
                    smallActive = true
                end

                if smallActive then
                    pom1 = xdist(small, oka)
                    pom2 = ydist(small, oka)
                else
                    pom1 = xdist(big, oka)
                    pom2 = ydist(big, oka)
                end
                if small:isAlive() or big:isAlive() then
                    if pom1 < 0 then
                        if math.abs(pom1) >= 2 * math.abs(pom2) then
                            oka.novysmer = 6
                        elseif math.abs(pom2) >= 2 * math.abs(pom1) then
                            oka.novysmer = 4
                        else
                            oka.novysmer = 5
                        end
                    else
                        if math.abs(pom1) >= 2 * math.abs(pom2) then
                            oka.novysmer = 2
                        elseif math.abs(pom2) >= 2 * math.abs(pom1) then
                            oka.novysmer = 4
                        else
                            oka.novysmer = 3
                        end
                    end
                end
                if oka.smer == -1 then
                    oka.smer = oka.novysmer
                elseif oka.smer < oka.novysmer then
                    oka.smer = oka.smer + 1
                elseif oka.smer > oka.novysmer then
                    oka.smer = oka.smer - 1
                end
                oka.afaze = oka.smer
                if random(200) < 1 then
                    oka.kuk = random(4) + 4
                end
            end
            oka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_malej()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        malej.houpe = 0
        malej.oci = 0

        return function()
            if math.mod(game_getCycles(), 3) == 0 then
                if random(100) < 10 then
                    malej.oci = random(5)
                end
            end
            if malej.dir ~= dir_no and malej.houpe == 0 then
                malej.faze = 0
                malej.houpe = 1
            end
            switch(malej.houpe){
                [0] = function()
                    if random(100) < 2 then
                        malej.afaze = 4
                    else
                        malej.afaze = malej.oci
                    end
                end,
                [1] = function()
                    malej.faze = malej.faze + 1
                    switch(malej.faze){
                        [1] = function()
                            malej.afaze = 5
                        end,
                        [4] = function()
                            malej.afaze = 6
                        end,
                        [6] = function()
                            if malej.dir == dir_no then
                                malej.houpe = 0
                                malej.oci = 0
                            else
                                malej.faze = 0
                            end
                        end,
                    }
                end,
            }
            malej:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_ruka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        ruka.cinnost = 0
        ruka.smer = 0
        ruka.faze = 0

        return function()
            if odd(game_getCycles()) then
                pomb1 = xdist(ruka, small) == 0 and ydist(ruka, small) > 0 and ydist(ruka, small) < 10
                pomb2 = xdist(ruka, big) == 0 and ydist(ruka, big) > 0 and ydist(ruka, big) < 10
                if pomb1 and pomb2 then
                    if small.Y > big.Y then
                        pomb2 = false
                    end
                end
                if pomb1 or pomb2 then
                    if ruka.cinnost ~= 2 then
                        ruka.faze = 0
                    end
                    ruka.cinnost = 2
                    if pomb1 then
                        if small:isLeft() then
                            ruka.smer = 0
                        else
                            ruka.smer = 1
                        end
                    elseif big:isLeft() then
                        ruka.smer = 0
                    else
                        ruka.smer = 1
                    end
                elseif ruka.cinnost == 2 then
                    ruka.cinnost = 0
                    ruka.faze = 0
                end
                switch(ruka.cinnost){
                    [0] = function()
                        if random(100) < 2 then
                            ruka.cinnost = 1
                            ruka.afaze = 0
                            ruka.faze = (random(3) + 2) * 2
                        else
                            if random(100) < 3 then
                                ruka.smer = 1 - ruka.smer
                            end
                            if ruka.smer == 0 then
                                ruka.faze = math.mod(ruka.faze + 1, 7)
                            else
                                ruka.faze = math.mod(ruka.faze + 6, 7)
                            end
                            ruka.afaze = ruka.faze
                        end
                    end,
                    [1] = function()
                        ruka.faze = ruka.faze - 1
                        if odd(ruka.faze) then
                            ruka.afaze = 7
                        else
                            ruka.afaze = 0
                        end
                        if ruka.faze == 0 then
                            ruka.cinnost = 0
                        end
                    end,
                    [2] = function()
                        ruka.faze = 1 - ruka.faze
                        ruka.afaze = 8 + ruka.faze + ruka.smer * 2
                    end,
                }
            end
            ruka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pldicek()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pldicek.pocet = 0
        initPldici(pldicek)

        return function()
            progPldici(pldicek)
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_mutant()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false


        return function()
            if odd(game_getCycles()) then
                if dvere1.dir == dir_no and dvere2.dir == dir_no then
                    if 0 <= mutant.afaze and mutant.afaze <= 4 then
                        local rand20 = random(20)
                        if rand20 == 0 then
                            mutant.afaze = 5
                        elseif 1 <= rand20 and rand20 <= 3 then
                            mutant.afaze = random(5)
                        end
                    elseif 5 == mutant.afaze or mutant.afaze == 9 then
                        if random(4) == 2 then
                            mutant.afaze = 5 + random(5)
                        else
                            local rand20 = random(20)
                            if 0 <= rand20 and rand20 <= 1 then
                                mutant.afaze = random(5)
                            elseif 2 <= rand20 and rand20 <= 7 then
                                mutant.afaze = 6 + random(3)
                            end
                        end
                    end
                else
                    mutant.afaze = 9
                end
            end
            mutant:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_klicka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_zataras()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_horni1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dolni1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_zkum()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_horni2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dolni2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_kostra()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_oko()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_qldik1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_qldik2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_qldik3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_lahvac()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_oka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_malej()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_ruka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pldicek()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_mutant()
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

