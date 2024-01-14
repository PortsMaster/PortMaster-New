if constants then
	constants.dlText = 0
	constants.dlScript = 1
	constants.dlChoice = 2
	constants.taLeft = 0
	constants.taRight = 1
	constants.taCenter = 2
end

require('routines')

local current_dialogue = nil

DialogueLine = {}
DialogueLine.__index = DialogueLine

function DialogueLine.create(type, contents, params)
	local a = {}
	setmetatable(a, DialogueLine)
	a.type = type
	a.contents = contents
	a.widgets = {}
	a.params = params
	if params and params.nextline then
		a.nextline = params.nextline
	else
		a.nextline = nil
	end
	return a
end

local function CleanLine(line)
	ret = string.gsub(line, "\n", "")
	ret = string.gsub(line, "/c%s+[%d%.]+%s+[%d%.]+%s+[%d%.]+%s+[%d%.]+/", "")
	return ret
end



local function global_keypress_proc(key)
	if not current_dialogue.allow_user_advance then return end
end

local function global_keyrelease_proc(key)
	if not current_dialogue.allow_user_advance then return end
	
	local cur_line = current_dialogue.lines[current_dialogue.currentline]
	local isLineText = (cur_line.type == constants.dlText)
	
	if isConfigKeyPressed(key, "gui_nav_accept") and isLineText then
		if cur_line.typer_ended then
			current_dialogue:advance(true)
		else
			assert(#cur_line.widgets == 1)
			WidgetUseTyper(cur_line.widgets[1], true, 0, false)
		end
	elseif isConfigKeyPressed(key, "gui_nav_decline") and isLineText then
		current_dialogue:advance(false)
	end
end

function DialogueChoice(sender)
	current_dialogue.lines[current_dialogue.currentline].nextline = GetWidgetName(sender)
	current_dialogue:advance(true)
end


function line_to_color(line)
	local r, g, b, a = string.match(line, "([%d%.]+) ([%d%.]+) ([%d%.]+) ([%d%.]+)")
	r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
	return { r, g, b, a }
end

function color_to_line(color)
	return color[1].." "..color[2].." "..color[3].." "..color[4]
end

local function on_typer_ended()
	current_dialogue.lines[current_dialogue.currentline].typer_ended = true
end

function DialogueLine:printline(dialogue, x, y, line, param)
	widget = CreateWidget(constants.wt_Label, "textline", nil, dialogue.textarea[1]+x, dialogue.textarea[2]+y, dialogue.textarea[3]-dialogue.textarea[1], 10)	
	WidgetSetCaption(widget, dictionary_string(line), true);
	WidgetSetCaptionFont(widget, dialogue.font, true)
	WidgetSetVisible(widget, true)
	WidgetSetCaptionColor(widget, dialogue.fontcolor, false)
	WidgetUseTyper(widget, true, 5, false)
	WidgetSetOnTyperEndedProc(widget, on_typer_ended)
	WidgetStartTyper(widget);
	self.typer_ended = false
	local _, wy = WidgetGetSize( widget )
	table.insert(self.widgets, widget)
	return wy
end

function ExplodeEndlines(line, param)
		local res = {}
		local res_param = {}
		local pos = string.find(line, "\n")
		while pos do
			table.insert(res, string.sub(line, 1, pos-1))
			table.insert(res_param, param)
			pos = string.find(line, "\n")
		end
		table.insert(res, string.sub(line, 1, pos-1))
		table.insert(res_param, param)
		return res, res_param
end

function DialogueLine:execute(dialogue)
	if self.params and self.params.portrait_left then
		dialogue:updateTextArea(self.params.portrait_left, true, {self.params.portrait_left_x or 0, self.params.portrait_left_y or 0})
	end
	if self.params and self.params.portrait_right then
		dialogue:updateTextArea(self.params.portrait_right, false, {self.params.portrait_right_x or 0, self.params.portrait_right_y or 0})
	end
	if self.type == constants.dlText then
		local cy = 0
		if not self.params then self.params={} end
		for ii=1,#self.contents do
			cy = cy + dialogue.vertspace + self:printline(dialogue, 0, ((ii-1)*dialogue.vertspace), self.contents[ii], self.params[ii])
		end
		if not dialogue.window then
			dialogue.window = Window.create(dialogue.x, dialogue.y, dialogue.w, math.max(dialogue.pl.y+2*dialogue.vertspace, dialogue.pr.y+2*dialogue.vertspace, cy+2*dialogue.vertspace), "window1")
		else
			dialogue.window:resize( dialogue.w, math.max(dialogue.pl.y+2*dialogue.vertspace, dialogue.pr.y+2*dialogue.vertspace, cy+4*dialogue.vertspace) )
		end
	elseif self.type == constants.dlScript then
		 self.contents(self.params)
		 dialogue:advance(true)
	elseif self.type == constants.dlChoice then
		if not self.params then self.params = {} end
		local cy = 0
		if self.params.text then
			cy = cy + dialogue.vertspace + self:printline(dialogue, 0, 0, self.params.text, nil)
		end
		for ii=1,#self.contents do
			if not self.params[ii] then self.params[ii] = "DIALOGUE_END" end
			widget = CreateWidget(constants.wt_Button, self.params[ii], nil, dialogue.textarea[1], dialogue.textarea[2]+cy, dialogue.textarea[3]-dialogue.textarea[1], 15)
			WidgetSetCaption(widget, dictionary_string(self.contents[ii]), true)
			WidgetSetCaptionFont(widget, "dialogue")
			WidgetSetCaptionColor(widget, dialogue.fontcolor, false)
			WidgetSetVisible(widget, true)
			_, wy = WidgetGetSize(widget)
			cy = cy + dialogue.vertspace + wy
			WidgetSetLMouseClickProc(widget, DialogueChoice)
			if ii == 1 then WidgetGainFocus(widget) end
			table.insert(self.widgets, widget)
		end
		if not dialogue.window then
			dialogue.window = Window.create(dialogue.x, dialogue.y, dialogue.w, math.max(dialogue.pl.y+2*dialogue.vertspace, dialogue.pr.y+2*dialogue.vertspace, cy+2*dialogue.vertspace), "window1")
		else
			dialogue.window:resize( dialogue.w, math.max(dialogue.pl.y+2*dialogue.vertspace, dialogue.pr.y+2*dialogue.vertspace, cy+2*dialogue.vertspace) )
		end

	else
		Log("Something terrible happened - there was a dialogue line with unknown type!")
	end
end

function DialogueLine:destroyWidgets()
	local ii
	for ii=1,#self.widgets do
		DestroyWidget(self.widgets[ii])
		self.widgets[ii] = nil
	end
end

Dialogue = {}
Dialogue.__index = Dialogue

function Dialogue.create()
	local a = {}
	setmetatable(a,Dialogue)
	a.widgets = {}
	a.currentline = nil
	a.lines = {}
	a.lines["ROOT"] = DialogueLine.create(0, constants.dlText, "This dialogue is empty.")
	a.x = 0
	a.y = 0
	a.w = 640
	a.h = 80
	a.pl = {}
	a.pl.sprite = nil
	a.pl.x = 0
	a.pl.y = 0
	a.pl.widget = nil
	a.pr = {}
	a.pr.sprite = nil
	a.pr.widget = nil
	a.pr.x = 0
	a.pr.y = 0
	a.textalign = constants.taLeft
	a.font = "dialogue"
	a.fontcolor = {1, 1, 1, 1}
	a.window = nil
	local x,y = GetCaptionSize("dialogue", "W")
	a.vertspace = math.floor(y*1.5)
	a.horspace = math.floor(x*1.5)
	a.textarea = {a.x+a.horspace, a.y+a.vertspace, a.x+a.w-a.horspace, a.y+a.h-a.vertspace}
	
	a.allow_user_advance = true
	
	a.saved_global_proc = { }
	
	return a
end

function Dialogue:destroyPortrait(left)
	if left then
		self.textarea = {self.x+self.horspace, self.y+self.vertspace, self.x+self.w-self.horspace-self.pr.x-self.horspace, math.max(self.y+self.h, self.pr.y)-self.vertspace}
		if self.pl.widget and left then DestroyWidget(self.pl.widget) self.pl.widget = nil end
		self.pl.x = 0
		self.pl.y = 0
	else
		self.textarea = {self.x+self.horspace+self.pl.x+self.horspace, self.y+self.vertspace, self.x+self.w-self.horspace, math.max(self.y+self.h, self.pl.y)-self.vertspace}
		if self.pr.widget and not left then DestroyWidget(self.pr.widget) self.pr.widget = nil end
		self.pr.x = 0
		self.pr.y = 0
	end
end

function Dialogue:updateTextArea(portrait, left, size)
	if not portrait then
		self:destroyPortrait(true)
		self:destroyPortrait(false)
		return
	end
	if portrait == "PORTRAIT_CLEAR" then
		self:destroyPortrait(left)
		return
	end
	if left then
		if not self.pl then self.pl = {} end
		if self.pl.widget then  
			self:destroyPortrait(left)
		end
		self.pl.sprite = portrait
		self.pl.x = size[1]
		self.pl.y = size[2]
		self.pl.widget = CreateWidget(constants.wt_Picture, "portrait", nil, self.x+self.horspace, self.y+self.vertspace, self.pl.x, self.pl.y)
		WidgetSetSprite(self.pl.widget, portrait)
		WidgetSetAnim(self.pl.widget, "left")
		WidgetSetVisible(self.pl.widget, true)
		self.textarea[1] = self.x+2*self.horspace+self.pl.x
	else
		if not self.pr then self.pr = {} end
		if self.pr.widget then  
			self:destroyPortrait(left)
		end
		self.pr.sprite = portrait
		self.pr.x = size[1]
		self.pr.y = size[2]
		self.pr.widget = CreateWidget(constants.wt_Picture, "portrait", nil, self.x+self.w-self.horspace-self.pr.x - self.pl.x, self.y+self.vertspace, self.pr.x, self.pr.y)
		WidgetSetSprite(self.pr.widget, portrait)
		WidgetSetAnim(self.pr.widget, "right")
		WidgetSetVisible(self.pr.widget, true)
		self.textarea[3] = self.x+self.w-2*self.horspace-self.pr.x
	end
end

function Dialogue:advance(straight_order)
	local old_currnetline = self.currentline	
	
	if straight_order then
		if not self.lines[self.currentline].nextline  then
			--Log("NO NEXTLINE, DEFAULTING")
			if type(self.currentline) == "number" then
				self.currentline = self.currentline + 1
			elseif self.currentline == "ROOT" then
				self.currentline = 1
			end
		else
			self.currentline = self.lines[self.currentline].nextline
		end
	else
		if self.lines[self.currentline].params.skip_to then
			Log("skip_to = ", self.lines[self.currentline].params.skip_to)
			self.currentline = self.lines[self.currentline].params.skip_to
		else
			return
		end	
	end
	
	self.lines[old_currnetline]:destroyWidgets()
	
	if self.currentline == "DIALOGUE_END" then
		--current_dialogue:updateTextArea()
		--current_dialogue.window:destroy()
		--current_dialogue = nil
		self:destroy()
	else
		self:execute()
	end
end

function Dialogue:start(x, y, w, h)
	--Log("Dialogue:start")
	if x then self.x = x end
	if y then self.y = y end
	if w then self.w = w end
	if h then self.h = h end
	
	-- Сохроняем старые глобальные обработчики
	self.saved_global_proc = { GlobalGetKeyDownProc(), GlobalGetKeyReleaseProc() }
	
	GlobalSetKeyDownProc(global_keypress_proc)
	GlobalSetKeyReleaseProc(global_keyrelease_proc)
	
	self:updateTextArea()
	--self.window = Window.create(self.x-10, self.y-10, self.w+30, self.h+10, "window1")
	self:execute()
end

function Dialogue:destroy()
	self:updateTextArea()
	self.window:destroy()
	self.window = nil
	self.currentline = nil

	-- Восстанавливаем старые обработчики
	GlobalSetKeyDownProc(self.saved_global_proc[1])
	GlobalSetKeyReleaseProc(self.saved_global_proc[2])
	
	current_dialogue = nil
end

function Dialogue:execute()
	current_dialogue = self
	if not self.currentline then
		self.currentline = "ROOT"
	end
	if not self.lines[self.currentline] and self.lines[tonumber(self.currentline)] then self.currentline = tonumber(self.currentline) end
	if not self.lines[self.currentline] then self.currentline = "ROOT" end
	self.lines[self.currentline]:execute(self)
end

emptytable = {}
return emptytable
