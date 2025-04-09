--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--

---@class Classic
---@operator call:fun(...:any)
local Classic = {__class = "Classic"}
Classic.__index = Classic

---base function that can be called with Classic() or Classic:new()
function Classic:new() end

---returns the cloned instance
function Classic:clone()
	local meta, super, index = getmetatable(self), self.super, self.__index
	setmetatable(self, nil)
	self.__index, self.super = nil

	local clone = table.clone(self)
	setmetatable(self, meta); setmetatable(clone, meta)
	clone.__index, self.__index, clone.super, self.super = index, index, super, super
	return clone
end

---returns the class with the tables functions and variables
---@return Classic
function Classic:extend(type)
	local cls = {}

	for k, v in pairs(self) do
		if k:sub(1, 2) == "__" then cls[k] = v end
	end

	cls.__class = type or "Unknown"
	cls.__index = cls
	cls.super = self
	setmetatable(cls, self)

	return cls
end

---implements functions to the class
---@param ... Classic
function Classic:implement(...)
	for _, cls in pairs({...}) do
		for k, v in pairs(cls) do
			if self[k] == nil and type(v) == "function" and k ~= "new" and k:sub(1, 2) ~= "__" then
				self[k] = v
			end
		end
	end
end

---excludes functions from the class
---@param ... string
function Classic:exclude(...)
	for i = 1, select("#", ...) do
		self[select(i, ...)] = nil
	end
end

---check if its the same type or the parent types
---@param T any
function Classic:is(T)
	local mt = self
	repeat
		mt = getmetatable(mt)
		if mt == T then return true end
	until mt == nil
	return false
end

function Classic:__tostring()
	return self.__class
end

---calls the new function with args
---@param ... any
---@return any
function Classic:__call(...)
	local obj = setmetatable({}, self)
	obj:new(...)
	return obj
end

return Classic
