
--NOTE: crabs must be together in models.lua
local crabs = {}
for i = 0, 6 do
    crabs[i] = getModelsTable()[krabi.index + i]
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky03.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.qnevsimla = 0
        room.qautomat = 0
        room.qnezkusime = 0
        room.qhlava = 0
        room.komentovaly = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() and vladce.cinnost == 0 and not vladce:isTalking() then
                if room.komentovaly < vladce.promluvila then
                    room.komentovaly = vladce.promluvila
                    if room.komentovaly > 1 and random(100) < 50 then
                        switch(random(4)){
                            [0] = function()
                                room.qnevsimla = math.mod(room.qnevsimla + 1, 4)
                                if room.qnevsimla == 1 then
                                    addv(8, "vit-v-nevsimla")
                                end
                            end,
                            [1] = function()
                                room.qautomat = math.mod(room.qautomat + 1, 6)
                                if room.qautomat == 1 then
                                    addv(8, "vit-v-automat")
                                    addm(9, "vit-m-nebo")
                                end
                            end,
                            [2] = function()
                                room.qnezkusime = math.mod(room.qnezkusime + 1, 8)
                                if room.qnezkusime == 2 then
                                    addm(8, "vit-m-nezkusime")
                                    if room.komentovaly < 15 then
                                        addv(5, "vit-v-proc")
                                    end
                                end
                            end,
                            [3] = function()
                                room.qhlava = math.mod(room.qhlava + 1, 2)
                                if room.qautomat == 0 then
                                    switch(random(2)){
                                        [0] = function()
                                            addm(8, "vit-m-hlava")
                                        end,
                                        [1] = function()
                                            addv(8, "vit-v-hlava")
                                        end,
                                    }
                                end
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

        vladce.promluvila = 0
        vladce.delay = random(80) + 80
        vladce.ksichty = 0
        vladce.vital = 0
        vladce.obecne = {}
        vladce.specialni = {}
        vladce.prodleva = 100
        vladce.cinnost = 0

        return function()
            vladce.afaze = vladce.afaze + 1
            if countPairs(vladce.obecne) == 4 and countPairs(vladce.specialni) == 4 then
                vladce.prodleva = 2 * vladce.prodleva
                vladce.obecne = {}
                vladce.specialni = {}
            end
            if vladce.delay < 0 then
                vladce.delay = random(vladce.prodleva) + vladce.prodleva
            end
            if vladce.ksichty == 0 and vladce.cinnost == 0 then
                if vladce.delay > 0 then
                    vladce.delay = vladce.delay - 1
                elseif no_dialog() then
                    if vladce.vital == 0 then
                        vladce.cinnost = 1
                        vladce.vital = 1
                    elseif countPairs(vladce.obecne) == 0 or random(100) < 60 then
                        pom1 = random(5)
                        if vladce.obecne[pom1] == nil then
                            vladce.obecne[pom1] = true
                            vladce.cinnost = 2 + pom1
                            vladce.promluvila = vladce.promluvila + 1
                        end
                    else
                        pom1 = random(5)
                        if vladce.specialni[pom1] == nil then
                            vladce.specialni[pom1] = true
                            vladce.cinnost = 7 + pom1
                            vladce.promluvila = vladce.promluvila + 1
                        end
                    end
                end
            end
            if vladce.ksichty == 0 then
                switch(vladce.cinnost){
                    [0] = function()
                        if random(50) == 0 then
                            vladce.faze = 0
                            switch(vladce.afaze){
                                [1] = function()
                                    switch(random(5)){
                                        [0] = function()
                                            vladce.ksichty = 20
                                        end,
                                        [1] = function()
                                            vladce.ksichty = 10
                                        end,
                                        [2] = function()
                                            vladce.ksichty = 12
                                        end,
                                        [3] = function()
                                            vladce.afaze = 2
                                        end,
                                        [4] = function()
                                            vladce.ksichty = 21
                                        end,
                                    }
                                end,
                                [10] = function()
                                    switch(random(2)){
                                        [0] = function()
                                            vladce.ksichty = 11
                                        end,
                                        [1] = function()
                                            vladce.ksichty = 14
                                        end,
                                    }
                                end,
                                [11] = function()
                                    switch(random(2)){
                                        [0] = function()
                                            vladce.ksichty = 13
                                        end,
                                        [1] = function()
                                            vladce.ksichty = 22
                                        end,
                                    }
                                end,
                                [14] = function()
                                    switch(random(3)){
                                        [0] = function()
                                            vladce.ksichty = 1
                                        end,
                                        [1] = function()
                                            vladce.ksichty = 1
                                        end,
                                        [2] = function()
                                            vladce.afaze = 1
                                            vladce.cinnost = 10
                                            vladce.faze = vladce.faze - 1
                                        end,
                                    }
                                end,
                                [6] = function()
                                    switch(random(3)){
                                        [0] = function()
                                            vladce.ksichty = 12
                                        end,
                                        [1] = function()
                                            vladce.afaze = 1
                                        end,
                                    }
                                end,
                                default = function()
                                    vladce.afaze = 1
                                end,
                            }
                        end
                    end,
                    [1] = function()
                        vladce.delay = -1
                        vladce:talk("vit-hs-vitejte"..string.char(string.byte("A") + random(4)))
                        vladce.ksichty = 2
                        vladce.cinnost = 0
                    end,
                    [2] = function()
                        vladce.delay = -1
                        vladce:talk("vit-hs-demoni0")
                        vladce.ksichty = 1
                        vladce.cinnost = 0
                    end,
                    [3] = function()
                        vladce.delay = -1
                        vladce:talk("vit-hs-dite0")
                        vladce.ksichty = 3
                        vladce.cinnost = 0
                    end,
                    [4] = function()
                        vladce.delay = -1
                        vladce:talk("vit-hs-lod0")
                        vladce.ksichty = 1
                        vladce.cinnost = 0
                    end,
                    [5] = function()
                        vladce.delay = -1
                        vladce:talk("vit-hs-soud0")
                        vladce.ksichty = 4
                        vladce.cinnost = 0
                    end,
                    [6] = function()
                        vladce:talk("vit-hs-jidelna1")
                        vladce.ksichty = 1
                        vladce.cinnost = 61
                    end,
                    [61] = function()
                        addm(0, "vit-m-jakze")
                        addv(0, "vit-v-vazne")
                        addm(0, "vit-m-nechutne")
                        planSet(vladce, "cinnost", 63)
                        vladce.cinnost = 62
                    end,
                    [63] = function()
                        vladce:talk("vit-hs-jidelna2")
                        vladce.ksichty = 4
                        vladce.cinnost = 0
                        vladce.delay = -1
                    end,
                    [7] = function()
                        vladce.delay = -1
                        vladce:talk("vit-hs-kacir")
                        vladce.ksichty = 4
                        vladce.cinnost = 0
                    end,
                    [8] = function()
                        vladce.delay = -1
                        vladce:talk("vit-hs-vodovod0")
                        vladce.ksichty = 2
                        vladce.cinnost = 0
                    end,
                    [9] = function()
                        krabi:talk("vit-x-beg")
                        vladce.ksichty = 10
                        vladce.faze = 0
                        vladce.cinnost = 91
                    end,
                    [91] = function()
                        if not krabi:isTalking() then
                            vladce.cinnost = vladce.cinnost + 1
                            vladce.ksichty = 3
                            vladce:talk("vit-hs-reklama1")
                        end
                    end,
                    [92] = function()
                        vladce.cinnost = vladce.cinnost + 1
                        vladce.ksichty = 4
                        vladce:talk("vit-hs-reklama2")
                    end,
                    [93] = function()
                        vladce.cinnost = vladce.cinnost + 1
                        vladce.ksichty = 3
                        vladce:talk("vit-hs-reklama3")
                    end,
                    [94] = function()
                        vladce.cinnost = vladce.cinnost + 1
                        vladce.ksichty = 4
                        vladce:talk("vit-hs-reklama4")
                    end,
                    [95] = function()
                        vladce.cinnost = vladce.cinnost + 1
                        vladce.ksichty = 2
                        vladce:talk("vit-hs-reklama5")
                    end,
                    [96] = function()
                        vladce.cinnost = 0
                        vladce.delay = -1
                        vladce.ksichty = 10
                        vladce.faze = 0
                        krabi:talk("vit-x-end")
                    end,
                    [10] = function()
                        vladce.cinnost = 101
                        vladce.ksichty = 2
                        vladce:talk("vit-hs-klid1")
                    end,
                    [101] = function()
                        vladce.cinnost = vladce.cinnost + 1
                        vladce.ksichty = 4
                        vladce:talk("vit-hs-klid2")
                    end,
                    [102] = function()
                        vladce.cinnost = vladce.cinnost + 1
                        vladce.ksichty = 12
                        vladce.faze = 0
                        vladce.delay = 5
                    end,
                    [103] = function()
                        if vladce.delay > 0 then
                            vladce.delay = vladce.delay - 1
                        else
                            vladce.cinnost = vladce.cinnost + 1
                            vladce.ksichty = 13
                            vladce.faze = 0
                        end
                    end,
                    [104] = function()
                        vladce.cinnost = vladce.cinnost + 1
                        vladce.ksichty = 3
                        vladce:talk("vit-hs-klid3")
                    end,
                    [105] = function()
                        vladce.cinnost = vladce.cinnost + 1
                        vladce.ksichty = 2
                        vladce:talk("vit-hs-klid4")
                    end,
                    [106] = function()
                        vladce.cinnost = vladce.cinnost + 1
                        vladce.ksichty = 12
                        vladce.faze = 0
                        vladce.delay = 3
                    end,
                    [109] = function()
                        vladce.delay = -1
                        vladce.cinnost = 0
                    end,
                    [11] = function()
                        vladce.delay = -1
                        vladce:talk("vit-hs-pojis0")
                        vladce.ksichty = 2
                        vladce.cinnost = 0
                    end,
                    default = function()
                        if isIn(vladce.cinnost, {107, 108}) then
                            if vladce.delay > 0 then
                                vladce.delay = vladce.delay - 1
                            else
                                vladce.cinnost = vladce.cinnost + 1
                                vladce.ksichty = 22
                                vladce.faze = 0
                                vladce.delay = 1
                            end
                        else
                            vladce.cinnost = 0
                        end
                    end,
                }
            end
            local ksichty_table = {
                [0] = function()
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
                            if (isIn(vladce.faze, {1, 3, 5})) then
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
                            if (isIn(vladce.faze, {1, 3, 5})) then
                                vladce.afaze = 11
                            end
                        end,
                    }
                end,
            }

            ksichty_table[2] = ksichty_table[1]
            ksichty_table[3] = ksichty_table[1]
            ksichty_table[4] = ksichty_table[1]

            switch(vladce.ksichty)(ksichty_table)
            vladce.afaze = vladce.afaze - 1
            vladce:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krabi()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.globpole = {}
        for pom1 = 0, 6 do
            room.globpole[pom1] = 0
            crabs[pom1].afaze = 1
            crabs[pom1]:updateAnim()
        end

        return function()
            pomb1 = vladce:isTalking() or krabi:isTalking()
            for pom1 = 0, 6 do
                pom2 = dist(vladce, crabs[pom1])
                if isIn(crabs[pom1].dir, {dir_left, dir_right}) then
                    if room.globpole[pom1] < 3 then
                        room.globpole[pom1] = 3
                    end
                    room.globpole[pom1] = math.mod(room.globpole[pom1] - 2, 4) + 3
                    switch(room.globpole[pom1]){
                        [3] = function()
                            crabs[pom1].afaze = 0
                        end,
                        [4] = function()
                            crabs[pom1].afaze = 6
                        end,
                        [5] = function()
                            crabs[pom1].afaze = 0
                        end,
                        [6] = function()
                            crabs[pom1].afaze = 8
                        end,
                    }
                elseif pom2 <= 4 and pomb1 then
                    room.globpole[pom1] = 1
                    crabs[pom1].afaze = random(5) + 1
                    if crabs[pom1].afaze == 1 then
                        crabs[pom1].afaze = 0
                    end
                elseif pom2 <= 10 and pomb1 then
                    room.globpole[pom1] = 2
                    if crabs[pom1].afaze == 1 or random(100) < 10 then
                        crabs[pom1].afaze = random(5) + 1
                        if crabs[pom1].afaze == 1 then
                            crabs[pom1].afaze = 0
                        end
                    end
                    if random(100) < 5 then
                        crabs[pom1].afaze = 1
                    end
                else
                    switch(room.globpole[pom1]){
                        [0] = function()
                            crabs[pom1].afaze = 1
                        end,
                        [1] = function()
                            room.globpole[pom1] = -random(20) - 20
                        end,
                        [2] = function()
                            room.globpole[pom1] = -random(20) - 5
                        end,
                        default = function()
                            if isIn(room.globpole[pom1], {3, 4, 5, 6}) then
                                room.globpole[pom1] = -random(10) - 4
                                crabs[pom1].afaze = 0
                            else
                                if random(-room.globpole[pom1]) < 4 then
                                    crabs[pom1].afaze = 1
                                elseif random(100) < room.globpole[pom1] or crabs[pom1].afaze == 1 then
                                    crabs[pom1].afaze = random(5) + 1
                                    if crabs[pom1].afaze == 1 then
                                        crabs[pom1].afaze = 0
                                    end
                                end
                                room.globpole[pom1] = room.globpole[pom1] + 1
                            end
                        end,
                    }
                end
                crabs[pom1]:updateAnim()
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
    subinit = prog_init_vladce()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krabi()
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

