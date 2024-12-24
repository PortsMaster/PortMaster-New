local Throttle = {}
local ThrottleObject = {}
local dead, deadmax = {}, 32
ThrottleObject.__index = ThrottleObject

function ThrottleObject:new(inputs, step, delay)
	self.inputs = type(inputs[1]) == "function" and {inputs} or inputs
	self.step, self.delay = step, delay
	self.timeStep, self.time = 0, 0

	self:check()
	table.insert(Throttle.list, self)
	return self
end

function ThrottleObject:update(dt)
	local hold = false
	for _, v in ipairs(self.inputs) do
		local foo = table.remove(v, 1)
		hold = foo(unpack(v)); table.insert(v, 1, foo)
		if hold then break end
	end

	if hold then
		if self.time > 0 then
			self.timeStep = self.timeStep + dt
			if self.time > self.delay and self.timeStep > self.step then self.timeStep = 0 end
		end
		self.time = self.time + dt
	else
		self.time, self.timeStep = 0, 0
	end
end

function ThrottleObject:check()
	return self.time ~= 0 and self.timeStep == 0
end

function ThrottleObject:destroy()
	table.destroy(Throttle.list, self)
	table.insert(dead, setmetatable(self))
end

-- Throttle
Throttle.list = {}
function Throttle:make(inputs, step, delay)
	--checktype(2, inputs, 2, "Throttle.make", "table")
	return ThrottleObject.new(setmetatable(table.remove(dead) or {}, ThrottleObject),
		inputs, step or (1 / 18), delay or 0.5)
end

function Throttle:update(dt)
	for _, v in ipairs(self.list) do v:update(dt) end
	while #dead > deadmax do table.remove(dead) end
end

return Throttle
