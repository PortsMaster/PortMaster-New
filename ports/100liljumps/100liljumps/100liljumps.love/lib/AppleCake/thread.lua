local _err = error
error = function(msg)
  _err("Error thrown by AppleCake Thread: "..tostring(msg))
end

local PATH, OWNER = ...
local outputStream = require(PATH.."outputStream")
local threadConfig = require(PATH.."threadConfig")

local useBuffer, buffer = pcall(require, "string.buffer") -- Added in love11.4, jit2.1
local buf_dec, _options
if useBuffer then
  _options = { dict = threadConfig.dict }
  buf_dec = buffer.new(_options)
  buffer = nil
end

local out  = love.thread.getChannel(threadConfig.outStreamID)
local info = love.thread.getChannel(threadConfig.infoID)

local updateOwner = function(channel, owner)
  local info = channel:pop()
  info.owner = owner
  channel:push(info)
end

local commands = { }

commands["open"] = function(threadID, filepath)
  if info:peek().owner == nil then
    if OWNER ~= threadID then
      error("Thread "..threadID.."tried to begin session. Only thread "..OWNER..", that created the outputStream, can begin sessions")
    end
    outputStream.open(filepath)
    info:performAtomic(updateOwner, threadID)
  end
end

commands["close"] = function(threadID)
  if OWNER ~= threadID then
    error("Thread "..threadID.." tried to end session owned by thread "..OWNER)
  end
  outputStream.close()
  info:performAtomic(updateOwner, nil)
  return true
end

commands["writeProfile"]  = outputStream.writeProfile
commands["writeMark"]     = outputStream.writeMark
commands["writeCounter"]  = outputStream.writeCounter
commands["writeMetadata"] = outputStream.writeMetadata

while true do
  local command
  if useBuffer then
    command = buf_dec:set(out:demand()):decode()
  else
    command = out:demand()
  end
  if command.buffer then
    for _, encoded in ipairs(command) do
      local decoded = buf_dec:set(encoded):decode()
      local fn = commands[decoded.command]
      if fn and fn(decoded[1], decoded[2], decoded[3]) then
        return
      end
    end
  else
    local fn = commands[command.command]
    if fn and fn(command[1], command[2], command[3]) then
      return
    end
  end
end