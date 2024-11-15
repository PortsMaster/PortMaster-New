
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky15.ogg")
    local pokus = getRestartCount()
    local roompole = createArray(1)


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        if pokus == 1 then
            room.cast1 = 0
        else
            room.cast1 = 2
        end
        room.ocel1 = 0
        room.osejvu = 0
        room.cast2 = 0
        room.restartovat = 0
        room.neuvazovat = 0
        room.nepoustej = 0
        room.uhnimi = 0
        room.mamstrach = 0
        room.oknize = 0
        room.delayrada = -1
        room.poslrada = 0

        return function()
            if roompole[0] == 1 and room.restartovat == 0 and isReady(big) and isReady(small) and no_dialog() then
                roompole[0] = 2
                addv(10, "pra-v-schvalne")
                addm(5, "pra-m-znovu")
            end
            if no_dialog() and isReady(small) and isReady(big) and roompole[0] == 0 then
                if room.delayrada > 0 then
                    room.delayrada = room.delayrada - 1
                end
                if room.cast1 == 0 then
                    room.cast1 = 1
                    addm(random(20) + 10, "pra-m-pravidla")
                elseif room.cast1 == 1 and big.Y == tal.Y + 1 and small.Y > tal.Y + 1 then
                    room.cast1 = 2
                    addv(5, "pra-v-klesnout")
                elseif room.cast1 <= 2 and snek.X == 5 and tal.Y == 26 and big.Y == 27 then
                    room.cast1 = 3
                    addv(5, "pra-v-nahore")
                elseif room.ocel1 == 0 and val1.X == 11 and small.X == 8 and not small:isLeft() then
                    room.ocel1 = 1
                    addm(5, "pra-m-nepohnu")
                elseif room.cast1 <= 3 and big.X == 9 and sek.Y == 24 then
                    room.cast1 = 4
                    addm(0, "pra-m-zpatky")
                elseif room.osejvu == 0 and sek.Y == 27 and (small.X > 15 or big.X > 15) then
                    room.osejvu = 1
                    addv(5, "pra-v-problem")
                    addm(5, "pra-m-reseni")
                elseif room.cast2 == 0 and (small.X >= 22 or big.X >= 21) and jah.X == 22 then
                    room.cast2 = 1
                    addv(15, "pra-v-zapeklita")
                    addm(15 + random(15), "pra-m-vyrazit")
                    addv(5, "pra-v-dobrynapad")
                elseif room.cast2 < 2 and sek.X == 14 and sek.Y == 27 and small.X == 15 and small.Y == 28 then
                    if jah.X > 19 then
                        room.cast2 = 3
                        addv(0, "pra-v-vzit")
                        addm(5, "pra-m-prisun")
                    end
                elseif room.cast2 < 2 and sek.X == 14 and sek.Y == 27 and jah.X < 22 and (small.X >= 20 or small.Y <= 28) then
                    room.cast2 = 3
                    addm(10, "pra-m-chytit")
                    addv(20 + random(60), "pra-v-spatne")
                    room.restartovat = 1
                elseif room.restartovat == 0 and mer.X == 35 and mer.Y == 30 then
                    addv(10 + random(30), "pra-v-spatne")
                    room.restartovat = 1
                elseif room.osejvu == 1 and small.X >= 29 and big.X >= 29 and (small.Y < 19 or big.Y < 19) then
                    addv(random(40), "pra-v-ukladani")
                    room.osejvu = 2
                elseif room.neuvazovat == 0 and small.Y == 21 and small.X >= 23 and small.X <= 28 and small:isLeft() then
                    room.neuvazovat = 1
                    addm(2, "pra-m-uvazovat")
                elseif room.nepoustej == 0 and soup.Y <= 10 and small.Y >= 14 and small.X >= 22 then
                    room.nepoustej = 1
                    addm(5, "pra-m-pustis")
                elseif room.uhnimi ~= 1 and soup.Y == 9 and small.X >= 22 and small.X <= 24 and small.Y >= 11 and small.Y <= 12 then
                    room.uhnimi = 1
                    addv(5, "pra-v-zavazis")
                elseif room.uhnimi == 1 and soup.Y == 9 and (small.X > 26 or small.Y > 13) then
                    room.uhnimi = 2
                elseif room.mamstrach == 0 and room.uhnimi > 0 and soup.Y <= 10 and small.X >= 32 and small.Y >= 13 and small.Y <= 14 then
                    room.mamstrach = 1
                    addm(5, "pra-m-strach")
                    addv(5, "pra-v-prekvapit")
                elseif room.restartovat == 0 and small.Y >= 14 and small.X >= 23 and small.X < 34 and big.Y < soup.Y then
                    addv(10 + random(30), "pra-v-spatne")
                    room.restartovat = 1
                elseif room.oknize == 0 and small.Y < 10 then
                    room.oknize = 1
                    addm(20, "pra-m-kniha")
                    addv(2, "pra-v-valec")
                    addm(10, "pra-m-jakudelat")
                    addv(5, "pra-v-nezapomen")
                elseif room.oknize == 1 and knih.X == 26 and knih.Y == 7 then
                    room.oknize = 2
                    room.delayrada = random(50) + 100
                elseif room.delayrada == 0 and knih.X == 26 then
                    if big.Y <= 3 or room.poslrada == 2 then
                        addv(10, "pra-v-nezapomen")
                        room.poslrada = 1
                        room.delayrada = random(300) + 150
                    else
                        addv(10, "pra-v-objet")
                        if room.poslrada == 0 then
                            addm(0, "pra-m-neradit")
                        end
                        room.poslrada = 2
                        room.delayrada = random(50) + 50
                    end
                elseif room.restartovat == 0 and svic.X == 3 and svic.Y >= 21 and svic.Y <= 22 and svic.dir == dir_no then
                    room.restartovat = 1
                    roompole[0] = 1
                    addm(10, "pra-m-stava")
                    addv(0, "pra-v-dopredu")
                    addm(5, "pra-m-restart")
                elseif room.restartovat == 0 and val2.X == 15 and val2.Y == 11 then
                    addv(10 + random(30), "pra-v-spatne")
                    room.restartovat = 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_soup()
        return function()
            if soup.dir ~= dir_no then
                room.osejvu = 2
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
    subinit = prog_init_soup()
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

