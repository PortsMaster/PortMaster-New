
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky14.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.zvednout = 0
        room.uvod = random(42) + 14
        room.ahojkrabe = 0
        room.pobliz = 0
        room.nesahat = 0
        room.bud = 0
        room.rozhovor = 0
        room.veselit = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.zvednout == 0 and dist(big, valec) <= 1 and big.dir == dir_no and random(6) == 1 and valec.Y > 14 then
                    room.zvednout = 1
                    addv(4, "re-v-ocel")
                elseif room.uvod <= 0 then
                    local bit_spi = {}
                    if krab.spi == 0 then
                        switch(random(10)){
                            [1] = function()
                                bit_spi[0] = true
                                bit_spi[2] = true
                            end,
                            [2] = function()
                                bit_spi[0] = true
                                bit_spi[2] = true
                            end,
                            [3] = function()
                                bit_spi[1] = true
                                bit_spi[3] = true
                            end,
                            [4] = function()
                                bit_spi[1] = true
                                bit_spi[3] = true
                            end,
                            [5] = function()
                                bit_spi[4] = true
                                bit_spi[5] = true
                            end,
                            [6] = function()
                                bit_spi[0] = true
                                bit_spi[2] = true
                            end,
                            [7] = function()
                                bit_spi[1] = true
                                bit_spi[3] = true
                            end,
                            [8] = function()
                                bit_spi[0] = true
                                bit_spi[4] = true
                            end,
                            [9] = function()
                                bit_spi[1] = true
                                bit_spi[2] = true
                            end,
                            [0] = function()
                                bit_spi[4] = true
                            end,
                        }
                    end
                    if bit_spi[0] then
                        addv(3 + random(9), "re-v-koraly0")
                    end
                    if bit_spi[1] then
                        addv(3 + random(9), "re-v-koraly1")
                    end
                    if bit_spi[2] then
                        addm(3 + random(9), "re-m-libi0")
                    end
                    if bit_spi[3] then
                        addm(3 + random(9), "re-m-libi1")
                    end
                    if bit_spi[4] then
                        addm(3 + random(9), "re-m-libi2")
                    end
                    if bit_spi[5] then
                        addv(3 + random(9), "re-v-pokoj")
                    end
                    room.uvod = 800 + random(300) + random(400)
                elseif room.ahojkrabe == 0 and dist(small, krab) <= 1 and random(20) == 1 then
                    room.ahojkrabe = 1
                    addm(1, "re-m-ahoj")
                elseif krab.spi == 0 and room.pobliz > 20 then
                    krab.spi = 1
                elseif room.bud == 0 and room.pobliz > random(800) then
                    room.bud = 1
                    krab:planDialog(2, "re-k-budi")
                    if room.ahojkrabe == 0 and random(2) == 1 then
                        room.ahojkrabe = 1
                        addm(5, "re-m-ahoj")
                    end
                elseif krab.dopad >= 1 and krab.dopad <= 10 then
                    krab.dopad = 1000
                    krab:planDialog(0, "re-k-au")
                elseif room.nesahat == 0 and (krab.dir == dir_left or krab.dir == dir_right) then
                    room.nesahat = 1
                    if odd(game_getCycles()) then
                        room.bud = 1
                    end
                    krab:planDialog(0, "re-k-nesahej")
                elseif room.pobliz == random(500) + 30 then
                    if odd(room.pobliz) then
                        krab:planDialog(5, "re-k-spim")
                    else
                        krab:planDialog(5, "re-k-otravujete")
                    end
                elseif room.rozhovor == 0 and room.pobliz > 1 and random(333) == 1 then
                    room.rozhovor = 1
                    addm(7, "re-m-uzitecny"..random(2))
                    if odd(game_getCycles()) then
                        addv(7, "re-v-obejit")
                    else
                        addv(6, "re-v-nech")
                        addv(3, "re-v-nervozni")
                    end
                elseif room.veselit == 0 and krab.spi > 0 and random(2000 + 100 * pokus) <= room.bud * 2 + room.nesahat * 2 + room.ahojkrabe + room.rozhovor then
                    room.veselit = 1
                    addm(10, "re-m-rozveselit")
                    addv(7, "re-v-nevsimej")
                end
            end
            room.uvod = room.uvod - 1
            if dist(big, krab) <= 1 or dist(small, krab) <= 1 then
                room.pobliz = room.pobliz + 1
            else
                room.pobliz = 0
            end
            if math.mod(game_getCycles(), 3000) == 0 then
                room.rozhovor = 0
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_valec()
        return function()
            if valec.dir == dir_up then
                room.zvednout = 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab.spi = 0
        krab.dopad = 10000

        return function()
            if krab:isTalking() then
                krab.spi = 1
            end
            if krab.spi == 0 then
                if krab.dir == dir_no then
                    krab.afaze = 0
                else
                    krab.spi = 1
                end
            elseif krab:isTalking() then
                krab.afaze = math.mod(game_getCycles(), 4) + 2
            elseif krab.dir == dir_down then
                krab.afaze = random(9) + 1
            else
                anim_table = {
                    [99] = function()
                        krab.spi = 0
                        room.pobliz = -14 - random(50)
                        if random(2) == 1 then
                            room.ahojkrabe = 0
                        end
                        if random(2) == 1 then
                            room.nesahat = 0
                        end
                        if random(2) == 1 then
                            room.bud = 0
                        end
                    end,
                    [20] = function()
                        krab.afaze = 0
                    end,
                    [26] = function()
                        krab.afaze = random(4) + 2
                    end,
                    default = function()
                        krab.afaze = 1
                    end,
                }
                anim_table[21] = anim_table[20]
                anim_table[22] = anim_table[20]
                anim_table[23] = anim_table[20]
                anim_table[24] = anim_table[20]
                anim_table[25] = anim_table[20]
                anim_table[27] = anim_table[26]
                anim_table[28] = anim_table[26]

                switch(math.mod(random(krab.spi), 100))(anim_table)
            end
            if krab.spi > 0 then
                krab.spi = krab.spi + 1
            end
            if krab.dir == dir_down then
                krab.dopad = 0
            else
                krab.dopad = krab.dopad + 1
            end

            krab:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_valec()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab()
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

