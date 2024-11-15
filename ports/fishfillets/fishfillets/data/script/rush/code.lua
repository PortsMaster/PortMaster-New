
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky14.ogg")
    local pokus = getRestartCount()

    local function svitiauto(x, y, svetlo)
      local neco

      if svetlo==1 then neco=2 else neco=0 end
      if cervene.X==x and cervene.Y+16==y and cervene.afaze==svetlo then
        return true end
      if fialove.X==x and fialove.Y+15==y and fialove.afaze==svetlo then
        return true end
      if modre.X==x and modre.Y+18==y and modre.afaze==svetlo then
        return true end
      if oranzove.X==x and oranzove.Y==y and oranzove.afaze==svetlo then
        return true end
      if zlute.X==x and zlute.Y+17==y and zlute.afaze==svetlo then
        return true end
      if cyan.X+neco==x and cyan.Y+13==y and cyan.afaze==svetlo then
        return true end
      if hnede.X+neco==x and cyan.Y+21==y and cyan.afaze==svetlo then
        return true end
      return false
    end

    local function svitDauto(auto, sirka, vyska, jinvys)
      if auto.dir == dir_down or
         (small.dir ~= dir_left and big.dir ~= dir_right and
         ((isWater(auto.X+sirka-1, auto.Y+vyska) and
	   isWater(auto.X+sirka, auto.Y+vyska) and
	   ((isWater(auto.X, auto.Y+jinvys) and
	    isWater(auto.X+1, auto.Y+jinvys))
	    or
	    (isWater(auto.X, auto.Y+jinvys)
	    and svitiauto(auto.X+1, auto.Y+jinvys, 2))
	    or
	    (isWater(auto.X+1, auto.Y+jinvys)
	    and svitiauto(auto.X-3, auto.Y+jinvys, 1)
	    )))
	  or
	  (isWater(auto.X, auto.Y+jinvys) and
	   isWater(auto.X+1, auto.Y+jinvys) and
	   small.X == auto.X+sirka-5 and
	   small.Y == auto.Y+vyska and
	   not small:isLeft()))) then
	auto.afaze=2
      else auto.afaze=0 end
    end

    local function svitNauto(auto, sirka, vyska, jinvys)
      svitDauto(auto, sirka, vyska, jinvys+14-vyska)
      if auto.dir == dir_up or
         (((small.Y==auto.Y+vyska and (small.X==auto.X+sirka-1 or
           small.X==auto.X+sirka)) or
	   (not isWater(auto.X+sirka, auto.Y+vyska+1) and
           not isWater(auto.X+sirka-1, auto.Y+vyska) and
	   small.X==auto.X+sirka+1 and small.Y==auto.Y+vyska+1)
	  or
           (isWater(auto.X+sirka-1, auto.Y+vyska) and
           not isWater(auto.X+sirka, auto.Y+vyska) and
	   small.X==auto.X+sirka+2 and small.Y==auto.Y+vyska+1))
	 and
	 isWater(auto.X+sirka, auto.Y-1) and
	 isWater(auto.X+sirka-1, auto.Y-1) and
	 isWater(auto.X, auto.Y+jinvys) and
	 isWater(auto.X+1, auto.Y+jinvys)) then
       auto.afaze = 1
      elseif auto.afaze==1 then
       auto.afaze = 0
      end
      auto:updateAnim()
    end

    local function svitVauto(auto, sirka, vyska)
     if auto == cervene and (not small:isAlive() or not big:isAlive()) then
      auto.afaze = 4
     elseif auto.X > 17 then auto.afaze = 3
     elseif auto.dir == dir_right or
      (big.Y == auto.Y and big.X+4 == auto.X
       and not big:isLeft() and
       isWater(auto.X+sirka, auto.Y) and
       isWater(auto.X+sirka, auto.Y+1) and
       isWater(auto.X+sirka, auto.Y+vyska-1) and
       isWater(auto.X+sirka, auto.Y+vyska)) then
      auto.afaze = 2
    elseif auto.dir == dir_left or
         ((small.Y == auto.Y or small.Y == auto.Y+1) and
           small.X-sirka == auto.X and small:isLeft() and
	   isWater(auto.X-1, auto.Y) and
	   isWater(auto.X-1, auto.Y+1) and
	   isWater(auto.X-1, auto.Y+vyska-1) and
	   isWater(auto.X-1, auto.Y+vyska)) then
      auto.afaze = 1
    else
      auto.afaze = 0
    end
    if small.dir ~= dir_up then auto:updateAnim() end
  end
    -- -------------------------------------------------------------
    local function prog_init_room()
        room.uvod = random(2)
	room.myslim = 999
	room.vysunout = true

        return function()
	  if room.uvod == 0 then
	    room.uvod = 2
	    addv(0, "v-upozornit")
	    addm(9, "m-silou")
	  end

	  if room.uvod == 2 and no_dialog() and room.myslim > 0 then
	    room.myslim = room.myslim-1
	  end

	  if room.myslim == 0 and isReady(big) and isReady(small) then
	    room.myslim = -1
	    addv(0, "v-ffneni")
	    addm(0, "m-myslis")
	    addv(0, "v-zopakuje")
	    addm(0, "m-obdivovat")
	  end

	  if cervene.X == 11 and cervene.dir == dir_left and
	     room.vysunout and isReady(big) and isReady(small) then
	    room.vysunout = false
	    addm(0, "m-vysunout")
	    addv(0, "v-chytra")
	  end

	  if cervene.X > 17 and cervene.afaze ~= 3 and
	     isReady(big) and isReady(small) then
	    addm(1, "sp-shout_small_02")
	    addv(0, "v-codelas")
	  end

	  if cervene.X < 18 and cervene.afaze == 3 and
	     isReady(big) and isReady(small) then
	    addm(1, "smrt-m-restart")
	  end

	  if room.uvod == 1 and no_dialog() and
	     isReady(small) and isReady(big) and
	    (zlute.dir ~= dir_no or hnede.dir ~= dir_no or
	     modre.dir ~= dir_no or cervene.dir ~= dir_no or
	     fialove.dir ~= dir_no or oranzove.dir ~= dir_no or
	     cyan.dir ~= dir_no or zelene.dir ~= dir_no or
	     cerne.dir ~= dir_no or sede.dir ~= dir_no or
	     ruzove.dir ~= dir_no) then
	    room.uvod = 2
	    addm(5, "m-hraje")
	  end

	  if hnede.X == zlute.X+4 and
	     hnede.dir == dir_no and zlute.dir == dir_no and
	   ((big.Y == zlute.Y and big.X+4 == zlute.X
	     and not big:isLeft()) or
	    (small.Y == hnede.Y or small.Y == hnede.Y+1) and
	     small.X == hnede.X+6 and small:isLeft()) then
	    if isWater(zlute.X-1, zlute.Y) and
	       isWater(zlute.X-1, zlute.Y+1) and
	       isWater(zlute.X-1, zlute.Y+18) and
	       isWater(zlute.X-1, zlute.Y+19) and
	       isWater(hnede.X-1, hnede.Y) and
	       isWater(hnede.X-1, hnede.Y+1) then
	      zlute.afaze = 1
	    elseif isWater(hnede.X+6, hnede.Y) and
		   isWater(hnede.X+6, hnede.Y+1) and
		   isWater(hnede.X+6, hnede.Y+21) and
		   isWater(hnede.X+6, hnede.Y+22) and
		   isWater(zlute.X+4, zlute.Y) and
		   isWater(zlute.X+4, zlute.Y+1) then
	      zlute.afaze = 2
	    else
	      zlute.afaze = 0
 	    end
	    hnede.afaze = zlute.afaze
	    zlute:updateAnim()
	    hnede:updateAnim()
	  else
 	    svitVauto(hnede, 6, 22)
 	    svitVauto(zlute, 4, 19)
	  end

 	  svitVauto(cervene, 4, 17)
 	  svitVauto(cyan, 6, 14)
 	  svitVauto(fialove, 4, 16)
 	  svitVauto(modre, 4, 18)
 	  svitVauto(oranzove, 4, 15)

	  svitNauto(ruzove, 20, 9, 6)
	  svitNauto(sede, 16, 7, 22)
	  svitNauto(cerne, 15, 7, 2)
	  svitNauto(zelene, 19, 9, 22)
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

