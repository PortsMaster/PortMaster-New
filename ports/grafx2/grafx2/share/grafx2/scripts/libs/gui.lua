--
-- Event-driven GUI library
--
--

gui = {

--
-- colors
--
black = 0,
dark  = 1,
light = 2,
white = 3,

-- "do nothing" function. Used as default callback
donothing = function(self)
end,

-- Metatable that hides the field "value" behind a property,
-- and calls render() after it's set.
propvalue = {
  __newindex = function(self, index, value)
    if index == "value" then
      self._value = value
      -- extra processing
      self:render()
      else
        rawset(self, index, value)
      end
  end,
  __index = function(self, index )
    if index == "value" then
      return self._value
    else
      return rawget( self, index )
    end
  end
},

--
-- dialog()
--
dialog = function(args)
  local dia = {
    title = args.title,
    w = args.w,
    h = args.h,
    --
    widgets = {},
    -- an indexed array, starting at 1. Used for calling the relevant
    -- callback when a numbered control is clicked.
    callbacks = {},

    --
    -- dialog.run() --
    --
    run = function(self)
      windowopen(self.w,self.h, self.title or "");
      -- examine all elements
      for _,widget in ipairs(self.widgets) do
        widget:create()
      end

      repeat
       local button, button2, key = windowdodialog();

        if button > 0 then
          local c = self.callbacks[button]
          if c ~= nil then
            -- run the callback
            local retvalue = c:click()
            -- stop the form if it returns non-nil
            if retvalue ~= nil then
              windowclose();
              return retvalue;
            end
          end
        end
      until key == 27;
      windowclose();
    end
  }
  local id = 1;
  -- examine all elements
  for _,value in ipairs(args) do
    -- all arguments that are tables are assumed to be widgets
    if type(value)=="table" then
      table.insert(dia.widgets, value)
      -- clickable widgets take up an auto-numbered id
      if (value.click) then
        dia.callbacks[id] = value
        id=id+1
      end
    end
  end
  return dia;
end,

--
-- button()
--
button = function(args)
  local but = {
    x = args.x,
    y = args.y,
    w = args.w,
    h = args.h,
    key = args.key,
    label = args.label,
    click = args.click or gui.donothing,
    create = args.repeatable and function(self)
      windowrepeatbutton(self.x, self.y, self.w, self.h, self.label, self.key or -1);
    end
    or function(self)
      windowbutton(self.x, self.y, self.w, self.h, self.label, self.key or -1);
    end
  }
  return but;
end,

--
-- label()
--
label = function(args)
  local lbl = {
    x = args.x,
    y = args.y,
    _value = args.value,
    format = args.format,
    fg = args.fg or gui.black,
    bg = args.bg or gui.light,
    render = function(self)
      if type(self.format) then
        windowprint(self.x, self.y, string.format(self.format, self._value), self.fg, self.bg);
      else
        windowprint(self.x, self.y, self._value, self.fg, self.bg);
      end
    end,
  }
  lbl.create = lbl.render
  setmetatable(lbl, gui.propvalue)
  return lbl;
end,

--
-- textbox
--
textbox = function(args)
  local txtbox = {
    x = args.x,
    y = args.y,
    nbchar = args.nbchar, -- visible size in characters
    --format = args.format, -- numeric, decimal, path
    decimal = args.decimal or 0,
    min = args.min,
    max = args.max,
    maxchar = args.maxchar, -- internal size
    _value = args.value,
    change = args.change or gui.donothing,
    --fg = args.fg or gui.black,
    --bg = args.bg or gui.light,
    create = function(self)
      windowinput(self.x, self.y, self.nbchar)
      self:render()
    end,
    render = function(self)
      local val = tostring(self._value)
      if string.len(val) < self.nbchar then
        val = string.rep(" ",self.nbchar - string.len(val)) .. val;
      elseif string.len(val) > self.nbchar then
        val = string.sub(val, 1, self.nbchar-1) .. gui.char.ellipsis
      end
      windowprint(self.x, self.y, val, gui.black, gui.light);
    end,
    click = function(self)
      local inputtype
      if (type(self._value) == "number" and ((self.min ~= nil and self.min<0) or self.decimal > 0)) then
        inputtype = 3 -- entry as double
      elseif (type(self._value) == "number") then
        inputtype = 1 -- entry as unsigned int
      else
        inputtype = 0 -- entry as string
      end
      local accept, val = windowreadline(self.x, self.y, self._value, self.nbchar, self.maxchar, self.decimal, inputtype);

      if accept then
        if (inputtype == 1 or inputtype == 3) then
          val = tonumber(val)
          -- round the decimal places
          val = gui.round(val, self.decimal)
        end
        if (self.min ~= nil and val < self.min) then
          val = self.min
        end
        if (self.max ~= nil and val > self.max) then
          val = self.max
        end

        self._value = val
      end
      self:render()
    end
  }
  setmetatable(txtbox, gui.propvalue)
  return txtbox;
end

}

gui.round = function(val, ipt)
  local mult = 10^ipt
  return math.floor(val * mult + 0.5) / mult
end

-- Character constants. May be useful in screens
gui.char = {
  ellipsis = string.char(133), -- ...
  arrowup = string.char(24),
  arrowdown = string.char(25),
  arrowleft = string.char(27),
  arrowright = string.char(26),
  vertical = string.char(18), -- double-ended arrow
  horizontal = string.char(29) -- double-ended arrow
}
