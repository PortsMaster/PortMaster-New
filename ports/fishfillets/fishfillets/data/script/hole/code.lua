
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky05.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------

    local function prog_init_room()
        local pom, cislohlasky;
        local lvolani = random(50)+100
        local ldejte = random(400)+200

        room.uvod = 0
	barva.zbyva = 0
	lebka.cinnost = 0
	lebka.volfaze = 0
	lebka.dejfaze = 0
	lebka.ooo = 0
	lebka.vinnetou = 0
	sluchatko.cinnost = 0
	ocel.mizeni = 0

        return function()
	  if room.uvod == 0 then
             room.uvod = 1
	     addm(5, "m-strasidelna")
	     addv(5, "v-bojim")
	  end

	  shrimp.afaze = random(5)
	  shrimp:updateAnim()

	  if lebka.X > 45 and lebka.Y > 17 and lebka.dir == dir_right
	     and lebka.vinnetou == 0 and no_dialog() then
	    planDialogSet(0, "l-vinnetou", 1, lebka, "cinnost")
	    lebka.vinnetou = 1
	  end

	  if barva.zbyva == 0 then
	    if barva.afaze ~= 0 then
	      barva.afaze = barva.afaze-1
	      barva:updateAnim()
	    end
	  else
	    barva.zbyva = barva.zbyva -1
	    if barva.afaze ~= 5 then
	      barva.afaze = barva.afaze+1
	      barva:updateAnim()
	    end
	  end

	  if sluchatko.cinnost ~= 0 or sluchatko.afaze ~= 0 then
	    sluchatko.afaze = sluchatko.afaze + 1
	    if sluchatko.afaze == 6 then
	      sluchatko.afaze = 0
	    end
	    sluchatko:updateAnim()
	  end

	  if sluchatko.cinnost ~= 0 and
	    (ocel.mizeni==1 or ocel.mizeni==3) then
	    ocel.mizeni = ocel.mizeni+1
	  end
	  if sluchatko.cinnost == 0 and ocel.mizeni==2 then
	    ocel.mizeni = 3
	  end

	  if lebka.cinnost == 1 then
	    if lebka.ooo == 0 then
	      lebka.afaze = random(4)
	    else
	      if lebka.afaze == 5 then lebka.afaze = 4
	      else lebka.afaze = 5 end
	      lebka.ooo = lebka.ooo-1;
	    end
	    lebka:updateAnim()
	  end

	  if isReady(small) and isReady(big) then
	    if celenka.X == lebka.X+1 and celenka.Y+2 == lebka.Y then
	      ldejte = 0
	    else
	      if ldejte == 0 then
	        if no_dialog() then
		  if lebka.dejfaze < 4 then
		    cislohlasky = lebka.dejfaze
		  else
		    cislohlasky = random(4)
		  end

	          if cislohlasky == 3 then
		    barva.zbyva = 100
		    pom = 6
		  else
		    pom = 0
		  end
		  if cislohlasky > 1 then lebka.ooo = 20 end

	          planDialogSet(pom, "l-dejte"..cislohlasky,
		                1, lebka, "cinnost")

		  if lebka.dejfaze < 4 then
		    lebka.dejfaze = lebka.dejfaze+1
		    if cislohlasky == 0 or cislohlasky == 2 then
		      addm(0, "m-nedame"..(cislohlasky/2))
		    else
		      addv(0, "v-nedame"..((cislohlasky-1)/2))
		    end
		    if cislohlasky == 2 then
		      planBusy(big, true)
		      addv(5, "v-neber")
		      planBusy(big, false)
		    end
		  end
		  ldejte = random(50)+500;
	        else
	          ldejte = ldejte + 10
	        end
	      else
	        ldejte = ldejte-1
	      end
	    end
	  end

	  if lebka.volfaze == 3 and no_dialog() and
	     isReady(small) and isReady(big) and
	     not small:isLeft() and
	     sluchatko.X >= small.X+1 and
	     sluchatko.X <= small.X+3 and
	     sluchatko.Y+10 >= small.Y and
	     sluchatko.Y+6 <= small.Y then
	    addm(0, "m-zmizet")
	    planDialogSet(0, "s-prejete", 1, sluchatko, "cinnost")
	    addv(0, "v-vratte")
	    planDialogSet(0, "s-prejete", 1, sluchatko, "cinnost")
	    lebka.volfaze = 4
	    ocel.mizeni = 1
	  end

	  if ocel.mizeni == 2 and ocel.afaze < 10 then
	    ocel.afaze = ocel.afaze+1
	    ocel:updateAnim()
	  elseif ocel.mizeni == 4 and ocel.afaze > 0 then
	    ocel.afaze = ocel.afaze-1
	    ocel:updateAnim()
	  end

	  if lebka.volfaze < 3 then
	    if lvolani == 0 then
	      if sluchatko.X >= lebka.X and sluchatko.X <= lebka.X+2
	         and sluchatko.Y+9 >= lebka.Y and
		 sluchatko.Y+5 <= lebka.Y then
	        if no_dialog() then
	          planDialogSet(10, "l-halo"..lebka.volfaze, 1, lebka, "cinnost")
	          planDialogSet(0, "s-prejete", 1, sluchatko, "cinnost")
		  lvolani = random(10)+200
		  lebka.volfaze = lebka.volfaze+1
		  if lebka.volfaze == 3 and
		     isReady(small) and isReady(big) then
   		    addm(10, "m-sluchatko")
   		    addv(0, "v-zkus")
		  end
	        else
	          lvolani = 50
	        end
	      end
	    else
	      lvolani = lvolani-1;
	    end
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

