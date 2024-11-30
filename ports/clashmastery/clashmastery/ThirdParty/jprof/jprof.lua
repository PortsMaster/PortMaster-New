-- https://github.com/pfirsich/jprof

_prefix = (...):match("(.+%.)[^%.]+$") or ""
-- we need to make sure we have our own instance, so we can adjust settings
local msgpack_old = package.loaded["MessagePack"]
package.loaded["MessagePack"] = nil
local msgpack = require(_prefix .."MessagePack")
package.loaded["MessagePack"] = msgpack_old

-- We need to make sure the number format is "double", so our timestamps have enough accuracy.
-- NOTE: It might be possible to subtract the first timestamp from all others
-- and gain a bunch of significant digits, but we probably want about 0.01ms accuracy
-- which corresponds to 1e-5 s. With ~7 significant digits in single precision floats,
-- our accuracy might suffer already at about 100 seconds, so we go with double
msgpack.set_number("double")

local profiler = {}

-- the zonestack is just for catching errors made using push/pop
-- we preallocate 16 elements here (tested in interactive luajit interpreter v2.0.5)
-- we do this, so table.insert/table.remove does have no (non-constant) impact on
-- the memory consumption we determine using collectgarbage("count"))
-- since no allocations/deallocations are triggered by them anymore
local zoneStack = {nil, nil, nil, nil, nil, nil, nil, nil,
                   nil, nil, nil, nil, nil, nil, nil, nil}
local profData = {}
local netBuffer = nil
local profEnabled = true
-- profMem keeps track of the amount of memory allocated by prof.push/prof.pop
-- which is then subtracted from collectgarbage("count"),
-- to measure the jprof-less (i.e. "real") memory consumption
local profMem = 0

local function getByte(n, byte)
    return bit.rshift(bit.band(n, bit.lshift(0xff, 8*byte)), 8*byte)
end

-- I need this function (and not just msgpack.pack), so I can pack and write
-- the file in chunks. If we attempt to pack a big table, the amount of memory
-- used during packing can exceed the luajit memory limit pretty quickly, which will
-- terminate the program before the file is written.
local function msgpackListIntoFile(list, file)
    local n = #list
    -- https://github.com/msgpack/msgpack/blob/master/spec.md#array-format-family
    if n < 16 then
        file:write(string.char(144 + n))
    elseif n < 0xFFFF then
        file:write(string.char(0xDC, getByte(n, 1), getByte(n, 0)))
    elseif n < 0xFFffFFff then
        file:write(string.char(0xDD, getByte(n, 3), getByte(n, 2), getByte(n, 1), getByte(n, 0)))
    else
        error("List too big")
    end
    for _, elem in ipairs(list) do
        file:write(msgpack.pack(elem))
    end
end

local function addEvent(name, memCount, annot)
    local event = {name, love.timer.getTime(), memCount, annot}
    if profData then
        table.insert(profData, event)
    end
    if netBuffer then
        table.insert(netBuffer, event)
    end
end

if PROF_CAPTURE then
    function profiler.push(name, annotation)
        if not profEnabled then return end

        if #zoneStack == 0 then
            assert(name == "frame", "(jprof) You may only push the 'frame' zone onto an empty stack")
        end

        local memCount = collectgarbage("count")
        table.insert(zoneStack, name)
        addEvent(name, memCount - profMem, annotation)

        -- Usually keeping count of the memory used by jprof is easy, but when realtime profiling is used
        -- netFlush also frees memory for garbage collection, which might happen at unknown points in time
        -- therefore the memory measured is slightly less accurate when realtime profiling is used
        -- if the full profiling data is not saved to profData, then only netBuffer will increase the
        -- memory used by jprof and all of it will be freed for garbage collection at some point, so that
        -- we should probably not try to keep track of it at all
        if profData then
            profMem = profMem + (collectgarbage("count") - memCount)
        end
    end

    function profiler.pop(name)
        if not profEnabled then return end

        if name then
            assert(zoneStack[#zoneStack] == name,
                ("(jprof) Top of zone stack, does not match the zone passed to prof.pop ('%s', on top: '%s')!"):format(name, zoneStack[#zoneStack]))
        end

        local memCount = collectgarbage("count")
        table.remove(zoneStack)
        addEvent("pop", memCount - profMem)
        if profiler.socket and #zoneStack == 0 then
            profiler.netFlush()
        end
        if profData then
            profMem = profMem + (collectgarbage("count") - memCount)
        end
    end

    function profiler.popAll()
        for i = #zoneStack, 1, -1 do
            profiler.pop(zoneStack[i])
        end
    end

    function profiler.write(filename)
        assert(#zoneStack == 0, "(jprof) Zone stack is not empty")

        if not profData then
            print("(jprof) No profiling data saved (probably because you called prof.connect())")
        else
            local file, msg = love.filesystem.newFile(filename, "w")
            assert(file, msg)
            msgpackListIntoFile(profData, file)
            file:close()
            print(("(jprof) Saved profiling data to '%s'"):format(filename))
        end
    end

    function profiler.enabled(enabled)
        profEnabled = enabled
    end

    function profiler.connect(saveFullProfData, port, address)
        local socket = require("socket")

        local sock, err = socket.tcp()
        if sock then
            profiler.socket = sock
        else
            print("(jprof) Could not create socket:", err)
            return
        end

        local status = profiler.socket:setoption("tcp-nodelay", true)
        if not status then
            print("(jprof) Could not set socket option.")
        end

        local status, err = profiler.socket:connect(address or "localhost", port or 1338)
        if status then
            print("(jprof) Connected to viewer.")
        else
            print("(jprof) Error connecting to viewer:", err)
            profiler.socket = nil
            return
        end

        netBuffer = {}
        if not saveFullProfData then
            profData = nil
        end
    end

    function profiler.netFlush()
        if profiler.socket and #netBuffer > 0 then
            -- This should be small enough to not make trouble
            -- (nothing like msgpackListIntoFile needed)
            local data = msgpack.pack(netBuffer)
            local len = data:len()
            assert(len < 0xFFffFFff)
            local header = string.char(getByte(len, 3), getByte(len, 2), getByte(len, 1), getByte(len, 0))
            local num, err = profiler.socket:send(header .. data)
            if not num then
                if err == "closed" then
                    print("(jprof) Connection to viewer closed.")
                    profiler.socket = nil
                    netBuffer = nil
                    return
                else
                    print("(jprof) Error sending data:", err)
                end
            end
            netBuffer = {}
        end
    end
else
    local noop = function() end

    profiler.push = noop
    profiler.pop = noop
    profiler.write = noop
    profiler.enabled = noop
    profiler.connect = noop
    profiler.netFlush = noop
end

return profiler