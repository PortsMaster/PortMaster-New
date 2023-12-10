-- Тут храниться функция serialize, которая сериализует таблицы, возвращает строку

local str= "";

local function basicSerialize (o)
	if type(o) == "number" then
		return tostring(o)
	elseif type(o) == "boolean" then
		return (o and "true") or "false"	-- o ? "true" : "false"
	elseif type(o) == "userdata" then
		--return string.format("%X", o)
		return tostring(o)
	else   -- assume it is a string
		return string.format("%q", o)
	end
end

local function save (name, value, saved, simple_only)
	saved = saved or {}       -- initial value
	local str = str .. name.. " = "
	if type(value) == "number" or type(value) == "string" or type(value) == "boolean" or (type(value) == "userdata" and not simple_only) then
		str = str .. basicSerialize(value).. "\n"
	elseif type(value) == "table" then
		if saved[value] then    -- value already saved?
			str = str .. saved[value].. "\n"  -- use its previous name
		else
			saved[value] = name   -- save name for next time
			str = str .. "{}\n"     -- create a new table
			for k,v in pairs(value) do      -- save its fields
				local fieldname = string.format("%s[%s]", name,
												basicSerialize(k))
				str = str .. save(fieldname, v, saved, simple_only)
			end
		end
	else
		if simple_only then 
			str = str .. "nil\n"
		else
			str = str .. "cannot save a " .. type(value) .. "\n"
		end
	end
	return str
end

function serialize(name, value, noFirstBlankLine, simple_only)
	local str = ""
	if not noFirstBlankLine then str = "\n\n"; end
	str = str .. save(name, value, nil, simple_only);
	
	return str;	
end
