
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky01.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.zatrpocitadlo = 1000 + random(4000)
        room.zavazi = 0
        room.klauspocitadlo = 500 + random(1500)
        room.stolecky = 0
        room.prycpocitadlo = 500 + random(1500)
        room.hrncisko = 0
        room.kresilko = 0
        room.ss = 0
        room.osam = 0
        local roompole = createArray(4)
        if roompole[3] == 2 then
            roompole[3] = 1
        end
        room.stoji = 0
        room.uprava = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.zatrpocitadlo > 0 then
                    room.zatrpocitadlo = room.zatrpocitadlo - 1
                end
                if room.klauspocitadlo > 0 then
                    room.klauspocitadlo = room.klauspocitadlo - 1
                end
                if room.prycpocitadlo > 0 then
                    room.prycpocitadlo = room.prycpocitadlo - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    pom1 = random(20)
                    if pokus == 1 then
                        pom1 = 3
                    end
                    if 0 <= pom1 and pom1 <= 5 then
                        addm(9 + random(35), "kuch-m-objev0")
                    elseif 6 <= pom1 and pom1 <= 9 then
                        addm(9 + random(35), "kuch-m-objev1")
                    elseif 10 <= pom1 and pom1 <= 17 then
                        addm(9 + random(42), "kuch-m-objev3")
                        if random(100) > pokus * 8 or random(100) < 30 then
                            addv(12, "kuch-v-varil")
                            addv(7, "kuch-v-problem")
                            addm(14, "kuch-m-noproblem")
                            addv(5, "kuch-v-podivej")
                        end
                    elseif pom1 == 18 then
                        addm(9 + random(35), "kuch-m-objev2")
                        room.zatrpocitadlo = -1
                    end
                elseif room.uvod == 1 and room.stolecky == 0 and big.pryc == 0 and random(70) == 1 then
                    room.stolecky = 1
                    if random(40 * pokus) < 50 then
                        addv(9 + random(100), "kuch-v-stolky0")
                    end
                elseif room.zatrpocitadlo == 0 then
                    room.zatrpocitadlo = -1
                    addm(9, "kuch-m-objev2")
                elseif room.zavazi == 0 and zavazedlo2.X == 39 and zavazedlo2.Y == 9 and random(10 * pokus) == 1 then
                    room.zavazi = 1
                    if pokus < 5 or random(100) < 40 then
                        addv(9, "kuch-v-stolky1")
                        if random(100) < 40 and room.zatrpocitadlo > -1 then
                            room.zatrpocitadlo = -1
                            addm(9, "kuch-m-objev2")
                        end
                    end
                elseif room.klauspocitadlo == 0 and big.pryc == 0 then
                    room.klauspocitadlo = 2000 + random(10000)
                    if pokus < 6 or random(100) < 50 then
                        addv(9, "kuch-v-stolky2")
                    end
                elseif room.prycpocitadlo == 0 and big.pryc == 0 then
                    room.prycpocitadlo = -1
                    if pokus < 10 or random(100) < 50 then
                        if random(100) < 70 then
                            addv(9, "kuch-v-odsud0")
                            if random(100) < 30 then
                                addv(9, "kuch-v-odsud1")
                            end
                            if random(100) < 25 then
                                addm(9, "kuch-m-premyslim0")
                            end
                        else
                            addv(9, "kuch-v-odsud1")
                        end
                        if random(100) < 90 or pokus == 1 then
                            if small.dir ~= dir_no and random(100) < 50 then
                                addm(6, "kuch-m-premyslim2")
                            elseif random(100) < 45 then
                                addm(9, "kuch-m-premyslim0")
                            else
                                addm(16, "kuch-m-premyslim1")
                            end
                        end
                    end
                elseif room.hrncisko == 0 and dist(spindira, small) < 2 and random(100) < 10 then
                    room.hrncisko = 1
                    if pokus < 6 or random(100) < 50 then
                        switch(random(3)){
                            [0] = function()
                                addm(9, "kuch-m-hrnec0")
                                if random(100) < 35 then
                                    addm(9, "kuch-m-hrnec2")
                                end
                            end,
                            [1] = function()
                                addm(9, "kuch-m-hrnec1")
                            end,
                            [2] = function()
                                addm(9, "kuch-m-hrnec2")
                            end,
                        }
                    end
                elseif room.kresilko == 0 and dist(kreslak, big) < 4 and (random(100) < 50 or roompole[1] == 0) then
                    room.kresilko = 1
                    addv(9, "kuch-v-kreslo0")
                    if random(100) < 70 then
                        addv(16, "kuch-v-ja")
                    end
                    if roompole[1] == 0 or random(100) < 70 then
                        if random(100) < 50 then
                            addm(9, "kuch-m-kreslo0")
                        else
                            addv(9, "kuch-v-kreslo1")
                            if random(100) < 65 then
                                addm(7, "kuch-m-kreslo2")
                            end
                        end
                    end
                    roompole[1] = 1
                elseif room.ss == 0 and dist(small, stolek) < 2 and random(100) == 1 then
                    addm(4, "kuch-m-stolky")
                    addv(8, "kuch-v-serie")
                    addm(8, "kuch-m-pekne")
                    room.ss = 1
                elseif room.osam == 0 and big.dole ~= 0 and random(100) == 1 then
                    room.osam = 1
                    addv(5, "kuch-v-obavam")
                elseif roompole[3] < 2 and dist(big, mecik) < 3 and random(50) == 1 then
                    if roompole[3] == 0 or random(2) == 1 then
                        roompole[3] = 2
                        addv(5, "kuch-v-mec")
                        addm(8, "kuch-m-porcovani")
                        addv(7, "kuch-v-nedela")
                    end
                elseif room.uprava == 0 and papir.dir ~= dir_no and random(14) == 1 then
                    room.uprava = 1
                    addv(7, "kuch-v-svitek"..random(2))
                    if random(2) == 1 then
                        addm(8, "kuch-m-recept")
                    else
                        addm(8, "kuch-m-kuchari")
                    end
                elseif room.stoji > 1000 + 2000 * roompole[2] and big.pryc == 1 then
                    room.stoji = 0
                    addm(16, "kuch-m-zapeklite")
                    roompole[2] = roompole[2] + 1
                end
            end
            room.stoji = room.stoji + 1
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        big.pryc = 0
        big.dole = 0

        return function()
            if big.X < 32 or big.Y > 13 then
                big.pryc = 1
                room.zavazi = 1
            end
            if big.X > 15 and big.Y > 20 then
                big.dole = 1
            else
                big.dole = 0
            end
            if big.dir ~= dir_no then
                room.stoji = 0
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        return function()
            if small.dir ~= dir_no then
                room.stoji = 0
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
    subinit = prog_init_big()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_small()
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

