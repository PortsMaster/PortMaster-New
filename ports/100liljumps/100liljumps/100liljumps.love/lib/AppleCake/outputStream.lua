local outputStream = { }

local lfs = love.filesystem or require("love.filesystem")
local insert, concat = table.insert, table.concat

local stream
local flush

outputStream.open = function(filepath)
  if stream then
    outputStream.close()
  end
  filepath = filepath or "profile.json"
  local errorMessage
  local major = love.getVersion()
  if major == 12 and lfs.openFile then
    stream, errorMessage = lfs.openFile(filepath, "w")
  else
    stream, errorMessage = lfs.newFile(filepath, "w")
  end
  if not stream then
    error("Could not open file("..tostring(filepath)..")for writing")
  end
  flush = stream:setBuffer("none")
  stream:write("[")
end

local shouldPushBack = false

outputStream.close = function(filepath)
  if not stream then
    return
  end
  stream:write("]")
  stream:close()
  stream = nil
  shouldPushBack = false
end

local pushBack = function()
  if shouldPushBack then
    stream:write(",")
  end
  shouldPushBack = true
end

local writeJsonArray
writeJsonArray = function(tbl)
  local str = { "{" }
  for k, v in pairs(tbl) do
    insert(str, ([["%s":]]):format(tostring(k)))
    local t = type(v)
    if t == "table" then
      insert(str, writeJsonArray(v))
    elseif t == "number" then
      insert(str, tostring(v))
    elseif t == "userdata" and v:typeOf("Data") then
      insert(str, ([["%s"]]):format(v:getString()))
    elseif t ~= "userdata" then
      insert(str, ([["%s"]]):format(tostring(v)))
    end
    insert(str, ",")
  end
  if #str == 1 then -- if none added
    return "{}"
  end
  str[#str] = "}"
  return concat(str)
end

outputStream.writeProfile = function(threadID, profile)
  if not stream then
    error("No file opened")
  end
  pushBack()
  stream:write(([[{"dur":%d,"name":"%s","ph":"X","pid":0,"tid":%d,"ts":%d]]):format(profile.finish-profile.start, profile.name:gsub('"','\"'), threadID, profile.start))
  if profile.args then
    stream:write([[,"args":]])
    stream:write(writeJsonArray(profile.args))
  end
  stream:write("}")
  if flush then
    stream:flush()
  end
end

outputStream.writeMark = function(threadID, mark)
  if not stream then
    error("No file opened")
  end
  pushBack()
  stream:write(([[{"name":"%s","ph":"i","pid":0,"tid":%d,"s":"%s","ts":%d]]):format(mark.name:gsub('"', '\"'), threadID, mark.scope, mark.start))
  if mark.args then
    stream:write([[,"args":]])
    stream:write(writeJsonArray(mark.args))
  end
  stream:write("}")
  if flush then
    stream:flush()
  end
end

outputStream.writeCounter = function(threadID, counter)
  if not stream then
    error("No file opened")
  end
  pushBack()
  stream:write(([[{"name":"%s","ph":"C","pid":0,"tid":%d,"ts":%d]]):format(counter.name, threadID, counter.start))
  if counter.args then
    stream:write([[,"args":]])
    stream:write(writeJsonArray(counter.args))
  end
  stream:write("}")
  if flush then
    stream:flush()
  end
end

local jsonMetadata = function(threadID, type, arg)
  if type == "process_name" or type == "thread_name" then
    stream:write(([[{"name":"%s","ph":"M","pid":0,"tid":%d,"args":{"name":"%s"}}]]):format(type, threadID, arg))
  elseif type == "thread_sort_index" then
    stream:write(([[{"name":"%s","ph":"M","pid":0,"tid":%d,"args":{"sort_index":%d}}]]):format(type, threadID, arg))
  end
end

outputStream.writeMetadata = function(threadID, metadata)
  if not stream then
    error("No file opened")
  end
  pushBack()
  local pb = false
  for key, name in pairs(metadata) do -- Supported; process_name, thread_name, thread_sort_index
    if pb then pushBack() end
    jsonMetadata(threadID, key, name)
    if flush then
      stream:flush()
    end
    pb = true
  end
end

return outputStream