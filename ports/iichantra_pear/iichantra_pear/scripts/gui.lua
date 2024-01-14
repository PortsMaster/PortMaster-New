GUIc = {}
GUIc.__index = GUIc

function GUIc.create()
	g = {}
	setmetatable(g, GUIc)
	g.thread = NewThread(GUIc.update)
	g.visible = false
	return g
end

function GUIc:show()
	self.thread = NewThread(self.update)
	if not self.created then
		self:init()
	end
	--Log("showing GUI")
	self.visible = true
	if self.gc then self.gc:show(true) end
	Resume(self.thread, self)
end

function GUIc:hide()
	self.visible = false
	if self.gc then self.gc:show(false) end
end

function GUIc:destroy()
	--Log("DESTRUCITY!")
	self.created = nil
end

function GUIc:init()	
	self.omb = ButtonPressed(keys.esc)
	if self.created then 
		return
	end
	self.created = true

	local player = GetPlayer()
	if not player then
		Log("Trying to init GUI before creating player object.")
	end
	
	self.gc = WidgetContainer.create("gui", true)
	self.widgetContainer = WidgetContainer.create("WAT", false)
	self.game_over_widgets = WidgetContainer.create("game_over_screen", false)
	
	self.lives = {}
	for i=1,5 do
		self.lives[i] = self.gc:addPicture( {id = "life"..i, x=66+i*16, y=44, sprite="gui", anim="life"} )
		CreateWidget(constants.wt_Picture, "snd"..i, nil, 66+i*16, 44, 16, 16)
	end

	self.gc:addPicture( {sprite="gui", anim="gui_main"} )
	self.gc:addPicture( {sprite="gui", anim="gui_score", x=477} )
	self.sync_bar = self.gc:addPicture( {sprite="gui", anim="sync_bar", x=521, y = 16, w = 118, h = 18} )
	WidgetSetBorderColor( self.gc.elements[self.sync_bar], { 1, 0, 0, 1 }, false )
	self.gc:addPicture( {sprite="gui", anim="gui-red", id="gui_red", x=169, y=8} )	
	self.gc:addPicture( {sprite="gui", anim="gui-blue", id="gui_blue", x=169, y=8, visible=false} )
	self.gc:addLabel( {text="HEALTH", id="gui_health_label", x=10, y=10} )
	self.gc:addLabel( {text="0", color={0, 1, 0, 1}, id="gui_health", x=30, y=25} )
	self.gc:addLabel( {text="SCORE: 0", x=492, y=4, id="gui_score"} )
	self.gc:addLabel( {text="AMMO", x=102, y=10, id="gui_ammo_label"} )
	self.gc:addLabel( {text="100", x=110, y=25, id="gui_ammo"} )

	self.lastnum = nil
	self.sync = {}
	self.sync[ 1] = self.gc:addPicture( {id = "sync1",  x=523, y=18, sprite="gui", anim="sync_red_extra", invisible = true} )
	self.sync[ 2] = self.gc:addPicture( {id = "sync2",  x=531, y=18, sprite="gui", anim="sync_red", invisible = true} )
	self.sync[ 3] = self.gc:addPicture( {id = "sync3",  x=540, y=18, sprite="gui", anim="sync_yellow", invisible = true} )
	self.sync[ 4] = self.gc:addPicture( {id = "sync4",  x=549, y=18, sprite="gui", anim="sync_yellow", invisible = true} )
	self.sync[ 5] = self.gc:addPicture( {id = "sync5",  x=558, y=18, sprite="gui", anim="sync_yellow", invisible = true} )
	self.sync[ 6] = self.gc:addPicture( {id = "sync6",  x=567, y=18, sprite="gui", anim="sync_yellow", invisible = true} )
	self.sync[ 7] = self.gc:addPicture( {id = "sync7",  x=576, y=18, sprite="gui", anim="sync_green", invisible = true} )
	self.sync[ 8] = self.gc:addPicture( {id = "sync8",  x=585, y=18, sprite="gui", anim="sync_yellow", invisible = true} )
	self.sync[ 9] = self.gc:addPicture( {id = "sync9",  x=594, y=18, sprite="gui", anim="sync_yellow", invisible = true} )
	self.sync[10] = self.gc:addPicture( {id = "sync10", x=603, y=18, sprite="gui", anim="sync_yellow", invisible = true} )
	self.sync[11] = self.gc:addPicture( {id = "sync11", x=612, y=18, sprite="gui", anim="sync_yellow", invisible = true} )
	self.sync[12] = self.gc:addPicture( {id = "sync12", x=621, y=18, sprite="gui", anim="sync_red", invisible = true} )
	self.sync[13] = self.gc:addPicture( {id = "sync13", x=630, y=18, sprite="gui", anim="sync_red_extra", invisible = true} )

	self.game_over_widgets:addButton( {id="respawn", x=225, y=192, sprite="gui", anim="co", on_left=soh_btnOnLClick} )

	self.bonus = {}
	self.bonus[1] = self.gc:addPicture( {id = "bonus1",  x=227, y=10, sprite="gui"} )
	self.bonus[2] = self.gc:addPicture( {id = "bonus2",  x=273, y=10, sprite="gui"} )
	self.bonus[3] = self.gc:addPicture( {id = "bonus3",  x=319, y=10, sprite="gui"} )

	self.gc:show(true)
	
end

function GUIc:updateSyncBar()
	if not mapvar.sync then mapvar.sync = 0 end
	if mapvar.sync > 17 or mapvar.sync < -17 then
		WidgetSetBorder(self.gc.elements[self.sync_bar], Loader.time % 8 >= 4 )
	else
		WidgetSetBorder(self.gc.elements[self.sync_bar], false )
	end
	self.lastnum = self.syncnum
	self.syncnum = math.floor( 13*(((mapvar.sync + 30)/60)) ) + 1
	if self.syncnum > 13 then self.syncnum = 13 end
	--[[
	if self.lastnum and self.lastnum ~= self.syncnum then
		self.gc:showWidget( self.sync[self.lastnum], false )
		self.gc:showWidget( self.sync[self.syncnum], true )
	elseif not self.lastnum then
		self.gc:showWidget( self.sync[self.syncnum], true )
	elseif not self.syncnum then
		self.syncnum = 7
		self.gc:showWidget( self.sync[self.syncnum], true )
	end
	--]]
	for i=1,13 do
		self.gc:showWidget( self.sync[i], false )
	end
	self.gc:showWidget( self.sync[self.syncnum], true )
end

function GUIc:update()
	while self.visible do
		local player = GetPlayer()
		if not player then return end
		local hp = player.health
	
		if ( hp < 50 ) then
			if ( hp < 25 ) then
				WidgetSetCaptionColor(self.gc.elements["gui_health"], {1.0, 0.0, 0.0, 1.0}, false)
			else
				WidgetSetCaptionColor(self.gc.elements["gui_health"], {1.0, 0.5, 0.0, 1.0}, false)
			end
		else
			WidgetSetCaptionColor(self.gc.elements["gui_health"], {0.0, 1.0, 0.0, 1.0}, false)
		end
		WidgetSetCaption(self.gc.elements["gui_health"], "" .. hp)
		WidgetSetCaption(self.gc.elements["gui_ammo"], "" .. player.ammo)
		if ( player.altWeaponActive ) then
			WidgetSetVisible(self.gc.elements["gui_blue"], true)
			WidgetSetCaptionColor(self.gc.elements["gui_ammo_label"], {1, 1, 1, 1.0}, false)
			WidgetSetCaptionColor(self.gc.elements["gui_ammo"], {1, 1, 1, 1.0}, false)
		else
			WidgetSetVisible(self.gc.elements["gui_blue"], false)
--[[
			WidgetSetCaptionColor(self.gc.elements["gui_ammo_label"], {0.5, 0.5, 0.5, 1.0}, false)
			WidgetSetCaptionColor(self.gc.elements["gui_ammo"], {0.5, 0.5, 0.5, 1.0}, false)
--]]
			WidgetSetCaptionColor(self.gc.elements["gui_ammo_label"], {0.5, 0.5, 0.5, 1.0}, false)
			WidgetSetCaptionColor(self.gc.elements["gui_ammo"], {0.5, 0.5, 0.5, 1.0}, false)

		end
		if ( mapvar == nil or mapvar.score == nil ) then
			WidgetSetCaption(self.gc.elements["gui_score"], "SCORE: 0000000")
		else
			WidgetSetCaption(self.gc.elements["gui_score"], string.format("SCORE: %07d", mapvar.score))
		end

		if ( mapvar ~= nil and mapvar.lives ~= nil ) then
			if (mapvar.lives >=  6) then 
				self.showlives = 5
			else
				self.showlives = mapvar.lives
			end
			for i=1,(self.showlives or 1) do
				if self.lives[i] then self.gc:showWidget(self.lives[i], true) end
			end
			for i=(self.showlives or 1)+1,5 do
				if self.lives[i] then self.gc:showWidget(self.lives[i], false) end
			end
		end
	self:updateSyncBar()
	if mapvar.bonuses then
		do	-- определение active_char
			local active_num = GetPlayerNum()
			local active_char = "CIRNO"
			for kk, kv in pairs(mapvar.char) do
				if kv == active_num then active_char = kk; break; end
			end
			mapvar.active_char = active_char
			
			if Loader.level.char then 
				mapvar.active_char = Loader.level.char
			end
		end
		if mapvar.active_char and not mapvar.bonuses[mapvar.active_char] then mapvar.bonuses[mapvar.active_char] = {} end
		if not stat.weapon then stat.weapon = {} end
		if mapvar.active_char and mapvar.bonuses[mapvar.active_char][1] then
			WidgetSetVisible( self.gc.elements[self.bonus[1]], true )
			WidgetSetAnim( self.gc.elements[self.bonus[1]], mapvar.bonuses[mapvar.active_char][1], false )
		else
			WidgetSetVisible( self.gc.elements[self.bonus[1]], false )
		end
		if mapvar.active_char and mapvar.bonuses[mapvar.active_char][2] then
			WidgetSetVisible( self.gc.elements[self.bonus[2]], true )
			WidgetSetAnim( self.gc.elements[self.bonus[2]], mapvar.bonuses[mapvar.active_char][2], false )
		else
			WidgetSetVisible( self.gc.elements[self.bonus[2]], false )
		end
		if mapvar.active_char and mapvar.weapon[mapvar.active_char] and mapvar.weapon[mapvar.active_char] ~= "none" then
			WidgetSetVisible( self.gc.elements[self.bonus[3]], true )
			WidgetSetAnim( self.gc.elements[self.bonus[3]], mapvar.weapon[mapvar.active_char], false )
		else
			WidgetSetVisible( self.gc.elements[self.bonus[3]], false )
		end
	else
		WidgetSetVisible( self.gc.elements[self.bonus[1]], false )
		WidgetSetVisible( self.gc.elements[self.bonus[2]], false )
		WidgetSetVisible( self.gc.elements[self.bonus[3]], false )
	end


	Wait(1)
	end
end

function GUIc:showGameOver()
	if self.gameOverShown then return end
	self.gameOverShown = true
	LoadSound("music\\iie_finish.it")
	StopBackMusic()
	PlaySnd("iie_finish", true)
	self.game_over_widgets:show(true)
end

return GUIc