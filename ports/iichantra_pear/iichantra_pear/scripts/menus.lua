require("routines")

SimpleMenu = {}
SimpleMenu.__index = SimpleMenu

--------------------------------------------------------------------------------------------
--[[
Menu-related 'classes'. They are as follows:
SimpleMenu	- 	a single menu window, which adjusts its own location and size based on its contents.
				Meant to be used as a part of PagedMenu. hor_align and vert_align can be either -1, 0 or 1
		
		SimpleMenu.create( position, hor_align, vert_align, hor_space, vert_space )
		
PagedMenu	-	several SimpleMenus strored in a single structure. Only one SimpleMenu is visible at any given
				time. If page number is ommited in any method call it is applyed to a currently visible menu.
				PagedMenu:cleanup() frees memory used by all the SimpleMenus and its contents. Any added content
				should inherit MenuItem functions.
		
		PagedMenu.create()
		PagedMenu:addPage( index, page )
		PagedMenu:add( content [, page] )
		PagedMenu:move( x, y [, page] )
		PagedMenu:show( [page] )
		PagedMenu:hide( [page] )
		PagedMenu:redraw()
		PagedMenu:cleanup()
		
MenuItem	-	basic class for any menu elements
		
		MenuItem:getSize()				-	must return two values: width and height
		MenuItem:changePosition(x,y)	-	should change the visible position of menu elements in absolute screen coordinates
		MenuItem:realign(x, width)		-	gives the possibility for element to realign itself based on x coordinate and avaiable space
		MenuItem:show(state)			-	either show or hide element based on state value
		MenuItem:cleanup()				-	must free any memory used by a menu element
		MenuItem:isFocusable()			-	must return boolean value - a possibility of MenuItem.widget gaining a focus.
											Wrong return value may result in an unspeakable horror.
											
MWCaption	-	a text label

		MWCaption.create( font={ name, color }, text, align, position )

MWComposition	-	two or more MenuItems on a single line. Can also be used for a single MenuItem but it does not make much sence.
		
		MWComposition.create( minimum_hor_space, menu_items={ MenuItem1, MenuItem2, ... } )
		
MWSpace		-	just an empty space. Can be used for creating vertical spaces or stretching window horizontally.

		MWSpace.create( height, width )
		
MWTextFocusable	-	a base class for any text line, that can gain focus, should not be used directly

MWFunctionButton	-	a text button that calls a custom function when interacted with. pointer may be a prototype name of a widget
						that would be shown near the button when it has focus.
						event( sender_id, param, sender_obj ) is called after a left click
						rEvent( sender_id, param, sender_obj ) is called after a right click
		
		MWFunctionButton.create( font={ name, color, active_color }, text, align, event, param, pointer, rEvent )
		
MWCycleButton		-	cycles through preset values of some variable in vars global table backwards and forward.
						If value_captions are ommited, values themselves are used.
						pointer may be a prototype name of a widget	that would be shown near the button when it has focus.
						if event is defined, event( sender_id, new_variable_value ) is called after each change
		
		MWCycleButton.create( font={ name, color, active_color }, text, align, pointer, event, var_name, 
								var_values={ value1, value2, ... }, value_captions={ caption1, caption2, ... } )

MWInputField		-	allows direct input from keyboard to a variable in vars global table. Backspace is supported, delete is not.
						if event is defined, event( sender_id, new_variable_value ) is called after each change
								
		MWInputField.create( font={ name, color, active_color }, text, align, pointer, event, var_name, max_length )
--]]
--------------------------------------------------------------------------------------------

MenuItem = {}
MenuItem_mt = { __index = MenuItem }

function MenuItem.create()
	local a = {}
	setmetatable(a, MenuItem_mt)
	return a
end

function MenuItem:getSize()
	return 0,0
end

function MenuItem:changePosition( x,y )
	return false
end

function MenuItem:realign( x, width )
end

function MenuItem:show( state )
	return false
end

function MenuItem:cleanup()
	return false
end

function MenuItem:isFocusable()
	return false
end

function MenuItem:disable()
	self.disabled = true
	return false
end

function MenuItem:enable()
	self.disabled = false
	return false
end

function MenuItem:setMenu( menu )
	self.menu = menu
	return false
end

-----------------------------------------------------------------------------------------------------------------------------

MWText = child( MenuItem )

function MWText.create( font, text, align )
	local a = MWText.bareCreate()
	a:init( font, text, align )
	return a
end

function MWText:init( font, text, align )
	self.font = font or { name = "default", color = {1, 1, 1, 1}, active_color = { 1, 0, 0, 1 } }
	self.font.name = self.font.name or "default"
	self.font.color = self.font.color or {1, 1, 1, 1}
	self.font.active_color = self.font.active_color or {1, 0, 0, 1}
	LangChanger.Register(self)
	self:setText(text)
	self.align = align or -1
	self.position = { 0, 0 }
end

function MWText:disable()
	if self.disabled then
		return false
	end
	MWText.super.disable(self);
	if (self.widget) then
		self.old_state = { color = self.font.color }
		WidgetSetCaptionColor( self.widget, { 0.5, 0.5, 0.5, 1 }, false )
	end
	return false
end

function MWText:enable()
	if not self.disabled then
		return false
	end
	MWText.super.enable(self);
	if (self.widget) then
		self.font.color = self.old_state.color
		WidgetSetCaptionColor( self.widget, self.font.color, false )
	end
	return false
end

function MWText:changePosition( x, y )
	self.position = { x,y }
	WidgetSetPos( self.widget, x, y )
	return true
end

function MWText:realign( x, width )
	sx, sy = self:getSize()
	if self.align == 0 then
		self:changePosition( x+(width-sx)/2, self.position[2] )
	elseif self.align == 1 then
		self:changePosition( x+width-sx, self.position[2] )
	else
		self:changePosition( x, self.position[2] )
	end	
end

function MWText:show( state )
	if state then
		WidgetSetVisible( self.widget, true )
	else
		WidgetSetVisible( self.widget, false )
	end
	return true
end

function MWText:cleanup()
	DestroyWidget( self.widget )
	LangChanger.Unregister(self)
end

function MWText:getSize()
	return GetCaptionSize( self.font.name, self.text )
end

function MWText:onLangChange()
	--self.text = dictionary_string(self.base_text) or "ERROR"
	self:setText(self.base_text)
end

function MWText:setText(text)
	self.text = dictionary_string(text) or "ERROR"
	self.base_text = text
	self:updateText()
	if self.menu and self.widget and WidgetGetVisible(self.widget) then 
		self.menu:redraw() 
	end
end

function MWText:updateText()
	--Log(debug.traceback())
	if (self.widget) then 
		WidgetSetCaption(self.widget, self.text, self.multiline)
	end
end

----------------------------------------------------------------------------------------------------------------------
--[[
MWCaption, your basic label.
--]]

MWCaption = child( MWText )

function MWCaption.create( font, text, align )
	local a = MWCaption.bareCreate()
	a:init( font, text, align )
	--local a = MWCaption.superCreate( font, text, align )
	--setmetatable( a, { __index = MWCaption } )
	local sx, sy = GetCaptionSize( a.font.name, dictionary_string(a.text) )
	a.widget = CreateWidget( constants.wt_Label, "MENU LABEL", nil, a.position[1], a.position[2], sx, sy )
	a:updateText()
	WidgetSetCaptionFont(a.widget, a.font.name)
	WidgetSetCaptionColor(a.widget, a.font.color, false)
	WidgetSetVisible(a.widget, true)
	return a
end

-----------------------------------------------------------------------------------------------------------------------------
--[[
MWComposition, several MenuItems in one line, aligned to uniformly fill it.
--]]

MWComposition = child( MenuItem )

function MWComposition.create( hor_space, menu_items )
	local a = MWComposition.bareCreate()
	a.elements = menu_items or { MWCaption.create( {name="default", color = {1,1,1,1}}, "TEST", -1 ) }
	a.width = 10
	a.max_w = 10
	a.hor_space = hor_space or 10
	return a
end

function MWComposition:getSize()
	local width, height = 0, 0, 0
	for key, value in pairs(self.elements) do
		local sx, sy = value:getSize()
		width = math.max(width, sx)
		height = math.max(height, sy)
	end
	self.max_w = width
	return (width + self.hor_space)*#self.elements , height
end

function MWComposition:changePosition( x, y )
	self.position = { x,y }
	local shift = self.width / #self.elements
	for i=1, #self.elements do
		self.elements[i]:changePosition( x + (i-1)*shift, y )
	end
	return true
end

function MWComposition:realign( x, width )
	sx, sy = self:getSize()
	self.width = width or 10
	local shift = self.width / #self.elements
	local nextx = x
	for i=1, #self.elements do
		local ex = math.max(x + (i-1)*shift, nextx)
		--self.elements[i]:changePosition( ex, self.position[2] )
		self.elements[i]:realign( ex, self.max_w + self.hor_space )
		local sx, sy = self.elements[i]:getSize()
		nextx = ex + sx + self.hor_space
	end
end

function MWComposition:show( state )
	for i=1, #self.elements do
		self.elements[i]:show( state )
	end
	return true
end

function MWComposition:cleanup()
	for i=1, #self.elements do
		self.elements[i]:cleanup()
	end
end

function MWComposition:disable()
	for i=1, #self.elements do
		self.elements[i]:disable()
	end
end

function MWComposition:enable()
	for i=1, #self.elements do
		self.elements[i]:enable()
	end
end

function MWComposition:setMenu( menu )
	self.menu = menu
	for i=1, #self.elements do
		self.elements[i]:setMenu( menu )
	end
end

-----------------------------------------------------------------------------------------------------------------------------
--[[
MWLabeledButton - an MenuItem with an attached MWCaption
--]]
MWLabeledButton = child( MWComposition )

function MWLabeledButton.create( font, text, hor_space, menu_item, vert_space, align )
	local a = MWLabeledButton.bareCreate()
	a.font = font or {name="default", color = {1,1,1,1}}
	a.elements = {}
		a.vert_space = vert_space or 0
	a.align = align or -1
	a.elements[1] = menu_item or MWCaption.create( {name="default", color = {1,1,1,1}}, "TEST", align ) 
	a.text = dictionary_string(text) or "ERROR:"
	a.elements[2] = MWCaption.create( font, text, -1 )
	a.focusable = false
	if a.elements[1].isFocusable() then
		a.focusable = true
		a.widget = a.elements[1].widget
	end
	a.hor_space = hor_space or 10
	return a
end

function MWLabeledButton:getSize()
	local sx, sy = self.elements[1]:getSize()
	local sx2, sy2 = self.elements[2]:getSize()
	return sx + sx2 + self.hor_space , math.max(sy, sy2)
end

function MWLabeledButton:changePosition( x, y )
	self.position = { x,y }
	self.elements[2]:changePosition( x, y+self.vert_space )
	local sx,sy = self.elements[2]:getSize()
	self.elements[1]:changePosition( x+sx+self.hor_space, y )
	if self.elements[1].pointer and self.elements[1].pointer.name then
		px, py = WidgetGetPos(self.elements[1].wpointer)
		WidgetSetPos(self.elements[1].wpointer, px - (sx+self.hor_space), py)
	end
		
	return true
end

function MWLabeledButton:realign( x, width )
	local sx,sy = self.elements[2]:getSize()
	if self.align == 1 then
		sx1, sy1 = self.elements[1]:getSize()
		self.elements[2]:realign( x+width-sx1-self.hor_space-sx, sx )
		self.elements[1]:realign( x+width-sx1, sx1 )
	else
		self.elements[2]:realign( x, sx )
		self.elements[1]:realign( x+sx+self.hor_space, sx )
	end

	if self.elements[1].pointer and self.elements[1].pointer.name then
		px, py = WidgetGetPos(self.elements[1].wpointer)
		WidgetSetPos(self.elements[1].wpointer, px - ( sx+self.hor_space), py)
	end
end

function MWLabeledButton:isFocusable()
	return self.focusable
end

-----------------------------------------------------------------------------------------------------------------------------
--[[
MWSpace - empty space. Can also be used to stretch window horisontally.
--]]
MWSpace = child( MenuItem )

function MWSpace.create( height, width )
	local a = MWSpace.bareCreate()
	a.height = height or 10
	a.width = width or 0
	return a
end

function MWSpace:getSize()
	return self.width, self.height
end

----------------------------------------------------------------------------------------------------------------------
--[[
MWTextFocusable, a basic class for all the menu buttons and input fields (except graphical bars)
--]]
MWTextFocusable = child( MWText )
MWTextFocusable.widgets = {}
MWTextFocusable.functions = shallow_copy( MWTextFocusable.super.functions )
MWTextFocusable.functions.focus = function (sender) local butt = MWTextFocusable.widgets[sender] if not butt then return end WidgetSetVisible(butt.wpointer, true) end
MWTextFocusable.functions.unfocus = function (sender) local butt = MWTextFocusable.widgets[sender] if not butt then return end WidgetSetVisible(butt.wpointer, false) end

function MWTextFocusable.create( font, text, align, pointer )
	--local a = MWTextFocusable.superCreate( font, text, align )
	--setmetatable( a, { __index = MWTextFocusable } )
	local a = MWTextFocusable.bareCreate()
	a:init( font, text, align, pointer )
	return a
end

function MWTextFocusable:init( font, text, align, pointer )
	MWTextFocusable.super.init( self, font, text, align )
	local sx, sy = GetCaptionSize( self.font.name, self.text )
	self.widget = CreateWidget( constants.wt_Button, "MENU LABEL", nil, 0, 0, sx, sy )
	self:setText(text)
	WidgetSetCaptionFont(self.widget, self.font.name)
	WidgetSetCaptionColor(self.widget, self.font.color, false)
	WidgetSetVisible(self.widget, true)
	self.font.active_color = font.active_color or {1, 1, 1, 1}
	self.pointer = pointer or {}
	self.pointer.pos = self.pointer.pos or { -25, -5 }
	self.event = event
	WidgetSetCaptionColor(self.widget, self.font.active_color, true)
	WidgetSetFocusable( self.widget, true )
	if self.pointer.name then
		WidgetSetFocusProc( self.widget, self.functions.focus )
		WidgetSetUnFocusProc( self.widget, self.functions.unfocus )
		self.wpointer = CreateWidget( constants.wt_Picture, "POINTER", nil, -25, -5, 0, 0 )
		WidgetSetSprite( self.wpointer, self.pointer.name )
		WidgetSetVisible( self.wpointer, false )
		WidgetSetAnim( self.wpointer, "idle" )
	end
	self.focusable = true
	MWTextFocusable.widgets[self.widget] = self
end

function MWTextFocusable:isFocusable()
	return true
end

function MWTextFocusable:changePosition( x, y )
	MWTextFocusable.super.changePosition( self, x, y )
	if self.pointer.name then
		WidgetSetPos( self.wpointer, x+self.pointer.pos[1], y+self.pointer.pos[2] )
	end
	return true
end

function MWTextFocusable:realign( x, width )
	sx, sy = self:getSize()
	if self.align == 0 then
		self:changePosition( x+(width-sx)/2, self.position[2] )
	elseif self.align == 1 then
		self:changePosition( x+width-sx, self.position[2] )
	else
		self:changePosition( x, self.position[2] )
	end	
end

function MWTextFocusable:show( state )
	MWTextFocusable.super.show( self, state )
	if self.wpointer and not state then
		WidgetSetVisible(self.wpointer, false)
	end
	return true
end

function MWTextFocusable:cleanup()
	MWTextFocusable.super.cleanup( self )
	MWTextFocusable.widgets[self.widget] = nil
	if self.pointer.name then
		DestroyWidget( self.wpointer )
	end
end

function MWTextFocusable:disable()
	if self.disabled then
		return false
	end
	MWTextFocusable.super.disable( self )
	WidgetSetLMouseClickProc( self.widget, nil )
	WidgetSetRMouseClickProc( self.widget, nil )
	WidgetSetKeyInputProc( self.widget, nil )
	WidgetSetKeyDownProc( self.widget, nil )
	WidgetSetKeyPressProc( self.widget, nil )
	WidgetSetFocusProc( self.widget, nil )
	WidgetSetUnFocusProc( self.widget, nil )
	WidgetSetFocusable( self.widget, false )
end

function MWTextFocusable:enable()
	if not self.disabled then
		return false
	end
	MWTextFocusable.super.enable( self )
	WidgetSetLMouseClickProc( self.widget, self.functions.lclick )
	WidgetSetRMouseClickProc( self.widget, self.functions.rclick )
	WidgetSetKeyInputProc( self.widget, self.functions.input )
	WidgetSetKeyDownProc( self.widget, self.functions.kdown )
	WidgetSetKeyPressProc( self.widget, self.functions.kpress )
	WidgetSetFocusProc( self.widget, self.functions.focus )
	WidgetSetUnFocusProc( self.widget, self.functions.unfocus )
	WidgetSetFocusable( self.widget, self.focusable )
end

function MWTextFocusable.setWidgetText( widget, text )
	local butt = MWTextFocusable.widgets[widget]
	if butt and butt.widget then
		butt:setText(text)
	end
end

----------------------------------------------------------------------------------------------------------------------
--[[
MWFunctionButton, calls a custom function when interacted with.
--]]

MWFunctionButton = child( MWTextFocusable )
MWFunctionButton.functions = shallow_copy( MWFunctionButton.super.functions )
MWFunctionButton.functions.lclick = function (sender) local butt = MWTextFocusable.widgets[sender] butt.event(sender, butt.param, butt) end
MWFunctionButton.functions.rclick = function (sender) local butt = MWTextFocusable.widgets[sender] butt.rEvent(sender, butt.param, butt) end

function MWFunctionButton.create( font, text, align, event, param, pointer, rEvent )
	--local a = MWFunctionButton.superCreate( font, text, align, pointer )
	--setmetatable( a, { __index = MWFunctionButton } )
	local a = MWFunctionButton.bareCreate()
	a:init( font, text, align, pointer )
	a.event = event or function() Log("[ERROR] Bad function call from MWFunctionButton") end
	a.rEvent = rEvent or function() --[[Log("[ERROR] Bad function call from MWFunctionButton")]] end
	a.param = param
	WidgetSetLMouseClickProc( a.widget, a.functions.lclick )
	WidgetSetRMouseClickProc( a.widget, a.functions.rclick )
	return a
end

----------------------------------------------------------------------------------------------------------------------
--[[
MWCycleButton, cycles through values of some variable. Can also make a function call with new value as a parameter after 
each change. Note that there are no actual link from variable to button, so several buttons with the same variable would
not sync.
--]]

MWCycleButton = child( MWTextFocusable )
MWCycleButton.functions = shallow_copy( MWCycleButton.super.functions )
--MWCycleButton.functions = {}
MWCycleButton.functions.lclick = 
		function (sender) 
					local butt = MWTextFocusable.widgets[sender]
					butt.current = butt.current + 1
					if butt.current > #butt.var_values then butt.current = 1 end
					vars[butt.var_name] = butt.var_values[butt.current]
					local new_caption = butt.value_captions[butt.current] or butt.var_values[butt.current] or "ERROR" 
					butt:setText(new_caption)
					local sx, sy = GetCaptionSize(butt.font.name, new_caption)
					WidgetSetSize( butt.widget, sx, sy )
					if butt.event then butt.event(sender, butt.var_values[butt.current]) end
					butt.menu:redraw()
		end
MWCycleButton.functions.rclick =
		function (sender) 
					local butt = MWTextFocusable.widgets[sender]
					butt.current = butt.current - 1
					if butt.current < 1 then butt.current = #butt.var_values end
					vars[butt.var_name] = butt.var_values[butt.current]
					local new_caption = butt.value_captions[butt.current] or butt.var_values[butt.current] or "ERROR" 
					butt:setText(new_caption)
					local sx, sy = GetCaptionSize(butt.font.name, new_caption)
					WidgetSetSize( butt.widget, sx, sy )
					if butt.event then butt.event(sender, butt.var_values[butt.current]) end
					butt.menu:redraw()
		end
MWCycleButton.functions.kpress =
		function (sender, key)
					local butt = MWTextFocusable.widgets[sender]
					local dir = 0
					if key == CONFIG.key_conf[1].left then
						dir = -1
					elseif key == CONFIG.key_conf[1].right then
						dir = 1
					end
					if dir == 0 then return end
					butt.current = butt.current + dir
					if butt.current < 1 then butt.current = #butt.var_values end
					if butt.current > #butt.var_values then butt.current = 1 end
					vars[butt.var_name] = butt.var_values[butt.current]
					local new_caption = butt.value_captions[butt.current] or butt.var_values[butt.current] or "ERROR" 
					butt:setText(new_caption)
					local sx, sy = GetCaptionSize(butt.font.name, dictionary_string(new_caption))
					WidgetSetSize( butt.widget, sx, sy )
					if butt.event then butt.event(sender, butt.var_values[butt.current]) end
					butt.menu:redraw()
		end

function MWCycleButton.create( font, text, align, pointer, event, var_name, var_values, value_captions )
	--local a = MWCycleButton.superCreate( font, text, align, pointer )
	--setmetatable( a, { __index = MWCycleButton } )
	local a = MWCycleButton.bareCreate()
	a:init( font, text, align, pointer )
	a.event = event
	a.var_name = var_name or "foo"
	a.var_values = var_values or { "foo", "bar" }
	a.value_captions = value_captions or {}
	a.current = 1
	for k,v in ipairs(var_values) do
		if v == vars[a.var_name] then a.current = k; break; end
	end
	local caption = (a.value_captions[a.current] or a.var_values[a.current] or "ERROR")
	a:setText(caption)
	local sx, sy = GetCaptionSize(a.font.name, caption)
	WidgetSetSize( a.widget, sx, sy )
	WidgetSetLMouseClickProc( a.widget, a.functions.lclick )
	WidgetSetRMouseClickProc( a.widget, a.functions.rclick )
	-- WidgetSetKeyPressProc( a.widget, a.functions.kpress )
	WidgetSetKeyDownProc( a.widget, a.functions.kpress )
	return a
end

function MWCycleButton:getSize()
	--local caption = (self.value_captions[self.current] or self.var_values[self.current] or "ERROR")
	return GetCaptionSize( self.font.name, self.text )
end

----------------------------------------------------------------------------------------------------------------------
--[[
MWInputField - Allows direct input to a variable from keyboard
--]]

MWInputField = child( MWTextFocusable )
MWInputField.functions = shallow_copy( MWInputField.super.functions )
MWInputField.functions.resize =
		function (sender)
			local butt = MWTextFocusable.widgets[sender]
			butt.menu:redraw()
		end
MWInputField.functions.input =
		function (sender)
			local butt = MWTextFocusable.widgets[sender]
			if butt.var_name then
				if not vars then vars = {} end
				vars[butt.var_name] = WidgetGetCaption(sender)
			end
		end

function MWInputField.create( font, text, align, pointer, event, var_name, max_length )
	--local a = MWInputFieldButton.superCreate( font, text, align, pointer )
	--setmetatable( a, { __index = MWInputField } )
	local a = MWInputField.bareCreate()
	a:init( font, text, align, pointer, event, var_name, max_length )
	return a
end


function MWInputField:init( font, text, align, pointer, event, var_name, max_length )
	MWTextFocusable.super.init( self, font, text, align )
	
	self.event = event
	self.var_name = var_name or "foo"
	self.max_length = max_length
	self.multiline = false
	LangChanger.Unregister(self)
	
	self:setText(text or vars[self.var_name] or "Error")
	
	local sx, sy = GetCaptionSize( self.font.name, self.text )
	self.widget = CreateWidget( constants.wt_Textfield, "MWInputField", nil, 0, 0, sx, sy )
	self:setText(text or vars[self.var_name] or "Error")
	WidgetSetCaptionFont(self.widget, self.font.name)
	WidgetSetCaptionColor(self.widget, self.font.color, false)
	WidgetSetVisible(self.widget, true)
	WidgetSetMaxTextfieldSize(self.widget, max_length)
	
	-- WidgetSetBorder(self.widget, true)
	-- WidgetSetBorderColor(self.widget, {1, 1, 1, 1}, true)
	-- WidgetSetBorderColor(self.widget, {0.5, 0.5, 0.5, 1}, false)
	
	self.font.active_color = font.active_color or {1, 1, 1, 1}
	self.pointer = pointer or {}
	self.pointer.pos = self.pointer.pos or { -25, -5 }
	WidgetSetCaptionColor(self.widget, self.font.active_color, true)
	WidgetSetFocusable( self.widget, true )
	if self.pointer.name then
		WidgetSetFocusProc( self.widget, self.functions.focus )
		WidgetSetUnFocusProc( self.widget, self.functions.unfocus )
		self.wpointer = CreateWidget( constants.wt_Picture, "POINTER", nil, -25, -5, 0, 0 )
		WidgetSetSprite( self.wpointer, self.pointer.name )
		WidgetSetVisible( self.wpointer, false )
		WidgetSetAnim( self.wpointer, "idle" )
	end
	self.focusable = true
	MWInputField.widgets[self.widget] = self
	
	WidgetSetResizeProc(self.widget, self.functions.resize)
	WidgetSetKeyInputProc(self.widget, self.functions.input)
	WidgetSetKeyDownProc(self.widget, self.functions.input)
end

function MWInputField:getSize()
	return WidgetGetSize(self.widget)
end

function MWInputField:setText(text)
	self.text = text
	self:updateText()
	if self.menu and self.widget and WidgetGetVisible(self.widget) then 
		self.menu:redraw() 
	end
end

-----------------------------------------------------------------------------------------------------------------------------

MWBar = child( MenuItem )
MWBar.widgets = {}
MWBar.functions = shallow_copy( MWBar.super.functions )
MWBar.functions.kpress = function( sender, key )
	local dir = 0
	if key == CONFIG.key_conf[1].left then
		dir = -1
	elseif key == CONFIG.key_conf[1].right then
		dir = 1
	end
	if dir == 0 then
		return
	end
	local bar = MWBar.widgets[sender]
	if bar then
		local old_last_bar = math.floor( (vars[bar.var_param.name] or bar.var_param.start) / bar.var_param.per_bar)
		dir = dir * bar.var_param.per_bar
		if not vars[ bar.var_param.name ] then vars[ bar.var_param.name ] = bar.var_param.start end
		vars[ bar.var_param.name ] = vars[ bar.var_param.name ] + dir 
		if ( vars[ bar.var_param.name ] > bar.var_param.max_value ) then
			vars[ bar.var_param.name ] = bar.var_param.max_value
		end
		if ( vars[ bar.var_param.name ] < bar.var_param.min_value ) then
			vars[ bar.var_param.name ] = bar.var_param.min_value
		end
		local new_last_bar = math.floor( (vars[bar.var_param.name] or bar.var_param.start) / bar.var_param.per_bar)
		if bar.bars[ new_last_bar ] or bar.bars[ old_last_bar ] then
			if new_last_bar > old_last_bar then
				if bar.bars[new_last_bar] then WidgetSetVisible(bar.bars[new_last_bar], true) end
			elseif new_last_bar < old_last_bar then
				if bar.bars[old_last_bar] then WidgetSetVisible(bar.bars[old_last_bar], false) end
			end
			if bar.event then
				bar.event( sender, vars[ bar.var_param.name ] )
			end
		end
	end
end
MWBar.functions.lclick = 
		function (sender) 
					MWBar.functions.kpress( sender, CONFIG.key_conf[1].left )
		end
MWBar.functions.rclick = 
		function (sender) 
					MWBar.functions.kpress( sender, CONFIG.key_conf[1].right )
		end
MWBar.functions.focus = function (sender) local bar = MWBar.widgets[sender] WidgetSetVisible(bar.wpointer, true) end
MWBar.functions.unfocus = function (sender) local bar = MWBar.widgets[sender] WidgetSetVisible(bar.wpointer, false) end

function MWBar.create( sprites, border, var_param, event, pointer )
	local a = MWBar.bareCreate()
	a.sprites = sprites or {}
	a.border = border or {}
	a.var_param = var_param or { name = "foo", start = 100, per_bar = 10, max_bars = 10, bar_size = {160, 16} }
	a.event = event
	a.pointer = pointer or {}
	if a.sprites.background then
		a.widget = CreateWidget( constants.wt_Button, "BAR_BACKGROUND", nil, 0, 0, a.var_param.bar_size[1], a.var_param.bar_size[2] )
		WidgetSetSprite( a.widget, a.sprites.background.name )
		WidgetSetAnim( a.widget, a.sprites.background.anim )
		--WidgetSetBorder( a.widget, true )
		--WidgetSetBorderColor( a.widget, {1,1,1,1}, true )
		--WidgetSetBorderColor( a.widget, {1,1,1,1}, false )
		WidgetSetKeyDownProc( a.widget, MWBar.functions.kpress )	-- Реакция на keyDown, чтобы срабатывали повторы клавиш
		--WidgetSetKeyPressProc( a.widget, MWBar.functions.kpress )
		WidgetSetLMouseClickProc( a.widget, a.functions.lclick )
		WidgetSetRMouseClickProc( a.widget, a.functions.rclick )
		WidgetSetFocusable( a.widget, true )
	end
	if a.sprites.start then
		a.start = CreateWidget( constants.wt_Picture, "BAR_START", nil, 0, 0, 0, 0 )
		WidgetSetSprite( a.start, a.sprites.start.name )
		WidgetSetVisible( a.start, true )
		WidgetSetAnim( a.start, a.sprites.start.anim )
		WidgetSetFocusable( a.start, false)
	end
	local visible_bars = math.min(a.var_param.start / a.var_param.per_bar, a.var_param.max_bars)
	a.bars = {}
	for i=1,a.var_param.max_bars do
		a.bars[i] = CreateWidget( constants.wt_Picture, "BAR", nil, 0, 0, 0, 0 )
		WidgetSetSprite( a.bars[i], a.sprites.bar.name )
		WidgetSetVisible( a.bars[i], iff(i > visible_bars, false, true) )
		WidgetSetAnim( a.bars[i], a.sprites.bar.anim )
		WidgetSetFocusable( a.bars[i], false)

	end
	if a.pointer.name then
		WidgetSetFocusProc( a.widget, MWBar.functions.focus )
		WidgetSetUnFocusProc( a.widget, MWBar.functions.unfocus )
		a.wpointer = CreateWidget( constants.wt_Picture, "POINTER", nil, -25, -5, 0, 0 )
		WidgetSetSprite( a.wpointer, a.pointer.name )
		WidgetSetVisible( a.wpointer, false )
		WidgetSetAnim( a.wpointer, "idle" )
	end
	a.position = { 0, 0 }
	a.background = a.widget
	MWBar.widgets[a.background] = a

	return a
end

function MWBar:getSize()
	local sx, sy = 0, 0
	sx = ( self.sprites.start.w or 0 ) + ( self.sprites.bar.w or 0 ) * self.var_param.max_bars + 2
	sy = math.max( ( self.sprites.start.h or 0 ), ( self.sprites.bar.h or 0 ) ) + 2
	return sx, sy
end

function MWBar:changePosition( x,y )
	self.position = {x, y}
	local cx, cy = x + 1, y + 1
	if self.start then
		WidgetSetPos( self.start, cx, cy )
		cx = cx + self.sprites.start.w
	end
	if self.widget then
		WidgetSetPos( self.widget, cx-1, cy-1 )
	end
	for i=1,#self.bars do
		WidgetSetPos( self.bars[i], cx, cy )
		cx = cx + self.sprites.bar.w
	end
	if self.wpointer then
		WidgetSetPos( self.wpointer, x+self.pointer.pos[1], y-x+self.pointer.pos[2] )
	end
end

function MWBar:realign( x, width )
	self.position[1] = x
	local cx, cy = self.position[1], self.position[2]
	cx = cx + 1
	cy = cy + 1
	if self.start then
		WidgetSetPos( self.start, cx, cy )
		cx = cx + self.sprites.start.w
	end
	if self.widget then
		WidgetSetPos( self.widget, cx-1, cy-1 )
	end
	for i=1,#self.bars do
		WidgetSetPos( self.bars[i], cx, cy )
		cx = cx + self.sprites.bar.w
	end
	if self.wpointer then
		WidgetSetPos( self.wpointer, x+self.pointer.pos[1], self.position[2]+self.pointer.pos[2] )
	end
end

function MWBar:show( state )
	if self.widget then
		WidgetSetVisible( self.widget, state )
	end
	if self.start then
		WidgetSetVisible( self.start, state )
	end
	local visible_bars = math.min( (vars[self.var_param.name] or self.var_param.start) / self.var_param.per_bar, self.var_param.max_bars)
	for i=1,#self.bars do
		WidgetSetVisible( self.bars[i], iff( i>visible_bars, false, state ) )
	end
	if self.wpointer and not state then
		WidgetSetVisible( self.wpointer, false )
	end
end

function MWBar:cleanup()
	if self.widget then
		DestroyWidget( self.widget )
	end
	if self.start then
		DestroyWidget( self.start )
	end
	for i=1,#self.bars do
		DestroyWidget( self.bars[i] )
	end

	return false
end

function MWBar:isFocusable()
	return true
end

function MWBar:disable()
	self.disabled = true
	return false
end

function MWBar:enable()
	self.disabled = false
	return false
end

function MWBar:setMenu( menu )
	self.menu = menu
	return false
end


-----------------------------------------------------------------------------------------------------------------------------

function SimpleMenu.create( position, hor_align, vert_align, hor_space, vert_space )
	local a = {}
	setmetatable(a, SimpleMenu)	
	a.contents = {}
	a.first_focusable = nil
	a.active_page = 1
	a.position = position or { 320, 240 }
	a.anchor = a.position
	a.vert_space = vert_space or 10
	a.nexty = vert_space/2
	a.hor_space = hor_space or 10
	a.hor_align = hor_align or 0
	a.vert_align = vert_align or 0
	return a
end

function SimpleMenu:add( content )
	table.insert( self.contents, content )
	if not (self.first_focusable) and (content:isFocusable()) then
		self.first_focusable = content.widget
		WidgetGainFocus( self.first_focusable )
	end
	content:setMenu(self)
	content:changePosition( self.position[1], self.position[2]+self.nexty )
	local sx, sy = content:getSize()
	self.nexty = self.nexty + sy + self.vert_space
	self:redraw()
	return #self.contents
end

function SimpleMenu:redraw()
	if self.noredraw then return end
	self:move( self.anchor[1], self.anchor[2] )
end

function SimpleMenu:calcSize()
	self.size = {self.hor_space, self.vert_space}
	for key, value in pairs(self.contents) do
		sx, sy = value:getSize()
		self.size[1] = math.max(self.size[1], sx)
		self.size[2] = self.size[2] + sy + self.vert_space
	end
	self.size[1] = self.size[1] + 2 * self.hor_space
end

function SimpleMenu:move( x, y )
	self:calcSize()
	self.position = { x, y }
	self.anchor = { x, y }
	if self.hor_align == 0 then
		self.position[1] = self.position[1] - self.size[1]/2
	elseif self.hor_align == 1 then
		self.position[1] = self.position[1] - self.size[1]
	end
	if self.vert_align == 0 then
		self.position[2] = self.position[2] - self.size[2]/2
	elseif self.vert_align == 1 then
		self.position[2] = self.position[2] - self.size[2]
	end
	local nexty = self.position[2] + self.vert_space
	for i=1, #self.contents do
		local cont = self.contents[i]
		cont:changePosition( self.position[1] + self.hor_space, nexty )
		sx, sy = cont:getSize()
		nexty = nexty + sy + self.vert_space
	end
	self.nexty = nexty
	self:show()
end

function SimpleMenu:show()
	self:calcSize()
	if self.window then 
			self.window:recreate( self.position[1], self.position[2], self.size[1], self.size[2] ) 
	elseif #self.contents > 0 then
			self.window = Window.create( self.position[1], self.position[2], self.size[1], self.size[2], "window1" ) 
	end
	for key, value in pairs(self.contents) do
		value:realign( self.position[1]+self.hor_space, self.size[1]-2*self.hor_space )
		value:show(true)
	end
end

function SimpleMenu:hide()
	for key, value in pairs(self.contents) do
		value:show(false)
	end
	if self.window then
		self.window:setVisible(false)
	end
end

function SimpleMenu:cleanup()
	if self.window then self.window:destroy() end
	for key, value in pairs(self.contents) do
		value:cleanup()
	end
end

function SimpleMenu:clear()
	for key, value in pairs(self.contents) do
		value:cleanup()
	end
	self.contents = {}
end

---------------------------------------------------------------------------------------------------------------------------

PagedMenu = {}
PagedMenu.__index = PagedMenu

function PagedMenu.create()
	local a = {}
	setmetatable(a, PagedMenu)
	a.pages = {}
	a.pages[1] = SimpleMenu.create( {320, 240}, 0, 0, 20, 10 )
	a.active_page = 1
	
	a.backStack = {}
	
	return a
end

function PagedMenu:add( content, page )
	local pg = page or self.active_page
	if not self.pages[pg] then 
		Log( "[WARNING] Creating page "..pg.." for PagedMenu, because it was called without init." )
		self.pages[pg] = SimpleMenu.create( {320, 240}, 0, 0, 20, 10 )
	end
	return self.pages[pg]:add( content )
end

function PagedMenu:addPage( index, page )
	if self.pages[index] then
		self.pages[index]:cleanup()
	end
	self.pages[index] = page
end

function PagedMenu:move( x, y, page )
	self.pages[page or self.active_page]:move(x,y)
end

function PagedMenu:calcSize( page )
	self.pages[page or self.active_page]:calcSize()
end

function PagedMenu:show( page )
	local pg = self.active_page
	if page and page ~= pg then
		pg = page
		self.pages[self.active_page]:hide()
	end
	if not self.pages[pg] then
		Log( "[WARNING] Creating page "..pg.." for PagedMenu, because it was called without init." )
		self.pages[pg] = SimpleMenu.create( {320, 240}, 0, 0, 20, 10 )
	end
	self.active_page = pg
	self.pages[pg]:show()
	if page and self.pages[pg].first_focusable then
		WidgetGainFocus( self.pages[pg].first_focusable )
	end
end

function PagedMenu:hide( page )
	self.pages[page or self.active_page]:hide()
end

function PagedMenu:cleanup(page)
	self.pages[page or self.active_page]:cleanup()
end

function PagedMenu:redraw()
	self.pages[self.active_page]:redraw()
end

function PagedMenu:clear(page)
	self.pages[page or self.active_page]:clear()
end

function PagedMenu:goBack()
	local top = self.backStack[table.maxn(self.backStack)]
	if top then
		table.remove(self.backStack)
		self:show(top)
	end
end

function PagedMenu:saveBackPage(page)
	table.insert(self.backStack, page)
end

function PagedMenu:clearBackStack()
	self.backStack = {}
end

-----------------------------------------------------------------------------------------------------------------------------
ScrollingMenu = {}
ScrollingMenu.__index = ScrollingMenu
ScrollingMenu.b2m = {}

function ScrollingMenu.create( position, hor_align, vert_align, hor_space, vert_space, max_shown )
	local a = {}
	setmetatable(a, ScrollingMenu)	
	a.contents = {}
	a.first_focusable = nil
	a.active_page = 1
	a.position = position or { 320, 240 }
	a.anchor = a.position
	a.vert_space = vert_space or 10
	a.nexty = vert_space/2
	a.hor_space = hor_space or 10
	a.hor_align = hor_align or 0
	a.vert_align = vert_align or 0
	a.max_shown = max_shown or 32
	a.last_shown = a.max_shown
	a.list_buttons = 
		MWComposition.create(10, {
			MWFunctionButton.create(
				{name="default", color={1,1,1,1}, active_color={.2,.2,1,1}}, 
				"PREVIOUS",
				0, 
				ScrollingMenu.prev,
				nil,
				{name="wakaba-widget"}
			),
			MWFunctionButton.create(
				{name="default", color={1,1,1,1}, active_color={.2,.2,1,1}}, 
				"NEXT",
				0, 
				ScrollingMenu.next,
				nil,
				{name="wakaba-widget"}
			)
		})
	ScrollingMenu.b2m[a.list_buttons.elements[1].widget] = a
	ScrollingMenu.b2m[a.list_buttons.elements[2].widget] = a
	a.list_buttons:disable()
	return a
end

function ScrollingMenu.prev( id )
	local menu = ScrollingMenu.b2m[id]
	if menu.last_shown > menu.max_shown then
		menu.last_shown = menu.last_shown - menu.max_shown
		menu:show()
	end
end

function ScrollingMenu.next( id )
	local menu = ScrollingMenu.b2m[id]
	if menu.last_shown < #menu.contents then
		menu.last_shown = menu.last_shown + menu.max_shown
		menu:show()
	end
end

function ScrollingMenu:add( content )
	table.insert( self.contents, content )
	if not (self.first_focusable) and (content:isFocusable()) then
		self.first_focusable = content.widget
		WidgetGainFocus( self.first_focusable )
	end
	content:setMenu(self)
	content:changePosition( self.position[1], self.position[2]+self.nexty )
	local sx, sy = content:getSize()
	self.nexty = self.nexty + sy + self.vert_space
	self:redraw()
	if #self.contents > self.max_shown then
		self.list_buttons:enable()
	else
		self.list_buttons:disable()
	end
	return #self.contents
end

function ScrollingMenu:redraw()
	if self.noredraw then return end
	self:move( self.anchor[1], self.anchor[2] )
end

function ScrollingMenu:calcSize()
	self.size = {self.hor_space, self.vert_space}
	sx, sy = self.list_buttons:getSize()
	self.size[1] = math.max(self.size[1], sx)
	self.size[2] = self.size[2] + sy + self.vert_space
	for i=math.max(1,self.last_shown-self.max_shown+1),math.min(#self.contents, self.last_shown) do
		sx, sy = self.contents[i]:getSize()
		self.size[1] = math.max(self.size[1], sx)
		self.size[2] = self.size[2] + sy + self.vert_space
	end
	self.size[1] = self.size[1] + 2 * self.hor_space
end

function ScrollingMenu:move( x, y )
	self:calcSize()
	self.position = { x, y }
	self.anchor = { x, y }
	if self.hor_align == 0 then
		self.position[1] = self.position[1] - self.size[1]/2
	elseif self.hor_align == 1 then
		self.position[1] = self.position[1] - self.size[1]
	end
	if self.vert_align == 0 then
		self.position[2] = self.position[2] - self.size[2]/2
	elseif self.vert_align == 1 then
		self.position[2] = self.position[2] - self.size[2]
	end
	local nexty = self.position[2] + self.vert_space
	local cont = self.list_buttons
	cont:changePosition( self.position[1] + self.hor_space, nexty )
	sx, sy = cont:getSize()
	nexty = nexty + sy + self.vert_space
	for i=math.max(1,self.last_shown-self.max_shown+1),math.min(#self.contents, self.last_shown) do
		cont = self.contents[i]
		cont:changePosition( self.position[1] + self.hor_space, nexty )
		sx, sy = cont:getSize()
		nexty = nexty + sy + self.vert_space
	end
	self.nexty = nexty
	self:show()
end

function ScrollingMenu:show()		--TODO
	self:calcSize()
	local nexty = self.position[2] + self.vert_space
	local cont = self.list_buttons
	cont:changePosition( self.position[1] + self.hor_space, nexty )
	sx, sy = cont:getSize()
	nexty = nexty + sy + self.vert_space
	for i=math.max(1,self.last_shown-self.max_shown+1),math.min(#self.contents, self.last_shown) do
		cont = self.contents[i]
		cont:changePosition( self.position[1] + self.hor_space, nexty )
		sx, sy = cont:getSize()
		nexty = nexty + sy + self.vert_space
	end
	self.nexty = nexty

	if self.window then 
			self.window:recreate( self.position[1], self.position[2], self.size[1], self.size[2] ) 
	elseif #self.contents > 0 then
			self.window = Window.create( self.position[1], self.position[2], self.size[1], self.size[2], "window1" ) 
	end
	for i=1,self.last_shown-self.max_shown do
		self.contents[i]:show(false)
	end
	for i=math.max(1,self.last_shown-self.max_shown+1),math.min(#self.contents, self.last_shown) do
		self.contents[i]:realign( self.position[1]+self.hor_space, self.size[1]-2*self.hor_space )
		self.contents[i]:show(true)
	end
	self.list_buttons:realign( self.position[1]+self.hor_space, self.size[1]-2*self.hor_space )
	self.list_buttons:show(true)
	for i=self.last_shown,#self.contents do
		self.contents[i]:show(false)
	end
end

function ScrollingMenu:hide()
	for key, value in pairs(self.contents) do
		value:show(false)
	end
	self.list_buttons:show(false)
	if self.window then
		self.window:setVisible(false)
	end
end

function ScrollingMenu:cleanup()
	if self.window then self.window:destroy() end
	self.list_buttons:cleanup()
	for key, value in pairs(self.contents) do
		value:cleanup()
	end
end

function ScrollingMenu:clear()
	self.last_shown = self.max_shown
	for key, value in pairs(self.contents) do
		value:cleanup()
	end
	self.contents = {}
end
