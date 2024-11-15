
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

        room.switch = 2 - math.mod(pokus, 2)
        room.kdy = 20 + random(20)
        room.bav = random(150)
        room.sprs = 0
        room.sp = 0
        room.pokl = 0

        return function()
            pom1 = 0
            if room.kdy > 0 then
                room.kdy = room.kdy - 1
            end
            if room.bav > 0 then
                room.bav = room.bav - 1
            end
            if no_dialog() and isReady(small) and isReady(big) then
                if room.kdy == 0 then
                    pom1 = room.switch
                    room.switch = 3 - room.switch
                    room.kdy = 500 + random(1000)
                end
                if room.sprs == 0 then
                    if dist(small, sprc) < 2 or sprc.dir ~= dir_no then
                        if random(20) == 1 then
                            room.sprs = 1
                            pom1 = 3
                        end
                    end
                end
                if room.bav == 0 and (whirlpool.tvor > 0 and dist(small, whirlpool) < 2 or whirlpool.dir ~= dir_no) then
                    if whirlpool:isTalking() or whirlpool.dir ~= dir_no then
                        pom2 = random(200)
                    else
                        pom2 = random(500)
                    end
                    switch(pom2){
                        [6] = function()
                            pom1 = 6
                        end,
                        [7] = function()
                            pom1 = 7
                        end,
                    }
                end
                if room.sp == 0 and sprc.dir == dir_down and random(10) == 1 then
                    room.sp = 1
                    pom1 = 5
                end
                if room.pokl == 0 and small.X <= sprc.X and small.Y <= sprc.Y then
                    room.pokl = 1
                    pom1 = 4
                end
            end
            if pom1 >= 6 then
                room.bav = random(1000) + 1000
            end
            switch(pom1){
                [1] = function()
                    if random(4) > 0 then
                        addv(7, "br-v-komfort")
                    end
                    addm(7, "br-m-bydli")
                    if random(5) > 0 then
                        addv(7, "br-v-santusak")
                        if random(6) > 0 then
                            addm(7, "br-m-podvodnik")
                        end
                    end
                end,
                [2] = function()
                    addm(7, "br-m-vsim" ..random(3))
                    addv(0, "br-v-nerozvadet" ..random(3))
                    if random(7) > 0 then
                        addm(10, "br-m-dva")
                        addv(5, "br-v-dost")
                    end
                end,
                [3] = function()
                    addm(7, "br-m-sprcha")
                    addv(7, "br-v-lazen")
                    if random(7) > 0 then
                        addm(9, "br-m-zapnout")
                        addv(6, "br-v-shodit")
                    end
                end,
                [4] = function()
                    addm(random(10) + 2, "br-m-poklady")
                end,
                [5] = function()
                    addv(7, "br-v-nechat")
                    if random(7) > 0 then
                        addm(7, "br-m-nefunguje")
                    end
                end,
                [6] = function()
                    if whirlpool:isTalking() then
                        adddel(13)
                    end
                    if random(7) > 0 then
                        addm(7, "br-m-ahoj")
                    end
                    addv(7, "br-v-draha")
                    if random(6) > 0 then
                        addm(7, "br-m-zkusit")
                    end
                end,
                [7] = function()
                    if whirlpool:isTalking() then
                        adddel(16)
                    end
                    addm(7, "br-m-bavi")
                end,
            }
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_whirlpool()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        whirlpool.tvor = 0

        return function()
            if whirlpool.anim == "" then
                switch(random(5)){
                    [3] = function()
                        if game_getCycles() > 20 then
                            setanim(whirlpool, "d?2-8S[tvor],1a4d?2-5a5a4d?1-3a5d?1-3a4d?2-7a5d?1-3S[tvor],0a0d?2-4")
                        end
                    end,
                    [4] = function()
                        if game_getCycles() > 20 then
                            setanim(whirlpool, "d?1-3S[tvor],1a4d?1-5a5d?1-5a4d?1-5" ..
                                "a6a7a8a9a6a7a8a9a6a7a8a9a6a7a8a9d?2-5a4d?1-3a5d1a4d?1-3" ..
                                "a9a8a7a6a9a8a7a6a9a8a7a6a9a8a7a6d?1-3a4d?1-3S[tvor],0a0")
                        end
                    end,
                    default = function()
                        setanim(whirlpool, "d13a0a1a2a3a0a1a2a3a0a1a2a3a0a1a2a3d8a3a2a1a0a3a2a1a0a3a2a1a0a3a2a1a0")
                    end,
                }
            end

            if odd(game_getCycles()) then
                goanim(whirlpool)
            elseif whirlpool.tvor == 1 and whirlpool.afaze > 5 and not whirlpool:isTalking() and random(20) == 1 then
                whirlpool:talk("br-x-pracka", VOLUME_FULL)
            end

            whirlpool:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_whirlpool()
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

