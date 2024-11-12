local GlobalVariables = class('GlobalVariables')

function GlobalVariables:initialize()
	self.list = {}
end

function GlobalVariables:add(id, property, value)

	if self.list[id] then
		self.list[id][property] = value
	else
		self.list[id] = {}
		self.list[id][property] = value
	end

	--print(id.." : " .. property .. " : " .. value)

end

function GlobalVariables:get(id, property)
	
	if not self.list[id] then
		return nil
	end	
	
	for key, value in pairs(self.list[id]) do
		if key == property then
			return value
		end
	end
	
	return nil
end

function GlobalVariables:clear()
	self.list = {}
end

function GlobalVariables:check(id, property, value)
	
	if not self.list[id] then
		return false
	end	
	
	for key, val in pairs(self.list[id]) do
		if key == property then
			if val == value then
				return true
			end
			if val == tonumber(value) then
				return true
			end
		end
	end
	
	return false
end

function GlobalVariables:dump()

	return lume.serialize(self.list)

end


return GlobalVariables