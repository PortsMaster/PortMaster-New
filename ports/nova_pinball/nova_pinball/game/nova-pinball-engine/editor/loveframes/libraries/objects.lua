--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

loveframes.objects = {}


--[[---------------------------------------------------------
	- func: Create(type, parent)
	- desc: creates a new object or multiple new objects
			(based on the method used) and returns said
			object or objects for further manipulation
--]]---------------------------------------------------------
function loveframes.Create(data, parent)
	
	if type(data) == "string" then
	
		local objects = loveframes.objects
		local object = objects[data]
		local objectcount = loveframes.objectcount
		
		if not object then
			loveframes.Error("Error creating object: Invalid object '" ..data.. "'.")
		end
		
		-- create the object
		local newobject = object:new()
		
		-- apply template properties to the object
		loveframes.ApplyTemplatesToObject(newobject)
		
		-- if the object is a tooltip, return it and go no further
		if data == "tooltip" then
			return newobject
		end
		
		-- remove the object if it is an internal
		if newobject.internal then
			newobject:Remove()
			return
		end
		
		-- parent the new object by default to the base gui object
		newobject.parent = loveframes.base
		table.insert(loveframes.base.children, newobject)
		
		-- if the parent argument is not nil, make that argument the object's new parent
		if parent then
			newobject:SetParent(parent)
		end
		
		loveframes.objectcount = objectcount + 1
		
		-- return the object for further manipulation
		return newobject
		
	elseif type(data) == "table" then

		-- table for creation of multiple objects
		local objects = {}
		
		-- this function reads a table that contains a layout of object properties and then
		-- creates objects based on those properties
		local function CreateObjects(t, o, c)
			local child = c or false
			local validobjects = loveframes.objects
			for k, v in pairs(t) do
				-- current default object
				local object = validobjects[v.type]:new()
				-- insert the object into the table of objects being created
				table.insert(objects, object)
				-- parent the new object by default to the base gui object
				object.parent = loveframes.base
				table.insert(loveframes.base.children, object)
				if o then
					object:SetParent(o)
				end
				-- loop through the current layout table and assign the properties found
				-- to the current object
				for i, j in pairs(v) do
					if i ~= "children" and i ~= "func" then
						if child then
							if i == "x" then
								object["staticx"] = j
							elseif i == "y" then
								object["staticy"] = j
							else
								object[i] = j
							end
						else
							object[i] = j
						end
					elseif i == "children" then
						CreateObjects(j, object, true)
					end
				end
				if v.func then
					v.func(object)
				end
			end
		end
		
		-- create the objects
		CreateObjects(data)
		
		return objects
		
	end
	
end

--[[---------------------------------------------------------
	- func: NewObject(id, name, inherit_from_base)
	- desc: creates a new object
--]]---------------------------------------------------------
function loveframes.NewObject(id, name, inherit_from_base)
	
	local objects = loveframes.objects
	local object = false
	
	if inherit_from_base then
		local base = objects["base"]
		object = loveframes.class(name, base)
		objects[id] = object
	else
		object = loveframes.class(name)
		objects[id] = object
	end
	
	return object
	
end

function loveframes.LoadObjects(dir)
	local objectlist = loveframes.GetDirectoryContents(dir)
	-- loop through a list of all gui objects and require them
	for k, v in ipairs(objectlist) do
		if v.extension == "lua" then
			loveframes.require(v.requirepath)
		end
	end
end
--return objects

---------- module end ----------
end