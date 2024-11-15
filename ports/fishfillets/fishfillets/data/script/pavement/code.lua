
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky02.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.pocetrad = 0
        room.kdydalsi = random(200) + 200
        room.posluvod = random(5)
        room.konce = {}

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.kdydalsi > 0 then
                    room.kdydalsi = room.kdydalsi - 1
                end
                if room.kdydalsi == 0 then
                    room.pocetrad = room.pocetrad + 1
                    room.kdydalsi = (random(200) + 100) * (room.pocetrad + 2)
                    pom1 = random(4)
                    if pom1 == room.posluvod then
                        pom1 = 4
                    end
                    room.posluvod = pom1
                    vladce:planDialog(20, "dir-hs-uvod"..pom1)
                    if countPairs(room.konce) < 9 then
                        repeat
                            pom1 = random(9)
                        until not room.konce[pom1]
                    else
                        room.konce = {}
                        pom1 = random(9)
                    end
                    room.konce[pom1] = true
                    vladce:planDialog(0, "dir-hs-konec"..pom1)
                    if room.pocetrad >= 5 then
                        pom1 = random(6)
                    else
                        pom1 = random(room.pocetrad + 1)
                    end
                    adddel(random(10))
                    if pom1 > 0 then
                        switch(random(2)){
                            [0] = function()
                                addm(0, "dir-m-rada"..(pom1 - 1))
                            end,
                            [1] = function()
                                addv(0, "dir-v-rada"..(pom1 - 1))
                            end,
                        }
                    end
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_vladce()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        vladce.ksichty = 0
        vladce.faze = 0

        return function()
            vladce.afaze = vladce.afaze + 1
            local anim_table = {
                [0] = function()
                    if vladce:isTalking() then
                        vladce.ksichty = random(4) + 1
                    end
                end,
                [1] = function()
                    if math.mod(game_getCycles(), 2) == 0 then
                        if vladce:isTalking() then
                            pom1 = random(3)
                        else
                            pom1 = 3
                        end
                        switch(vladce.ksichty){
                            [1] = function()
                                switch(pom1){
                                    [0] = function()
                                        vladce.afaze = 1
                                    end,
                                    [1] = function()
                                        vladce.afaze = 15
                                    end,
                                    [2] = function()
                                        vladce.afaze = 18
                                    end,
                                    [3] = function()
                                        vladce.afaze = 1
                                    end,
                                }
                            end,
                            [2] = function()
                                switch(pom1){
                                    [0] = function()
                                        vladce.afaze = 4
                                    end,
                                    [1] = function()
                                        vladce.afaze = 16
                                    end,
                                    [2] = function()
                                        vladce.afaze = 20
                                    end,
                                    [3] = function()
                                        vladce.afaze = 1
                                    end,
                                }
                            end,
                            [3] = function()
                                switch(pom1){
                                    [0] = function()
                                        vladce.afaze = 14
                                    end,
                                    [1] = function()
                                        vladce.afaze = 17
                                    end,
                                    [2] = function()
                                        vladce.afaze = 19
                                    end,
                                    [3] = function()
                                        vladce.afaze = 14
                                    end,
                                }
                            end,
                            [4] = function()
                                switch(pom1){
                                    [0] = function()
                                        vladce.afaze = 6
                                    end,
                                    [1] = function()
                                        vladce.afaze = 15
                                    end,
                                    [2] = function()
                                        vladce.afaze = 18
                                    end,
                                    [3] = function()
                                        vladce.afaze = 11
                                    end,
                                }
                            end,
                        }
                        if pom1 == 3 then
                            vladce.ksichty = 0
                        end
                    end
                end,
                [10] = function()
                    vladce.faze = vladce.faze + 1
                    switch(vladce.faze){
                        [1] = function()
                            vladce.afaze = 5
                        end,
                        [2] = function()
                            vladce.afaze = 9
                        end,
                        [3] = function()
                            vladce.afaze = 10
                        end,
                        [4] = function()
                            vladce.ksichty = 0
                        end,
                    }
                end,
                [11] = function()
                    vladce.faze = vladce.faze + 1
                    switch(vladce.faze){
                        [1] = function()
                            vladce.afaze = 9
                        end,
                        [2] = function()
                            vladce.afaze = 5
                        end,
                        [3] = function()
                            vladce.afaze = 1
                        end,
                        [4] = function()
                            vladce.ksichty = 0
                        end,
                    }
                end,
                [12] = function()
                    vladce.faze = vladce.faze + 1
                    switch(vladce.faze){
                        [1] = function()
                            vladce.afaze = 6
                        end,
                        [2] = function()
                            vladce.afaze = 7
                        end,
                        [3] = function()
                            vladce.afaze = 11
                        end,
                        [4] = function()
                            vladce.ksichty = 0
                        end,
                    }
                end,
                [13] = function()
                    vladce.faze = vladce.faze + 1
                    switch(vladce.faze){
                        [1] = function()
                            vladce.afaze = 7
                        end,
                        [2] = function()
                            vladce.afaze = 6
                        end,
                        [3] = function()
                            vladce.afaze = 1
                        end,
                        [4] = function()
                            vladce.ksichty = 0
                        end,
                    }
                end,
                [14] = function()
                    vladce.faze = vladce.faze + 1
                    switch(vladce.faze){
                        [1] = function()
                            vladce.afaze = 9
                        end,
                        [2] = function()
                            vladce.afaze = 5
                        end,
                        [3] = function()
                            vladce.afaze = 14
                        end,
                        [4] = function()
                            vladce.ksichty = 0
                        end,
                    }
                end,
                [20] = function()
                    vladce.faze = vladce.faze + 1
                    switch(vladce.faze){
                        [1] = function()
                            vladce.afaze = 6
                        end,
                        [2] = function()
                            vladce.afaze = 8
                        end,
                        [3] = function()
                            vladce.afaze = 8
                        end,
                        [4] = function()
                            vladce.afaze = 6
                        end,
                        [5] = function()
                            vladce.ksichty = 0
                        end,
                    }
                end,
                [21] = function()
                    vladce.faze = vladce.faze + 1
                    switch(vladce.faze){
                        [2] = function()
                            vladce.afaze = 4
                        end,
                        [6] = function()
                            vladce.ksichty = 0
                        end,
                        default = function()
                            if isIn(vladce.faze, {1, 3, 5}) then
                                vladce.afaze = 1
                            end
                        end,
                    }
                end,
                [22] = function()
                    vladce.faze = vladce.faze + 1
                    switch(vladce.faze){
                        [2] = function()
                            vladce.afaze = 12
                        end,
                        [6] = function()
                            vladce.ksichty = 0
                        end,
                        default = function()
                            if isIn(vladce.faze, {1, 3, 5}) then
                                vladce.afaze = 11
                            end
                        end,
                    }
                end,
            }

            anim_table[2] = anim_table[1]
            anim_table[3] = anim_table[1]
            anim_table[4] = anim_table[1]
            switch(vladce.ksichty)(anim_table)

            vladce.afaze = vladce.afaze - 1

            vladce:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_xichtik()
        return function()
            if random(1000) < 5 then
                xichtik.afaze = random(3)
            end

            xichtik:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_chobot()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        chobot.lastdir = dir_no
        chobot.oci = 0
        chobot.chapadla = 0
        chobot.akcnost = 2

        return function()
            if chobot.dir ~= dir_no then
                chobot.akcnost = 7
            elseif chobot.akcnost > 2 and math.mod(game_getCycles(), 5) == 0 then
                chobot.akcnost = chobot.akcnost - 1
            end
            if chobot.dir ~= chobot.lastdir then
                if not chobot:isTalking() then
                    if chobot.dir == dir_down then
                        chobot:talk("k1-chob-p", VOLUME_FULL)
                    elseif chobot.dir ~= dir_no then
                        switch(random(3)){
                            [0] = function()
                                chobot:talk("k1-chob-1", VOLUME_FULL)
                            end,
                            [1] = function()
                                chobot:talk("k1-chob-2", VOLUME_FULL)
                            end,
                            [2] = function()
                                chobot:talk("k1-chob-3", VOLUME_FULL)
                            end,
                        }
                    end
                end
                chobot.lastdir = chobot.dir
            end
            if chobot.dir == dir_no and math.mod(game_getCycles(), chobot.akcnost) == 0 then
                if random(2) == 0 then
                    if chobot.chapadla < 2 then
                        chobot.chapadla = chobot.chapadla + 1
                    else
                        chobot.chapadla = 0
                    end
                else
                    if chobot.chapadla > 0 then
                        chobot.chapadla = chobot.chapadla - 1
                    else
                        chobot.chapadla = 2
                    end
                end
            end
            pomb1 = xdist(small, chobot) == 0 and ydist(small, chobot) <= 0 and ydist(small, chobot) > -2 or xdist(big, chobot) == 0 and ydist(big, chobot) <= 0 and ydist(big, chobot) > -2
            pomb1 = pomb1 or chobot.dir ~= dir_no
            if pomb1 then
                chobot.oci = 1
            end
            switch(chobot.oci){
                [0] = function()
                    if random(100) < 5 then
                        chobot.oci = 2
                    end
                end,
                [2] = function()
                    if random(100) < 7 then
                        chobot.oci = 0
                    end
                end,
                [1] = function()
                    if not pomb1 and random(100) < 20 then
                        chobot.oci = 0
                    end
                end,
            }
            chobot.afaze = chobot.oci + 3 * chobot.chapadla

            chobot:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_vladce()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_xichtik()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_chobot()
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

