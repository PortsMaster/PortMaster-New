
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky05.ogg")
    local pokus = getRestartCount()
    local roompole = createArray(3)


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.rozh = random(50) + 10
        --NOTE: turn off standard black jokes
        stdBlackJoke = function() end

        return function()
            if game_getCycles() == room.rozh then
                room.rozh = room.rozh + 500 + random(1000)
                if no_dialog() then
                    if random(5) == 1 then
                        addm(2, "tr-m-ztuhl")
                    else
                        addm(3, "tr-m-chlad"..(random(2) + 1))
                        if game_getCycles() < 2000 or random(3) == 1 then
                            addv(5, "tr-v-jid"..(random(2) + 1))
                        end
                    end
                end
            end
            if isReady(small) and not isReady(big) and not big:isOut() then
                if snehulak.Y <= 5 then
                    if roompole[1] == 0 or pokus - roompole[1] > random(20) then
                        roompole[1] = pokus
                        addm(11, "tr-m-cvicit")
                    end
                end
            end
            if isReady(big) and not small:isAlive() then
                if snehulak.Y >= 5 then
                    if roompole[2] == 0 or pokus - roompole[2] > random(20) then
                        roompole[2] = pokus
                        addv(14, "tr-v-prezil")
                    end
                end
            end
            if snehulak.uder > 4 and no_dialog() and isReady(big) and isReady(small) then
                if odd(pokus) then
                    addv(4, "tr-v-agres")
                    snehulak.uder = -10
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snehulak()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        snehulak.prastil = 0
        snehulak.uder = 0

        return function()
            if snehulak.dir == dir_down and ocel.dir ~= dir_down then
                snehulak.afaze = 2
            else
                if snehulak.afaze == 2 then
                    snehulak.afaze = 1
                end
                pom1 = snehulak.afaze
                pomb1 = isReady(small) and small.X + 2 == snehulak.X and small.Y - 2 == snehulak.Y and not small:isLeft()
                if not pomb1 then
                    snehulak.afaze = 0
                    snehulak.prastil = 0
                elseif snehulak.dir == dir_right then
                    if odd(game_getCycles()) then
                        snehulak.afaze = 1 - snehulak.afaze
                    end
                else
                    if snehulak.prastil == 0 then
                        snehulak.prastil = -3
                        snehulak.afaze = 1
                    else
                        if snehulak.prastil < -1 then
                            snehulak.prastil = snehulak.prastil + 1
                        end
                        if snehulak.prastil == -1 then
                            snehulak.afaze = 0
                        end
                    end
                end
                if pom1 == 0 and snehulak.afaze == 1 then
                    snehulak:talk("tr-x-koste", VOLUME_FULL)
                    if no_dialog() then
                        addm(2, "tr-m-au"..(random(2) + 1))
                    end
                    snehulak.uder = snehulak.uder + 1
                end
            end
            snehulak:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_snehulak()
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

