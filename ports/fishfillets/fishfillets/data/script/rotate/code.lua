
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky03.ogg")

    addHeadAnim(small, "images/fishes/small", "head_dark", "dark_00")
    addHeadAnim(small, "images/fishes/small", "head_dark", "dark_01")
    addHeadAnim(big, "images/fishes/big", "head_dark", "dark_00")
    addHeadAnim(big, "images/fishes/big", "head_dark", "dark_01")

    local neztmaveno = true

    -- -------------------------------------------------------------
    local function ztmavfg()
      local i

      for key,model in pairs({small, big}) do
        if model:isAlive() then
          local action = model:getAction()
          if action == "turn" or action == "activate" or random(100) < 6 then
            model_useSpecialAnim(model.index, "head_dark", 1)
          else
            model_useSpecialAnim(model.index, "head_dark", 0)
          end
        end
      end

      if neztmaveno then
        for i = 0,4 do
          valecek[i]:setEffect("invisible")
          svetelko[i]:setEffect("invisible")
        end
        tyc:setEffect("invisible")
        ocel1:setEffect("invisible")
        ocel2:setEffect("invisible")
        ocel3:setEffect("invisible")
        room:setEffect("invisible")
	neztmaveno = false
      end
    end

    local function nastavvalec(index, smer)
      local i

      for i = 0,4 do
        if valecek[i].dir == dir_no and
	   valecek[i].Y+1 == valecek[index].Y and
	   valecek[i].X == valecek[index].X then
	  nastavvalec(i, smer)
	end
      end
      valecek[index].otacsmer = smer
    end

    local function najdiafazi(i)
      switch(valecek[i].rychlost){
      [1] = function()
        valecek[i].afaze = valecek[i].orifaze
      end,
      [2] = function()
        valecek[i].afaze = valecek[i].orifaze/2+12
      end,
      [3] = function()   
        valecek[i].afaze = valecek[i].orifaze/3+18
      end,
      [4] = function()
        valecek[i].afaze = valecek[i].orifaze/4+22
      end,
      [6] = function()
        valecek[i].afaze = valecek[i].orifaze/6+25
      end,
      [12] = function()
        valecek[i].afaze = valecek[i].orifaze/6+27
      end,
      [-12] = function()
        valecek[i].afaze = valecek[i].orifaze/6+29
      end,
      }
      valecek[i].afaze = math.floor(valecek[i].afaze)
    end
  

    local function tocvalec(i)
      if room.energie == 0 then
        valecek[i].afaze = valecek[i].afaze + valecek[i].otacsmer
        if valecek[i].afaze == 12 then valecek[i].afaze = 0 end
        if valecek[i].afaze == -1 then valecek[i].afaze = 11 end
        if valecek[i].otacsmer ~= 0 then valecek[i]:updateAnim() end
      else
        if valecek[i].otacsmer ~= 0 then
	  valecek[i].orifaze =
	    valecek[i].orifaze + valecek[i].otacsmer*room.defrychlost
	  if valecek[i].orifaze < 0 then
	    valecek[i].orifaze = valecek[i].orifaze + 12
	  end
	  if valecek[i].orifaze > 11 then
	    valecek[i].orifaze = valecek[i].orifaze - 12
	  end
	  if valecek[i].rychlost == room.defrychlost then
	    valecek[i].afaze = valecek[i].afaze + valecek[i].otacsmer
	    if valecek[i].afaze == room.maxfaze+1 then
	      valecek[i].afaze = room.minfaze
	    end
	    if valecek[i].afaze == room.minfaze-1 then
	      valecek[i].afaze = room.maxfaze
	    end
	  else
	    valecek[i].rychlost = room.defrychlost
	    najdiafazi(i)
	  end
	elseif valecek[i].rychlost ~= 0 then
	  switch(valecek[i].rychlost){
          [1] = function()
            valecek[i].rychlost = 0
          end,
          [2] = function()
            valecek[i].rychlost = 1
	    valecek[i].orifaze = valecek[i].otacsmer + valecek[i].orifaze
          end,
          [3] = function()   
            valecek[i].rychlost = 2
	    valecek[i].orifaze = 2*valecek[i].otacsmer + valecek[i].orifaze
          end,
          [4] = function()
            valecek[i].rychlost = 3
	    valecek[i].orifaze = 3*valecek[i].otacsmer + valecek[i].orifaze
          end,
          [6] = function()
            valecek[i].rychlost = 4
	    valecek[i].orifaze = 4*valecek[i].otacsmer + valecek[i].orifaze
          end,
          [12] = function()
            valecek[i].rychlost = 6
	    valecek[i].orifaze = 6*valecek[i].otacsmer + valecek[i].orifaze
          end,
          [-12] = function()
            valecek[i].rychlost = 12
          end,
          }
	  if valecek[i].orifaze > 11 then
	    valecek[i].orifaze = valecek[i].orifaze-12
	  end
	  if valecek[i].orifaze < 0 then
	    valecek[i].orifaze = valecek[i].orifaze+12
	  end
	  najdiafazi(i)
	end
      end
      valecek[i]:updateAnim()
    end

    local function prog_init_room()
        local i

	for i = 0,4 do
	  valecek[i].otacsmer = 0
	  svetelko[i]:setEffect("invisible")
	end
	tma:setEffect("invisible")

	room.energie=0
	room.jevidet = 0

        return function()
          if neztmaveno and tyc.afaze == 14 and tyc.Y == 10 then
              model_setViewShift(tyc.index, -1, 0)
              tyc:updateAnim()
          end
	  if room.jevidet == 0 or room.jevidet == 110 then
	    if tyc.Y == 10 and tyc.afaze ~= 14 then
              if tyc.afaze == 0 then
	        tyc:talk("tyc-pauau", VOLUME_FULL)
	        tyc.pocitadlo = 49
	        room.energie = 1
	        tyc.rychlost = 1
	        room.defrychlost = 2
	        room.minfaze = 12
	        room.maxfaze = 17
	        for i = 0,4 do
	          valecek[i].rychlost = 1
	          valecek[i].orifaze = valecek[i].afaze
	        end
	      end
	      if tyc.pocitadlo == 0 then
	        if room.energie ~= 6 then room.energie = room.energie+1 end
	        switch(tyc.rychlost){
	        [1] = function()
	          tyc.rychlost = 2
		  room.minfaze = 18
		room.maxfaze = 21
		room.defrychlost = 3
	        end,
	        [2] = function()
	          tyc.rychlost = 3
		  room.minfaze = 22
		  room.maxfaze = 24
		  room.defrychlost = 4
	        end,
	        [3] = function()
	          tyc.rychlost = 4
		  room.minfaze = 25
		  room.maxfaze = 26
		  room.defrychlost = 6
	        end,
	        [4] = function()
	          tyc.rychlost = 6
		  room.minfaze = 27
		  room.maxfaze = 28
		  room.defrychlost = 12
	        end,
	        [6] = function()
	          tyc.rychlost = 12
		  room.minfaze = 29
		  room.maxfaze = 30
		  room.defrychlost = -12
	        end,
	        [12] = function()
		  room.jevidet = 1
		  tma:setEffect("none")
		  sound_stopMusic()
	        end,
	        }
	        tyc.pocitadlo = 48
	      end
	      tyc.pocitadlo = tyc.pocitadlo-1
	      if tyc.afaze <= 1 then tyc.bliksmer = 1 end
	      if tyc.afaze == 13 then tyc.bliksmer = -1 end
	      tyc.afaze = tyc.afaze+tyc.bliksmer*tyc.rychlost
	      tyc:updateAnim()
	    end

	    for i = 0,4 do
	      valecek[i].otacsmer = 0
	      svetelko[i]:setEffect("invisible")
	    end
	    for i = 0,4 do
	      if (valecek[i].Y == 9 and valecek[i].dir == dir_no and
	         (valecek[i].X ~= 6 or tyc.afaze == 14)
		 and valecek[i].X ~= 8) or
	         (valecek[i].X == 8 and valecek[i].Y == 11) then

	        nastavvalec(i, math.mod(valecek[i].X, 2)*2-1)

	        svetelko[i].afaze = room.energie
	        model_setViewShift(svetelko[i].index,
				   valecek[i].X, valecek[i].Y+1)
	        svetelko[i]:setEffect("none")
	        svetelko[i]:updateAnim()
	      else
	        svetelko[i]:setEffect("invisible")
	      end
	    end
	    for i = 0,4 do
	      tocvalec(i)
	    end
	  elseif room.jevidet == 100 then
	    room.jevidet = room.jevidet+1
	    room.energie = 0
	    for i = 0,4 do
	      valecek[i].afaze = valecek[i].orifaze
	      valecek[i]:setEffect("none")
	      valecek[i]:updateAnim()
	    end
	    tyc.afaze = 14
	    tyc.rychlost = 0
	    model_setViewShift(tyc.index, -1, 0)
	    tyc:setEffect("none")
	    tyc:updateAnim()
	    ocel1:setEffect("none")
	    ocel2:setEffect("none")
	    ocel3:setEffect("none")
            room:setEffect("none")

	    room.jevidet = 101
	    game_changeBg("images/"..codename.."/tma.png")
	  elseif room.jevidet < 100 then
	    room.jevidet = room.jevidet+1
	    if neztmaveno then
	      game_changeBg("images/"..codename.."/tma.png")
	    end
	    ztmavfg()
	  elseif room.jevidet < 105 then
	    room.jevidet = room.jevidet+1
	    if neztmaveno then
	      game_changeBg("images/"..codename.."/tma.png")
	      neztmaveno = false
	    end
	  elseif room.jevidet == 105 then
	    game_changeBg("images/"..codename.."/pozadi.png")
	    room.jevidet = 106
	  elseif room.jevidet == 109 then
	    sound_playMusic("music/rybky03.ogg")
	    room.jevidet = 110
	  else room.jevidet = room.jevidet+1
          end
	  if room.jevidet == 2 then
	    tma:setEffect("invisible")
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

