local JSONBuilder = {}

local function buildArray(array)
	local result = "[]"
	if type(array) == "table" and #array > 0 then
		result = "["
		for i, v in ipairs(array) do
			if i == #array then
				result = result .. tostring(v)
			else
				result = result .. tostring(v) .. ", "
			end
		end
		result = result .. "]"
	end
	return result
end

---@param value table
---@return string
function JSONBuilder.buildChar(value)
	local result = "{}"
	if type(value) == "table" then
		result = "{\n"
		if value.animations ~= nil then
			result = result .. "\t\"animations\": ["
			if #value.animations > 0 then
				result = result .. "\n"
				for i, v in ipairs(value.animations) do
					local anim = "\t\t[\"%s\", \"%s\", %s, %d, %s, %s]"
					if i == #value.animations then
						anim = anim .. "\n"
					else
						anim = anim .. ",\n"
					end

					local name = v[1]
					local prefix = v[2]
					local indices = buildArray(v[3])
					local fps = v[4]
					local loop = tostring(v[5])
					local offsets = buildArray(v[6])

					anim = string.format(anim, name, prefix, indices, fps, loop, offsets)
					result = result .. anim
				end
				result = result .. "\t],\n"
			else
				result = result .. "],\n"
			end
		end
		if value.position ~= nil then
			result = result .. "\t\"position\": " .. buildArray({value.position.x, value.position.y}) .. ",\n"
		end
		if value.camera_points ~= nil then
			result = result ..
				"\t\"camera_points\": " .. buildArray({value.camera_points.x, value.camera_points.y}) .. ",\n"
		end
		if value.flip_x ~= nil then
			result = result .. "\t\"flip_x\": " .. tostring(value.flip_x) .. ",\n"
		end
		if value.icon ~= nil then
			result = result .. "\t\"icon\": \"" .. tostring(value.icon) .. "\",\n"
		end
		if value.color ~= nil then
			result = result .. "\t\"color\": \"" .. tostring(value.color) .. "\",\n"
		end
		if value.sprite ~= nil then
			result = result .. "\t\"sprite\": \"" .. tostring(value.sprite) .. "\",\n"
		end
		if value.antialiasing ~= nil then
			result = result .. "\t\"antialiasing\": " .. tostring(value.antialiasing) .. ",\n"
		end
		if value.sing_duration ~= nil then
			result = result .. "\t\"sing_duration\": " .. tostring(value.sing_duration) .. ",\n"
		end
		if value.scale ~= nil then
			result = result .. "\t\"scale\": " .. tostring(value.scale) .. "\n"
		end
		result = result .. "}"
	end
	return result
end

return JSONBuilder
