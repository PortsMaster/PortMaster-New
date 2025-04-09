--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- templates library
loveframes.templates = {}

--[[---------------------------------------------------------
	- func: RegisterTemplate(template)
	- desc: registers a template
--]]---------------------------------------------------------
function loveframes.RegisterTemplate(template)
	-- display an error message if template is not a table
	if type(template) ~= "table" then
		loveframes.Error("Could not register template: Template argument must be a table.")
	end
	
	local name = template.name
	local base = loveframes.objects["base"]
	
	-- display an error message if a template name was not given
	if not name then
		loveframes.Error("Could not register template: No template name given.")
	end
	
	if name == "Base" then
		base:include(template.properties["*"])
	end
	
	-- insert the template into the available templates table
	loveframes.templates[name] = template
	
end

--[[---------------------------------------------------------
	- func: ApplyTemplatesToObject(object)
	- desc: applies the properties of registered templates 
			to an object
--]]---------------------------------------------------------
function loveframes.ApplyTemplatesToObject(object)
	local templates = loveframes.templates
	local type = object.type
	-- loop through all available templates
	for k, v in pairs(templates) do
		-- make sure the base template doesn't get applied more than once
		if k ~= "Base" then
			local properties = v.properties
			local hasall = loveframes.TableHasKey(properties, "*")
			local hasobject = false
			if not hasall then
				hasobject = loveframes.TableHasKey(properties, type)
			end
			if hasall then
				for k, v in pairs(properties["*"]) do
					object[k] = v
				end
			elseif hasobject then
				-- apply the template properties to the object
				for k, v in pairs(properties[type]) do
					object[k] = v
				end
			end
		end
	end
	
end

function loveframes.LoadTemplates(dir)
	local templatelist = loveframes.GetDirectoryContents(dir)
	-- loop through a list of all gui templates and require them
	for k, v in ipairs(templatelist) do
		if v.extension == "lua" then
			local template = require(v.requirepath)
			loveframes.RegisterTemplate(template)
		end
	end
end
--return templates

---------- module end ----------
end
