local PATH = (...):match("(.-)[^%.]+$")
local dirPATH = PATH:gsub("%.","/") -- for thread.lua to be read as a file
--[[
  AppleCake Profiling for Love2D
  https://github.com/EngineerSmith/AppleCake
  Docs can be found in the README.md
  License is MIT, details can be found in the LICENSE file

  Written by https://github.com/EngineerSmith or 
  EngineerSmith#4628 on Discord

  You can view the profiling data visually by going to 
  chrome:\\tracing and dropping in the json created.
  Check README.md#Viewing-AppleCake for more details
]]

local lt = love.thread or require("love.thread")

local threadConfig = require(PATH.."threadConfig")
local info = lt.getChannel(threadConfig.infoID)

local _err= error
local error = function(msg)
  _err("Error thrown by AppleCake: "..tostring(msg))
end

local isActive -- Used to return the same table as first requested
local threadStartIndex -- Used for sorting the thread; sorts by thread started

local function setActiveMode(active)
  if isActive == nil then
    info:performAtomic(function()
        local i = info:pop()
        if i then
          isActive = i.active
          threadStartIndex = i.threadIndex
        else
          if active == nil then
            active = true
          end
          isActive = active
          threadStartIndex = 0
        end
        info:push({ active = isActive, threadIndex = threadStartIndex + 1})
      end)
  end
end

local AppleCakeEnableLevels = {
  ["none"]     = 0,
  ["profiles"] = 1,
  ["mark"]     = 2,
  ["counter"]  = 4,
  ["all"]      = 7,
}

local emptyFunc = function() end
local emptyProfile = {stop=emptyFunc, args={}}
local emptyCounter = { }

local AppleCakeRelease = {
  isDebug       = false, -- Deprecated
  isActive      = true,  -- Replaced isDebug
  enableLevels  = AppleCakeEnableLevels,
  beginSession  = emptyFunc,
  endSession    = emptyFunc,
  enabled       = emptyFunc,
  profile       = function() return emptyProfile end,
  stopProfile   = emptyFunc,
  profileFunc   = function() return emptyProfile end,
  mark          = emptyFunc,
  counter       = function() return emptyCounter end,
  countMemory   = function() return emptyCounter end,
  setName       = emptyFunc,
  setThreadName = emptyFunc,
  setThreadSortIndex = emptyFunc,
  -- Added for those who want to convert from jprof
  jprof = {
      push     = emptyFunc,
      pop      = emptyFunc,
      popAll   = emptyFunc,
      write    = emptyFunc,
      enabled  = emptyFunc,
      connect  = emptyFunc,
      netFlush = emptyFunc,
    },
  -- Deprecated
  markMemory   = emptyFunc,
  _stopProfile = emptyFunc,
}

local AppleCake

return function(active)
  setActiveMode(active)
  if not isActive then
    return AppleCakeRelease
  end
  if AppleCake then -- return appleCake if it's already been made
    return AppleCake
  end
  
  AppleCake = {
    isDebug       = false, -- Deprecated
    isActive      = true,  -- Replaced isDebug
    enableLevels = AppleCakeEnableLevels,
  }
  
  local threadID = threadStartIndex
  local commandTbl = { threadID }
  
  if not love.timer then
    require("love.timer")
  end
  local _getTime = love.timer.getTime
  local getTime = function() -- Return time in microseconds
    return _getTime() * 1e+6
  end
  
  local thread
  local outStream = love.thread.getChannel(threadConfig.outStreamID)
  
  local useBuffer, buffer = pcall(require, "string.buffer") -- Added in love11.4, jit2.1
  local buf_enc, _options
  if useBuffer then
    _options = { dict = threadConfig.dict }
    buf_enc = buffer.new(_options)
    buffer = nil
  end
  
  local bufferMode = false -- set with AppleCake.setBuffer
  local commandBuffer, commandBufferIndex = { buffer = true }, 1
  
  local pushCommand = function(command, arg, force)
    commandTbl.command = command
    commandTbl[2] = arg
    if not bufferMode or force then
      if useBuffer then
        outStream:push(buf_enc:reset():encode(commandTbl):get())
      else
        outStream:push(commandTbl)
      end
    else -- useBuffer must be true
      commandBuffer[commandBufferIndex] = buf_enc:reset():encode(commandTbl):get() 
      commandBufferIndex = commandBufferIndex + 1
    end
    commandTbl[2] = nil
  end
  
  AppleCake.beginSession = function(filepath, name)
    if thread then
      AppleCake.endSession()
    else
      thread = lt.newThread(dirPATH.."thread.lua")
    end
    pushCommand("open", filepath, true)
    thread:start(PATH, threadID)
    if not name then
      name = love.filesystem.getIdentity()
    end
    AppleCake.setName(name)
    AppleCake.setThreadSortIndex(threadStartIndex)
  end
  
  AppleCake.endSession = function()
    if thread and thread:isRunning() then
      AppleCake.flush()
      pushCommand("close", nil, true)
      thread:wait()
    elseif not thread then
      error("The session can only be closed within the thread that started it.")
    end
  end
  
  AppleCake.setBuffer = function(enabled)
    AppleCake.flush()
    bufferMode = enabled == true
    if bufferMode and not useBuffer then
      error("You can only use the buffer in Love11.4+, jit2.1. If you're using a package manager, sometimes it doesn't include the correct version of jit and you should use the appImage.")
    end
  end
  
  AppleCake.flush = function()
    if commandBufferIndex ~= 1 then
      outStream:push(buf_enc:reset():encode(commandBuffer):get())
      commandBuffer, commandBufferIndex = { buffer = true }, 1
    end
  end
  
  local profileEnabled = true
  local markEnabled    = true
  local counterEnabled = true
  --[[ Disable logging in an area of code e.g.
    AppleCake.enable(AppleCake.enableLevels["none"])
    AppleCake.enable(AppleCake.enableLevels["all"])
    -- only allow profiling and marks, disable counters
      AppleCake.enable(AppleCake.enableLevels["profile"] + AppleCake.enableLevels["mark"])
      AppleCake.enable(AppleCake.enableLevels["all"] - AppleCake.enableLevels["counters"])
    -- Following also works:
      AppleCake.enable("none")
      AppleCake.enable("all")
    
     -- Note, it's better to use require("libs.appleCake")(false) to stop logging all together.
              This is useful for temp disabling in a section of code
  ]]
  AppleCake.enable = function(level)
    if type(level) ~= "number" then
      level = level and level:lower() or "all"
      level = AppleCakeEnableLevels[level] or AppleCakeEnableLevels["all"]
    end
    
    profileEnabled = level/AppleCakeEnableLevels["profile"] % 2 == 1
    markEnabled    = level/AppleCakeEnableLevels["mark"] % 2 == 1
    counterEnabled = level/AppleCakeEnableLevels["counter"] % 2 == 1
  end
  
  -- Profile a section of code
  AppleCake.profile = function(name, args, profile)
    if not profileEnabled then return emptyProfile end
    if profile then
      profile.name = name
      profile.args = args
      profile._stopped = false
      profile.start = getTime()
      return profile
    else
      return {
          stop = AppleCake.stopProfile,
          name  = name,
          args  = args,
          start = getTime(),
        }
    end
  end
  
  AppleCake.stopProfile = function(profile)
    profile.finish = getTime()
    if not profileEnabled then return end
    if profile._stopped then
      error("Attempted to stop and write profile more than once. If attempting to reuse profile, ensure it is passed back into the function which created it to reset it's use")
    end
    profile.stop = nil -- Can't push functions
    profile._stopped = nil -- decrease number of fields
    
    pushCommand("writeProfile", profile)
    
    profile.stop = AppleCake.stopProfile
    profile._stopped = true
  end
  
  -- Profile time taken within a function
  AppleCake.profileFunc = function(args, profile)
    if not profileEnabled then return emptyProfile end
    if profile then
      return AppleCake.profile(profile.name, args, profile)
    end
    local info = debug.getinfo(2, "fnS")
    if info then
      local name
      if info.name then
        name = info.name
      elseif info.func then -- Attempt to create a name from memory address
        name = tostring(info.func):sub(10)
      else
        error("Could not generate name for this function")
      end
      if info.short_src then
          name = name.."@"..info.short_src..(info.linedefined and "#"..info.linedefined or "")
      end
      return AppleCake.profile(name, args)
    end
  end
  
  -- Mark an event at a point in time
    -- Scope: "p": process, make a line across the entire process
    --        "t": thread, make a line across the current thread
  AppleCake.mark = function(name, scope, args)
    if not markEnabled then return end
    if scope == nil or (scope ~= "p" and scope ~= "t") then
      scope = "p"
    end
    pushCommand("writeMark", {
        name  = name,
        args  = args,
        scope = scope,
        start = getTime(),
      })
  end
  
  -- Track variable over time
  AppleCake.counter = function(name, args, counter)
    if not counterEnabled then return end
    if counter then
      counter.name  = name
      counter.args  = args
      counter.start = getTime()
    else
      counter = {
          name  = name,
          args  = args,
          start = getTime(),
        }
    end
    pushCommand("writeCounter", counter)
    return counter
  end
  
  local memArg, mem = { }, nil
  AppleCake.countMemory = function(option)
    if not counterEnabled then return end
    if option == "megabyte" then
      memArg.megabytes = collectgarbage("count")/1024
    elseif option == "byte" then
      memArg.bytes = collectgarbage("count")*1024
    else --kilobyte
      memArg.kilobytes = collectgarbage("count")
    end
    mem = AppleCake.counter("Memory usage", memArg, mem)
  end
  
  -- Set the name of the process, usually your projects name, or identity
  AppleCake.setName = function(name)
    if type(name) == "string" then
      pushCommand("writeMetadata", {
          process_name = name,
          thread_name  = name,
        }, true)
    end
  end
  
  AppleCake.setThreadName = function(name)
    if type(name) == "string" then
      pushCommand("writeMetadata", {
          thread_name = name,
        }, true)
    end
  end
  
  -- By default this is the order the threads are created
  AppleCake.setThreadSortIndex = function(index)
    if type(index) == "number" then
      assert(index >= 0, "Given index must be greater than or equal to 0")
      pushCommand("writeMetadata", {
          thread_sort_index = index,
        }, true)
    end
  end
  
  -- jprof functions to allow others to easily intergate profiling into thier already jprof filled code
  AppleCake.jprof = { }
  local jprof = AppleCake.jprof
  
  -- Custom functions
  -- NOTE: You must at least call appleCake.beginSession() or jprof.START() otherwise it will not be able to write out using these functions
  jprof.START = AppleCake.beginSession
  
  jprof.COUNTMEMORY = AppleCake.countMemory -- function to count memory, as we don't do it in push
  
  -- classic jprof functions
  local stack, anno = { }, { }
  jprof.push = function(name, annotation)
    anno[1] = annotation -- to avoid creating a new table for each annotation
    table.insert(stack, AppleCake.profile(name, anno, stack[name]))
  end
  
  jprof.pop = function(name)
    local head = stack[#stack]
    if name then
      assert(name == head.name, ("(appleCake.jprof) Top of zone stack, does not match the zone passed to appleCake.jprof.pop ('%s', on top: '%s')!"):format(name, stack[#stack])) -- Error message taken from jprof
    end
    head:stop()
    stack[#stack] = nil
  end
  
  jprof.popAll = function()
    for i=#stack, 1, -1 do
      if not stack[i]._stopped then
        stack[i]:stop()
      end
    end
    stack = { }
  end
  
  jprof.write = AppleCake.beginSession -- will wait for previous session to close, before reopening
  
  jprof.enabled = function(enabled)
    AppleCake.enable(enabled and AppleCakeEnableLevels["all"] or AppleCakeEnableLevels["none"])
  end
  
  local notSupported = function() error("Sorry this function is not supported in AppleCake right now") end
  
  jprof.connect  = notSupported
  jprof.netFlush = notSupported
  
  --[[ Deprecated functions ]]
  
  -- _stopProfile deprecated with stopProfile
  AppleCake._stopProfile = AppleCake.stopProfile
  
  -- markMemory deprecated with countMemory
  AppleCake.markMemory = AppleCake.countMemory
  
  return AppleCake
end