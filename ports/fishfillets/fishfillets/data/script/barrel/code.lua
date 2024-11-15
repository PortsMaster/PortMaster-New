
file_include('script/share/prog_border.lua')

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
    barel:setGoal("goal_out")

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.celakrajni = 0
        room.ozviratkach = {}
        room.hl1 = random(400) + 400
        room.hl2 = room.hl1 + random(800) + 800
        room.hl3 = room.hl2 + random(1600) + 1600
        room.hl4 = room.hl3 + random(3200) + 3200
        room.onoze = 0
        room.opldech = 0
        room.okukajde = 0
        room.okrabovi = 0
        room.okachne = 0

        return function()
            if stdBorderReport() then
                addm(6, "bar-m-barel")
                if random(100) < 30 or room.celakrajni == 0 then
                    addv(random(10) + 5, "bar-v-genofond")
                end
                room.celakrajni = 1
            end
            if no_dialog() and isReady(small) and isReady(big) then
                if room.hl1 > 0 then
                    room.hl1 = room.hl1 - 1
                end
                if room.hl2 > 0 then
                    room.hl2 = room.hl2 - 1
                end
                if room.hl3 > 0 then
                    room.hl3 = room.hl3 - 1
                end
                if room.hl4 > 0 then
                    room.hl4 = room.hl4 - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    switch(pokus){
                        [1] = function()
                            pom1 = 5
                        end,
                        [2] = function()
                            pom1 = randint(2, 4)
                        end,
                        default = function()
                            pom1 = random(6)
                        end,
                    }
                    adddel(10 + random(20))
                    if pom1 >= 4 then
                        switch(random(2)){
                            [0] = function()
                                addv(0, "bar-v-videt0")
                            end,
                            [1] = function()
                                addm(0, "bar-m-videt1")
                            end,
                        }
                    end
                    if pom1 >= 5 then
                        addv(5, "bar-v-co")
                    end
                    if pom1 >= 2 then
                        addm(10, "bar-m-pobit")
                        planDialogSet(2, "bar-x-suckne", 201, pldik, "cinnost")
                        addv(10, "bar-v-priciny")
                        planDialogSet(2, "bar-x-suckano", 202, pldik, "cinnost")
                    end
                    if pom1 >= 4 then
                        addm(random(30) + 10, "bar-m-no")
                    end
                    if pom1 >= 2 then
                        addv(5, "bar-v-sud")
                    end
                    if pom1 >= 3 then
                        addm(5, "bar-m-panb")
                    end
                elseif room.hl1 == 0 or room.hl2 == 0 or room.hl3 == 0 or room.hl4 == 0 then
                    if room.hl1 == 0 then
                        room.hl1 = -1
                    end
                    if room.hl2 == 0 then
                        room.hl2 = -1
                    end
                    if room.hl3 == 0 then
                        room.hl3 = -1
                    end
                    if room.hl4 == 0 then
                        room.hl4 = -1
                    end
                    if countPairs(room.ozviratkach) == 0 then
                        pom1 = random(2)
                    elseif countPairs(room.ozviratkach) == 4 then
                        room.ozviratkach = {}
                        pom1 = random(4)
                    else
                        repeat
                            pom1 = random(4)
                        until not room.ozviratkach[pom1]
                    end
                    room.ozviratkach[pom1] = true
                    adddel(50 + random(100))
                    switch(pom1){
                        [0] = function()
                            addm(0, "bar-m-rada")
                            addv(7, "bar-v-kdyby" ..random(2))
                        end,
                        [1] = function()
                            addm(0, "bar-m-mutanti")
                            if random(100) < 50 then
                                addv(10, "bar-v-ufouni")
                            end
                            addm(random(50) + 10, "bar-m-zmeni")
                        end,
                        [2] = function()
                            addv(0, "bar-v-lih")
                            addm(8, "bar-m-fdto")
                            pldotec:planDialog(3, "bar-x-vypr")
                            addm(10, "bar-m-promin")
                        end,
                        [3] = function()
                            addv(0, "bar-v-sbirka")
                            addm(10, "bar-m-dost" ..random(2))
                        end,
                    }
                elseif room.onoze == 0 and nozka.cinnost < 20 and dist(small, nozka) < 5 and random(1000) < 2 then
                    room.onoze = 1
                    addm(3, "bar-m-noha")
                elseif room.opldech == 0 and dist(big, pldotec) <= 5 and random(100) < 1 then
                    room.opldech = 1
                    addv(10, "bar-v-pld")
                    addm(6, "bar-m-pudy")
                    addv(2, "bar-v-traverza")
                    planDialogSet(2, "bar-x-suckne", 201, pldik, "cinnost")
                elseif room.okukajde == 0 and kukajda.dir ~= dir_no and random(100) < 2 and small.dir ~= dir_no then
                    room.okukajde = 1
                    addm(10, "bar-m-rybka")
                    if random(100) < 70 then
                        addv(random(30) + 5, "bar-v-fotka")
                    end
                elseif room.okrabovi == 0 and look_at(big, krabik) and dist(big, krabik) <= 3 and random(100) < 1 then
                    room.okrabovi = 1
                    addv(10, "bar-v-krab")
                elseif room.okachne == 0 and kachnicka.dir ~= dir_no and small.dir ~= dir_no and random(100) < 10 then
                    room.okachne = 1
                    addm(5, "bar-m-kachna")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_barel()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        setanim(barel, "a0d8a1a2a3a4d3a3a2a1R")

        return function()
            goanim(barel)
            barel:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_kachnicka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        kachnicka.cinnost = random(100) + 10

        return function()
            if kachnicka.cinnost > 0 then
                if kachnicka:isTalking() then
                    kachnicka:killSound()
                end
                if odd(game_getCycles()) and random(100) < 10 then
                    kachnicka.afaze = random(5)
                end
                kachnicka.cinnost = kachnicka.cinnost - 1
                if kachnicka.cinnost == 0 then
                    kachnicka.afaze = 5
                    kachnicka.cinnost = -30 - random(60)
                end
            else
                if not kachnicka:isTalking() then
                    kachnicka:talk("bar-x-kchkch", VOLUME_LOW, -1)
                end
                kachnicka.afaze = math.mod(kachnicka.afaze - 5 + 1, 4) + 5
                kachnicka.cinnost = kachnicka.cinnost + 1
                if kachnicka.cinnost == 0 then
                    kachnicka.afaze = 0
                    kachnicka.cinnost = 30 + random(100)
                end
            end
            kachnicka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_had()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        had.streva = random(4)
        had.huba = random(3)

        return function()
            if math.mod(game_getCycles(), 3) == 0 then
                if (had.huba == 0) then
                        if random(1000) < 15 then
                            had.huba = random(2) + 1
                        end
                else
                        if random(1000) < 15 then
                            had.huba = 0
                        elseif random(100) < 50 then
                            had.huba = 3 - had.huba
                        end
                end
            end
            had.streva = math.mod(had.streva + 1, 4)
            had.afaze = 4 * had.huba + had.streva
            had:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_ocicko()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        ocicko.cinnost = 0

        return function()
            if (ocicko.cinnost == 0) then
                    local rnd = random(8)
                    if random(100) < 10 then
                        if (rnd >= 0) and (rnd <= 2) then
                                ocicko.citac = random(5) + 5
                                ocicko.cinnost = 1
                                ocicko.faze = random(2) * 2
                        elseif (rnd == 3) then
                                ocicko.citac = random(3) + 2
                                ocicko.cinnost = 2
                                ocicko.faze = random(2) * 2
                        elseif (rnd >= 4) and (rnd <= 6) then
                                ocicko.citac = random(12) + 12
                                ocicko.cinnost = 3 + random(2)
                        elseif (rnd == 7) then
                                ocicko.citac = random(10) + 2
                                ocicko.cinnost = 5
                        end
                    end
            elseif (ocicko.cinnost == 1) or (ocicko.cinnost == 2) then
                    switch(ocicko.faze){
                        [0] = function()
                            if ocicko.cinnost == 1 then
                                ocicko.afaze = 1
                            else
                                ocicko.afaze = 3
                            end
                            if random(100) < 20 then
                                ocicko.faze = ocicko.faze + 1
                            end
                        end,
                        [1] = function()
                            ocicko.afaze = 0
                            ocicko.faze = ocicko.faze + 1
                        end,
                        [2] = function()
                            if ocicko.cinnost == 1 then
                                ocicko.afaze = 2
                            else
                                ocicko.afaze = 4
                            end
                            if random(100) < 20 then
                                ocicko.faze = ocicko.faze + 1
                            end
                        end,
                        [3] = function()
                            ocicko.afaze = 0
                            ocicko.citac = ocicko.citac - 1
                            if ocicko.citac == 0 then
                                ocicko.cinnost = 0
                            else
                                ocicko.faze = 0
                            end
                        end,
                    }
                elseif (ocicko.cinnost >= 3) or (ocicko.cinnost <= 5) then
                    switch(ocicko.cinnost){
                        [3] = function()
                            switch(ocicko.afaze){
                                [0] = function()
                                    ocicko.afaze = random(4) + 1
                                end,
                                [1] = function()
                                    ocicko.afaze = 3
                                end,
                                [2] = function()
                                    ocicko.afaze = 4
                                end,
                                [3] = function()
                                    ocicko.afaze = 2
                                end,
                                [4] = function()
                                    ocicko.afaze = 1
                                end,
                            }
                        end,
                        [4] = function()
                            switch(ocicko.afaze){
                                [0] = function()
                                    ocicko.afaze = random(4) + 1
                                end,
                                [1] = function()
                                    ocicko.afaze = 4
                                end,
                                [2] = function()
                                    ocicko.afaze = 3
                                end,
                                [3] = function()
                                    ocicko.afaze = 1
                                end,
                                [4] = function()
                                    ocicko.afaze = 2
                                end,
                            }
                        end,
                        [5] = function()
                            if random(100) < 40 then
                                ocicko.afaze = random(5)
                            end
                        end,
                    }
                    ocicko.citac = ocicko.citac - 1
                    if ocicko.citac == 0 then
                        ocicko.cinnost = 0
                        ocicko.afaze = 0
                    end
            end
            ocicko:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_kukajda()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        kukajda.ploutvicka = 0
        kukajda.oci = 0
        kukajda.mrknuti = 0

        return function()
            kukajda.ploutvicka = math.mod(kukajda.ploutvicka + 1, 6)
            if (kukajda.ploutvicka == 0) or (kukajda.ploutvicka == 1) then
                    kukajda.afaze = 0
            elseif (kukajda.ploutvicka == 2) or (kukajda.ploutvicka == 5) then
                    kukajda.afaze = 1
            elseif (kukajda.ploutvicka == 3) or (kukajda.ploutvicka == 4) then
                    kukajda.afaze = 2
            end

            if random(100) < 3 then
                kukajda.oci = random(5)
            end
            if kukajda.mrknuti > 0 then
                kukajda.mrknuti = kukajda.mrknuti - 1
                kukajda.afaze = kukajda.afaze + 15
            else
                kukajda.afaze = kukajda.afaze + kukajda.oci * 3
                if random(100) < 4 then
                    kukajda.mrknuti = random(3) + 2
                end
            end
            kukajda:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_killer()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        killer.ocas = 0
        killer.usmev = 0

        return function()
            if odd(game_getCycles()) then
                killer.ocas = 1 - killer.ocas
            end
            if killer.usmev > 0 then
                killer.usmev = killer.usmev - 1
                killer.afaze = killer.ocas
            else
                if random(100) < 2 then
                    killer.usmev = random(30) + 10
                    killer:talk("bar-x-gr" ..random(3), VOLUME_LOW)
                end
                killer.afaze = 2 * killer.ocas + 2
                if random(100) < 7 then
                    killer.afaze = killer.afaze + 1
                end
            end
            killer:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlubinna()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        hlubinna.ploutvicka = 0
        hlubinna.zzzeni = 0

        return function()
            hlubinna.ploutvicka = math.mod(hlubinna.ploutvicka + 1, 5)
            if (hlubinna.ploutvicka == 3) then
                    hlubinna.afaze = 1
            elseif (hlubinna.ploutvicka == 4) then
                    hlubinna.afaze = 0
            else
                    hlubinna.afaze = hlubinna.ploutvicka
            end

            if hlubinna.zzzeni > 0 then
                hlubinna.afaze=hlubinna.afaze + 6
                hlubinna.zzzeni = hlubinna.zzzeni - 1
            elseif random(100) < 5 then
                hlubinna.afaze = hlubinna.afaze + 3
            elseif random(1000) < 15 then
                hlubinna.afaze=hlubinna.afaze + 6
                hlubinna.zzzeni = 5
                hlubinna:talk("bar-x-zzz", VOLUME_LOW)
            end
            hlubinna:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krabik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krabik.oci = 0

        return function()
            if odd(game_getCycles()) and random(100) < 10 then
                krabik.oci = random(5)
            end
            if random(100) < 10 then
                krabik.afaze = 5
            else
                krabik.afaze = krabik.oci
            end
            krabik:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_baget()
        return function()
            if random(100) < 6 then
                baget.afaze = 1
            else
                baget.afaze = 0
            end
            baget:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_nozka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        nozka.cinnost = random(100) + 20
        nozka.dup = 0
        nozka.oci = 0

        return function()
            if odd(game_getCycles()) and random(100) < 10 then
                nozka.oci = random(5)
            end
            if nozka.cinnost > 0 then
                nozka.cinnost = nozka.cinnost - 1
                nozka.dup = 0
                if nozka.cinnost == 0 then
                    nozka.cinnost = -20 - random(60)
                end
            else
                if math.mod(game_getCycles(), 3) == 0 then
                    nozka.dup = 1 - nozka.dup
                    if nozka.dup == 0 then
                        nozka:talk("bar-x-tup", VOLUME_LOW)
                    end
                end
                if nozka.cinnost < -1 or nozka.dup == 0 then
                    nozka.cinnost = nozka.cinnost + 1
                end
                if nozka.cinnost == 0 then
                    nozka.cinnost = 10 + random(150)
                end
            end
            if random(100) < 4 then
                nozka.afaze = 5
            else
                nozka.afaze = nozka.oci
            end
            nozka.afaze = nozka.afaze + nozka.dup * 6
            nozka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pldik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pldik.cinnost = 0
        pldik.oci = 0
        pldik.suckani = 0

        return function()
            switch(pldik.cinnost){
                [0] = function()
                    if random(1000) < 5 then
                        pldik.cinnost = 1
                    end
                    if random(100) < 5 then
                        pldik.oci = random(5)
                        if pldik.oci > 0 then
                            pldik.oci = pldik.oci + 1
                        end
                    end
                    if pldik.suckani == 0 and random(100) < 4 then
                        pldik.suckani = random(5) + 1
                        pldik.suckfaze = 0
                    end
                end,
                [1] = function()
                    if random(1000) < 10 then
                        pldik.cinnost = 0
                    end
                    pldik.oci = 6
                    if pldik.suckani == 0 and random(100) < 4 then
                        pldik.suckani = random(4) + 1
                        pldik.suckfaze = 0
                    end
                end,
                [201] = function()
                    if not pldik:isTalking() then
                        pldik.cinnost = 0
                    end
                    pldik.oci = 1
                    if pldik.suckani == 0 then
                        pldik.suckani = 1000
                        pldik.suckfaze = 0
                    end
                end,
                [202] = function()
                    if not pldik:isTalking() then
                        pldik.cinnost = 0
                    end
                    pldik.oci = 0
                    if pldik.suckani == 0 then
                        pldik.suckani = 1000
                        pldik.suckfaze = 0
                    end
                end,
            }
            pldik.afaze = pldik.oci * 2
            if random(100) < 5 then
                pldik.afaze = 12
            end
            if pldik.suckani > 0 then
                if (pldik.suckfaze == 0) then
                        if pldik.cinnost < 200 then
                            pldik:talk("bar-x-suck" ..random(4), VOLUME_LOW)
                        end
                elseif isRange(pldik.suckfaze, 1, 3) then
                        pldik.afaze = pldik.afaze + 1
                elseif (pldik.suckfaze == 5) then
                        pldik.suckani = pldik.suckani - 1
                end
                pldik.suckfaze = math.mod(pldik.suckfaze + 1, 6)
            end
            pldik:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_shark()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        shark.oci = random(2)
        shark.pusa = random(2)

        return function()
            if random(1000) < 5 then
                shark.oci = 1 - shark.oci
            end
            if random(1000) < 5 then
                shark.pusa = 1 - shark.pusa
            end
            shark.afaze = shark.oci + shark.pusa * 2
            if shark.oci == 0 and random(100) < 3 then
                shark.afaze = shark.afaze + 1
            end
            shark:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pldotec()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pldotec.vlnit = 0
        pldotec.del = 0
        pldotec.ocko = 0
        pldotec.smer = 0
        pldotec.faze = 0
        pldotec.smutny = 0

        return function()
            switch(pldotec.dir){
                [dir_no] = function()
                    if pldotec.vlnit == -1 then
                        pldotec.vlnit = 8
                    end
                end,
                [dir_down] = function()
                    pldotec.vlnit = -1
                end,
                default = function()
                    pldotec.vlnit = 8
                end,
            }
            if pldotec.vlnit > 0 then
                pldotec.smutny = 0
            end
            if pldotec.vlnit > 0 then
                if pldotec.del == 0 then
                    if (pldotec.vlnit >= 6) and (pldotec.vlnit <= 8) then
                            pldotec.del = 1
                    elseif (pldotec.vlnit >= 3) and (pldotec.vlnit <= 5) then
                            pldotec.del = 2
                    else
                            pldotec.del = 3
                    end

                    if random(2) == 0 then
                        pldotec.afaze = math.mod(pldotec.afaze + 1, 4)
                    else
                        pldotec.afaze = math.mod(pldotec.afaze + 3, 4)
                    end
                    pldotec.vlnit = pldotec.vlnit - 1
                    if pldotec.vlnit == 0 then
                        pldotec.del = 0
                    end
                    if pldotec.vlnit == 0 then
                        pldotec.afaze = 0
                    elseif pldotec.vlnit == 1 then
                        pldotec.afaze = 3
                    end
                else
                    pldotec.del = pldotec.del - 1
                end
            elseif pldotec.smutny > 0 then
                if pldotec.ocko == 0 then
                    if random(100) < 10 then
                        pldotec.ocko = 3
                    end
                end
                if pldotec.ocko > 0 then
                    pldotec.ocko = pldotec.ocko - 1
                end
                if pldotec.ocko > 0 then
                    pldotec.afaze = 15
                else
                    pldotec.afaze = 14
                end
                pldotec.smutny = pldotec.smutny - 1
            else
                if random(100) < 10 then
                    pldotec.smer = 1 - pldotec.smer
                end
                if (pldotec.faze == 0) then
                        pldotec.afaze = 0
                        if random(100) < 10 then
                            pldotec.faze = 1
                        end
                elseif (pldotec.faze == 1) or (pldotec.faze == 4) then
                        pldotec.faze = pldotec.faze + 1
                        pldotec.afaze = 4
                elseif (pldotec.faze == 5) then
                        pldotec.afaze = 0
                        pldotec.faze = 0
                else
                        pldotec.faze = pldotec.faze + 1
                        pldotec.afaze = 5
                end

                switch(pldotec.afaze){
                    [0] = function()
                        if pldotec.smer == 1 then
                            pldotec.afaze = 6
                        end
                    end,
                    [4] = function()
                        if pldotec.smer == 1 then
                            pldotec.afaze = 7
                        end
                    end,
                }
                if pldotec.ocko == 0 then
                    if random(100) < 10 then
                        pldotec.ocko = 3
                    end
                end
                if pldotec.ocko > 0 then
                    pldotec.ocko = pldotec.ocko - 1
                end
                if pldotec.ocko > 0 then
                    if pldotec.afaze == 0 then
                        pldotec.afaze = 9
                    else
                        pldotec.afaze = pldotec.afaze + 6
                    end
                end
            end
            pldotec:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_levahlava()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        levahlava.kouka = random(3)
        levahlava.makoukat = levahlava.kouka
        levahlava.cinnost = 0

        return function()
            if levahlava.kouka == 0 and pravahlava.kouka == 0 and levahlava.cinnost == 0 and levahlava.cinnost == 0 and levahlava.makoukat == 0 and pravahlava.makoukat == 0 and random(100) < 5 then
                levahlava.cinnost = 2
                pravahlava.cinnost = 2
            end
            if levahlava.kouka ~= levahlava.makoukat then
                if levahlava.kouka == 1 or levahlava.makoukat == 1 then
                    levahlava.kouka = levahlava.makoukat
                else
                    levahlava.kouka = 1
                end
            end
            switch(levahlava.cinnost){
                [0] = function()
                    if random(1000) < 5 then
                        levahlava.cinnost = 1
                    elseif random(100) < 5 then
                        levahlava.makoukat = random(3)
                    end
                    levahlava.afaze = levahlava.kouka * 2
                    if levahlava.afaze > 0 then
                        levahlava.afaze = levahlava.afaze + 1
                    end
                    if random(100) < 95 then
                        levahlava.afaze = levahlava.afaze + 1
                    end
                end,
                [1] = function()
                    levahlava.afaze = levahlava.kouka * 2
                    if levahlava.afaze > 0 then
                        levahlava.afaze = levahlava.afaze + 1
                    end
                    if random(1000) < 5 then
                        levahlava.cinnost = 0
                    end
                end,
                [2] = function()
                    levahlava.afaze = 2
                    if random(100) < 3 then
                        levahlava.cinnost = 0
                        pravahlava.cinnost = 0
                    end
                end,
            }
            levahlava:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pravahlava()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pravahlava.kouka = random(3)
        pravahlava.makoukat = pravahlava.kouka
        pravahlava.cinnost = 0

        return function()
            if pravahlava.kouka ~= pravahlava.makoukat then
                if pravahlava.kouka == 1 or pravahlava.makoukat == 1 then
                    pravahlava.kouka = pravahlava.makoukat
                else
                    pravahlava.kouka = 1
                end
            end
            switch(pravahlava.cinnost){
                [0] = function()
                    if random(1000) < 5 then
                        pravahlava.cinnost = 1
                    elseif random(100) < 5 then
                        pravahlava.makoukat = random(3)
                    end
                    pravahlava.afaze = pravahlava.kouka * 2
                    if pravahlava.afaze > 0 then
                        pravahlava.afaze = pravahlava.afaze + 1
                    end
                    if random(100) < 95 then
                        pravahlava.afaze = pravahlava.afaze + 1
                    end
                end,
                [1] = function()
                    pravahlava.afaze = pravahlava.kouka * 2
                    if pravahlava.afaze > 0 then
                        pravahlava.afaze = pravahlava.afaze + 1
                    end
                    if random(1000) < 5 then
                        pravahlava.cinnost = 0
                    end
                end,
                [2] = function()
                    pravahlava.afaze = 2
                end,
            }
            pravahlava:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_barel()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_kachnicka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_had()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_ocicko()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_kukajda()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_killer()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlubinna()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krabik()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_baget()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_nozka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pldik()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_shark()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pldotec()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_levahlava()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pravahlava()
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

