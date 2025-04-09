LayeredBar = 
{ 
	x = 348; y = 18; w = 170; h = 14; z_min = 0.9; z_max = 1; 
	pmin = 0; pmax = 100; 
	layers = {}; visibility = true;
	wc = nil
}
LayeredBar.__index = LayeredBar

function LayeredBar.create()
	local bar = {} 
	setmetatable(bar, LayeredBar)
	return bar
end

function LayeredBar:init(x, y, w, h, layers, z_min, z_max)
	self.x = x;
	self.y = y;
	self.w = w;
	self.h = h;
	self.z_min = z_min;
	self.z_max = z_max;
	self.layers = shallow_copy(layers);
	
	local z_step = (z_max-z_min) / #layers;
	local z = z_min
	for k,v in ipairs(self.layers) do
		v.widget = CreateWidget(constants.wt_Widget, "bar_layer"..k, nil, x, y, w, h)
		WidgetSetZ(v.widget, z)
		WidgetSetColorBox(v.widget, v.color)
		z = z + z_step
		if not v.cur then v.cur = self.pmax end
	end
	
	wc = WidgetContainer.create("bar_widgets", self.visibility)
end

function LayeredBar:init_default(layers, text)
	self:init(self.x, self.y, self.w, self.h, layers, self.z_min, self.z_max);
	self:addBorderPicture("gui", "boss_health_bar", -6, -18);
	self:addLabel(text or "", {1,1,1,1}, nil, 0, -14);
end

function LayeredBar:addBorderPicture(sprite, anim, x_off, y_off)
	local pic = {}
	pic.sprite = sprite
	pic.anim = anim
	pic.x = self.x + x_off
	pic.y = self.y + y_off
	pic.id = "bar_border"
	wc:addPicture(pic)
end

function LayeredBar:addLabel(text, color, font, x_off, y_off)
	local t = {}
	t.text = text
	t.color = color
	t.font = font
	t.x = self.x + x_off
	t.y = self.y + y_off
	t.id = "bar_label"
	wc:addLabel(t)
end

function LayeredBar:destroy()
	for k,v in ipairs(self.layers) do
		DestroyWidget(v.widget)
		v.widget = nil
	end
	self.layers = nil
	if wc then wc:destroy(); wc = nil end
end

function LayeredBar:show(state)
	if not state then state = false end
	self.visibility = state
	for k,v in ipairs(self.layers) do
		WidgetSetVisible(v.widget, state)
	end
	if wc then wc:show(state); wc = nil end
end

function LayeredBar:move(x,y)
	self.x = x
	self.y = y
	for k,v in ipairs(self.layers) do
		WidgetSetPos(v.widget, x, y)
	end
	--if self.border then WidgetSetPos(self.border, x + self.border_x_off, y + self.border_y_off) end
end

function LayeredBar:resize(w,h)
	self.w = w
	self.h = h
	for k,v in ipairs(self.layers) do
		local p = (v.cur - self.pmin)/(self.pmax - self.pmin)
		WidgetSetSize(v.widget, self.w * p, self.h)
	end
end

function LayeredBar:setLayerVal(n, l)
	if not l then l = #self.layers end
	if self.lock_first and l == 1 then return end
	
	if n < self.pmin then n = self.pmin end
	if n > self.pmax then n = self.pmax end
		
	local layer = self.layers[l]
	if layer then
		local wid = layer.widget
		local p = (n - self.pmin)/(self.pmax - self.pmin)
		--Log(p, "  ", self.w * p)
		WidgetSetSize(wid, self.w * p, self.h)
		layer.cur = n
	end
end

function LayeredBar:getLayerVal(l)
	if self.layers[l] then return self.layers[l].cur end
	return nil
end

return LayeredBar