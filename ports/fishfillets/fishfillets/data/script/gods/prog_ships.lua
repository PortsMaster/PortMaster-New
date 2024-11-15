
local maxlodex=10
local maxlodey=10
local nlodi=7
function getNShips()
    return nlodi
end

local nkostek = {4,4,4,6,6,5,7}
local tvary = {
              {{1,0},{0,1},{1,1},{2,1},{0,0},{0,0},{0,0}},
              {{1,0},{0,1},{1,1},{2,1},{0,0},{0,0},{0,0}},
              {{1,0},{0,1},{1,1},{2,1},{0,0},{0,0},{0,0}},
              {{1,0},{0,1},{1,1},{2,1},{1,2},{3,1},{0,0}},
              {{1,0},{0,1},{1,1},{2,1},{1,2},{3,1},{0,0}},
              {{2,0},{0,1},{1,1},{2,1},{3,1},{0,0},{0,0}},
              {{1,0},{3,0},{0,1},{1,1},{2,1},{3,1},{4,1}}}

-- -----------------------------------------------------------------
local function umistilod(h, x, y, sm, cislo, zkouset)
    local planek = room.planek
    local px, py, pi, pj
    local vysl = true

    for i = 1, nkostek[cislo] do
        pi = tvary[cislo][i][1]
        pj = tvary[cislo][i][2]
        switch(sm){
            [0] = function()
                px = x + pi
                py = y + pj
            end,
            [1] = function()
                px = x - pj
                py = y + pi
            end,
            [2] = function()
                px = x - pi
                py = y - pj
            end,
            [3] = function()
                px = x + pj
                py = y - pi
            end,
        }
        if zkouset then
            if px > 0 and px <= maxlodex and py > 0 and py <= maxlodey then
                vysl = vysl and planek[h][1][px][py] == 0 and (px == 1 or planek[h][1][px - 1][py] == 0) and (px == maxlodex or planek[h][1][px + 1][py] == 0) and (py == 1 or planek[h][1][px][py - 1] == 0) and (py == maxlodey or planek[h][1][px][py + 1] == 0)
            else
                vysl = false
            end
        else
            planek[h][1][px][py] = cislo
        end
    end

    return vysl
end

-- -----------------------------------------------------------------
function initLode()
    room.planek = {}
    local planek = room.planek
    for player = 1, 2 do
        planek[player] = {}
        for hit = 1, 2 do
            planek[player][hit] = {}
            for x = 1, maxlodex do
                planek[player][hit][x] = {}
                for y = 1, maxlodey do
                    planek[player][hit][x][y] = 0
                end
            end
        end
    end

    local pompole = {}
    for p = 1, maxlodex * maxlodey * 4 do
        pompole[p] = {}
    end
    local pocet = 0
    for h = 1, 2 do
        repeat
            for i = 1, maxlodex do
                for j = 1, maxlodey do
                    planek[h][1][i][j] = 0
                    planek[h][2][i][j] = 0
                end
            end
            local n = 8
            repeat
                n = n - 1
                pocet = 0
                for i = 1, maxlodex do
                    for j = 1, maxlodey do
                        for sm = 0, 3 do
                            if umistilod(h, i, j, sm, n, true) then
                                pocet = pocet + 1
                                pompole[pocet][1] = i
                                pompole[pocet][2] = j
                                pompole[pocet][3] = sm
                            end
                        end
                    end
                end
                if pocet > 0 then
                    local p = random(pocet) + 1
                    umistilod(h, pompole[p][1], pompole[p][2], pompole[p][3], n, false)
                end
            until pocet == 0 or n == 1
        until pocet ~= 0
    end
end

-- -----------------------------------------------------------------
local posltrefena = -1
function getLastHit()
    return posltrefena
end

--[[
 vysledek: 1 - voda, 2 - nemuze byt, 3 - zasah, 4 - potopena,
            5 - podvod potopena, 6 - zasah podvod, 7 - potopena podvod
            8 - to jsi uz rikal+voda, 9 - to uz jsi rikal+zasah
]]
--[[
  hrac1: je-li nacata: 70% zkusi pokracovat v nacate lodi, 10% zkusi neco jineho,
                       20% uplne nahodne
         neni-li nacata, 80% zkusi regulerne, 20% zkusi nahodne
  hrac2: je-li nacata: 90% bude pokracovat, 10% zkusi jinam
         pri pokracovani muze najit podvod
         neni-li nacata, zkusi jinam
  potopi-li hrac2 lod a je-li to posl. moznost, pak na 50% podvod potopena,
  pokud je to jen prubezny zasah (ne prvni), pak 5% zasah podvod
]]
function hrajlode(h)
    local planek = room.planek
    local pompole = {}
    for p = 1, maxlodex * maxlodey do
        pompole[p] = {}
    end
    local pocet
    local divnych
    local nacata, potopena
    local cinnost
    local vysl
    local lod
    local sx, sy

    nacata = false
    for i = 1, maxlodex do
        for j = 1, maxlodey do
            if planek[h][2][i][j] == 3 then
                nacata = true
            end
        end
    end
    if h == 1 then
        if nacata then
            local rand100 = random(100)
            if isRange(rand100, 0, 49) then
                cinnost = 1
            elseif isRange(rand100, 50, 69) then
                cinnost = 2
            else
                cinnost = 3
            end
        else
            local rand100 = random(100)
            if isRange(rand100, 0, 69) then
                cinnost = 2
            else
                cinnost = 3
            end
        end
    elseif nacata then
        local rand100 = random(100)
        if isRange(rand100, 0, 89) then
            cinnost = 1
        else
            cinnost = 2
        end
    else
        cinnost = 2
    end
    pocet = 0
    sx = -1
    switch(cinnost){
        [1] = function()
            for i = 1, maxlodex do
                for j = 1, maxlodey do
                    if planek[h][2][i][j] == 0 then
                        if i > 1 and planek[h][2][i - 1][j] == 3 or i < maxlodex and planek[h][2][i + 1][j] == 3 or j > 1 and planek[h][2][i][j - 1] == 3 or j < maxlodey and planek[h][2][i][j + 1] == 3 then
                            pocet = pocet + 1
                            pompole[pocet][1] = i
                            pompole[pocet][2] = j
                        end
                    end
                end
            end
            if pocet == 0 then
                for i = 1, maxlodex do
                    for j = 1, maxlodey do
                        if planek[h][2][i][j] == 6 then
                            pocet = pocet + 1
                            pompole[pocet][1] = i
                            pompole[pocet][2] = j
                        end
                    end
                end
            end
            if pocet > 0 then
                pocet = random(pocet) + 1
                sx = pompole[pocet][1]
                sy = pompole[pocet][2]
            end
        end,
        [2] = function()
            if h == 2 and random(100) < 75 then
                for i = 2, maxlodex - 1 do
                    for j = 2, maxlodey - 1 do
                        if planek[h][2][i][j] == 0 then
                            pocet = pocet + 1
                            pompole[pocet][1] = i
                            pompole[pocet][2] = j
                        end
                    end
                end
            end
            if pocet == 0 then
                for i = 1, maxlodex do
                    for j = 1, maxlodey do
                        if planek[h][2][i][j] == 0 then
                            pocet = pocet + 1
                            pompole[pocet][1] = i
                            pompole[pocet][2] = j
                        end
                    end
                end
            end
            if pocet > 0 then
                pocet = random(pocet) + 1
                sx = pompole[pocet][1]
                sy = pompole[pocet][2]
            end
        end,
    }
    if sx == -1 then
        sx = random(maxlodex) + 1
        sy = random(maxlodey) + 1
    end
    lod = planek[3 - h][1][sx][sy]
    if isRange(lod, 1, 3) then
        posltrefena = 3 + random(2)
    elseif isRange(lod, 4, 5) then
        posltrefena = 0
    elseif lod == 6 then
        posltrefena = 1
    elseif lod == 7 then
        posltrefena = 2
    else
        posltrefena = -1
    end
    if planek[h][2][sx][sy] ~= 0 and planek[h][2][sx][sy] ~= 2 and h == 1 then
        if lod == 0 then
            vysl = 8
        else
            vysl = 9
        end
    elseif lod == 0 then
        vysl = 1
        planek[h][2][sx][sy] = 1
    else
        potopena = true
        for i = 1, maxlodex do
            for j = 1, maxlodey do
                if i ~= sx or j ~= sy then
                    if planek[3 - h][1][i][j] == lod and planek[h][2][i][j] ~= 3 then
                        potopena = false
                    end
                end
            end
        end
        if potopena then
            vysl = 4
        else
            vysl = 3
        end
        if planek[h][2][sx][sy] == 6 then
            planek[h][2][sx][sy] = vysl
            vysl = vysl + 3
        else
            planek[h][2][sx][sy] = vysl
        end
        if vysl == 4 and h == 2 then
            pocet = 0
            for i = 1, maxlodex do
                for j = 1, maxlodey do
                    if i ~= sx and j ~= sy and planek[3 - h][1][i][j] == lod then
                        if i > 1 and (planek[h][2][i - 1][j] == 0 or planek[h][2][i - 1][j] == 6) or i < maxlodex and (planek[h][2][i + 1][j] == 0 or planek[h][2][i + 1][j] == 6) or j > 1 and (planek[h][2][i][j - 1] == 0 or planek[h][2][i][j - 1] == 6) or j < maxlodey and (planek[h][2][i][j + 1] == 0 or planek[h][2][i][j + 1] == 6) then
                            pocet = pocet + 1
                        end
                    end
                end
            end
            if pocet == 0 then
                vysl = 5
            end
        end
        if vysl == 3 and h == 2 then
            pocet = 0
            for i = 1, maxlodex do
                for j = 1, maxlodey do
                    if i ~= sx and j ~= sy and planek[3 - h][1][i][j] == lod then
                        if planek[h][2][i][j] == 3 then
                            pocet = pocet + 1
                        end
                    end
                end
            end
            if pocet > 0 and random(100) < 10 then
                vysl = 1
                planek[h][2][sx][sy] = 6
            end
        end
        if planek[h][2][sx][sy] == 4 then
            for i = 1, maxlodex do
                for j = 1, maxlodey do
                    if planek[3 - h][1][i][j] == lod then
                        planek[h][2][i][j] = 4
                        if i > 1 and planek[h][2][i - 1][j] == 0 then
                            planek[h][2][i - 1][j] = 2
                        end
                        if i < maxlodex and planek[h][2][i + 1][j] == 0 then
                            planek[h][2][i + 1][j] = 2
                        end
                        if j > 1 and planek[h][2][i][j - 1] == 0 then
                            planek[h][2][i][j - 1] = 2
                        end
                        if j < maxlodey and planek[h][2][i][j - 1] == 0 then
                            planek[h][2][i][j + 1] = 2
                        end
                    end
                end
            end
        end
    end
    return vysl, sx, sy
end


