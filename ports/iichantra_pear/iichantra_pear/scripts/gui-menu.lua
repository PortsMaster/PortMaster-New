require( "menus" )
require("weather")

Menu = PagedMenu.create()
Menu.mn = false

local firstKeyConfigPage = 102

-------------------------------------------------------------------------------------------------------------------------------------------
--Page 1: Main menu
Menu:addPage( 1, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )
vars.game_mode = "STORY"
vars.start_map = "2011-lab"
vars.difficulty = 1

Menu:add( MWSpace.create( 0, 15 ) )
Menu:add( 
			MWFunctionButton.create( 
					{name="default", color={1,1,1,1}, active_color={.2,.2,1,1}}, 
					"START",
					0, 
					function (sender, param) 
						difficulty = vars.difficulty
						assert(Loader.startGame( vars.start_map ))
						Menu.hideMainMenu()
					end, 
					nil,
					{name="wakaba-widget"}
			) 
		)

local load = Menu:add(
			MWFunctionButton.create( 
					{name="default", color={1,1,1,1}, active_color={.2,1,.2,1}}, 
					"LOAD", 
					0, 
					function (sender, param) 
						Menu:saveBackPage(1)
						Menu.showLoadMenu()
					end, 
					nil,
					{name="wakaba-widget"}
			)
		)

--Menu.pages[1].contents[load]:disable()
Menu:add( MWSpace.create( 0, 10 ) )

local sx, sy = GetCaptionSize( "default",  dictionary_string("DIFFICULTY:") )
Menu:add( 
			MWLabeledButton.create( 
					{name="default", color={1,1,1,1}, active_color={1,0,0,1}}, 
					"DIFFICULTY:", 
					15, 
					MWCycleButton.create(
						{name="default", color={.8,.8,1,1}, active_color={.6,.6,1,1}},
						"",
						-1,
						{ name = "wakaba-widget" },
						function ( sender, new_value )
							if new_value > 1 then
								WidgetSetCaptionColor( sender, {1, .3, .3, 1}, false )
								WidgetSetCaptionColor( sender, {1, .1, .1, 1}, true )
							elseif new_value < 1 then
								WidgetSetCaptionColor( sender, {.3, .3, 1, 1}, false )
								WidgetSetCaptionColor( sender, {.1, .1, 1, 1}, true )
							else
								WidgetSetCaptionColor( sender, {.8, .8, 1, 1}, false )
								WidgetSetCaptionColor( sender, {.6, .6, 1, 1}, true )
							end
						end,
						"difficulty",
						{1, 2, 0.5},
						{"Just another ktd.", "Novak-kun mode!", "I'm _tsu young to die."}
					)
			) 
		)

local sx, sy = GetCaptionSize( "default",  dictionary_string("MODE:") )
Menu:add( 
			MWLabeledButton.create( 
					{name="default", color={1,1,1,1}, active_color={1,0,0,1}}, 
					"MODE:", 
					15, 
					MWCycleButton.create(
						{name="default", color={.8,.8,1,1}, active_color={.6,.6,1,1}},
						"",
						-1,
						{ name = "wakaba-widget" },
						function ( sender, new_value )
						--[[
							if new_value == "STORY" then
								vars.start_map = "1-1script"
							elseif new_value == "SURVIVAL" then
								vars.start_map = "survival"
							else
								vars.start_map = "1-1script"
							end
						--]]
							vars.start_map = "2011-lab"
						end,
						"game_mode",
						{"STORY"}
					)
			) 
		)
		
Menu:add( MWSpace.create( 0, 10 ) )		
Menu:add( 
			MWFunctionButton.create( 
					{name="default", color={1,1,1,1}, active_color={.2,.2,1,1}}, 
					"OPTIONS",
					0, 
					function (sender, param) 
						Menu:show(2)
						Menu:saveBackPage(1)
					end, 
					nil,
					{name="wakaba-widget"}
			) 
		)
Menu:add( 
			MWFunctionButton.create( 
					{name="default", color={1,.5,.5,1}, active_color={1,.2,.2,1}}, 
					"EXIT",
					0, 
					ExitGame, 
					nil,
					{name="wakaba-widget"}
			) 
		)
Menu:add( MWSpace.create( 0, 15 ) )

function Menu.showMainMenu()
	InitNewGame()
	Menu.mn = true
	SetCamLag( 0 )
--[[
	local rib = CreateRibbon("1st_plan", 615, 0, 0.1, 0);
	SetRibbonZ(rib, -0.1)
	SetRibbonBounds(rib, 43, 0, 0, 0)
	rib = CreateRibbon("2nd_plan", 615, 0, 0.45, 0);
	SetRibbonZ(rib, -0.75)
	SetRibbonBounds(rib, 43, 0, 0, 0)
	rib = CreateRibbon("2nd_plan", 615, 0, 0.3, 0);
	SetRibbonZ(rib, -0.75)
	SetRibbonBounds(rib, 43, 0, 0, 0)
	rib = CreateRibbon("3nd_plan", 615, 0, 0.5, 0);
	SetRibbonZ(rib, -0.8)
	SetRibbonBounds(rib, 43, 0, 0, 0)
	rib = CreateRibbon("4nd_plan", 615, 0, 0.6, 0);
	SetRibbonZ(rib, -0.85)
	SetRibbonBounds(rib, 43, 0, 0, 0)
	rib = CreateRibbon("skyline", 0, 200, 0.7, 0);
	SetRibbonZ(rib, -0.9)
	SetRibbonBounds(rib, 43, 0, 0, 0)
--]]
	CONFIG.backcolor_r = 0.000000;
	CONFIG.backcolor_g = 0.000000;
	CONFIG.backcolor_b = 0.000000;

	--LoadConfig()
	FadeOutGlobalVolume(5000, true, nil)

	PlayBackMusic( "music/nsmpr_wti.it" )
	LetterBox( false )

	SetRibbonObjRepitition( CreateRibbonObj( "2011parallax3", -1.000000, 1.000000, -243, -234, -1.1, false ), true, true )
	local rib = CreateRibbonObj( "2011menu4", 0.15, 0, 0, -160-70, -1, false )
	SetRibbonObjRepitition( rib, true, false )
	rib = CreateRibbonObj( "2011menu3", 0.125, 0, 0, -140-80, -1, false )
	SetRibbonObjRepitition( rib, true, false )
	local rib = CreateRibbonObj( "2011menu2", 0.075, 0, 0, -120-100, -1, false )
	SetRibbonObjRepitition( rib, true, false )
	local rib = CreateRibbonObj( "2011menu1", -0.4, 0, 0, -200-20, -0.1, false )
	SetRibbonObjRepitition( rib, true, false )
	
	Menu.register_weather = function ( id, weather_id )
	end
	Menu.create_weather = function ()
		CreateSprite( "weather-snow", 0, 0 )
	end
	SetWind( { 2, 0 } )
	Weather.set_slave_weather_proc(Menu, Menu.register_weather, Menu.create_weather)
	Weather.check_weather()
	
	Menu.logo = CreateWidget( constants.wt_Picture, "menu_logo", nil, 64, 20, 1, 1 )
	WidgetSetSprite(Menu.logo, "logo-cold")
	WidgetSetVisible(Menu.logo, true)
	
	slow = CreateEnemy( "hoverbike", 0, 135 );
	CreateEffect( "dust-hoverbike", 0, 0, slow, 0 )
	sign = CreateSprite("hw_sign", 590, 70);
	ObjectPushInt((slow or 1), (sign or 0));
	
	--SetCamObjOffset(-200, 50);
	SetCamAttachedObj((slow or 1));
	SetCamAttachedAxis(true, false);
	SetCamObjOffset(-225, 0);
	SetCamUseBounds(false)

	Menu:show(1)
end

function Menu.hideMainMenu()
	Menu.mn = false
	Weather.clean_slave_weather_proc(Menu)
	if Menu.logo then DestroyWidget( Menu.logo ) end
	Menu:hide()
end
-------------------------------------------------------------------------------------------------------------------------------------------
--Pages 2 and 3: Options from main menu and from in-game
Menu:addPage( 2, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )
Menu:addPage( 3, SimpleMenu.create( {320, 240}, 0, 0, 30, 10 ) )

function Menu.createCommonOptions( page )
		Menu:add( MWSpace.create(0, 15), page )
		Menu:add(
			MWFunctionButton.create(
				{name="default", color = {1, 1, 1, 1}, color_active = {.7, .7, 1, 1}},
				"CONTROLS",
				0,
				function (sender, param)
					Menu.logo_visible = WidgetGetVisible( Menu.logo )
					WidgetSetVisible( Menu.logo, false )
					Menu:show(4)
					Menu:saveBackPage(page)
				end,
				nil,
				{ name = "wakaba-widget" }
			),
			page
		)
		Menu:add(
			MWFunctionButton.create(
				{name="default", color = {1, 1, 1, 1}, color_active = {.7, .7, 1, 1}},
				"AUDIO",
				0,
				function (sender, param)
					Menu:show(5)
					Menu:saveBackPage(page)
				end,
				nil,
				{ name = "wakaba-widget" }
			),
			page
		)
		---[[
		Menu:add(
			MWFunctionButton.create(
				{name="default", color = {1, 1, 1, 1}, color_active = {.7, .7, 1, 1}},
				"GAME",
				0,
				function (sender, param)
					Menu:show(6)
					Menu:saveBackPage(page)
				end,
				nil,
				{ name = "wakaba-widget" }
			),
			page
		)
		--]]
end

--[[
Menu:add(
	MWComposition.create(
		30, {	
				MWFunctionButton.create({name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
				"RESUME",
				0,
				function (sender, param)
					Menu:hide()
					pop_pause()
					Menu.mn = false
				end,
				nil,
				{ name = "wakaba-widget" }),
				
				MWFunctionButton.create({name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
				"EXIT",
				0,
				function (sender, param)
					Loader.exitGame()
				end,
				nil,
				{ name = "wakaba-widget" }),
			}
	),
	3
)
-]]
Menu:add( MWSpace.create(0, 15), 2 )
Menu:add( MWSpace.create(0, 15), 3 )

--[[
vars.music = "CHIPTUNE"
Menu:add( 
			MWLabeledButton.create( 
					{name="default", color={1,1,1,1}, active_color={1,0,0,1}}, 
					"MUSIC:", 
					15, 
					MWCycleButton.create(
						{name="default", color={.8,.8,1,1}, active_color={.6,.6,1,1}},
						"",
						-1,
						{ name = "wakaba-widget", pos = { -(sx+40), -5 } },
						function (sender, value)
							if value == "CHIPTUNE" then
								PlayBackMusic("music/nsmpr_choice.it")
							else
								PlayBackMusic("music/nsmpr_EpilepticMarch.ogg")
							end
						end,
						"music",
						{"CHIPTUNE", "FULL"},
						nil
					)
			),
			3
		)
--]]

Menu:add(
		MWFunctionButton.create({name="default", color = {1, .8, .8, 1}, color_active = {1, .7, .7, 1}},
				"RESUME",
				0,
				function (sender, param)
					Menu:hide()
					pop_pause()
					Menu.mn = false
				end,
				nil,
				{ name = "wakaba-widget" }),
		3
)

Menu:add(
		MWFunctionButton.create({name="default", color = {1, .8, .8, 1}, color_active = {1, .7, .7, 1}},
				"EXIT",
				0,
				function (sender, param)
					Loader.exitGame()
				end,
				nil,
				{ name = "wakaba-widget" }),
		3
)

Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, 1}, color_active = {1, .7, .7, 1}},
		"BACK",
		0,
		function (sender, param)
			Menu:goBack()
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	2
)

Menu:add(
	MWFunctionButton.create(
		{name="default", color = {.8, .8, 1, 1}, color_active = {.7, .7, 1, 1}},
		"RESTART",
		0,
		function (sender, param)
			Loader.restartGame( Loader.map_name )
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	3
)
--[[
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
		"SAVE GAME",
		0,
		function (sender, param)
			Menu:saveBackPage(3)
			Menu.showSaveMenu()
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	3
)
--]]
--Menu:add( MWSpace.create(0, 15), 3 )

Menu.createCommonOptions(2)
Menu.createCommonOptions(3)


Menu:add( MWSpace.create(0, 15), 2 )
Menu:add( MWSpace.create(0, 15), 3 )
--------------------------------------------------------------------------------------------------------------------------------------------
--Page 4: controls config

Menu:addPage( 4, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )
do
	Menu:add( MWSpace.create(0, 15), 4 )

	for i = 1,constants.configKeySetsNumber do
		local button = MWFunctionButton.create(
							{name="default", color={1,1,1,1}, active_color={.2,.2,1,1}},
							(dictionary_string("CONTROLLER") .. " " .. i),
							0,
							function (sender, param, sender_obj)
								if not Menu.locked then Menu.locked = { false } end
								table.insert( Menu.locked, true )
								Menu:saveBackPage(4)
								Menu:show(sender_obj.keyConfigPageNumber + firstKeyConfigPage)
							end,
							nil,
							{name="wakaba-widget"}
						)
						
		button.setText = function(self, t)
			self.text = dictionary_string("CONTROLLER") .. " " .. self.keyConfigPageNumber
			self:updateText()
			if self.menu and self.widget and WidgetGetVisible(self.widget) then 
				self.menu:redraw() 
			end
		end
		
		button.keyConfigPageNumber = i - 1
		Menu:add( button, 4 )
	end	
	Menu:add( MWSpace.create(0, 15), 4 )
	Menu:add(
		MWFunctionButton.create(
			{name="default", color = {1, .8, .8, 1}, color_active = {1, .7, .7, 1}},
			"BACK",
			0,
			function (sender, param)
				WidgetSetVisible( Menu.logo, (Menu.logo_visible or false) )
				Menu:show(Menu.back)
				Menu:goBack()
				--Menu:show(oldBack or Menu.back)
			end,
			nil,
			{ name = "wakaba-widget" }
		),
		4
	)	
	Menu:add( MWSpace.create(0, 15), 4 )	
end
--------------------------------------------------------------------------------------------------------------------------------------------
--Page 5: audio config

Menu:addPage( 5, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )
Menu:add( MWSpace.create(0, 15), 5 )
Menu:add( MWCaption.create( nil, "VOLUME", 0 ), 5 )
Menu:add( MWSpace.create(0, 15), 5 )
Menu:add( MWLabeledButton.create(
			{name="default", color={1,1,1,1}, active_color={1,0,0,1}},
			"MASTER",
			30,
			MWBar.create(
				{
					background={ name="gui", anim="snd_bkg", w = 1, h = 18 },
					start={ name="gui", anim="snd_main", w = 16, h = 16 },
					bar={ name="gui", anim="snd_block", w = 16, h = 16 }
				},
				{},
				{ name = "volume", start = GetMasterSoundVolume(), per_bar = 0.1, max_bars = 10, max_value = 1.0, min_value = 0, bar_size = { 160, 16 } },
				function ( sender, new_value )
					if (not Menu.mute) or (Menu.mute == "OFF") then
						CONFIG.volume = new_value
						SetMasterSoundVolume( new_value )
						SaveConfig()	
					end
				end,
				{ name = "wakaba-widget", pos = {-20, 0}}
			),
			5,
			1
		),
		5
)
Menu:add(	MWLabeledButton.create(
			{name="default", color={1,1,1,1}, active_color={1,0,0,1}},
			"MUSIC",
			30,
			MWBar.create(
				{
					background={ name="gui", anim="snd_bkg", w = 1, h = 18 },
					start={ name="gui", anim="snd_main", w = 16, h = 16 },
					bar={ name="gui", anim="snd_block", w = 16, h = 16 }
				},
				{},
				{ name = "volume_music", start = GetMasterMusicVolume(), per_bar = 0.1, max_bars = 10, max_value = 1.0, min_value = 0, bar_size = { 160, 16 } },
				function ( sender, new_value )
					if (not Menu.mute) or (Menu.mute == "OFF") then
						SetMasterMusicVolume( new_value )
						SaveConfig()	
					end
				end,
				{ name = "wakaba-widget", pos = {-20, 0}}
			),
			5,
			1
		),
		5
)
Menu:add(	MWLabeledButton.create(
			{name="default", color={1,1,1,1}, active_color={1,0,0,1}},
			"SOUND",
			30,
			MWBar.create(
				{
					background={ name="gui", anim="snd_bkg", w = 1, h = 18 },
					start={ name="gui", anim="snd_main", w = 16, h = 16 },
					bar={ name="gui", anim="snd_block", w = 16, h = 16 }
				},
				{},
				{ name = "volume_sound", start = GetMasterSFXVolume(), per_bar = 0.1, max_bars = 10, max_value = 1.0, min_value = 0, bar_size = { 160, 16 } },
				function ( sender, new_value )
					if (not Menu.mute) or (Menu.mute == "OFF") then
						SetMasterSFXVolume( new_value )
						SaveConfig()	
					end
				end,
				{ name = "wakaba-widget", pos = {-20, 0}}
			),
			5,
			1
		),
		5
)
Menu:add( MWSpace.create(0, 5), 5 )
local sx, sy = GetCaptionSize( "default",  dictionary_string("MUTE:") )
Menu:add( 
			MWLabeledButton.create( 
					{name="default", color={1,1,1,1}, active_color={1,0,0,1}}, 
					"MUTE:", 
					15, 
					MWCycleButton.create(
						{name="default", color={.8,.8,1,1}, active_color={.6,.6,1,1}},
						"",
						-1,
						{ name = "wakaba-widget" },
						function (sender, new_value)
							Menu.mute = new_value
							if new_value == "ON" then
								Menu.mute_volume = GetMasterSoundVolume()
								SetMasterSoundVolume(0)
							else
								SetMasterSoundVolume(Menu.mute_volume)
							end
						end,
						"mute",
						{"OFF", "ON"},
						{"MUTE_OFF", "MUTE_ON"}
					)
			),
			5
		)
Menu:add( MWSpace.create(0, 15), 5 )
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, 1}, color_active = {1, .7, .7, 1}},
		"BACK",
		0,
		function (sender, param)
			Menu:goBack()
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	5
)
Menu:add( MWSpace.create(0, 15), 5 )

--------------------------------------------------------------------------------------------------------------------------------------------
--Page 6: game config
Menu:addPage( 6, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )
vars.weather = CONFIG.weather
vars.language = CONFIG.language

Menu:add( MWSpace.create(0, 15), 6 )

local sx, sy = GetCaptionSize( "default",  dictionary_string("WEATHER EFFECTS:") )

Menu:add( 
			MWLabeledButton.create( 
					{name="default", color={1,1,1,1}, active_color={1,0,0,1}}, 
					"WEATHER EFFECTS:", 
					15, 
					MWCycleButton.create(
						{name="default", color={.8,.8,1,1}, active_color={.6,.6,1,1}},
						"",
						-1,
						{ name = "wakaba-widget" },
						function (sender, new_value)
							CONFIG.weather = new_value
							LoadConfig()
							SaveConfig()
							Weather.check_weather()
						end,
						"weather",
						{1, 0},
						{"WEATHER_FULL", "WEATHER_NONE"}
					)
			),
			6
		)
Menu:add( 
			MWLabeledButton.create( 
					{name="default", color={1,1,1,1}, active_color={1,0,0,1}}, 
					"LANGUAGE:", 
					15, 
					MWCycleButton.create(
						{name="default", color={.8,.8,1,1}, active_color={.6,.6,1,1}},
						"",
						-1,
						{ name = "wakaba-widget"},
						function (sender, new_value)
							CONFIG.language = new_value
							LoadConfig()
							SaveConfig()
							LangChanger.LoadLanguage()
						end,
						"language",
						{"english", "russian"},
						{"ENGLISH", "RUSSIAN"}
					)
			),
			6
		)

Menu:add( MWSpace.create(0, 15), 6 )
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, 1}, color_active = {1, .7, .7, 1}},
		"BACK",
		0,
		function (sender, param)
			Menu:goBack()
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	6
)
		
Menu:add( MWSpace.create(0, 15), 6 )

-------------------------------------------------------------------------------------------------------------------------------------------
--Page 7: Game Over

function Menu.showGameOver()
	StopBackMusic()
	PlaySnd( "music/iie_lose_jingle.it", false )
	if not Menu.gow then
		local widget = CreateWidget( constants.wt_Picture, "GAME OVER, MAN", nil, CONFIG.scr_width/2-173, 150, 1, 1 )
		WidgetSetSprite( widget, "gui" )
		WidgetSetAnim( widget, "game_over" )
		WidgetSetVisible( widget, true )
		Menu.gow = widget
	else
		WidgetSetVisible( Menu.gow, true )
	end
end

local function gameover_exit()
	WidgetSetVisible( Menu.gow, false )
	Menu.goshown = false
	Menu:hide()
	Menu:clearBackStack()
	Loader.exitGame()
end

Menu:addPage( 7, SimpleMenu.create( {320, 280}, 0, 0, 30, 10 ) )
Menu:add( MWSpace.create(0, 15), 7 )
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
		"RESTART",
		0,
		function (sender, param)
			WidgetSetVisible( Menu.gow, false )
			Loader.state = 'new' 
            	Loader.restartGame( Loader.mapName ) 
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	7
)
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
		"SEND SCORES AND EXIT TO MENU",
		0,
		function (sender, param)
			Menu:saveBackPage(7)
			Menu.showScoresMenu()
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	7
)
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
		"TO MENU",
		0,
		function (sender, param)
			gameover_exit()
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	7
)
Menu:add( MWSpace.create(0, 15), 7 )


-------------------------------------------------------------------------------------------------------------------------------------------
--Page 8: End level
Menu:addPage( 8, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )
Menu:add( MWSpace.create(0, 15), 8 )
Menu:add( MWCaption.create( nil, "Congratulations", 0 ), 8 )
Menu:add( MWSpace.create(0, 15), 8 )
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
		"CONTINUE",
		0,
		function (sender, param)
			StopAllSnd()
			pop_pause()
			FadeIn(0)
			Loader.ChangeLevel(Loader.map_name)
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	8
)
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
		"SAVE GAME",
		0,
		function (sender, param)
			Menu:saveBackPage(8)
			Menu.showSaveMenu()
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	8
)
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
		"EXIT",
		0,
		function (sender, param)
			Menu.locked = false
			pop_pause()
			FadeIn(0)
			Loader.exitGame()
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	8
)
Menu:add( MWSpace.create(0, 15), 7 )


function Menu.showEndLevelMenu(nextLevel)
	FadeOut({0, 0, 0}, 0)
	StopBackMusic()
	PlaySnd( "music/iie_win_jingle.it", true )
	Menu.locked = {true}
	push_pause(true)
	Loader.map_name = nextLevel
	Menu:show(8)
end

-------------------------------------------------------------------------------------------------------------------------------------------
--Page 9: Load game
--Page 10: Save game

local function createLoadSaveMenu(menu_num, label, button_func, func_get_show_func)

	Menu:addPage( menu_num, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )

	Menu:add( MWSpace.create(0, 15), menu_num )
	Menu:add( MWCaption.create( nil, label, 0 ), menu_num )
	Menu:add( MWSpace.create(0, 15), menu_num )
	local slot_buttons = {}
	for i = 1, 12 do
		local button = MWFunctionButton.create(
				{name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
				"Slot" .. i,
				0,
				button_func,
				nil,
				{ name = "wakaba-widget" }
			)
		slot_buttons[i] = button
		button.slot_num = i
		Menu:add(button, menu_num)
	end
	Menu:add( MWSpace.create(0, 15), menu_num )
	Menu:add(
		MWFunctionButton.create(
			{name="default", color = {1, .8, .8, 1}, color_active = {1, .7, .7, 1}},
			"BACK",
			0,
			function (sender, param)
				Menu:goBack()
			end,
			nil,
			{ name = "wakaba-widget" }
		),
		menu_num
	)
	Menu:add( MWSpace.create(0, 15), menu_num )
	return slot_buttons
end



local function load_button_lclick (sender, param)
	local butt = MWFunctionButton.widgets[sender]
	if butt and butt.slot_num then  
		Saver:loadGame(butt.slot_num)
		Menu.hideMainMenu()
	end
end

local function save_button_lclick (sender, param)
	local butt = MWFunctionButton.widgets[sender]
	if butt and butt.slot_num then  
		local info = {}
		info.mapname = Loader.level.name or "UNNAMED MAP"
		Saver:saveGame(butt.slot_num, info)
		Menu:goBack()
	end
end


local load_buttons = createLoadSaveMenu(9, "Load game", load_button_lclick, get_load_button_show_func)
local save_buttons = createLoadSaveMenu(10, "Save game", save_button_lclick, get_save_button_show_func)

function Menu.showSaveMenu()
	for k,v in pairs(save_buttons) do
		if Saver:doesExist(v.slot_num) then
			MWTextFocusable.setWidgetText(v.widget, Saver:getSlotName(v.slot_num))
		else
			MWTextFocusable.setWidgetText(v.widget, "None")
		end
	end
	Menu:show(10)
end

function Menu.showLoadMenu()
	for k,v in pairs(load_buttons) do
		if Saver:doesExist(v.slot_num) then
			MWTextFocusable.setWidgetText(v.widget, Saver:getSlotName(v.slot_num))
			v:enable()
		else
			MWTextFocusable.setWidgetText(v.widget, "None")
			v:disable()
		end
	end
	Menu:show(9)	
end
-------------------------------------------------------------------------------------------------------------------------------------------
--Page 11: Send scores

vars.nickname = "Anonymous"

Menu:addPage( 11, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )
Menu:add( MWSpace.create(0, 15), 11 )
Menu:add( MWCaption.create( nil, "SEND SCORES", 0 ), 11 )
Menu:add( MWSpace.create(0, 15), 11 )

local scores_points_caption = MWCaption.create({name="dialogue", color={.7, 1, .7, 1}, active_color={1,1,1,1}}, "0", nil)
local scores_seconds_caption = MWCaption.create({name="dialogue", color={.7, 1, .7, 1}, active_color={1,1,1,1}}, "0", nil)
Menu:add(
	MWLabeledButton.create({name="dialogue", color = {1, .8, .8, .8}, color_active = {.7, .7, .7, 1}}, "POINTS", 10, 
		scores_points_caption, 
		nil, nil),
	11
)
Menu:add(
	MWLabeledButton.create({name="dialogue", color = {1, .8, .8, .8}, color_active = {.7, .7, .7, 1}}, "SECONDS", 10, 
		scores_seconds_caption, 
		nil, nil),
	11
)

Menu:add( MWSpace.create(0, 15), 11 )

Menu:add(
	MWLabeledButton.create({name="dialogue", color = {1, .8, .8, .8}, color_active = {.7, .7, .7, 1}}, "Name", 10, 
		MWInputField.create({name="dialogue", color={.7, .7, .7, 1}, active_color={1,1,1,1}}, 
			nil, -1, nil,
			nil, "nickname", 16), 
		nil, nil),
	11
)

Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, .8}, color_active = {1, .7, .7, 1}},
		"SEND",
		0,
		function (sender, param)
			local points = (mapvar and mapvar.score) and mapvar.score or 0
			local seconds = (mapvar and mapvar.game_timer) and mapvar.game_timer or 0
			--Log("Sending scores ", points, " ", seconds, " ", vars.nickname)
			local res = SendHighscores(vars.nickname, points, seconds/1000) 
			if res then
				gameover_exit()
			else
				Menu.scores_status_caption:show(true)
				Menu.scores_status_caption:setText("Sending failed")
			end
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	11
)
Menu:add(
	MWFunctionButton.create(
		{name="default", color = {1, .8, .8, 1}, color_active = {1, .7, .7, 1}},
		"BACK",
		0,
		function (sender, param)
			WidgetSetVisible( Menu.gow, true )
			Menu:goBack()
		end,
		nil,
		{ name = "wakaba-widget" }
	),
	11
)
Menu:add( MWSpace.create(0, 15), 11 )
Menu.scores_status_caption = MWCaption.create( nil, "", 0 )
Menu:add( Menu.scores_status_caption, 11 )


Menu:add( MWSpace.create(0, 15), 11 )

function Menu.showScoresMenu()
	local points = (mapvar and mapvar.score) and mapvar.score or 0
	local seconds = (mapvar and mapvar.game_timer) and mapvar.game_timer or 0
	scores_points_caption:setText(points)
	scores_seconds_caption:setText(seconds/1000)
	WidgetSetVisible( Menu.gow, false )
	Menu:show(11)
	Menu.scores_status_caption:show(false)
end

-------------------------------------------------------------------------------------------------------------------------------------------

for i=2,11 do
	Menu:hide(i)
end

-------------------------------------------------------------------------------------------------------------------------------------------
--Page 101: Press button
Menu:addPage( 101, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )
Menu:add( MWSpace.create(0, 15), 101 )
Menu:add( MWCaption.create( nil, "PRESS BUTTON", 0 ), 101 )
Menu:add( MWSpace.create(0, 15), 101 )
Menu:hide(101)

-------------------------------------------------------------------------------------------------------------------------------------------
--Page 102 - 110: Key config for key sets

local function getKeyConfigButtonName(code)
	return (code ~= 0) and ( GetKeyName(code) or "BAD_BUTTON" ) or ""
end

function setButt(sender, param, sender_obj)
	--Log("key = ", sender_obj.configKey, " setNum = ", sender_obj.keysSetNum)
	local oldGlobalOnReleaseProc = GlobalGetKeyReleaseProc()
	--Log("oldGlobalOnReleaseProc = ", oldGlobalOnReleaseProc)

	local function keyWaiter(keyCode)
		--Log("in keyWaiter key = ", sender_obj.configKey, " setNum = ", sender_obj.keysSetNum)
		--Log("keycode = ", keyCode, " - ", GetKeyName(keyCode))
		
		GlobalSetKeyReleaseProc(oldGlobalOnReleaseProc)
		if CONFIG.key_conf[sender_obj.keysSetNum] then
			CONFIG.key_conf[sender_obj.keysSetNum][sender_obj.configKey] = keyCode
			LoadConfig()
			SaveConfig()
			MWTextFocusable.setWidgetText(sender, 
				getKeyConfigButtonName(CONFIG.key_conf[sender_obj.keysSetNum][sender_obj.configKey]))
		end
		
		Menu:show(sender_obj.keysSetNum - 1 + firstKeyConfigPage)

		return true
	end

	GlobalSetKeyReleaseProc(keyWaiter)
	Menu:show(101)
end

function clearButt(sender, param, sender_obj)
	if CONFIG.key_conf[sender_obj.keysSetNum] then
		CONFIG.key_conf[sender_obj.keysSetNum][sender_obj.configKey] = 0
		LoadConfig()
		SaveConfig()
		MWTextFocusable.setWidgetText(sender, 
			getKeyConfigButtonName(CONFIG.key_conf[sender_obj.keysSetNum][sender_obj.configKey]))
	end
end	

local function controlsButton( key, name, num )
	local sx, sy = GetCaptionSize( "default", dictionary_string(name)..":" )
	local key_name = getKeyConfigButtonName(CONFIG.key_conf[num] and CONFIG.key_conf[num][key] or 0)
	--Log("key = ", key," val = ", key_val, " name = ", key_name)	
	
	local button = MWFunctionButton.create(
				{name="default", color={.8,.8,1,1}, active_color={.6,.6,1,1}},
				key_name,
				-1,
				setButt,
				key,
				{ name = "wakaba-widget" },
				clearButt
			)
	button.configKey = key
	button.keysSetNum = num
	
	ret = MWLabeledButton.create(
			{name="default", color={1,1,1,1}, active_color={1,0,0,1}},
			name,
			15,
			button
	)
	return ret
end

local function createKeyConfigPage(num)
	local pageNum = num - 1 + firstKeyConfigPage
	--Log("crating keyConfPage #", pageNum)
	Menu:addPage( pageNum, SimpleMenu.create( {320, 300}, 0, 0, 30, 10 ) )
	--Menu:add( MWSpace.create(0, 15), pageNum )
	--Menu:add( MWCaption.create( font={name="default", color={1,1,1,1} }, ("CONTROLLER " .. (pageNum - firstKeyConfigPage)), -1, nil )
	Menu:add( MWSpace.create(0, 15), pageNum )
	Menu:add( controlsButton( "left", "LEFT", num ), pageNum )
	Menu:add( controlsButton( "right", "RIGHT", num ), pageNum )
	Menu:add( controlsButton( "up", "UP", num ), pageNum )
	Menu:add( controlsButton( "down", "DOWN", num ), pageNum )
	Menu:add( controlsButton( "sit", "CROUCH", num ), pageNum )
	Menu:add( controlsButton( "fire", "SHOOT", num ), pageNum )
	Menu:add( controlsButton( "jump", "JUMP", num ), pageNum )
	Menu:add( controlsButton( "change_weapon", "WEAPON", num ), pageNum )
	Menu:add( controlsButton( "change_player", "CHARACTER", num ), pageNum )
	Menu:add( controlsButton( "player_use", "USE", num ), pageNum )
	Menu:add( controlsButton( "gui_nav_menu", "MENU", num ), pageNum )
	Menu:add( controlsButton( "gui_nav_accept", "ACCEPT", num ), pageNum )
	Menu:add( controlsButton( "gui_nav_decline", "CANCEL", num ), pageNum )
	Menu:add( controlsButton( "gui_nav_next", "MENU NEXT", num ), pageNum )
	Menu:add( controlsButton( "gui_nav_prev", "MENU BACK", num ), pageNum )
	Menu:add( MWSpace.create(0, 15), pageNum )
	Menu:add(
		MWFunctionButton.create(
			{name="default", color = {1, .8, .8, 1}, color_active = {1, .7, .7, 1}},
			"BACK",
			0,
			function (sender, param)
				table.remove(Menu.locked, #Menu.locked)
				Menu:goBack()
			end,
			nil,
			{ name = "wakaba-widget" }
		),
		pageNum
	)
	Menu:add( MWSpace.create(0, 15), pageNum )
	Menu:hide(pageNum)
end

for i = 1,constants.configKeySetsNumber do
	createKeyConfigPage(i)
end

