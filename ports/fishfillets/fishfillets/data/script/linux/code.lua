
file_include("script/share/prog_border.lua")

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    dialog_addFont("font_linuxer1", 125, 73, 255)
    dialog_addFont("font_linuxer2", 0, 207, 58)

    text.hudba = random(14)
    if text.hudba == 0 then
      sound_playMusic("music/kufrik.ogg")
    elseif text.hudba == 1 then
      sound_playMusic("music/menu.ogg")
    elseif text.hudba <= 8 then
      sound_playMusic("music/rybky0"..(text.hudba-1)..".ogg")
    elseif text.hudba == 9 then
      sound_playMusic("music/rybky09.ogg")
    elseif text.hudba == 10 then
      sound_playMusic("music/rybky10.ogg")
    else
      sound_playMusic("music/rybky"..(text.hudba+2)..".ogg")
    end

    --NOTE: a final level
    small:setGoal("goal_alive")
    big:setGoal("goal_alive")
    linuxak1:setGoal("goal_out")
    linuxak2:setGoal("goal_out")
    -- -------------------------------------------------------------
    local function prog_init_room()
    	local i

    	room.uvod = true
	room.cas = random(100)+100
	room.linfaze = 0
	room.dialkolik = true
	room.dialkaslat = true
	room.dialnebrat = true
	room.dialopak = true
	room.dialdole = true
	room.dialvtipy = true
	room.dialneba = 0
	room.jenjeden = 6
	room.opak = {}
	room.opak[0] = false
	room.opak[1] = false
	room.opak[2] = false
	text.hudba = 5
	cursor.afaze = 0

	local function pis()
	  local aktulin, mezera

	  if text.afaze == 15 then aktulin = linuxak2
	  else aktulin = linuxak1 end

	  cursor.afaze = cursor.afaze+1
	  if cursor.afaze <= text.delka then
	    cursor:updateAnim()

	    mezera = false
	    if text.afaze == 14 then
	      if cursor.afaze == 3 or cursor.afaze == 10 or
	      	 cursor.afaze == 12 or cursor.afaze == 15 or
		 cursor.afaze == 19 or cursor.afaze == 25 or
		 cursor.afaze == 27 or cursor.afaze == 30 or
		 cursor.afaze == 35 or cursor.afaze == 37 then
		mezera = true end
	    elseif text.afaze == 15 then
	      if cursor.afaze == 2 or cursor.afaze == 5 then mezera = true end
	    else
	      if cursor.afaze == 8 then mezera = true end
	    end

	    if mezera then
	      cursor:talk("space"..random(18), VOLUME_FULL)
	    else
	      cursor:talk("key"..random(30), VOLUME_FULL)
	    end

	    if aktulin.afaze <= 2 then aktulin.afaze = 2 end
	    aktulin.afaze = aktulin.afaze + 1 + random(3)
	    if aktulin.afaze > 5 then aktulin.afaze = aktulin.afaze-4 end
	    if aktulin.afaze == 2 then aktulin.afaze = 0 end
	    aktulin:updateAnim()
	  elseif text.afaze < 14 then
	    if cursor.afaze == text.delka+29 then
	      aktulin.afaze = 3
	      aktulin:updateAnim()
	    elseif cursor.afaze == text.delka+30 then
	      aktulin.afaze = 0
	      aktulin:updateAnim()
	      cursor.afaze = 0
	      cursor:updateAnim()
	      cursor:talk("enter"..random(14), VOLUME_FULL)
	      if text.afaze == 0 then
	        sound_playMusic("music/kufrik.ogg")
	      elseif text.afaze == 1 then
	        sound_playMusic("music/menu.ogg")
	      else
	        text.afaze = text.afaze-1
	        if text.afaze >= 8 then text.afaze = text.afaze+1 end
	        if text.afaze >= 11 then text.afaze = text.afaze+2 end
	        if text.afaze >= 10 then
	          sound_playMusic("music/rybky"..text.afaze..".ogg")
	        else
	          sound_playMusic("music/rybky0"..text.afaze..".ogg")
	        end
	      end
              if random(3) == 0 then
	        planDialogSet(0, "2-skriptik", 1, linuxak2, "mluvi")
	      elseif room.dialneba >= 0 then
	        if random(8) < room.dialneba then
	          room.dialneba = -1
	      	  addv(10, "v-prepinani")
	        end
	      end
	      if room.dialneba >= 0 then room.dialneba = room.dialneba+1 end
	    end
	  else
	    if aktulin.afaze ~= 0 then
	      aktulin.afaze = 0
	      aktulin:updateAnim()
	    end
	    if cursor.afaze > text.delka+40 then
	      i = cursor.afaze
	      cursor.afaze = 2*text.delka+40-i
	      cursor:updateAnim()
	      if cursor.afaze > 0 then cursor.afaze = i
	      elseif text.afaze == 14 then
	        planDialogSet(10, "1-trilobyte", 1, linuxak1, "mluvi")
		planTimeAction(2, pis)
		text.afaze = 15
		text.delka = 8
		text:updateAnim()
		planDialogSet(0, "text15", 1, text, "mluvi")
	      end
	    elseif cursor.afaze == text.delka+40 and text.afaze == 14 then
	      planDialogSet(0, "2-trapnejsi", 1, linuxak2, "mluvi")
	    end
	  end
	end

      	local function vyber_dialog()
	  local pocet

	  if room.linfaze == 0 then pocet = 4 else pocet = 1 end
	  if random(3) == 0 then
	    if room.dialkolik then pocet = pocet+1 end
	    if room.dialkaslat then pocet = pocet+1 end
	    if room.dialnebrat then pocet = pocet+1 end
	    if room.dialvtipy and room.linfaze == 0 then pocet = pocet+1 end
	  end

	  i = random(pocet)

	  if room.linfaze == 0 then
	    if i == 0 then
              planDialogSet(0, "2-hadi", 1, linuxak2, "mluvi")
              planDialogSet(0, "1-jazyka", 1, linuxak1, "mluvi")
              planDialogSet(0, "2-C", 1, linuxak2, "mluvi")
              planDialogSet(0, "1-prekonane", 1, linuxak1, "mluvi")
              planDialogSet(0, "2-pomala", 1, linuxak2, "mluvi")
              planDialogSet(0, "1-pohodli", 1, linuxak1, "mluvi")
              planDialogSet(0, "2-prave", 1, linuxak2, "mluvi")
	    elseif i == 1 then
              planDialogSet(0, "1-wilber", 1, linuxak1, "mluvi")
              planDialogSet(0, "2-maskot", 1, linuxak2, "mluvi")
              planDialogSet(0, "1-dohnat", 1, linuxak1, "mluvi")
              planDialogSet(0, "2-neni", 1, linuxak2, "mluvi")
              planDialogSet(0, "1-zamaskovali", 1, linuxak1, "mluvi")
	    elseif i == 2 then
              planDialogSet(0, "2-nezaujata", 1, linuxak2, "mluvi")
              planDialogSet(0, "1-prvni", 1, linuxak1, "mluvi")
              planDialogSet(0, "2-abecedy", 1, linuxak2, "mluvi")
              planDialogSet(20, "1-archlinux", 1, linuxak1, "mluvi")
              planDialogSet(0, "2-zapomel", 1, linuxak2, "mluvi")
              planDialogSet(0, "1-podruhe", 1, linuxak1, "mluvi")
	      room.linfaze = 1
	    elseif i == 3 then
              planDialogSet(0, "1-nebavi", 1, linuxak1, "mluvi")
	      text.afaze = random(13)
	      if text.afaze >= text.hudba then text.afaze = text.afaze+1 end
	      text:updateAnim()
	      text.hudba = text.afaze
	      if text.afaze == 0 then text.delka = 18
	      elseif text.afaze == 1 then text.delka = 16
	      else text.delka = 19 end
	      planTimeAction(2, pis)
	      planDialogSet(0, "text"..text.afaze, 1, text, "mluvi")
	    end
	    if i < 3 and room.dialopak then
	      if room.opak[i] then
	        addm(20, "m-samem")
		addv(5, "v-argumenty")
	        room.dialopak = false
	      end
	      room.opak[i] = true
	    end
	    i = i-4
	  else
	    if i == 0 then
	      room.linfaze = room.linfaze+1
	      if room.linfaze == 2 then
                planDialogSet(0, "2-naprogramovana", 1, linuxak2, "mluvi")	      
                planDialogSet(0, "1-ubuntu", 1, linuxak1, "mluvi")
                planDialogSet(0, "2-vykradacka", 1, linuxak2, "mluvi")	      
	      elseif room.linfaze == 3 then
                planDialogSet(0, "1-zkousel", 1, linuxak1, "mluvi")
                planDialogSet(0, "2-root", 1, linuxak2, "mluvi")	      
                planDialogSet(0, "1-nepotrebuje", 1, linuxak1, "mluvi")
                planDialogSet(0, "2-postavene", 1, linuxak2, "mluvi")	      
                planDialogSet(0, "1-rozhrani", 1, linuxak1, "mluvi")
	      elseif room.linfaze == 4 then
                planDialogSet(0, "2-slackware", 1, linuxak2, "mluvi")	      
                planDialogSet(0, "1-balickovaci", 1, linuxak1, "mluvi")
                planDialogSet(0, "2-svuj", 1, linuxak2, "mluvi")	      
	        room.linfaze = 0
	      end
	    end
	    i = i-1
	  end
	  if room.dialkolik then
	    if i == 0 then
	      room.dialkolik = false
	      if random(2) == 0 then
	        addv(0, "v-musime")
		addm(5, "m-radi")
		addv(5, "v-radeji")
	      else
	        addm(0, "m-nemyslis")
		addv(10, "v-forkovat")
	      end
	    end
	    i = i-1
	  end
	  if room.dialkaslat then
	    if i == 0 then
	      room.dialkaslat = false
	      addm(0, "m-vykaslat")
	      addv(5, "v-nabourali")
	    end
	    i = i-1
	  end
	  if room.dialnebrat then
	    if i == 0 then
	      room.dialnebrat = false
	      if random(2) == 0 then
	        addv(0, "v-vyrobil")
		addm(5, "m-sileny")
	      else
	        addv(0, "v-osobne")
		addm(5, "m-ostatni")
	      end
	    end
	    i = i-1
	  end
	  if room.dialvtipy and room.linfaze == 0 then
	    if i == 0 then
	      addm(0, "m-vtipni")
	      planDialogSet(0, "1-rozdil", 1, linuxak1, "mluvi")
	      planTimeAction(10, pis)
	      text.afaze = 14
	      text.delka = 39
	      text:updateAnim()
	      planDialogSet(0, "text14", 1, text, "mluvi")
	    end
	    i = i-1
	  end
        end

        return function()
          if stdBorderReport() then
            addm(random(10) + 5, "m-ukolem")
            addv(random(10) + 5, "v-alespon")
          end
	  if room.uvod then
	    room.uvod = false
	    if random(2) == 0 then
	      addm(20, "m-tatinek")
	      addv(8, "v-kdojiny")
	      addm(0, "m-zadarmo")
	    else
	      addm(20, "m-zamykali")
	      addv(2, "v-horydoly")
	      addm(5, "m-linuxaci")
	      addv(10, "v-ven")
	    end
	  end
	  if cursor.afaze > 0 then
	    pis()
	  elseif no_dialog() and isReady(big) and isReady(small) then
	    if not linuxak1:isOut() and not linuxak2:isOut() then
	      room.cas = room.cas-1
	      if room.cas == 0 then
	        vyber_dialog()
	        room.cas = random(100)+100
	      elseif small.Y == 29 and room.dialdole then
	        addv(0, "v-dole")
                planDialogSet(0, "2-bubliny", 1, linuxak2, "mluvi")	      
                planDialogSet(0, "1-odpadnou", 1, linuxak1, "mluvi")	      
	        room.dialdole = false
	      end
	    elseif not linuxak1:isOut() or not linuxak2:isOut() then
	      if room.jenjeden > 0 then room.jenjeden = room.jenjeden-1
	      elseif room.jenjeden == 0 then
	        room.jenjeden = -1
		addv(0, "v-snazit")
		addm(5, "m-nestaci")
	      end
	    end
	  end
	  if linuxak1.mluvi == 1 and linuxak1:isTalking() then
	    linuxak1.afaze = linuxak1.afaze+1+random(2)
	    if linuxak1.afaze >= 3 then linuxak1.afaze = linuxak1.afaze-3 end
	    linuxak1:updateAnim()
	  elseif linuxak1.afaze > 0 and linuxak1.afaze < 3 then
	    linuxak1.afaze = 0
	    linuxak1:updateAnim()
	  end
	  if linuxak2.mluvi == 1 and linuxak2:isTalking() then
	    linuxak2.afaze = linuxak2.afaze+1+random(2)
	    if linuxak2.afaze >= 3 then linuxak2.afaze = linuxak2.afaze-3 end
	    linuxak2:updateAnim()
	  elseif linuxak2.afaze > 0 and linuxak2.afaze < 3 then
	    linuxak2.afaze = 0
	    linuxak2:updateAnim()
	  end
	  if small.Y == 29 and small.X >= 10 and small.X <= 12
	     and bubble1.Y < 29 then
	    bubble1.afaze = bubble1.afaze+1
	    if bubble1.afaze == 1 then bubble1:updateAnim()
	    elseif bubble1.afaze == 2 then
	      bubble1.afaze = 0
	      bubble1:updateAnim()
	      bubble1.afaze = 2
	    elseif bubble1.afaze == 8 then bubble1.afaze = 0 end
	    if bubble2.Y < 29 then
	      if bubble1.afaze == 2 then
	        bubble2.afaze = 1
		bubble2:updateAnim()
	      elseif bubble1.afaze == 3 then
	        bubble2.afaze = 0
		bubble2:updateAnim()
	      end
	    end
	  end
	  if bubble1.dir == dir_down then
	    bubble1.afaze = 0
	    bubble1:updateAnim()
	    bubble2.afaze = 0
	    bubble2:updateAnim()
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

