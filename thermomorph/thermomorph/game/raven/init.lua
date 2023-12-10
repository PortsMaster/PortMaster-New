-- vim: st=4 sts=4 sw=4 et:
--- Main Sentry reporting module.
-- This module contains the core of the reporting logic, it still depends on a
-- network layer to actually send the data to the Sentry server.
--
-- @module raven
-- @copyright 2014-2017 CloudFlare, Inc.
-- @license BSD 3-clause (see LICENSE file)

local util = require 'raven.util'
local cjson = require 'external.json'

local _M = {}
_M._VERSION = util._VERSION

local debug_getinfo = debug.getinfo
local table_insert = table.insert
local unpack = unpack or table.unpack -- luacheck: ignore
local generate_event_id = util.generate_event_id
local iso8601 = util.iso8601
local json_encode = cjson.encode
local errlog = util.errlog

local catcher_trace_level = 4

--- Table describing main Sentry client settings.
-- @field sender Object used to send message, see `rave.senders.*` modules to
--  find a sender suitable with your application
-- @field level  Set the message level (string), defaults to `"error"`
-- @field logger Sets the message logger (string), defaults to `"root"`
-- @field tags   Defaults tags for sent messages, defaults to `{}`. Example:
--  `{ "foo"="bar", ... }`
-- @field extra  Default extra data sent with messages, defaults to `{}`
-- @table sentry_conf

local raven_mt = { }
raven_mt.__index = raven_mt

--- Create a new Sentry client.
-- It takes a @{sentry_conf} table tune its behavior.
-- @param conf client configuration.
-- @return     a new raven instance
-- @usage
-- local raven = require "raven"
-- local rvn = raven.new {
--    sender = require("raven.senders.luasocket").new {
--       dsn = "http://pub:secret@127.0.0.1:8080/sentry/proj-id",
--    },
--    tags = { foo = "bar", abc = "def" },
--    logger = "foo",
-- }
function _M.new(conf)
    local obj = {
        sender = assert(conf.sender, "sender is required"),
        level = conf.level or "error",
        logger = conf.logger or "root",
        tags = conf.tags or nil,
        user = conf.user or nil,
        extra = conf.extra or nil,
    }

    return setmetatable(obj, raven_mt)
end

--- This method is reponsible to return the `server_name` field.
-- The default implementation just returns `"undefined"`, users are encouraged
-- to override this to something more sensible.
function _M.get_server_name()
    return "undefined"
end

local function backtrace(level)
    local frames = {}

    level = level + 1

    while true do
        local info = debug_getinfo(level, "Snl")
        if not info then
            break
        end

        table_insert(frames, 1, {
            filename = info.short_src,
            ["function"] = info.name,
            lineno = info.currentline,
        })

        level = level + 1
    end
    return { frames = frames }
end

--- This table can be used to tune the message reporting.
-- @field tags Tags for the message, they will be coalesced with the ones
--  provided in the @{sentry_conf} table used in the constructor if any. In
--  case of conflict, the message tags have precedence.
--
-- @field extra Extra data for the message. Like tags, data is merged with
--  the extra data passed to the constructor.
--
-- @field trace_level Starting stack level for the report (can be used to skip
--  useless frames. The internal raven frames are automatically skipped, so a
--  level of `1` is means that the direct caller will be reported as culprit.
--
-- @table report_conf


--- A Raven client instance is responsible to collect events and send them
-- using the associated sender object.
-- @type Raven

--- Send an exception to Sentry.
-- See [reference](https://docs.sentry.io/clientdev/interfaces/exception/).
-- Note that the stack trace will be filled automatically.
--
-- Note that the `conf` table will be modified by the function, therefore it
-- is not safe to reuse conf table across calls. Consider passing common
-- attributes to the client constructor instead.
--
-- @function Raven:captureException
-- @param exception  a table describing the exception conforming to the Sentry
--  format described in the reference docs
-- @param conf       capture configuration table, see @{report_conf}
-- @return           On success, return event id. If not success, return nil and
--  an error string.
-- @usage
-- local rvn = ravennew(...)
-- local exception = { { -- beware, exceptions are arrays
--    type = "SyntaxError",
--    value = "Wattttt!",
--    module = "mymodule",
--    -- stacktrace is populated automatically
-- } }
-- local id, err = rvn:captureException(exception,
--     { tags = { foo = "bar", abc = "def" }})
function raven_mt:captureException(exception, conf)
    local trace_level
    if not conf then
        conf = { trace_level = 2 }
    elseif not conf.trace_level then
        conf.trace_level = 2
    else
        conf.trace_level = conf.trace_level + 1
    end

    trace_level = conf.trace_level
    exception[1].stacktrace = backtrace(trace_level)

    local payload = {
        exception = exception,
        message = exception[1].value,
        culprit = self:get_culprit(trace_level),
    }

    -- because whether tail call will or will not appear in the stack back trace
    -- is different between PUC-lua or LuaJIT, so just avoid tail call
    local id, err = self:send_report(payload, conf)
    return id, err
end

--- Send a message to Sentry.
-- See [reference](https://docs.sentry.io/clientdev/interfaces/message/).
--
-- Note that the `conf` table will be modified by the function, therefore it
-- is not safe to reuse conf table across calls. Consider passing common
-- attributes to the client constructor instead.
--
-- @function Raven:captureMessage
-- @param message the message, usually a raw string
-- @param conf    capture configuration table, see @{report_conf}
-- @return        On success, return event id. If not success, return nil and
--  an error string.
-- @usage
-- local rvn = ravennew(...)
-- local id, err = rvn:captureMessage("simple message",
--     { tags = { foo = "bar", abc = "def" }})
function raven_mt:captureMessage(message, conf)
    if not conf then
        conf = { trace_level = 2 }
    elseif not conf.trace_level then
        conf.trace_level = 2
    else
        conf.trace_level = conf.trace_level + 1
    end

    local payload = {
        message = message,
        culprit = self:get_culprit(conf.trace_level),
    }

    local id, err = self:send_report(payload, conf)
    return id, err
end

--- Alias of @{Raven:captureException}.
-- @function Raven:capture_exception
raven_mt.capture_exception = raven_mt.captureException

--- Ailas of @{Raven:captureMessage}.
-- @function Raven:capture_message
raven_mt.capture_message = raven_mt.captureMessage

local function merge_tables(msg, root)
    if not root then
        return msg
    elseif not msg then
        return root
    end

    -- both table exist, merge root into msg
    for k, v in pairs(root) do
        msg[k] = msg[k] or v
    end
    return msg
end

--- Send directly a report to Sentry.
-- This is an internal function, you should not call it directly, use
-- @{Raven:captureException} or @{Raven:captureMessage} instead.
--
-- Note that the `conf` table will be modified by the function, therefore it
-- is not safe to reuse conf table across calls. Consider passing common
-- attributes to the client constructor instead.
--
-- @function Raven:send_report
-- @param json table to be sent. Don't need to fill `event_id`, `timestamp`,
--  `tags` and `level`.
-- @param conf capture configuration table, see @{report_conf}
-- @return On success, return event id. If not success, return nil and an
--  error string.
function raven_mt:send_report(json, conf)
    local event_id = generate_event_id()

    if not json then
        json = self.json
        if not json then
            return
        end
    end

    json.event_id  = event_id
    json.timestamp = iso8601()
    json.level     = self.level
    json.platform  = "lua"
    json.logger    = self.logger
    json.user      = self.user

    if conf then
        json.tags = merge_tables(conf.tags, self.tags)
        json.extra = merge_tables(conf.extra, self.extra)

        if conf.level then
            json.level = conf.level
        end
    else
        json.tags = self.tags
        json.extra = self.extra
    end

    json.server_name = nil

    local json_str = json_encode(json)
    local ok, err = self.sender:send(json_str)

    if not ok then
        errlog("Failed to send to Sentry: ", err, " ",  json_str)
        return nil, err
    end
    return json.event_id
end

-- Get culprit using given level
function raven_mt:get_culprit(level) -- luacheck: ignore self
    local culprit

    level = level + 1
    local info = debug_getinfo(level, "Snl")
    if info.name then
        culprit = info.name
    else
        culprit = info.short_src .. ":" .. info.linedefined
    end
    return culprit
end

-- catcher: used to catch an error from xpcall.
function raven_mt:catcher(err)
    if debug then
        errlog("catch: ", err)
    end

    return {
        message = err,
        culprit = self:get_culprit(catcher_trace_level),
        exception = { {
            value = err,
            stacktrace = backtrace(catcher_trace_level),
        } },
    }
end

--- Call given function and report any errors to Sentry.
-- @function Raven:call
-- @param f     function to be called
-- @param ...   function's arguments
-- @return      the same as @{xpcall}
-- @usage
-- function func(a, b, c)
--     return a * b + c
-- end
-- return rvn:call(func, 1, 'foo', true)
function raven_mt:call(f, ...)
    -- When used with ngx_lua, connecting a tcp socket in xpcall error handler
    -- will cause a "yield across C-call boundary" error. To avoid this, we
    -- move all the network operations outside of the xpcall error handler.
    local json_exception
    local res = { xpcall(f,
        function (err)
            local ok
            ok, json_exception = pcall(self.catcher, self, err)
            if not ok then
                -- when failed, json_exception is error message
                errlog(json_exception)
            end
            return err
        end,
        ...) }
    if json_exception then
        self:send_report(json_exception)
    end

    return unpack(res)
end

-- This metatable is associated with returned error object so the original
-- error message is returned when tostring is invoked on it. This allows to use
-- the error objects for logging purposes as well. This is mostly a workaround
-- of xpcall error handlers having a single result.
local err_mt = {
    __tostring = function(self)
        return self.message
    end,
}

--- Return a error handler function to be used with @{xpcall}
-- This is a high performance version of the @{call} method, but it demands
-- some more work to be used. It return a function that will turn a Lua error
-- into a Sentry exception table. It is meant to be used as a @{xpcall} error
-- hander.
--
-- The error handler returns that table, the should then be sent with the
-- @{send_report} method when appropriate. This cannot be easily done in the
-- error handler itself as Lua disallow yielding form an error handler.
--
-- It has better performance than @{call} because it avoid creating temporary
-- objects at each invocation.
--
-- Note that the error table generated by the handler has a `__tostring`
-- metamethod returning the original error message for logging purposes.
--
-- @function Raven:gen_capture_err
-- @usage
-- local handler = rvn:gen_capture_err()
-- local ok, err = xpcall(function() error("boom") end, handler)
-- if not ok then
--    rvn:send_report(err, { tags = { "foo"="bar" } })
-- end
function raven_mt:gen_capture_err()
    return function (err)
        local ok, json_exception = pcall(self.catcher, self, err)
        if not ok then
            -- when failed, json_exception is error message
            errlog('failed to run exception catcher: ' .. tostring(json_exception))
            -- try to return something anyway (error message with no culprit and
            -- no stacktrace
            json_exception = {
                message = err,
                culprit = '???',
                exception = { { value=err } },
            }
        end
        return setmetatable(json_exception, err_mt)
    end
end

return _M
