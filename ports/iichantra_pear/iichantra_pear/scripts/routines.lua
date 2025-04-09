pause_stack = {}

function push_pause( state )
	table.insert( pause_stack, GamePaused() )
	TogglePause( state )
end

function pop_pause()
	TogglePause( (pause_stack[#pause_stack] or false) )
	table.remove( pause_stack, #pause_stack )
end

function dictionary_string(string)
	if not dictionary or not dictionary[string] then
		return string
	end
	return dictionary[string]
end

function iff( condition, a, b )
	if condition then
		return a
	else
		return b
	end
end

function diff_iff( condition, object )
	if condition then
		return object
	else
		return { constants.ObjNone }
	end
end

function child( parent )
	local a = {}
	local a_mt = { __index = a }
	
	function a.bareCreate()
		local ni = {}
		setmetatable( ni, a_mt )
		return ni
	end
	
	function a.superCreate( ... )
		local b = parent.create( unpack(arg) )
		setmetatable( b, a_mt ) 
		return b
	end
	
	function a:super( func, ... )
		local l_arg = arg
		table.remove(l_arg, 1)
		return parent[func]( parent, l_arg )
	end
	
	if parent then
		setmetatable( a, { __index = parent } )
		a.super = parent
	end
	
	return a
end

function shallow_copy( source )
	if not source then return {} end
	local ret = {}
	for key, value in pairs(source) do
		ret[key] = value
	end
	return ret
end

function deep_copy( source )
	if not source then return {} end
	local ret = {}
	for key, value in pairs(source) do
		if type(value) == 'table' then
			ret[key] = deep_copy(value)
		else
			ret[key] = value
		end
	end
	return ret
end

function is_char( char )
	if not char then return false end
	if #char == 1 then
		return true
	end
	return false
end

function random( tab )
	if tab then
		if #tab == 0 then
			ret = {}
			for key, value in pairs(tab) do
				table.insert(ret, value)
			end
		else
			ret = tab
		end
		return ret[math.random(1, #ret)]
	end
	return nil
end

function protected_string(str)
	return string.gsub(str, "[%.%!%*%?%-%[%]%(%)%^%$%%]", "%%%1")
end

local function nextid()
	WidgetContainer.last_id = WidgetContainer.last_id + 1
	return WidgetContainer.last_id - 1
end

function NewMapThread( thread )
	if not mapvar then
		return NewThread( thread, true )
	else
		if not mapvar.threads then mapvar.threads = {} end
		local ret = NewThread( thread, true )
		table.insert( mapvar.threads, ret )
		return ret
	end
end

function StopMapThreads()
	if not mapvar or not mapvar.threads then return end
	for key, value in pairs( mapvar.threads ) do
		StopThread( value )
	end
	mapvar.threads = {}
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- WidgetContainer

WidgetContainer = {}
WidgetContainer.__index = WidgetContainer
WidgetContainer.w2c = {}
WidgetContainer.w2id = {}
WidgetContainer.last_id = 1

function WidgetContainer.create(id, visibility, on_show)
	local a = {}
	setmetatable(a,WidgetContainer)
	a.elements = {}
	a.pointers = {}
	a.onfocus = {}
	a.onunfocus = {}
	a.params = {}
	a.onleft = {}
	a.onright = {}
	a.onkey = {}
	a.visible = {}
	a.id = id
	a.visibility = visibility or false
	a.on_show = on_show
	return a
end

function WidgetContainer:addLabel(WidgetTable)
	local wt = WidgetTable
	wt.text = wt.text or "NULL"
	if dictionary and dictionary[wt.text] then wt.text = dictionary[wt.text] end
	wt.color = wt.color or {1, 1, 1, 1}
	wt.x = wt.x or 0
	wt.y = wt.y or 0
	wt.id = wt.id or "WIDGET" ..nextid()
	wt.font = wt.font or "default"
	wt.visible = wt.visible or true
	if wt.center and wt.text then
		local dx, dy = GetCaptionSize(wt.font, wt.text)
		--Log(wt.text.." "..dx.." "..dy)
		wt.x = wt.center[1]-math.floor(dx/2)
		wt.y = wt.center[2]-math.floor(dy/2)
		--Log(wt.text.." "..wt.x.." "..wt.y)
	end
	local widget = CreateWidget(constants.wt_Label, wt.id, nil, wt.x, wt.y, GetCaptionSize(wt.font, wt.text))
	WidgetSetCaption(widget, wt.text)
	WidgetSetCaptionColor(widget, wt.color, false)
	WidgetSetCaptionFont(widget, wt.font)
	WidgetSetVisible(widget, self.visibility and wt.visible)

	if self.elements[wt.id] then DestroyWidget(self.elements[wt.id]) end
	self.elements[wt.id] = widget
	self.visible[wt.id] = wt.visible
	WidgetContainer.w2c[wt.id] = self
	WidgetContainer.w2id[widget] = wt.id

	return wt.id
end

function WidgetContainer:addPicture(WidgetTable)
	local wt = WidgetTable
	wt.sprite = wt.sprite or "wakaba-widget"
	wt.anim = wt.anim or "idle"
	wt.visible = iff(wt.invisible, false, true)
	wt.x = wt.x or 0
	wt.y = wt.y or 0
	wt.w = wt.w or 28
	wt.h = wt.h or 28
	wt.id = wt.id or "WIDGET" ..nextid()
	local widget = CreateWidget(constants.wt_Picture, wt.id, nil, wt.x, wt.y, wt.w, wt.h)
	WidgetSetSprite(widget, wt.sprite)
	WidgetSetAnim(widget, wt.anim)
	WidgetSetLMouseClickProc(widget, WidgetContainer.onLeft)
	WidgetSetRMouseClickProc(widget, WidgetContainer.onRight)
	WidgetSetFocusProc(widget, WidgetContainer.onFocus)
	WidgetSetUnFocusProc(widget, WidgetContainer.onUnfocus)
	WidgetSetKeyPressProc(widget, WidgetContainer.onKey)
	WidgetSetVisible(widget, (self.visibility and wt.visible))

	if self.elements[wt.id] then DestroyWidget(self.elements[wt.id]) end
	self.elements[wt.id] = widget
	self.onfocus[wt.id] = wt.on_focus
	self.onunfocus[wt.id] = wt.on_unfocus
	self.onleft[wt.id] = wt.on_left
	self.onright[wt.id] = wt.on_right
	self.onkey[wt.id] = wt.on_key
	self.params[wt.id] = wt.params
	self.visible[wt.id] = wt.visible
	WidgetContainer.w2c[wt.id] = self
	WidgetContainer.w2id[widget] = wt.id

	return wt.id
end

function WidgetContainer:addButton(WidgetTable)
	local wt = WidgetTable
	wt.font = wt.font or "default"
	wt.color = wt.color or {1, 1, 1, 1}
	wt.color_focused = wt.color_focused or {1, 1, 1, 1}
	wt.anim = wt.anim or "idle"
	wt.visible = wt.visible or true
	wt.x = wt.x or 0
	wt.y = wt.y or 0
	if wt.text and dictionary and dictionary[wt.text] then wt.text = dictionary[wt.text] end
	local sz1, sz2 = GetCaptionSize(wt.font, (wt.text) or ".")
	wt.w = wt.w or sz1
	wt.h = wt.h or sz2
	wt.id = wt.id or "WIDGET" ..nextid()
	local dx, dy = 0,0
	if wt.center and wt.text then
		dx = wt.x - (wt.center[1]-math.floor(sz1/2))
		dy = wt.y - (wt.center[2]-math.floor(sz2/2))
		wt.x = wt.x - dx
		wt.y = wt.y - dy
	end
	local widget = CreateWidget(constants.wt_Button, wt.id, nil, wt.x, wt.y, wt.w, wt.h)
	if wt.text then
		--Log(wt.text..":"..(dictionary[wt.text] or "nil"))
		WidgetSetCaption(widget, wt.text)
		WidgetSetCaptionColor(widget, wt.color, false)
		WidgetSetCaptionColor(widget, wt.color_focused, true)
		WidgetSetCaptionFont(widget, wt.font)
	end
	WidgetSetVisible(widget, (self.visibility and wt.visible))
	if wt.sprite then
		WidgetSetSprite(widget, wt.sprite)
		WidgetSetAnim(widget, wt.anim)
	end
	WidgetSetLMouseClickProc(widget, WidgetContainer.onLeft)
	WidgetSetRMouseClickProc(widget, WidgetContainer.onRight)
	WidgetSetFocusProc(widget, WidgetContainer.onFocus)
	WidgetSetUnFocusProc(widget, WidgetContainer.onUnfocus)
	if wt.non_focusable then
		WidgetSetFocusable(widget, false)
	end

	if wt.pointer_proto then
		pointer = CreateWidget(constants.wt_Picture, wt.id.."_pointer", nil, wt.pointer_x-dx, wt.pointer_y-dy, 1, 1)
		WidgetSetSprite(pointer, wt.pointer_proto)
		WidgetSetAnim(pointer, "idle")
		WidgetSetVisible(pointer, false)
	end

	if self.elements[wt.id] then DestroyWidget(self.elements[wt.id]) end
	if self.pointers[wt.id] then 
		--Log(wt.id)
		--Log(self.pointers[wt.id])
		DestroyWidget(self.pointers[wt.id]) 
		self.pointes[wt.id] = nil 
	end
	self.elements[wt.id] = widget
	self.onfocus[wt.id] = wt.on_focus
	self.onunfocus[wt.id] = wt.on_unfocus
	self.onleft[wt.id] = wt.on_left
	self.onright[wt.id] = wt.on_right
	self.params[wt.id] = wt.params
	self.pointers[wt.id] = pointer
	self.visible[wt.id] = wt.visible
	WidgetContainer.w2c[wt.id] = self
	WidgetContainer.w2id[widget] = wt.id

	--Log(serialize("wt", wt))

	return wt.id
end

function WidgetContainer:show(state)
	if self.on_show then
		self.on_show(state)
	end
	self.visibility = state
	for key, value in pairs(self.elements) do
		WidgetSetVisible(self.elements[key], (self.visible[key] and self.visibility))
		if not self.visibility and self.pointers[key] then WidgetSetVisible(self.pointers[key], false) end
	end
end

function WidgetContainer:destroy()
	for key, value in pairs(self.elements) do
		DestroyWidget(self.elements[key])
		if self.pointers[key] then 
			DestroyWidget(self.pointers[key]) 
		end
		self.elements[key] = nil
		self.pointers[key] = nil
	end
end

function WidgetContainer:destroyWidget(id)
	if self.elements[id] then
		DestroyWidget(self.widgets[id])
		self.elements[id] = nil
		if self.pointers[id] then
			DestroyWidget(self.pointers[id])
		end
	else
		Log(string.format("WARNING: WidgetContainer %s: trying to destroy widget %s which does not exists.", (self.id or "BAD CONTAINER"), (id or "BAD WIDGET")))
	end
end

function WidgetContainer:showWidget(id, state)
	if self.elements[id] then
		self.visible[id] = iff(state, true, false)
		WidgetSetVisible(self.elements[id], (self.visible[id] and self.visibility))
		if not self.visible[id] and self.pointers[id] then WidgetSetVisible(self.pointers[id], false) end
	else
		Log(string.format("WARNING: WidgetContainer %s: trying to change visibility of widget %s which does not exists.", (self.id or "BAD CONTAINER"), (id or "BAD WIDGET")))
	end

end

function WidgetContainer.onFocus(sender)
	local id = WidgetContainer.w2id[sender]
	local cont = WidgetContainer.w2c[id]
	if not cont or not id then
		Log("ERROR: A call to WidgetContainer function from widget not in the container!")
		return
	end
	
	if ( cont.pointers[id] ) then
		WidgetSetVisible( cont.pointers[id], true )
	end
	if ( cont.onfocus[id] ) then
		cont.onfocus[id](sender, cont.params[id])
	end
end

function WidgetContainer.onUnfocus(sender)
	local id = WidgetContainer.w2id[sender]
	local cont = WidgetContainer.w2c[id]

	if not cont or not id then
		Log("ERROR: A call to WidgetContainer function from widget not in the container!")
		return
	end
	
	if ( cont.pointers[id] ) then
		WidgetSetVisible( cont.pointers[id], false )
	end
	if ( cont.onunfocus[id] ) then
		cont.onunfocus[id](sender, cont.params[id])
	end
end

function WidgetContainer.onLeft(sender)
	local id = WidgetContainer.w2id[sender]
	local cont = WidgetContainer.w2c[id]

	if not cont or not id then
		Log("ERROR: A call to WidgetContainer function from widget not in the container!")
		return
	end
	
	if ( cont.onleft[id] ) then
		cont.onleft[id](sender, cont.params[id])
	end
end

function WidgetContainer.onRight(sender)
	local id = WidgetContainer.w2id[sender]
	local cont = WidgetContainer.w2c[id]

	if not cont or not id then
		Log("ERROR: A call to WidgetContainer function from widget not in the container!")
		return
	end
	
	if ( cont.onright[id] ) then
		cont.onright[id](sender, cont.params[id])
	end
end

function WidgetContainer.onKey(sender, key)
	local id = WidgetContainer.w2id[sender]
	local cont = WidgetContainer.w2c[id]

	if not cont or not id then
		Log("ERROR: A call to WidgetContainer function from widget not in the container!")
		return
	end
	
	if ( cont.onkey[id] ) then
		cont.onkey[id](sender, key)
	end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Window
-- Рисует окно с рамкой. Использует 9 виджетов. Для изменения размеров использует методы рендера с повторением текстур.
Window = {}
Window.__index = Window
Window.widgets = {}

-- Создает и настраивает виджеты окна. Достаточно вызвать один раз (если не ввести какие-то еще настройки окна типа спрайта).
function Window:prepareWidgets()
	local ww = self.widgets
	
	local function CWW(x,y,sprite,anim,rm)
		--Log(anim)
		local widget = CreateWidget(constants.wt_Picture, "window", nil, x, y, self.dsize, self.dsize)
		WidgetSetSprite(widget, sprite)
		WidgetSetSpriteRenderMethod(widget, rm)
		WidgetSetVisible(widget, true)
		WidgetSetAnim(widget, anim)
		WidgetSetFocusable(widget, false)
		--WidgetSetBorder(widget, true)
		return widget
	end
	
	if not ww.tl then ww.tl = CWW(self.x, self.y, self.sprite, "topleft", constants.rsmStandart) end
	if not ww.t then ww.t = CWW(self.x, self.y, self.sprite, "top", constants.rsmRepeatX) end
	if not ww.tr then ww.tr = CWW(self.x, self.y, self.sprite, "topright", constants.rsmStandart) end
	if not ww.l then ww.l = CWW(self.x, self.y, self.sprite, "left", constants.rsmRepeatY) end
	if not ww.c then ww.c = CWW(self.x, self.y, self.sprite, "center", constants.rsmRepeatXY) end
	if not ww.r then ww.r = CWW(self.x, self.y, self.sprite, "right", constants.rsmRepeatY) end
	if not ww.bl then ww.bl = CWW(self.x, self.y, self.sprite, "bottomleft", constants.rsmStandart) end
	if not ww.b then ww.b = CWW(self.x, self.y, self.sprite, "bottom", constants.rsmRepeatX) end
	if not ww.br then ww.br = CWW(self.x, self.y, self.sprite, "bottomright", constants.rsmStandart) end
end

-- Задает виджетам окна правильное положение и размеры
function Window:show()
	self:setVisible(true)
	
	local ww = self.widgets
	
	local x1 = self.x
	local y1 = self.y
	local x2 = x1 + self.dsize
	local y2 = y1 + self.dsize
	local x3 = x1 + self.w - self.dsize
	local y3 = y1 + self.h - self.dsize
	
	local mw = x3 - x2
	local mh = y3 - y2
	
	WidgetSetPos(ww.tl, x1, y1)
	WidgetSetPos(ww.t, x2, y1)
	WidgetSetPos(ww.tr, x3, y1)
	WidgetSetPos(ww.l, x1, y2)
	WidgetSetPos(ww.c, x2, y2)
	WidgetSetPos(ww.r, x3, y2)
	WidgetSetPos(ww.bl, x1, y3)
	WidgetSetPos(ww.b, x2, y3)
	WidgetSetPos(ww.br, x3, y3)
	
	WidgetSetSize(ww.t, mw, self.dsize)
	WidgetSetSize(ww.b, mw, self.dsize)
	WidgetSetSize(ww.c, mw, mh)
	WidgetSetSize(ww.l, self.dsize, mh)
	WidgetSetSize(ww.r, self.dsize, mh)
end

function Window:resize( w, h )
	self.w = w
	self.h = h
	--self:prepareWidgets()
	self:show()
end

function Window:move( x, y )
	self.x = x
	self.y = y
	self:show()
end

function Window:recreate( x, y, w, h )
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	--self:prepareWidgets()
	self:show()
end

function Window.create(x, y, w, h, sprite)
	local a = {}
	setmetatable(a, Window)
	a.x = x
	a.y = y
	a.w = w
	a.h = h
	a.dsize = 16
	a.sprite = sprite
	a.visible = true
	a.widgets = { }
	a:prepareWidgets()
	a:show()
	return a
end

function Window:setVisible(visibility)
	self.visible = visibilty
	for key, value in pairs(self.widgets) do
		WidgetSetVisible(value, visibility)
	end
end

function Window:destroy()
	for key, value in pairs(self.widgets) do
		DestroyWidget(value)
	end
end

-----------------------------------------------------------------

function LetterBox( state )
	if state then
		if not letterbox1 then
			letterbox1 = CreateWidget(constants.wt_Widget, "letterbox1", nil, 0, 0, CONFIG.scr_width, CONFIG.scr_height/8)
			WidgetSetZ(letterbox1, 0.5)
			WidgetSetColorBox( letterbox1, {0,0,0,1} )
		end
		if not letterbox2 then 
			letterbox2 = CreateWidget(constants.wt_Widget, "letterbox2", nil, 0, CONFIG.scr_height*7/8, CONFIG.scr_width, CONFIG.scr_height/8)
			WidgetSetZ(letterbox2, 0.5)
			WidgetSetColorBox( letterbox2, {0,0,0,2} )
		end
	else
		if ( letterbox1 ) then DestroyWidget(letterbox1); letterbox1 = nil end
		if ( letterbox2 ) then DestroyWidget(letterbox2); letterbox2 = nil end
	end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Fading

local fade_color = {0, 0, 0, 0}
local fade_box = nil
local fade_z = 0.5
local fading_in = false

local function FadeOutThread( color, time )
	--Log("FadeOutThread called")
	if not color then color = { 0, 0, 0 } end
	if time == 0 then time = 1 end
	local fade_start = GetCurTime()
	local fade_alpha = 0
	local progress
	fade_color = color
	
	if not fade_box then
		fade_box = CreateWidget(constants.wt_Widget, "fade_box", nil, 0, 0, CONFIG.scr_width, CONFIG.scr_height)
		WidgetSetZ(fade_box, fade_z)
		WidgetSetVisible(fade_box, true)
	end	
	
	while fade_alpha ~= 1 do
		fade_alpha = (GetCurTime() - fade_start) / time
		if fade_alpha > 1 then fade_alpha = 1 end
		WidgetSetColorBox(fade_box, {color[1], color[2], color[3], fade_alpha} )
		Wait(1)
	end
	
	--Log("FadeOutThread ending, fading_in = ", fading_in)
end

local function FadeInThread( time )
	local fade_start = GetCurTime()
	--Log("FadeInThread called, time = ", time, ", cur_time = ", fade_start, ", fading_in = ", fading_in, ", fade_box = ", fade_box)
	if not fade_box then return end
	local fade_alpha = 1
	while (fade_start + time > GetCurTime()) and fading_in do
		fade_alpha = 1 - (GetCurTime()-fade_start)/time
		WidgetSetColorBox(fade_box, {fade_color[1], fade_color[2], fade_color[3], fade_alpha} )
		Wait(1)
	end
	if fading_in then 
		DestroyWidget(fade_box)
		fade_box = nil
	end	
	--Log("FadeInThread ending, fading_in = ", fading_in)
	fading_in = false
end

function FadeOut( color, time )
	--Log("FadeOut called, fading_in = ", fading_in)
	fading_in = false
	if time > 0 then		
		local fade_thread = NewThread( FadeOutThread )
		Resume( fade_thread, color, time )
	else
		screen = GetScreenInfo()
		if not fade_box then 
			fade_box = CreateWidget(constants.wt_Widget, "fade_box", nil, 0, 0, CONFIG.scr_width, CONFIG.scr_height)
		end
		WidgetSetZ(fade_box, fade_z)
		WidgetSetVisible(fade_box, true)
		WidgetSetColorBox(fade_box, {color[1], color[2], color[3], 1} )
	end
end

function FadeIn( time )
	--Log("FadeIn called, fading_in = ", fading_in)
	if fading_in then return end
	fading_in = true
	local fade_thread = NewThread( FadeInThread )
	Resume( fade_thread, time )
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Тут функции, которые что-то плавно двигают

-- Фукнция мувера, выполняется в отдельном потоке и считает время
local function moveThread(time, linear, action, end_action)
	assert(action and (type(action) == "function"))
	assert(end_action and (type(end_action) == "function"))
	
	local time_start = GetCurTime()
	local cur_time = time_start
Wait(1)
	while time_start + time > cur_time do
		local t = (cur_time - time_start)/time

		if not linear then t = t*t*(3-2*t) end
		
		action(t)
		
		Wait(1)
		cur_time = GetCurTime()
	end 
	
	end_action()
	
	--Log("moveThread ended")
end

-- Плавно двигает виджет
function MoveWidgetTo(widget, new_pos, time, linear, onEnd)
	assert(widget)
	assert(new_pos and (type(new_pos) == "table"))
	assert(time)
	
	local old_x, old_y = WidgetGetPos(widget)
	if not old_x or not old_y then return end
	local time_start = GetCurTime()
	local cur_time = time_start
	
	local x = 0
	local y = 0
	
	
	
	local function on_timer(t)
		x = old_x + (new_pos[1] - old_x) * t
		y = old_y +(new_pos[2] - old_y) * t
		WidgetSetPos(widget, x, y)
	end
	local function last_move()
		WidgetSetPos(widget, new_pos[1], new_pos[2])
		if onEnd and (type(onEnd) == "function") then onEnd() end
	end
	
	local move_thread = NewThread(moveThread)
	--Log("move_thread = ", move_thread)
	Resume(move_thread, widget, new_pos, time, linear, onEnd)
end

-- Цепояет камеру к объекту и плавно смещает её к нему
-- shift_x, shift_y - сдвиг относительно объекта
function AttachCamToObjSlowly(id, shift_x, shift_y, time, linear, onEnd)
	assert(id)
	assert(shift_x)
	assert(shift_y)
	assert(time)
	
	local obj = GetObject(id)
	if not obj then return end
	
	local obj_x, obj_y = obj.aabb.p.x, obj.aabb.p.y
	local cam_x, cam_y = GetCamPos()
	
	SetCamAttachedObj(id);
	
	local foc_x, foc_y = GetCamFocusShift()
	local old_x = -(cam_x - obj_x) + foc_x
	local old_y = -(cam_y - obj_y) + foc_y
	
	SetCamObjOffset(old_x,old_y)
	
	local function on_timer(t)
		local x = old_x + (shift_x - old_x) * t
		local y = old_y + (shift_y - old_y) * t
		SetCamObjOffset(x,y)
	end
	local function last_move()
		SetCamObjOffset(shift_x,shift_y)
		if onEnd and (type(onEnd) == "function") then onEnd() end
	end
	
	local move_thread = NewThread(moveThread)
	--Log("move_thread = ", move_thread)
	Resume(move_thread, time, linear, on_timer, last_move)
end

-- Цепояет камеру к объекту и плавно смещает её к нему
-- shift_x, shift_y - сдвиг относительно объекта
function ChangeGlobalVolumeSlowly(from, to, time, linear, onEnd)
	assert(from)
	assert(to)
	assert(time)
	
	local old = from
	CONFIG.volume = from
	LoadConfig()
	
	local function on_timer(t)
		local v = old + (to - old) * t
		
		CONFIG.volume = v
		LoadConfig()
	end
	local function last_move()
		CONFIG.volume = to
		LoadConfig()
		SaveConfig()
		if onEnd and (type(onEnd) == "function") then onEnd() end
	end
	
	local move_thread = NewThread(moveThread)
	--Log("move_thread = ", move_thread)
	Resume(move_thread, time, linear, on_timer, last_move)
end

function FadeOutGlobalVolume(time, linear, onEnd)
	ChangeGlobalVolumeSlowly(0, CONFIG.volume, time, linear, onEnd)
end
----------------------------------------------------------------------
----------------------------------------------------------------------

function isConfigKeyPressed(key, cfgKeyName)
	for i = 1, constants.configKeySetsNumber do
		if CONFIG.key_conf[i][cfgKeyName] == key then return true end
	end
	return false
end
--------------------------------------------------------------------------

function showStageName( number, event )
	push_pause(true)
	GUI:hide()
	local st1, st2 = dictionary_string("STAGE").." "..tostring(number), dictionary_string(Loader.level.name or "ANONYMOUS")
	local x1, y1 = GetCaptionSize("default", st1)
	local x2, y2 = GetCaptionSize("default", " ")
	local x3, y3 = GetCaptionSize("default", st2)
	local label = CreateWidget(constants.wt_Label, "Label1", nil, CONFIG.scr_width/2-math.max(x1, x3)/2, CONFIG.scr_height/2-y1-y2/2, 200, 10)
	WidgetSetBorder(label, false)
	WidgetSetCaptionColor(label, {1,1,1,1}, false)
	WidgetSetCaption(label, st1.."/n/n"..st2, true)
	WidgetUseTyper(label, true, 20, false)
	WidgetStartTyper(label);
	mapvar.tmp.label = label
	mapvar.tmp.ssn_event = event
	Resume( NewThread( function()
		Wait( 2000 )
		DestroyWidget( mapvar.tmp.label )
		pop_pause()
		GUI:show()
		mapvar.tmp.ssn_event()
	end ))
end

--------------------------------------------------------------------------

routines = {}

return routines
