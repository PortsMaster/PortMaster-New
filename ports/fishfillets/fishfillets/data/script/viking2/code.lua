
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky05.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        if pokus == 1 or random(100) < 40 then
            room.quvod = random(10) + 10
        else
            room.quvod = -2
        end
        room.chechtoni = 0
        room.chechthlaska = 0
        room.moczbabelcu = 0
        room.qvousy = 0
        room.pravvousy = 70
        room.qpejsek = 300 + random(600)
        room.lastval = 0

        return function()
            if not isReady(small) or not isReady(big) then
                room.quvod = -1
                room.qpejsek = -1
            end
            if room.quvod > 0 then
                room.quvod = room.quvod - 1
            elseif room.quvod == 0 then
                room.quvod = -1
                addm(5, "dr1-m-dlouho")
                addv(5, "dr1-v-urcite")
                if random(4) > 0 then
                    addv(30 + random(30), "dr1-v-olaf")
                end
                if random(4) > 0 then
                    addv(30 + random(30), "dr1-v-leif")
                end
                if random(4) > 0 then
                    addv(30 + random(30), "dr1-v-harold")
                end
                if random(4) > 0 then
                    addv(30 + random(30), "dr1-v-snorr")
                end
                if random(4) > 0 then
                    addv(30 + random(30), "dr1-v-thorson")
                end
                if random(6) > 0 then
                    planDialogSet(50 + random(30), "dr1-x-erik", 116, hlavadr, "mluvi")
                end
                planSet(room, "quvod", -2)
            elseif room.quvod == -2 then
                if viking7.dostal == -1 then
                    viking7.dostal = 0
                end
            end
            if not pesos:isTalking() and room.qpejsek > 0 then
                room.qpejsek = room.qpejsek - 1
            end
            if room.quvod == -2 then
                if room.moczbabelcu == 1 then
                    if no_dialog() then
                        planDialogSet(2 + random(20), "dr-1-achjo", 210, viking1, "cinnost")
                    end
                    room.moczbabelcu = 0
                elseif room.chechtoni == 1 then
                    if no_dialog() then
                        room.chechthlaska = room.chechthlaska + 1
                        switch(room.chechthlaska){
                            [1] = function()
                                planDialogSet(5 + random(20), "dr-1-procja", 210, viking1, "cinnost")
                            end,
                            [2] = function()
                                planDialogSet(5 + random(20), "dr-1-chechtajici", 210, viking1, "cinnost")
                            end,
                        }
                    end
                    room.chechtoni = 0
                elseif no_dialog() then
                    if random(1000) < 7 and viking5.cinnost == 0 then
                        viking5.cinnost = 1
                    elseif random(10000) < room.pravvousy then
                        local qvousy_table = {
                            [0] = function()
                                switch(random(2)){
                                    [0] = function()
                                        planDialogSet(10, "dr-3-spravny", 230, viking3, "cinnost")
                                    end,
                                    [1] = function()
                                        planDialogSet(10, "dr-3-cojeto", 230, viking3, "cinnost")
                                    end,
                                }
                                switch(random(2)){
                                    [0] = function()
                                        planDialogSet(6, "dr-4-magazin", 240, viking4, "cinnost")
                                    end,
                                    [1] = function()
                                        planDialogSet(6, "dr-4-copy", 240, viking4, "cinnost")
                                    end,
                                }
                                room.qvousy = 10
                                room.pravvousy = 50
                            end,
                            [10] = function()
                                repeat
                                    pom1 = random(3) + 1
                                until pom1 ~= room.qvousy - 10
                                if room.qvousy == 10 then
                                    room.qvousy = pom1 + 10
                                else
                                    room.qvousy = 20
                                end
                                switch(pom1){
                                    [1] = function()
                                        planDialogSet(6, "dr-3-radeji", 230, viking3, "cinnost")
                                        planDialogSet(3, "dr-4-moderni", 240, viking4, "cinnost")
                                    end,
                                    [2] = function()
                                        planDialogSet(6, "dr-4-myslis", 240, viking4, "cinnost")
                                        planDialogSet(0, "dr-3-samozrejme", 230, viking3, "cinnost")
                                        planDialogSet(10, "dr-4-budu", 240, viking4, "cinnost")
                                        planDialogSet(5, "dr-4-hmmm", 241, viking4, "cinnost")
                                        planDialogSet(2, "dr-4-ne", 240, viking4, "cinnost")
                                    end,
                                    [3] = function()
                                        planDialogSet(6, "dr-4-erik", 240, viking4, "cinnost")
                                        planDialogSet(0, "dr-3-nesmysl", 230, viking3, "cinnost")
                                        planDialogSet(0, "dr-4-taky", 240, viking4, "cinnost")
                                        planDialogSet(0, "dr-3-nemel", 230, viking3, "cinnost")
                                    end,
                                }
                                room.pravvousy = 40
                            end,
                            [20] = function()
                                room.pravvousy = room.pravvousy - 5
                                switch(random(4)){
                                    [0] = function()
                                        planDialogSet(10, "dr-3-mladez", 230, viking3, "cinnost")
                                    end,
                                    [1] = function()
                                        planDialogSet(10, "dr-3-chlap", 230, viking3, "cinnost")
                                    end,
                                    [2] = function()
                                        planDialogSet(10, "dr-3-mladi", 230, viking3, "cinnost")
                                    end,
                                    [3] = function()
                                        planDialogSet(10, "dr-4-stejne", 240, viking4, "cinnost")
                                    end,
                                }
                            end,
                        }

                        qvousy_table[11] = qvousy_table[10]
                        qvousy_table[12] = qvousy_table[10]
                        qvousy_table[13] = qvousy_table[10]

                        switch(room.qvousy)(qvousy_table)
                    elseif random(1000) < 4 then
                        pom1 = random(3) + 1
                        if pom1 == room.lastval then
                            pom1 = 4
                        end
                        room.lastval = pom1
                        switch(pom1){
                            [1] = function()
                                planSet(viking2, "cinnost", -1)
                                viking2:planDialog(5, "dr-2-uzbudeme"..(random(2) + 1))
                                planDialogSet(3, "dr-1-aztambudem", 210, viking1, "cinnost")
                            end,
                            [2] = function()
                                planSet(viking2, "cinnost", -1)
                                viking2:planDialog(5, "dr-2-odskocit")
                                planDialogSet(3, "dr-1-pockej", 210, viking1, "cinnost")
                            end,
                            [3] = function()
                                planSet(viking2, "cinnost", -1)
                                viking2:planDialog(5, "dr-2-netrva")
                                planDialogSet(3, "dr-1-trpelivost", 210, viking1, "cinnost")
                            end,
                            [4] = function()
                                planSet(viking2, "cinnost", -1)
                                viking2:planDialog(5, "dr-2-urcite")
                                planDialogSet(3, "dr-1-bojovnik", 210, viking1, "cinnost")
                            end,
                        }
                    elseif room.qpejsek == 0 and pesos:isTalking() then
                        room.qpejsek = -1
                        addm(10 + random(30), "dr-m-podivej")
                        pom1 = random(2)
                        if pom1 == 0 or random(2) == 0 then
                            addm(3, "dr-m-nedycha")
                        end
                        switch(pom1){
                            [0] = function()
                                addv(6, "dr-v-napsa")
                            end,
                            [1] = function()
                                addv(7, "dr-v-nato")
                            end,
                        }
                    end
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_viking1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        viking1.cinnost = 0

        return function()
            switch(viking1.cinnost){
                [0] = function()
                    if random(100) < 5 then
                        viking1.afaze = random(3)
                    end
                end,
                [210] = function()
                    viking1.afaze = random(3)
                end,
            }
            viking1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_viking3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        viking3.cinnost = 0

        return function()
            switch(viking3.cinnost){
                [0] = function()
                    viking3.afaze = 0
                end,
                [230] = function()
                    viking3.afaze = random(2) * 2
                end,
            }
            if random(100) < 5 then
                viking3.afaze = viking3.afaze + 1
            end
            viking3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_viking4()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        viking4.cinnost = 0

        return function()
            switch(viking4.cinnost){
                [0] = function()
                    viking4.afaze = 0
                end,
                [240] = function()
                    if odd(game_getCycles()) then
                        viking4.afaze = math.floor(viking4.afaze / 2)
                        if viking4.afaze == 0 or viking4.afaze == 1 then
                                if random(100) < 20 then
                                    viking4.afaze = 2 + random(2)
                                else
                                    viking4.afaze = 1 - viking4.afaze
                                end
                        elseif viking4.afaze == 2 or viking4.afaze == 3 then
                                if random(100) < 35 then
                                    viking4.afaze = random(2)
                                else
                                    viking4.afaze = 5 - viking4.afaze
                                end
                        end
                        viking4.afaze = viking4.afaze + viking4.afaze
                    end
                end,
                [241] = function()
                    viking4.afaze = 6
                end,
            }
            if random(100) < 5 then
                viking4.afaze = viking4.afaze + 1
            end
            viking4:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_viking5()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        viking5.cinnost = 0
        viking5.poslhlaska = 0
        viking5.pochlasek = 0

        return function()
            switch(viking5.cinnost){
                [0] = function()
                    viking5.faze = 0
                    if random(1000) < 3 then
                        viking5.cinnost = 2
                    end
                end,
                [1] = function()
                    switch(viking5.faze){
                        [0] = function()
                            viking5.afaze = 4
                            pom1 = random(4) + 1
                            if pom1 == viking5.poslhlaska then
                                pom1 = 5
                            end
                            viking5:planDialog(0, "dr-5-srab"..pom1)
                            viking5.poslhlaska = pom1
                            viking5.faze = viking5.faze + 1
                            viking5.pochlasek = viking5.pochlasek + 1
                        end,
                        [1] = function()
                            if viking5:isTalking() then
                                viking5.afaze = 2 + random(2) * 2
                                if viking5.afaze == 2 then
                                    if random(100) < 20 then
                                        viking5.afaze = viking5.afaze - 1 + 2 * random(2)
                                    end
                                end
                            else
                                viking5.faze = viking5.faze + 1
                            end
                        end,
                        [2] = function()
                            if isIn(viking5.pochlasek, {3, 8, 15, 20, 30, 50}) then
                                room.moczbabelcu = 1
                            end
                            viking5.cinnost = 2
                            viking5.faze = 0
                        end,
                    }
                end,
                [2] = function()
                    switch(viking5.faze){
                        [0] = function()
                            viking5.delay = random(5) + 10
                            viking5.faze = viking5.faze + 1
                        end,
                        [1] = function()
                            if viking5.afaze == 3 then
                                if random(2) == 0 then
                                    viking5.afaze = 2
                                else
                                end
                            elseif random(100) < 10 then
                                if random(2) == 0 then
                                    viking5.afaze = 3
                                else
                                    viking5.afaze = 1
                                end
                            else
                                viking5.afaze = 2
                            end
                            if viking5.delay == 0 then
                                viking5.faze = 2
                            else
                                viking5.delay = viking5.delay - 1
                            end
                        end,
                        [2] = function()
                            viking5.afaze = 0
                            viking5.cinnost = 0
                        end,
                    }
                end,
            }
            viking5:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_viking6()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        viking6.smich = 0

        return function()
            switch(viking6.smich){
                [0] = function()
                    if random(100) < 5 then
                        viking6.afaze = 1
                    else
                        viking6.afaze = 0
                    end
                end,
                [1] = function()
                    game_killPlan()
                    viking6:planDialog(0, "dr-6-checheche")
                    viking6.smich = viking6.smich + 1
                end,
                [2] = function()
                    if viking6:isTalking() then
                        if viking6.afaze == 2 then
                            viking6.afaze = 3
                        else
                            viking6.afaze = 2
                        end
                    else
                        viking6.afaze = 0
                        viking6.smich = 0
                        room.chechtoni = 1
                    end
                end,
            }
            viking6:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_viking7()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        viking7.dostal = -1
        viking7.afaze = 1

        return function()
            switch(viking7.dostal){
                [0] = function()
                    if viking7:isTalking() then
                        if viking7.afaze == 1 then
                            viking7.afaze = 2
                        else
                            viking7.afaze = 1
                        end
                    else
                        viking7.afaze = 1
                        if random(100) < 10 then
                            viking7:talk("dr-7-sm"..(random(8) + 1), VOLUME_FULL)
                        end
                    end
                end,
                [1] = function()
                    viking7.dostal = viking7.dostal + 1
                    viking7.afaze = 0
                end,
                [2] = function()
                    viking7.dostal = viking7.dostal + 1
                    viking7.afaze = 0
                end,
                [3] = function()
                    viking7.dostal = viking7.dostal + 1
                    viking7.afaze = 0
                end,
                [4] = function()
                    viking7.otrne = random(1200) + 600
                    viking7.dostal = viking7.dostal + 1
                    viking6.smich = 1
                end,
                [5] = function()
                    if viking7.otrne > 0 then
                        viking7.otrne = viking7.otrne - 1
                    end
                    if model_isTalking(271) then
                        viking7.afaze = random(2) * 2 + 3
                        if random(100) < 7 then
                            viking7.afaze = viking7.afaze + 1
                        end
                    else
                        viking7.afaze = 3
                        if random(100) < 7 then
                            viking7.afaze = viking7.afaze + 1
                        end
                        if viking7.otrne == 0 then
                            viking7.dostal = 0
                        elseif random(100) < 3 then
                            model_talk(271, "dr-7-brble"..(random(5) + 1), VOLUME_FULL)
                        end
                    end
                end,
            }
            viking7:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_viking8()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        viking8.nervozita = 0
        viking8.cinnost = 0

        return function()
            if viking8.nervozita == 0 then
                viking8.nervozita = 1
                viking8.mira1 = random(200) + 200
                viking8.mira2 = viking8.mira1 + random(150) + 150
                viking8.mira0 = random(viking8.mira1 - 80) + 90
            end
            if viking7:isTalking() then
                viking8.nervozita = viking8.nervozita + 1
            end
            switch(viking8.cinnost){
                [0] = function()
                    if viking8.nervozita == viking8.mira1 then
                        viking8.nervozita = viking8.nervozita + 1
                        if no_dialog() then
                            viking8.cinnost = 10
                        else
                            viking8.nervozita = viking8.nervozita - 20
                        end
                    elseif viking8.nervozita == viking8.mira2 then
                        viking8.nervozita = viking8.nervozita + 1
                        if no_dialog() then
                            viking8.cinnost = 20
                        else
                            viking8.nervozita = viking8.nervozita - 20
                        end
                    elseif viking8.nervozita == viking8.mira0 then
                        viking8.nervozita = viking8.nervozita + 1
                        viking8.cinnost = 5
                    end
                end,
                [5] = function()
                    viking8.afaze = 3
                    viking8.delay = 5
                    viking8.cinnost = viking8.cinnost + 1
                end,
                [6] = function()
                    if viking8.delay > 0 then
                        viking8.delay = viking8.delay - 1
                    else
                        viking8.cinnost = viking8.cinnost + 1
                    end
                end,
                [7] = function()
                    viking8.cinnost = 0
                    viking8.afaze = 0
                end,
                [10] = function()
                    viking8.afaze = 3
                    viking8:talk("dr-8-ztichni"..(random(2) + 1))
                    viking8.cinnost = viking8.cinnost + 1
                end,
                [11] = function()
                    if viking8:isTalking() then
                        viking8.afaze = random(3) + 3
                    else
                        viking8.afaze = 0
                        viking8.cinnost = 0
                    end
                end,
                [20] = function()
                    viking8.afaze = 3
                    viking8:talk("dr-8-nenechas")
                    viking8.cinnost = viking8.cinnost + 1
                end,
                [21] = function()
                    if viking8:isTalking() then
                        viking8.afaze = random(3) + 3
                    else
                        viking8.cinnost = viking8.cinnost + 1
                        viking8.delay = 20
                    end
                end,
                [22] = function()
                    viking8.afaze = 1
                    viking8:talk("dr-8-aaa")
                    viking8.cinnost = viking8.cinnost + 1
                    viking8.delay = 9
                end,
                [23] = function()
                    if viking8.delay == 0 then
                        viking8.cinnost = viking8.cinnost + 1
                    else
                        viking8.delay = viking8.delay - 1
                    end
                end,
                [24] = function()
                    viking8.afaze = 2
                    model_talk(281, "dr-x-buch", VOLUME_FULL)
                    viking7.dostal = 1
                    viking8.nervozita = 0
                    viking8.cinnost = viking8.cinnost + 1
                    viking8.delay = 4
                end,
                [25] = function()
                    if viking8.delay == 0 then
                        viking8.afaze = 1
                        viking8.cinnost = viking8.cinnost + 1
                        viking8.delay = 3
                    else
                        viking8.delay = viking8.delay - 1
                    end
                end,
                [26] = function()
                    if viking8.delay == 0 then
                        viking8.afaze = 0
                        viking8.cinnost = 0
                        viking8.delay = 3
                    else
                        viking8.delay = viking8.delay - 1
                    end
                end,
            }
            viking8:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pesos()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pesos.cinnost = 0

        return function()
            switch(pesos.cinnost){
                [0] = function()
                    pesos.afaze = 2
                    pesos.cinnost = 1
                    pesos.delay = random(100) + 50
                end,
                [1] = function()
                    if pesos.delay == 0 then
                        pesos.cinnost = pesos.cinnost + 1
                    else
                        pesos.delay = pesos.delay - 1
                    end
                end,
                [2] = function()
                    pesos:talk("dr-x-pes", VOLUME_FULL, -1)
                    pesos.delay = random(100) + 20
                    pesos.cinnost = pesos.cinnost + 1
                end,
                [3] = function()
                    if pesos.delay == 0 then
                        pesos:killSound()
                        pesos.cinnost = 0
                    else
                        if pesos.afaze == 0 then
                            pesos.afaze = 1
                        else
                            pesos.afaze = 0
                        end
                        pesos.delay = pesos.delay - 1
                    end
                end,
            }
            pesos:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_viking2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        viking2.cinnost = 0

        return function()
            switch(viking2.cinnost){
                [0] = function()
                    viking2.faze = 0
                    if random(1000) < 3 then
                        viking2.cinnost = 2
                    end
                end,
                [-1] = function()
                    viking2.afaze = 2
                    if viking2:isTalking() then
                        viking2.cinnost = 1
                    end
                end,
                [1] = function()
                    if viking2:isTalking() then
                        viking2.afaze = 2 + random(2) * 2
                        if viking2.afaze == 2 then
                            if random(100) < 7 then
                                viking2.afaze = viking2.afaze - 1 + 2 * random(2)
                            end
                        end
                    else
                        viking2.faze = 0
                        viking2.cinnost = viking2.cinnost + 1
                    end
                end,
                [2] = function()
                    switch(viking2.faze){
                        [0] = function()
                            viking2.delay = random(5) + 10
                            viking2.faze = viking2.faze + 1
                        end,
                        [1] = function()
                            if viking2.afaze == 3 then
                                if random(2) == 0 then
                                    viking2.afaze = 2
                                else
                                end
                            elseif random(100) < 7 then
                                if random(2) == 0 then
                                    viking2.afaze = 3
                                else
                                    viking2.afaze = 1
                                end
                            else
                                viking2.afaze = 2
                            end
                            if viking2.delay == 0 then
                                viking2.faze = 2
                            else
                                viking2.delay = viking2.delay - 1
                            end
                        end,
                        [2] = function()
                            viking2.afaze = 0
                            viking2.cinnost = 0
                        end,
                    }
                end,
            }
            viking2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlavadr()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        hlavadr.mluvi = 0

        return function()
            if math.mod(game_getCycles(), 3) == 1 then
                if hlavadr.mluvi ~= 0 then
                    pom1 = hlavadr.afaze
                    repeat
                        hlavadr.afaze = random(3)
                    until hlavadr.afaze ~= pom1
                else
                    hlavadr.afaze = 0
                end
            end
            hlavadr:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_viking1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_viking3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_viking4()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_viking5()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_viking6()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_viking7()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_viking8()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pesos()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_viking2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlavadr()
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

