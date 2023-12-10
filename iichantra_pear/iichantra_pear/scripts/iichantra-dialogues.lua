require("dialogue")
require("routines")
dialogues = {}

------------------------------------------------
dialogues[1] = Dialogue.create()
dialogues[1].lines["ROOT"] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", "DIALOGUE1-1"}, {
					{align=constants.taCenter}, 
					{align=constants.taLeft},
					portrait_left="portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues[1].lines[1] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNKNOWN", "DIALOGUE1-2"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "PORTRAIT_CLEAR"})	
dialogues[1].lines[2] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", "DIALOGUE1-3"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left="portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues[1].lines[3] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", "DIALOGUE1-4"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
dialogues[1].lines[4] = DialogueLine.create(constants.dlChoice,
					{"DIALOGUE1-5", "DIALOGUE1-6"}, {
					5, 
					43,
					text = "DIALOGUE_SOH",
					portrait_left="portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR"})
					
	--Тут лучше оставить побольше места в первой строчке, потому что названия кнопок могуть быть длинными.
dialogues[1].lines[5] = DialogueLine.create(constants.dlText, {
					string.format(dictionary_string("DIALOGUE1-7"), GetKeyName(CONFIG.key_conf[1].gui_nav_decline))}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
	
dialogues[1].lines[6] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", "DIALOGUE1-8" }, {
					{align=constants.taCenter},
					{},
					skip_to = 9,
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[7] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", "DIALOGUE1-9"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[8] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", "DIALOGUE1-10"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
			
dialogues[1].lines[9] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-11"}, {
					{align=constants.taCenter},
					{},
					skip_to = 12 } )
					
dialogues[1].lines[10] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", "DIALOGUE1-12"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[11] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-13"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[12] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-14"}, {
					{align=constants.taCenter},
					{},
					skip_to = 17} )
					
dialogues[1].lines[13] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE1-15"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
	
dialogues[1].lines[14] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-16"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[15] = DialogueLine.create(constants.dlScript, 
					function()
						Log("dialog line 15")
						FadeIn(2000) 
					end )
					
dialogues[1].lines[16] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-17"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[17] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-18"}, {
					{align=constants.taCenter},
					{} 
					} )
					
dialogues[1].lines[18] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE1-19"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[19] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-20"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[20] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE1-21"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[21] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-22"}, {
					{align=constants.taCenter},
					{},
					skip_to = 23,
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[22] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE1-23"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )				
	
dialogues[1].lines[23] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-24"}, {
					{align=constants.taCenter},
					{},
					skip_to = 27,
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )

dialogues[1].lines[24] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE1-25"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )	

dialogues[1].lines[25] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE1-26"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[26] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-27"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )

dialogues[1].lines[27] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-28"}, {
					{align=constants.taCenter},
					{} } )
					
dialogues[1].lines[28] = DialogueLine.create(constants.dlText, { "DIALOGUE1-29" }, {
					{align=constants.taCenter}, 
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "portrait-unyl" } )
					
dialogues[1].lines[29] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-30"}, {
					{align=constants.taCenter},
					{},
					{},
					skip_to = 32,
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[30] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE1-31"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[31] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-32"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )		
					
dialogues[1].lines[32] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE1-33"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[33] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-34"}, {
					{align=constants.taCenter},
					{},
					skip_to = 39,
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )	

dialogues[1].lines[34] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE1-35"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )	
					
dialogues[1].lines[35] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-36"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )

dialogues[1].lines[36] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE1-37"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )	

dialogues[1].lines[37] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE1-38"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )

dialogues[1].lines[38] = DialogueLine.create(constants.dlScript, 
					function()
						local f = function()
							local widget = CreateWidget(constants.wt_Picture, "w", nil, 300, 200, 28, 28)
							WidgetSetSprite(widget, "gui")
							WidgetSetAnim(widget, "sync_bar")
							local vis = true
							for i = 0,6 do
								WidgetSetVisible(widget, vis)
								Wait(300)
								vis = not vis
							end
							MoveWidgetTo(widget, {521, 16}, 2000, false, function () DestroyWidget(widget) end)
							Wait(5000)
						end
						local thr = NewThread(f)
						Resume(thr)
					end)
					
dialogues[1].lines[39] = DialogueLine.create(constants.dlText, { 
					"DIALOGUE1-39"}, {
					{},
					portrait_left = "PORTRAIT_CLEAR", 
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[40] = DialogueLine.create(constants.dlText, { 
					string.format(dictionary_string("DIALOGUE1-40"), GetKeyName(CONFIG.key_conf[1].change_player))}, {
					{},
					{} } )
					
dialogues[1].lines[41] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-41"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[42] = DialogueLine.create(constants.dlText, {"DIALOGUE_PROFESSOR", 
					"DIALOGUE1-42"}, {
					{align=constants.taCenter},
					{},
					portrait_right = "portrait-prof", 
					portrait_right_x = 100, 
					portrait_right_y = 100,
					portrait_left = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[43] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE1-43"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[1].lines[44] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE1-44"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )	
					
dialogues[1].lines[45] = DialogueLine.create(constants.dlScript, function() pop_pause() nomenu = false FadeIn(2000) PlayBackMusic("music/iie_whbt.it") GUI:show() EnablePlayerControl(true) end)
dialogues[1].lines[45].nextline = "DIALOGUE_END"

------------------------------------------------
------------------------------------------------
dialogues[2] = Dialogue.create()
dialogues[2].lines["ROOT"] = DialogueLine.create(constants.dlScript, 
					function() 
						push_pause( true )
						nomenu = true 
						GUI:hide()
						EnablePlayerControl(false) 
					end)
					
dialogues[2].lines[1] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE2-1"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )	

dialogues[2].lines[2] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE2-2"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[2].lines[3] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE2-3"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )	
					
dialogues[2].lines[4] = DialogueLine.create(constants.dlScript, 
					function() 
						pop_pause()
						nomenu = false 
						GUI:show() 
						EnablePlayerControl(true) 
					end)
dialogues[2].lines[4].nextline = "DIALOGUE_END"

------------------------------------------------
------------------------------------------------
dialogues[3] = Dialogue.create()
dialogues[3].lines["ROOT"] = DialogueLine.create(constants.dlScript, 
					function() 
						-- Скорее всего, скрипт в отдельном треде заранее подведет Унылку, сам все спрячет и потом вызовет диалог
						--TogglePause() 
						--nomenu = true 
						--GUI:hide()
						--EnablePlayerControl(false) 
					end)
					
dialogues[3].lines[1] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE3-1"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[3].lines[2] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE3-2"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )	
					
dialogues[3].lines[3] = DialogueLine.create(constants.dlScript, 
					function() 
						-- Тут плевок слоупока и акробатика СОХ
					end)
					
dialogues[3].lines[4] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE3-3"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[3].lines[5] = DialogueLine.create(constants.dlScript, 
					function() 
						nomenu = false 
						GUI:show() 
						EnablePlayerControl(true) 
					end)
dialogues[3].lines[5].nextline = "DIALOGUE_END"

------------------------------------------------
------------------------------------------------
dialogues[4] = Dialogue.create()
dialogues[4].lines["ROOT"] = DialogueLine.create(constants.dlScript, 
					function() 
						push_pause( true ) 
						nomenu = true 
						GUI:hide()
						EnablePlayerControl(false) 
					end)
					
dialogues[4].lines[1] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE4-1"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[4].lines[2] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE4-2"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[4].lines[3] = DialogueLine.create(constants.dlScript, 
					function() 
						-- С нарастающим звуком лопастей прилетает вертолёт.
					end)
					
dialogues[4].lines[4] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE4-3"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[4].lines[5] = DialogueLine.create(constants.dlScript, 
					function() 
						pop_pause()
						nomenu = false 
						GUI:show() 
						EnablePlayerControl(true) 
					end)
dialogues[4].lines[5].nextline = "DIALOGUE_END"

------------------------------------------------
------------------------------------------------
dialogues[5] = Dialogue.create()
dialogues[5].lines["ROOT"] = DialogueLine.create(constants.dlScript, 
					function() 
						-- Тут тоже сначала сценка, так что все будет готово
						--TogglePause() 
						--nomenu = true 
						--GUI:hide()
						--EnablePlayerControl(false) 
					end)
					
dialogues[5].lines[1] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE5-1"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )

dialogues[5].lines[2] = DialogueLine.create(constants.dlScript, 
					function() 
						-- СОХ поворачивается налево.
					end)
					
dialogues[5].lines[3] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE5-2"}, {
					{align=constants.taCenter}, 
					{} } )
					
dialogues[5].lines[4] = DialogueLine.create(constants.dlScript, 
					function() 
						-- Тут всякая акробатика и укрощение строптивых слоупоков
						--TogglePause() 
						--nomenu = false 
						--GUI:show() 
						--EnablePlayerControl(true) 
					end)
dialogues[5].lines[4].nextline = "DIALOGUE_END"

------------------------------------------------
------------------------------------------------
dialogues[6] = Dialogue.create()
dialogues[6].lines["ROOT"] = DialogueLine.create(constants.dlScript, 
					function() 
						push_pause(true)
						nomenu = true 
						GUI:hide()
						EnablePlayerControl(false) 
					end)
dialogues[6].lines[1] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE6-1"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[6].lines[2] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE6-2"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[6].lines[3] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE6-3"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[6].lines[4] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE6-4"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[6].lines[5] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE6-5"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[6].lines[6] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE6-6"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[6].lines[7] = DialogueLine.create(constants.dlText, {"DIALOGUE6-7"}, {
					{},
					portrait_left = "PORTRAIT_CLEAR", 
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[6].lines[8] = DialogueLine.create(constants.dlScript, 
					function() 
						pop_pause()
						nomenu = false 
						GUI:show() 
						EnablePlayerControl(true) 
					end)
dialogues[6].lines[8].nextline = "DIALOGUE_END"

------------------------------------------------
------------------------------------------------
dialogues[7] = Dialogue.create()
dialogues[7].lines["ROOT"] = DialogueLine.create(constants.dlScript, 
					function() 
						push_pause(true)
						nomenu = true 
						GUI:hide()
						EnablePlayerControl(false) 
					end)

dialogues[7].lines[1] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE7-1"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR",
					skip_to = 4} )
					
dialogues[7].lines[2] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE7-2"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[7].lines[3] = DialogueLine.create(constants.dlScript, 
					function() 
						-- +1 минута к времени СОХ
					end)
dialogues[7].lines[3].nextline = 11	-- переход на конец диалога
					
dialogues[7].lines[4] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE7-3"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[7].lines[5] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE7-4"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[7].lines[6] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE7-5"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[7].lines[7] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE7-6"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[7].lines[8] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE7-7"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[7].lines[9] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE7-8"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[7].lines[10] = DialogueLine.create(constants.dlScript, 
					function() 
						-- Дополнительное очко в сторону секретной концовки
					end)
					
dialogues[7].lines[11] = DialogueLine.create(constants.dlScript, 
					function() 
						pop_pause()
						nomenu = false 
						GUI:show() 
						EnablePlayerControl(true) 
					end)
dialogues[7].lines[11].nextline = "DIALOGUE_END"

------------------------------------------------
------------------------------------------------
dialogues[8] = Dialogue.create()
dialogues[8].lines["ROOT"] = DialogueLine.create(constants.dlScript, 
					function() 
						push_pause(true)
						nomenu = true 
						GUI:hide()
						EnablePlayerControl(false) 
					end)
					
dialogues[8].lines[1] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE8-1"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR",
					skip_to = 4} )
					
dialogues[8].lines[2] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE8-2"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[8].lines[3] = DialogueLine.create(constants.dlScript, 
					function() 
						-- Может тут тоже какой-то эффект от краткого диалога
					end)
dialogues[8].lines[3].nextline = 11	-- переход на конец диалога
					
dialogues[8].lines[4] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE8-3"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[8].lines[5] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE8-4"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[8].lines[6] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE8-5"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[8].lines[7] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE8-6"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[8].lines[8] = DialogueLine.create(constants.dlText, {"DIALOGUE_UNYL", 
					"DIALOGUE8-7"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-unyl", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[8].lines[9] = DialogueLine.create(constants.dlText, {"DIALOGUE_SOH", 
					"DIALOGUE8-8"}, {
					{align=constants.taCenter}, 
					{},
					portrait_left = "portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR" } )
					
dialogues[8].lines[10] = DialogueLine.create(constants.dlScript, 
					function() 
						-- Дополнительное очко в сторону секретной концовки
					end)
					
dialogues[8].lines[11] = DialogueLine.create(constants.dlScript, 
					function() 
						pop_pause()
						nomenu = false 
						GUI:show() 
						EnablePlayerControl(true) 
					end)
dialogues[8].lines[11].nextline = "DIALOGUE_END"

--------------------------------------------------------------------------------------------------

dialogues.ny = {}
dialogues.ny[1] = Dialogue.create()
dialogues.ny[1].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011DIntro2"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})

dialogues.ny[1].lines[1] = DialogueLine.create(constants.dlText, {
					string.format(dictionary_string("2011DIntro3"), GetKeyName(CONFIG.key_conf[1].player_use))}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[1].lines[1].nextline = 666
dialogues.ny[1].lines[666] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.old_pl = GetPlayer().id
						SwitchCharacter(false)
					end )
dialogues.ny[1].lines[666].nextline = 2
dialogues.ny[1].lines[2] = DialogueLine.create(constants.dlText, {
					"2011DIntro4"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_left_x = 100, 
					portrait_left_y = 100})

dialogues.ny[1].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						Menu.locked = false
						LetterBox( false )
						local player = GetPlayer()
		
						SetObjDead( mapvar.tmp.old_pl )
	
						SetCamAttachedObj(player.id);		-- Цепляем камеру к объекту
						SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
						SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
						--AttachCamToObjSlowly(player.id, 0, 60, 3000, false, nil)
						SetCamLag( 0.9 )
						-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
						SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта
						EnablePlayerControl(true)
					end )
dialogues.ny[1].lines[3].nextline = "DIALOGUE_END"

dialogues.ny[2] = Dialogue.create()
dialogues.ny[2].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D11"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[2].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D12"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})	
dialogues.ny[2].lines[2] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D13"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[2].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.spoke_to_guard = true
						dialogues.ny[2].lines["ROOT"].nextline = 4
						EnablePlayerControl(true)
					end )
dialogues.ny[2].lines[3].nextline = "DIALOGUE_END"
dialogues.ny[2].lines[4] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D15"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[2].lines[5] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[2].lines[5].nextline = "DIALOGUE_END"

dialogues.ny[3] = Dialogue.create()
dialogues.ny[3].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D14"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[3].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.spoke_to_guard = true
						EnablePlayerControl(true)
					end )
dialogues.ny[3].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[4] = Dialogue.create()
dialogues.ny[4].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D21"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[4].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D22"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[4].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						dialogues.ny[4].lines["ROOT"].nextline = 3
						EnablePlayerControl(true)
					end )
dialogues.ny[4].lines[2].nextline = "DIALOGUE_END"
dialogues.ny[4].lines[3] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D23"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[4].lines[3].nextline = 2

dialogues.ny[5] = Dialogue.create()
dialogues.ny[5].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D31"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[5].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D32"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[5].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[5].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[6] = Dialogue.create()
dialogues.ny[6].lines["ROOT"] = DialogueLine.create(constants.dlScript, function() end)
dialogues.ny[6].lines[1] = DialogueLine.create(constants.dlScript, function() end)
dialogues.ny[6].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D41"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[6].lines[3] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D42"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[6].lines[4] = DialogueLine.create(constants.dlScript, 
					function()
						dialogues.ny[6].lines[1].nextline = 5
						EnablePlayerControl(true)
					end )
dialogues.ny[6].lines[4].nextline = "DIALOGUE_END"

dialogues.ny[6].lines[5] = DialogueLine.create(constants.dlText, {
					"2011D43"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[6].lines[6] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D44"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[6].lines[7] = DialogueLine.create(constants.dlText, {
					"2011D45"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[6].lines[7].nextline = 4

dialogues.ny[7] = Dialogue.create()
dialogues.ny[7].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D51"}, {
					{},
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"}
					)
dialogues.ny[7].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D52"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[7].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[7].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[8] = Dialogue.create()
dialogues.ny[8].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D61"}, {
					{},
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[8].lines[ 1] = DialogueLine.create(constants.dlText, {"2011D62"}, { {}, portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[ 2] = DialogueLine.create(constants.dlText, {"2011D63"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[ 3] = DialogueLine.create(constants.dlText, {"2011D64"}, { {}, portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[ 4] = DialogueLine.create(constants.dlText, {"2011D65"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[ 5] = DialogueLine.create(constants.dlText, {"2011D66"}, { {}, portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[ 6] = DialogueLine.create(constants.dlText, {"2011D67"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[ 7] = DialogueLine.create(constants.dlText, {"2011D68"}, { {}, portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[ 8] = DialogueLine.create(constants.dlText, {"2011D69"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[ 9] = DialogueLine.create(constants.dlText, {"2011D610"}, { {}, portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[10] = DialogueLine.create(constants.dlText, {"2011D611"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[11] = DialogueLine.create(constants.dlText, {"2011D612"}, { {}, portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[12] = DialogueLine.create(constants.dlText, {"2011D613"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[13] = DialogueLine.create(constants.dlText, {"2011D614"}, { {}, portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[14] = DialogueLine.create(constants.dlText, {"2011D615"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[15] = DialogueLine.create(constants.dlText, {"2011D616"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[16] = DialogueLine.create(constants.dlText, {"2011D617"}, { {}, portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[17] = DialogueLine.create(constants.dlText, {"2011D618"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[18] = DialogueLine.create(constants.dlText, {"2011D619"}, { {},portrait_left = "portrait-captain", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[19] = DialogueLine.create(constants.dlText, {"2011D620"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[20] = DialogueLine.create(constants.dlText, {"2011D621"}, { {},portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[21] = DialogueLine.create(constants.dlText, {"2011D622"}, { {},portrait_left = "portrait-captain", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[22] = DialogueLine.create(constants.dlText, {"2011D623"}, { {},portrait_left = "portrait-captain", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[23] = DialogueLine.create(constants.dlChoice,
					{"2011D624", "2011D625"}, {
					24, 
					27,
					portrait_left="portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[8].lines[24] = DialogueLine.create(constants.dlText, {"2011D626"}, { {},portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[25] = DialogueLine.create(constants.dlText, {"2011D627"}, { {},portrait_left = "portrait-captain", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[26] = DialogueLine.create(constants.dlScript, 
					function()
						Resume( NewThread( function()
							mapvar.tmp.to_tutorial = true
							SetDynObjAcc( GetPlayer().id, -2, 0 )
							Wait(1000)
							FadeOut( {0,0,0}, 1000 )
							Wait(1000)
							Loader.ChangeLevel("2011-tutorial")
						end ))
					end )
dialogues.ny[8].lines[26].nextline = "DIALOGUE_END"
dialogues.ny[8].lines[27] = DialogueLine.create(constants.dlText, {"2011D628"}, { {},portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[28] = DialogueLine.create(constants.dlText, {"2011D629"}, { {},portrait_left = "portrait-captain", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[28].nextline = 666
dialogues.ny[8].lines[666] = DialogueLine.create(constants.dlText, {"2011D71"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[667] = DialogueLine.create(constants.dlText, {"2011D72"}, { {},portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[668] = DialogueLine.create(constants.dlText, {"2011D73"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[669] = DialogueLine.create(constants.dlText, {"2011D74"}, { {},portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[8].lines[669].nextline = 29
dialogues.ny[8].lines[29] = DialogueLine.create(constants.dlScript, 
					function()
						FadeOut({0,0,0,1}, 500)
						Resume( NewThread(  
							function()
								Wait(2000)
								Menu.showEndLevelMenu("2011-1script")
							end
						) )
					end )
dialogues.ny[8].lines[29].nextline = "DIALOGUE_END"

dialogues.ny[9] = Dialogue.create()
dialogues.ny[9].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D81"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[9].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D82"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[9].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[9].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[10] = Dialogue.create()
dialogues.ny[10].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D91"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})

dialogues.ny[10].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.old_pl = GetPlayer().id
						SwitchCharacter(false)
						Menu.locked = false
						LetterBox( false )
						local player = GetPlayer()
		
						SetObjDead( mapvar.tmp.old_pl )
	
						--SetCamAttachedObj(player.id);		-- Цепляем камеру к объекту
						SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
						SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
						AttachCamToObjSlowly(player.id, 0, 60, 3000, false, nil)
						-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
						--SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта
						EnablePlayerControl(true)
					end )
dialogues.ny[10].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[11] = Dialogue.create()
dialogues.ny[11].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D101"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[11].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[11].lines[1].nextline = "DIALOGUE_END"


dialogues.ny[12] = Dialogue.create()
dialogues.ny[12].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D111"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[12].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D112"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[12].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D113"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[12].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )

dialogues.ny[12].lines[3].nextline = "DIALOGUE_END"

dialogues.ny[13] = Dialogue.create()
dialogues.ny[13].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D121"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[13].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D122"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[13].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D123"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[13].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )

dialogues.ny[13].lines[3].nextline = "DIALOGUE_END"

dialogues.ny[14] = Dialogue.create()
dialogues.ny[14].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D131"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[14].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D132"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[14].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D133"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[14].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )

dialogues.ny[14].lines[3].nextline = "DIALOGUE_END"



dialogues.ny[15] = Dialogue.create()
dialogues.ny[15].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D141"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[15].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D142"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[15].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )

dialogues.ny[15].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[16] = Dialogue.create()
dialogues.ny[16].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D151"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[16].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D152"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[16].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D153"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[16].lines[3] = DialogueLine.create(constants.dlText, {
					"2011D154"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[16].lines[4] = DialogueLine.create(constants.dlText, {
					"2011D155"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[16].lines[5] = DialogueLine.create(constants.dlText, {
					"2011D156"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[16].lines[6] = DialogueLine.create(constants.dlScript, 
					function()
						FadeOut({0,0,0,1}, 500)
						Resume( NewThread(  
							function()
								Wait(2000)
								Menu.showEndLevelMenu("2011-cinematics")
							end
						) )
					end )
dialogues.ny[16].lines[6].nextline = "DIALOGUE_END"

dialogues.ny[17] = Dialogue.create()
dialogues.ny[17].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D161"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[17].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.dl1 = true
					end )
dialogues.ny[17].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[18] = Dialogue.create()
dialogues.ny[18].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D163"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[18].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_UNKNOWN",
					"2011D164"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[18].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D165"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[18].lines[3] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_UNKNOWN",
					"2011D166"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[18].lines[4] = DialogueLine.create(constants.dlText, {
					"2011D167"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[18].lines[5] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_UNKNOWN",
					"2011D168"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[18].lines[6] = DialogueLine.create(constants.dlText, {
					"2011D169"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[18].lines[7] = DialogueLine.create(constants.dlScript, 
					function()
						FadeOut({0,0,0}, 2000)
						Resume( NewThread( function()
							Wait(2000)
							FadeIn(0)
							Loader.ChangeLevel("2011-base")
						end ))
					end )
dialogues.ny[18].lines[7].nextline = "DIALOGUE_END"

dialogues.ny[19] = Dialogue.create()
dialogues.ny[19].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_ENEMY1",
					"2011D171"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[19].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						AttachCamToObjSlowly(mapvar.tmp.btd, 0, 60, 1000, false, nil)
						SetObjAnim( mapvar.tmp.com, "move_left", false )
						SetObjAnim( mapvar.tmp.btd, "turn", false )
						Wait( 3000 )
					end )
dialogues.ny[19].lines[2] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_ENEMY2",
					"2011D172"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[19].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
					end )
dialogues.ny[19].lines[4] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_ENEMY2",
					"2011D173"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[19].lines[5] = DialogueLine.create(constants.dlScript, 
					function()
						Resume( NewMapThread( function()
							SetObjAnim( mapvar.tmp.btd, "turn", false )
							Wait( 300 )
							if mapvar.tmp.wtf then return end
							SetObjAnim( mapvar.tmp.btd, "turn", false )
							Wait( 300 )
							if mapvar.tmp.wtf then return end
							SetObjAnim( mapvar.tmp.btd, "turn", false )
							Wait( 300 )
							if mapvar.tmp.wtf then return end
							SetObjAnim( mapvar.tmp.btd, "turn", false )
						end ) )
					end )
dialogues.ny[19].lines[6] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_ENEMY2",
					"2011D174"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[19].lines[7] = DialogueLine.create(constants.dlScript, 
					function()
						Resume( NewMapThread( function()
							mapvar.tmp.wtf = true
							SetObjAnim( mapvar.tmp.btd, "move_left", false )
							AttachCamToObjSlowly(mapvar.tmp.slp, 0, 60, 1000, false, nil)
							Wait(1500)
							SetObjAnim( mapvar.tmp.slp, "sleep", false )
							Wait(1500)
							mapvar.tmp.cf = CreateEnemy( "camera-focus", 80, -143 )
							AttachCamToObjSlowly(mapvar.tmp.cf, 0, 60, 1000, false, nil)
							Wait(1000)
							mapvar.tmp.dl2 = true
						end ))
					end )
dialogues.ny[19].lines[7].nextline = "DIALOGUE_END"


dialogues.ny[20] = Dialogue.create()
dialogues.ny[20].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D181"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[20].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.dl1 = true
					end )
dialogues.ny[20].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[21] = Dialogue.create()
dialogues.ny[21].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					string.format( dictionary_string("2011D182"), GetKeyName(CONFIG.key_conf[1].player_use) )}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[21].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D183"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[21].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D184"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[21].lines[3] = DialogueLine.create(constants.dlText, {
					"2011D185"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[21].lines[4] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.dl3 = true
					end )
dialogues.ny[21].lines[4].nextline = "DIALOGUE_END"

dialogues.ny[22] = Dialogue.create()
dialogues.ny[22].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D191"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[22].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						GUI:show()
						EnablePlayerControl( true )
					end )
dialogues.ny[22].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[23] = Dialogue.create()
dialogues.ny[23].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011KEY2"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[23].lines["ROOT"].nextline = 22
dialogues.ny[23].lines[22] = DialogueLine.create(constants.dlText, {
					"2011D201"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[23].lines[22].nextline = 1
dialogues.ny[23].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						GUI:show()
						mapvar.tmp.got_weapons = true
						EnablePlayerControl( true )
					end )
dialogues.ny[23].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[24] = Dialogue.create()
dialogues.ny[24].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D221"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[24].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D222"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[24].lines[2] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D223"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[24].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[24].lines[3].nextline = "DIALOGUE_END"

dialogues.ny[25] = Dialogue.create()
dialogues.ny[25].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D231"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[25].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D232"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[25].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[25].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[26] = Dialogue.create()
dialogues.ny[26].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D241"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[26].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D242"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[26].lines[2] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D243"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[26].lines[3] = DialogueLine.create(constants.dlText, {
					"2011D244"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[26].lines[4] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[26].lines[4].nextline = "DIALOGUE_END"

dialogues.ny[27] = Dialogue.create()
dialogues.ny[27].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D251"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[27].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D252"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[27].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[27].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[28] = Dialogue.create()
dialogues.ny[28].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D261"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[28].lines[1] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D262"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[28].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl(true)
					end )
dialogues.ny[28].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[29] = Dialogue.create()
dialogues.ny[29].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D271"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D272"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D273"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[3] = DialogueLine.create(constants.dlText, {
					"2011D274"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[4] = DialogueLine.create(constants.dlText, {
					"2011D275"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[5] = DialogueLine.create(constants.dlText, {
					"2011D276"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[6] = DialogueLine.create(constants.dlText, {
					"2011D277"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[7] = DialogueLine.create(constants.dlText, {
					"2011D278"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[8] = DialogueLine.create(constants.dlText, {
					"2011D279"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[9] = DialogueLine.create(constants.dlText, {
					"2011D2710"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[10] = DialogueLine.create(constants.dlText, {
					"2011D2711"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[11] = DialogueLine.create(constants.dlText, {
					"2011D2712"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[12] = DialogueLine.create(constants.dlText, {
					"2011D2713"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[29].lines[13] = DialogueLine.create(constants.dlScript, 
					function()
						Resume( NewThread( function() 
							FadeOut({0,0,0,0}, 2000)
							Wait(2000)
							Menu.showEndLevelMenu("2011-house")
						end ))
					end )
dialogues.ny[29].lines[13].nextline = "DIALOGUE_END"

dialogues.ny[30] = Dialogue.create()
dialogues.ny[30].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D211"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})

dialogues.ny[30].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.old_pl = GetPlayer().id
						SwitchCharacter(false)
						Menu.locked = false
						LetterBox( false )
						local player = GetPlayer()
		
						SetObjDead( mapvar.tmp.old_pl )
	
						--SetCamAttachedObj(player.id);		-- Цепляем камеру к объекту
						SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
						SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
						AttachCamToObjSlowly(player.id, 0, 60, 3000, false, nil)
						-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
						--SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта
						EnablePlayerControl(true)
					end )
dialogues.ny[30].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[31] = Dialogue.create()
dialogues.ny[31].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011KEY1"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[31].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						Resume( NewThread( function() 
							FadeOut({0,0,0,0}, 2000)
							Wait(2000)
							Menu.showEndLevelMenu("2011-lab")
						end ))
					end )
dialogues.ny[31].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[32] = Dialogue.create()
dialogues.ny[32].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011KEY3"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[32].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						GUI:show()
						pop_pause()
					end )
dialogues.ny[32].lines[1].nextline = "DIALOGUE_END"


dialogues.ny[33] = Dialogue.create()
dialogues.ny[33].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D281"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[33].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						local explosion = CreateSprite("../projectiles/explosion-safe", -581, -171)
						SetObjAnim( explosion, "die", false )
						SetCamAttachedObj( explosion )
						local bt = CreateEnemy("btard", -581, -171)
						SetDynObjVel( bt, -80, 0 )
						DamageObject( bt, 9000 )
					end )
dialogues.ny[33].lines[2] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_UNKNOWN",
					"2011D282"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[33].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						local un = CreateEnemy("unylchan", -585, -171) 
						SetObjSpriteMirrored( un, true )
						SetCamAttachedObj( un )
					end )
dialogues.ny[33].lines[4] = DialogueLine.create(constants.dlText, {
					"2011D283"}, {
					{}, 
					portrait_left = "portrait-unyl",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[33].lines[5] = DialogueLine.create(constants.dlText, {
					"2011D284"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[33].lines[6] = DialogueLine.create(constants.dlText, {
					"2011D285"}, {
					{}, 
					portrait_left = "portrait-unyl",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[33].lines[7] = DialogueLine.create(constants.dlText, {
					"2011D286"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[33].lines[8] = DialogueLine.create(constants.dlText, {
					"2011D287"}, {
					{}, 
					portrait_left = "portrait-unyl",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[33].lines[9] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.dl1 = true
					end )
dialogues.ny[33].lines[9].nextline = "DIALOGUE_END"

dialogues.ny[34] = Dialogue.create()
dialogues.ny[34].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					string.format( dictionary_string("2011D291"), GetKeyName(CONFIG.key_conf[1].player_use) )}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[34].lines[1] = DialogueLine.create(constants.dlText, {
					string.format( dictionary_string("2011D292"), GetKeyName(CONFIG.key_conf[1].change_player) )}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[34].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						LetterBox( false )
						GUI:show()
						EnablePlayerControl( true )
					end )
dialogues.ny[34].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[35] = Dialogue.create()
dialogues.ny[35].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D301"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[35].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						GUI:show()
					end )
dialogues.ny[35].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[36] = Dialogue.create()
dialogues.ny[36].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D302"}, {
					{}, 
					portrait_left = "portrait-unyl",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[36].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						GUI:show()
					end )
dialogues.ny[36].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[37] = Dialogue.create()
dialogues.ny[37].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D303"}, {
					{}, 
					portrait_left = "portrait-unyl",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[37].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						GUI:show()
					end )
dialogues.ny[37].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[38] = Dialogue.create()
dialogues.ny[38].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D311"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[38].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D312"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[38].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						Resume( NewThread( function() 
							FadeOut({0,0,0,0}, 2000)
							Wait(2000)
							Menu.showEndLevelMenu("2011-pytard")
						end ))
					end )
dialogues.ny[38].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[39] = Dialogue.create()
dialogues.ny[39].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D321"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[39].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D322"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[39].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						Resume( NewMapThread( end_boss_battle ) )
						PlayBackMusic( "music/iie_boss.it" )
						pop_pause()
						GUI:show()
					end )
dialogues.ny[39].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[40] = Dialogue.create()
dialogues.ny[40].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D331"}, {
					{}, 
					portrait_left = "portrait-unyl",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[40].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						GUI:show()
					end )
dialogues.ny[40].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[41] = Dialogue.create()
dialogues.ny[41].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D351"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[41].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D352"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[41].lines[2] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D353"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[41].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl( true )
					end )
dialogues.ny[41].lines[3].nextline = "DIALOGUE_END"

dialogues.ny[42] = Dialogue.create()
dialogues.ny[42].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D361"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[42].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl( true )
					end )
dialogues.ny[42].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[43] = Dialogue.create()
dialogues.ny[43].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D371"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[43].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl( true )
					end )
dialogues.ny[43].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[44] = Dialogue.create()
dialogues.ny[44].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D381"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[44].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D382"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[44].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl( true )
					end )
dialogues.ny[44].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[45] = Dialogue.create()
dialogues.ny[45].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"DIALOGUE_GUARD",
					"2011D391"}, {
					{}, 
					portrait_left = "PORTRAIT_CLEAR",
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[45].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl( true )
					end )
dialogues.ny[45].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[46] = Dialogue.create()
dialogues.ny[46].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D401"}, {
					{}, 
					portrait_left = "portrait-prof",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[46].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						EnablePlayerControl( true )
					end )
dialogues.ny[46].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[47] = Dialogue.create()
dialogues.ny[47].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D341"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[47].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.old_pl = GetPlayer().id
						SwitchCharacter(false)
						Menu.locked = false
						LetterBox( false )
						local player = GetPlayer()
		
						SetObjDead( mapvar.tmp.old_pl )
	
						--SetCamAttachedObj(player.id);		-- Цепляем камеру к объекту
						SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
						SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
						AttachCamToObjSlowly(player.id, 0, 60, 3000, false, nil)
						-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
						--SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта
						EnablePlayerControl(true)
					end )
dialogues.ny[47].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[48] = Dialogue.create()
dialogues.ny[48].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D411"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[48].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D412"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[48].lines[2] = DialogueLine.create(constants.dlText, {
					string.format(dictionary_string("2011D413"), GetKeyName(CONFIG.key_conf[1].fire))}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[48].lines[3] = DialogueLine.create(constants.dlText, {
					"2011D414"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[48].lines[4] = DialogueLine.create(constants.dlText, {
					"2011D415"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[48].lines[5] = DialogueLine.create(constants.dlScript, 
					function()
						ToggleDoor( mapvar.tmp.doors[1] )
						GUI:show()
						EnablePlayerControl( true )
					end )
dialogues.ny[48].lines[5].nextline = "DIALOGUE_END"

dialogues.ny[49] = Dialogue.create()
dialogues.ny[49].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D421"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[49].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D422"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[49].lines[2] = DialogueLine.create(constants.dlScript, 
					function()
						ToggleDoor( mapvar.tmp.doors[2] )
						GUI:show()
						EnablePlayerControl( true )
					end )
dialogues.ny[49].lines[2].nextline = "DIALOGUE_END"

dialogues.ny[50] = Dialogue.create()
dialogues.ny[50].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D431"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[50].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D432"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[50].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D433"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[50].lines[3] = DialogueLine.create(constants.dlText, {
					"2011D434"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[50].lines[4] = DialogueLine.create(constants.dlScript, 
					function()
						GUI:show()
						EnablePlayerControl( true )
					end )
dialogues.ny[50].lines[4].nextline = "DIALOGUE_END"

dialogues.ny[51] = Dialogue.create()
dialogues.ny[51].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D441"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[51].lines[1] = DialogueLine.create(constants.dlText, {
					string.format(dictionary_string("2011D442"), GetKeyName(CONFIG.key_conf[1].change_weapon))}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[51].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D443"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[51].lines[3] = DialogueLine.create(constants.dlText, {
					"2011D444"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[51].lines[4] = DialogueLine.create(constants.dlText, {
					"2011D445"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[51].lines[5] = DialogueLine.create(constants.dlScript, 
					function()
						GUI:show()
						EnablePlayerControl( true )
						Resume( NewMapThread( function()
							Wait( 10000 )
							GUI:hide()
							EnablePlayerControl( false )
							dialogues.ny[52]:start()
						end ) )
					end )
dialogues.ny[51].lines[5].nextline = "DIALOGUE_END"

dialogues.ny[52] = Dialogue.create()
dialogues.ny[52].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D451"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[52].lines[1] = DialogueLine.create(constants.dlText, {
					"2011D452"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[52].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D453"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[52].lines[3] = DialogueLine.create(constants.dlChoice,
					{"2011D454", "2011D455"}, {
					4, 
					6,
					text = "DIALOGUE_SOH",
					portrait_left="portrait-soh", 
					portrait_left_x = 100, 
					portrait_left_y = 100,
					portrait_right = "PORTRAIT_CLEAR"})
dialogues.ny[52].lines[4] = DialogueLine.create(constants.dlText, {
					"2011D456"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[52].lines[5] = DialogueLine.create(constants.dlScript, 
					function()
						ToggleDoor( mapvar.tmp.doors[3] )
						GUI:show()
						EnablePlayerControl( true )
					end )
dialogues.ny[52].lines[5].nextline = "DIALOGUE_END"
dialogues.ny[52].lines[6] = DialogueLine.create(constants.dlScript, 
					function()
						GUI:show()
						EnablePlayerControl( true )
						Resume( NewMapThread( function()
							Wait( 10 )
							GUI:hide()
							EnablePlayerControl( false )
							dialogues.ny[53]:start()
						end ) )
					end )
dialogues.ny[52].lines[6].nextline = "DIALOGUE_END"

dialogues.ny[53] = Dialogue.create()
dialogues.ny[53].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D461"}, {
					{}, 
					portrait_left = "portrait-captain",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[53].lines["ROOT"].nextline = 666
dialogues.ny[53].lines[666] = DialogueLine.create(constants.dlText, {"2011D71"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[53].lines[667] = DialogueLine.create(constants.dlText, {"2011D72"}, { {},portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[53].lines[668] = DialogueLine.create(constants.dlText, {"2011D73"}, { {},portrait_left = "portrait-prof", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[53].lines[669] = DialogueLine.create(constants.dlText, {"2011D74"}, { {},portrait_left = "portrait-soh", portrait_left_x = 100, portrait_left_y = 100})
dialogues.ny[53].lines[669].nextline = 29
dialogues.ny[53].lines[29] = DialogueLine.create(constants.dlScript, 
					function()
						FadeOut({0,0,0,1}, 500)
						Resume( NewThread(  
							function()
								Wait(2000)
								Menu.showEndLevelMenu("2011-1script")
							end
						) )
					end )
dialogues.ny[53].lines[29].nextline = "DIALOGUE_END"


dialogues.ny["LOCKED_SOH"] = Dialogue.create()
dialogues.ny["LOCKED_SOH"].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011DLOCKED"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny["LOCKED_SOH"].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						GUI:show()
					end )
dialogues.ny["LOCKED_SOH"].lines[1].nextline = "DIALOGUE_END"

dialogues.ny["LOCKED_UNYL"] = Dialogue.create()
dialogues.ny["LOCKED_UNYL"].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011DLOCKED"}, {
					{}, 
					portrait_left = "portrait-unyl",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny["LOCKED_UNYL"].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						GUI:show()
					end )
dialogues.ny["LOCKED_UNYL"].lines[1].nextline = "DIALOGUE_END"


dialogues.ny[54] = Dialogue.create()
dialogues.ny[54].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D471"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[54].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						pop_pause()
						GUI:show()
						EnablePlayerControl( true )
					end )
dialogues.ny[54].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[55] = Dialogue.create()
dialogues.ny[55].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D481"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[55].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						SetObjAnim(mapvar.tmp.boss[2], "speak-start", false)
						SetCamAttachedObj( mapvar.tmp.boss[2] )
					end )
dialogues.ny[55].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D482"}, {
					{}, 
					portrait_left = "portrait-lolwut",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[55].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						SetObjAnim(mapvar.tmp.boss[2], "speak-wait", false)
						SetCamAttachedObj( GetPlayer().id )
					end )
dialogues.ny[55].lines[2] = DialogueLine.create(constants.dlText, {
					"2011D483"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[55].lines[3] = DialogueLine.create(constants.dlScript, 
					function()
						SetObjAnim(mapvar.tmp.boss[2], "speak-loop", false)
						SetCamAttachedObj( mapvar.tmp.boss[2] )
					end )
dialogues.ny[55].lines[4] = DialogueLine.create(constants.dlText, {
					"2011D484"}, {
					{}, 
					portrait_left = "portrait-lolwut",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[55].lines[5] = DialogueLine.create(constants.dlScript, 
					function()
						SetObjAnim(mapvar.tmp.boss[2], "speak-wait", false)
						SetCamAttachedObj( GetPlayer().id )
					end )
dialogues.ny[55].lines[6] = DialogueLine.create(constants.dlText, {
					"2011D485"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[55].lines[7] = DialogueLine.create(constants.dlScript, 
					function()
						SetObjAnim(mapvar.tmp.boss[2], "speak-loop", false)
						SetCamAttachedObj( mapvar.tmp.boss[2] )
					end )
dialogues.ny[55].lines[8] = DialogueLine.create(constants.dlText, {
					"2011D486"}, {
					{}, 
					portrait_left = "portrait-lolwut",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[55].lines[9] = DialogueLine.create(constants.dlScript, 
					function()
						SetObjAnim(mapvar.tmp.boss[2], "speak-wait", false)
						SetCamAttachedObj( mapvar.tmp.boss[1] )
					end )
dialogues.ny[55].lines[10] = DialogueLine.create(constants.dlText, {
					"2011D487"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[55].lines[11] = DialogueLine.create(constants.dlScript, 
					function()
						SetObjAnim(mapvar.tmp.boss[2], "speak-loop", false)
						SetCamAttachedObj( mapvar.tmp.boss[1] )
					end )
dialogues.ny[55].lines[12] = DialogueLine.create(constants.dlText, {
					"2011D488"}, {
					{}, 
					portrait_left = "portrait-lolwut",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[55].lines[13] = DialogueLine.create(constants.dlScript, 
					function()
						SetObjAnim(mapvar.tmp.boss[2], "speak-wait", false)
						SetCamAttachedObj( GetPlayer().id )
					end )
dialogues.ny[55].lines[14] = DialogueLine.create(constants.dlText, {
					"2011D489"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[55].lines[15] = DialogueLine.create(constants.dlScript, 
					function()
						PlayBackMusic("music/iie_boss.it")
						SetObjAnim(mapvar.tmp.boss[2], "speak-end", false)
						SetObjAnim(mapvar.tmp.boss[1], "pre-idle", false)
						GUI:show()
						mapvar.tmp.bar = LayeredBar.create()
						local bar_colors = {}
						bar_colors[2] = { color = { 200/255, 25/255, 25/255, 1 } }
						bar_colors[1] = { color = {0,0,0,0} }
						mapvar.tmp.bar.pmin = 0
						mapvar.tmp.bar.pmax = 1500
						mapvar.tmp.bar:init_default( bar_colors , "THAT GUY")
						mapvar.tmp.bar.lock_first = true		-- Первый слой будет фоновым
						EnablePlayerControl( true )
					end )
dialogues.ny[55].lines[15].nextline = "DIALOGUE_END"

dialogues.ny[56] = Dialogue.create()
dialogues.ny[56].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D491"}, {
					{}, 
					portrait_left = "portrait-lolwut",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[56].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						SetObjDead( mapvar.tmp.boss[2] )
						mapvar.tmp.boss[2] = CreateEnemy( "2011-btardis2", 200, -274 )
						SetEnemyWaypoint( mapvar.tmp.boss[2], mapvar.tmp.bs_wp[1] )
						mapvar.tmp.bar = LayeredBar.create()
						local bar_colors = {}
						bar_colors[2] = { color = { 183/255, 195/255, 81/255, 1 } }
						bar_colors[1] = { color = {0,0,0,0} }
						mapvar.tmp.bar.pmin = 0
						mapvar.tmp.bar.pmax = 500
						mapvar.tmp.bar:init_default( bar_colors , "DR. LOLWUT")
						mapvar.tmp.bar.lock_first = true		-- Первый слой будет фоновым
						pop_pause()
						GUI:show()
						FadeIn(1000)
					end )
dialogues.ny[56].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[57] = Dialogue.create()
dialogues.ny[57].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D501"}, {
					{}, 
					portrait_left = "portrait-lolwut",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[57].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						mapvar.tmp.dl1 = true
					end )
dialogues.ny[57].lines[1].nextline = "DIALOGUE_END"

dialogues.ny[58] = Dialogue.create()
dialogues.ny[58].lines["ROOT"] = DialogueLine.create(constants.dlText, {
					"2011D511"}, {
					{}, 
					portrait_left = "portrait-soh",
					portrait_right = "PORTRAIT_CLEAR",
					portrait_left_x = 100, 
					portrait_left_y = 100})
dialogues.ny[58].lines[1] = DialogueLine.create(constants.dlScript, 
					function()
						GUI:show()
						EnablePlayerControl( true )
					end )
dialogues.ny[58].lines[1].nextline = "DIALOGUE_END"
