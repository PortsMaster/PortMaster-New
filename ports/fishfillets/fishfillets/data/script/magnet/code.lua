
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky09.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.zacatek = 0
        room.vyresime = 0
        room.pristrojek = 0
        room.nahoda = 0
        room.zelezo = 0
        room.nezvlada = 0
        room.cas = 500 + random(4000)
        room.cas1 = 500 + random(7000)
        room.blesky = 0
        room.spatne = 0
        room.husikuze = 0
        room.bouchacka = 0
        room.hybe = 0
        room.malomista = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.cas > 0 then
                    room.cas = room.cas - 1
                end
                if room.cas1 > 0 then
                    room.cas1 = room.cas1 - 1
                end
                if room.hybe == 0 and small.dir ~= dir_no and magnetek.dir ~= dir_no then
                    room.hybe = 1
                    addm(random(42) + 9, "pap-m-zvlastni")
                    addv(9, "pap-v-prekvapeni")
                    if room.vyresime == 0 and random(100) < 50 then
                        room.vyresime = 1
                        addm(5 + random(4), "pap-m-teorie")
                    end
                elseif room.zacatek == 0 then
                    room.zacatek = 1
                    addv(42 + 9, "pap-v-ha")
                    addm(5 + random(4), "pap-m-magnet")
                    if random(100) < 35 then
                        addv(5 + random(4), "pap-v-potrebovat")
                    end
                elseif room.pristrojek == 0 and dist(superpristroj, small) < 2 and random(100) < 30 then
                    room.pristrojek = 1
                    addm(9, "pap-m-radio")
                    room.nahoda = random(3)
                    if pokus > 5 and random(100) < 40 then
                        room.nahoda = 4
                    end
                    switch(room.nahoda){
                        [0] = function()
                            addv(5 + random(4), "pap-v-radio")
                            if random(100) < 60 then
                                addm(5 + random(4), "pap-m-nechme")
                            end
                            addv(16, "pap-v-divny")
                        end,
                        [1] = function()
                            addv(5 + random(4), "pap-v-divny")
                            if random(100) < 50 then
                                addm(5 + random(4), "pap-m-nechme")
                            end
                        end,
                        [2] = function()
                            addv(5 + random(4), "pap-v-radio")
                            if room.vyresime == 0 and random(100) < 50 then
                                room.vyresime = 1
                                addm(5 + random(4), "pap-m-teorie")
                            end
                        end,
                    }
                elseif room.zelezo == 0 and (dist(konstrukce1, small) < 1 or dist(konstrukce2, small) < 1) and random(100) < 10 then
                    room.zelezo = 1
                    addm(9, "pap-m-ocel")
                    room.nahoda = random(2)
                    if pokus > 5 and random(100) < 40 then
                        room.nahoda = 2
                    end
                    switch(room.nahoda){
                        [0] = function()
                            addv(5 + random(4), "pap-v-vufu")
                            if room.nezvlada == 0 and random(100) < 40 then
                                room.nezvlada = 1
                                addm(9, "pap-m-naucit")
                                addm(15 + random(8), "pap-m-nepohnu")
                            end
                        end,
                        [1] = function()
                            room.nezvlada = 1
                            addm(9, "pap-m-naucit")
                            addm(15 + random(8), "pap-m-nepohnu")
                        end,
                    }
                elseif room.nezvlada == 0 and room.cas == 0 then
                    room.nezvlada = 1
                    addm(9, "pap-m-naucit")
                    addm(15 + random(8), "pap-m-nepohnu")
                elseif room.blesky == 0 and magnetek.kolik ~= 0 and room.cas1 == 0 then
                    if pokus < 6 or random(100) < 60 then
                        room.blesky = 1
                        addv(9, "pap-v-pole")
                        if random(100) < 70 then
                            room.spatne = 1
                            addm(5 + random(4), "pap-m-nedobre")
                        else
                            room.husikuze = 1
                            addm(5 + random(4), "pap-m-mraz")
                        end
                    end
                elseif room.malomista == 0 and big.X == 26 and (14 <= big.Y and big.Y <= 17) and bambitka.X == bambitka.XStart and bambitka.Y == bambitka.YStart and random(100) < 30 then
                    room.malomista = 1
                    addv(9, "pap-v-tesno")
                elseif room.bouchacka == 0 and dist(bambitka, small) < 3 then
                    room.bouchacka = 1
                    if pokus < 4 or random(100) < 30 then
                        addm(9, "pap-m-coje")
                        room.nahoda = random(5)
                        switch(room.nahoda){
                            [0] = function()
                                addm(16, "pap-m-pistole")
                                addv(5 + random(4), "pap-v-laserova")
                                addm(12, "pap-m-jejedno")
                                addv(5 + random(4), "pap-v-nemir")
                                addm(5 + random(4), "pap-m-nejde")
                            end,
                            [1] = function()
                                addm(16, "pap-m-pistole")
                            end,
                            [2] = function()
                                addv(5 + random(4), "pap-v-laserova")
                                if random(100) < 40 then
                                    addm(12, "pap-m-jejedno")
                                end
                            end,
                        }
                    end
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_magnetek()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        magnetek.kolik = 0

        return function()
            magnetek.kolik = 0
            if magnetek.anim == "" and isIn(magnetek.X, {12, 11}) and random(100) < 10 then
                magnetek.kolik = random(11) + 1
            end
            kolik_table = {
                [1] = function()
                    setanim(magnetek, "a1d?0-2a0S[kolik],0")
                end,
                [3] = function()
                    setanim(magnetek, "a1d?0-2a2a1a0S[kolik],0")
                end,
                [5] = function()
                    --TODO: was typo here? S11 or S1?
                    setanim(magnetek, "a1d?0-2a2a3a2a1a0S[kolik],0")
                end,
                [7] = function()
                    setanim(magnetek, "a1d?0-2a2a3a4a2a1a0S[kolik],0")
                end,
                [9] = function()
                    setanim(magnetek, "a1d?0-2a?1-4a?1-4a1a0S[kolik],0")
                end,
                [10] = function()
                    setanim(magnetek, "a1d?0-2a?1-4a?1-4a?1-4a1a0S[kolik],0")
                end,
                [11] = function()
                    setanim(magnetek, "a1d?0-2a?1-4a?1-4a?1-4a?1-4a1a0S[kolik],0")
                end,
            }

            kolik_table[2] = kolik_table[1]
            kolik_table[4] = kolik_table[3]
            kolik_table[6] = kolik_table[5]
            kolik_table[8] = kolik_table[7]
            switch(magnetek.kolik)(kolik_table)

            if magnetek.anim ~= "" then
                goanim(magnetek)
            end
            magnetek:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_superpristroj()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        superpristroj.faze = 0
        superpristroj.smer = 0

        return function()
            if superpristroj.faze < 6 and random(3) == 0 then
                superpristroj.smer = 1 - superpristroj.smer
            end
            if superpristroj.anim ~= "" then
                goanim(superpristroj)
            elseif superpristroj.smer == 0 and superpristroj.faze < 6 then
                superpristroj.faze = superpristroj.faze + 1
                superpristroj.afaze = superpristroj.faze
            elseif superpristroj.smer == 0 and superpristroj.faze == 6 then
                superpristroj.faze = superpristroj.faze - 1
                superpristroj.smer = 1 - superpristroj.smer
                setanim(superpristroj, "a6a7a8a7a6")
            elseif superpristroj.smer == 1 and superpristroj.faze > 0 then
                superpristroj.faze = superpristroj.faze - 1
                superpristroj.afaze = superpristroj.faze
            else
                superpristroj.smer = 1 - superpristroj.smer
                superpristroj.faze = superpristroj.faze + 1
                superpristroj.afaze = superpristroj.faze
            end
            superpristroj:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_magnetek()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_superpristroj()
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

