Console = {}
Console.contents = {}
Console.command_history = {}

function EditMap( mapname )
	Editor.open( mapname )
	--table.insert( Loader.slaveKeyProcessors, Editor.KeyProcessor )
end

function Console.addMessage( message, on_screen, sound )
	table.insert( Console.contents, message )
end

function Console.keyProcessor( key )
	if key == keys["enter"] then
		Console.addMessage( code )
		--[[
		local code = WidgetGetCaption( Console.console_text )
		if CONFIG.debug == 1 then
			Log( "CONSOLE: '",code,"'" )
		end
		table.insert(Console.command_history, code)
		if #Console.command_history > 10 then
			table.remove( Console.command_history, 1 )
		end
		Console.history = -1
		if not console_chat then
			local success, result = loadstring(code)
			if not success then
				Console.addMessage( "  "..tostring( result ))
				WidgetSetCaption( Console.console_text, "" )
			else
				success, result = pcall( success )
				if (not success) or (result) then
					Console.addMessage( "  "..tostring( result ) )
					WidgetSetCaption( Console.console_text, "" )
				else
					WidgetSetCaption( Console.console_text, "" )
				end
			end
		else
			Message(code)
		end
		--]]
		Console.showLog()
	elseif key == keys["up"] then
		if Console.history == -1 then
			Console.history = #Console.command_history
		else
			Console.history = Console.history - 1
		end
		if Console.history == 0 then Console.history = 1 end
		WidgetSetCaption( Console.console_text, (Console.command_history[Console.history or 0] or "") )
	elseif key == keys["down"] then
		if Console.history == -1 then
			return true
		else
			Console.history = Console.history + 1
		end
		if Console.history == #Console.command_history then Console.history = -1 end
		WidgetSetCaption( Console.console_text, (Console.command_history[Console.history or 0] or "") )
	elseif key == keys["tilde"] then
		if not Console.just_appeared == true then
			Console.toggle()
		else
			Console.just_appeared = false
		end
		return true
	end
	Console.just_appeared = false
	WidgetGainFocus( Console.console_text )
end

function Console.showLog()
	for i=1,math.min( #Console.contents, Console.logStrings ) do
		WidgetSetCaption( Console.logWidgets[ Console.logStrings - i + 1 ], Console.contents[ #Console.contents-i+1 ] )
	end
	for i=Console.logStrings, #Console.contents do
		table.remove( Console.contents, #Console.contents )
	end
end

function Console.toggle()
	Console.shown = not ( Console.shown or false )
	if Console.shown then
		push_pause( true )
		Console.just_appeared = true
		if not Console.console_back then
			Console.console_back = CreateWidget(constants.wt_Widget, "console_bkg", nil, 0, 0, CONFIG.scr_width, CONFIG.scr_height/2)
			WidgetSetZ(Console.console_back, 0.98999)
			WidgetSetColorBox(Console.console_back, {0, 0, 0, 0.9} )
			Console.logStrings = math.floor( (CONFIG.scr_height/2 - 20) / 20 )
			Console.logWidgets = {}
			for i=1,Console.logStrings do
				local widgie = CreateWidget(constants.wt_Label, "console_text", nil, 5, 20*(i-1), 25500, CONFIG.scr_height/2 )
				WidgetSetCaptionFont( widgie, "dialogue" )
				WidgetSetZ(widgie, 0.99999)
				table.insert( Console.logWidgets, widgie )
			end
			Console.console_text = CreateWidget(constants.wt_Textfield, "console_text", nil, 5, CONFIG.scr_height/2 - 20, 25500, CONFIG.scr_height/2 )
			WidgetSetCaptionColor( Console.console_text, { 1, 1, 1, 1}, true )
			WidgetSetCaptionFont( Console.console_text, "dialogue" )
			WidgetSetZ(Console.console_text, 0.99999)
		else
			Console.console_text = CreateWidget(constants.wt_Textfield, "console_text", nil, 5, CONFIG.scr_height/2 - 20, 25500, CONFIG.scr_height/2 )
			WidgetSetCaptionColor( Console.console_text, { 1, 1, 1, 1}, true )
			WidgetSetCaptionFont( Console.console_text, "dialogue" )
			WidgetSetZ(Console.console_text, 0.99999)

			WidgetGainFocus( Console.console_text )
			--WidgetSetCaption( Console.console_text, "" )
		end
		for i=1,Console.logStrings do
			WidgetSetVisible( Console.logWidgets[i], true )
		end
		Console.showLog()
		WidgetSetVisible(Console.console_back, true)
		WidgetSetVisible(Console.console_text, true)
		for i=1,Console.logStrings do
			WidgetSetVisible( Console.logWidgets[i], true )
		end
		WidgetGainFocus(Console.console_text)
		--Console.oldKeyProcessor = GlobalGetKeyReleaseProc
		--GlobalSetKeyReleaseProc( Console.keyProcessor )
		table.insert(Loader.slaveKeyProcessors, Console.keyProcessor)
		Console.keyProcessorId = #Loader.slaveKeyProcessors
		EnablePlayerControl( false )
	else
		pop_pause()
		WidgetSetVisible( Console.console_back, false )
		--WidgetSetVisible( Console.console_text, false )
		DestroyWidget( Console.console_text )
		for i=1,Console.logStrings do
			WidgetSetVisible( Console.logWidgets[i], false )
		end
		table.remove( Loader.slaveKeyProcessors, Console.keyProcessorId )
		--GlobalSetKeyReleaseProc( Console.oldKeyProcessor )
		EnablePlayerControl( true )
	end
end

return Console
