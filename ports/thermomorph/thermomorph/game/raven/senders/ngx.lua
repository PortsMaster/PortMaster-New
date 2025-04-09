-- vim: st=4 sts=4 sw=4 et:
--- Network backend using the [lua-nginx-module](https://github.com/openresty/lua-nginx-module) cosocket API.
-- This module can be used with the raw Lua module for nginx or the OpenResty
-- bundle.
--
-- It will require the `lua_ssl_trusted_certificate` to be set correctly when
-- reporting to a HTTPS endpoint.
--
-- @module raven.senders.ngx
-- @copyright 2014-2017 CloudFlare, Inc.
-- @license BSD 3-clause (see LICENSE file)

-- luacheck: globals ngx

local util = require 'raven.util'

local ngx_socket = ngx.socket
local ngx_get_phase = ngx.get_phase
local string_format = string.format
local table_remove = table.remove
local parse_dsn = util.parse_dsn
local generate_auth_header = util.generate_auth_header
local _VERSION = util._VERSION
local _M = {}

-- provide a more sensible implementation of the error log function
function util.errlog(...)
    ngx.log(ngx.ERR, 'raven-lua failure: ', ...)
end

-- as we don't want to use an external HTTP library, just send the HTTP request
-- directly using cosocket API
local HTTP_REQUEST = string.gsub([[POST %s HTTP/1.0
Host: %s
Connection: close
Content-Type: application/json
Content-Length: %d
User-Agent: %s
X-Sentry-Auth: %s

%s
]], '\r?\n', '\r\n')

local CALLBACK_DEFAULT_ERRMSG =
    "failed to onfigure socket (custom callback did not returned a value)"

local function send_msg(self, msg)
    local ok
    local sock, err = ngx_socket.tcp()
    if not sock then
        return nil, err
    end

    if self.configure_socket then
        ok, err = self.configure_socket(self, sock)
        if not ok then
            return nil, err or CALLBACK_DEFAULT_ERRMSG
        end
    end

    ok, err = sock:connect(self.target, self.port)
    if not ok then
        return nil, err
    end

    if self.protocol == 'https' then
        -- TODO: session resumption?
        ok, err = sock:sslhandshake(false, self.host, self.verify_ssl)
        if not ok then
            sock:close()
            return nil, err
        end
    end

    ok, err = sock:send(msg)
    if not ok then
        sock:close()
        return nil, err
    end

    local resp
    resp, err = sock:receive('*a')
    sock:close()
    if not resp then
        return nil, err
    end

    local status = resp:match("HTTP/%d%.%d (%d%d%d) %w+")
    if status ~= "200" then
        return nil, "Server response status not 200:" .. (status or "nil")
    end

    return resp:match("\r\n\r\n(.*)") or ""
end

-- async task pushing: sometimes the socket API is not available, in this case,
-- messages are pushed into a queue and sent in a timer. Only one timer at most
-- is running per instance (and per worker): timers are a scarce resource, we
-- don't want to exhaust the timer pool during message storms.
--
-- TODO: expose an option on the ctor to always use this? it might be desirable
-- to not slow down hot code sections by sending messages

local function send_task(premature, self)
    if premature then
        return
    end

    local ok, err = xpcall(function()
        local send_queue = self.send_queue
        while #send_queue > 0 do
            local msg = send_queue[1]
            -- do not remove the message yet as an empty queue is the signal to
            -- re-start the task
            local ok, err = send_msg(self, msg)
            if not ok then
                ngx.log(ngx.ERR, 'raven: failed to send message asyncronously: ',
                    err, '. Drop the message.')
            end
            table_remove(send_queue, 1)
        end
    end, debug.traceback)

    if not ok then
        ngx.log(ngx.ERR, 'raven: failed to run the async sender task: ', err)
        -- TODO: restart the task here? requires a extra counter as we don't want
        -- to fail in loop indefinitely.
    end
    self.task_running = false
end


local mt = {}
mt.__index = mt

function mt:send(json_str)
    local auth = generate_auth_header(self)
    local msg = string_format(HTTP_REQUEST, self.request_uri, self.host, #json_str,
        "raven-lua-ngx/" .. _VERSION, auth, json_str)
    local phase = ngx_get_phase()
    -- rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
    if phase == 'rewrite' or
        phase == 'access' or
        phase == 'content' or
        phase == 'content' or
        phase == 'timer' or
        phase == 'ssl_cert' or
        phase == 'ssl_session_fetch'
    then
        -- socket is available
        return send_msg(self, msg)
    else
        -- cannot use socket: push the message in the async queue
        local send_queue = self.send_queue
        local queue_size = #send_queue
        if queue_size <= self.queue_limit then
            send_queue[queue_size + 1] = msg
            if not self.task_running then
                local ok, err = ngx.timer.at(0, send_task, self)
                if not ok then
                    return nil, 'failed to schedule async sender task: ' .. err
                end

                -- assume the task is already running, as other messages might
                -- be reported before it is actually scheduled and run.
                self.task_running = true
            end
        else
            return nil, 'failed to send message asyncronously: queue is full'
        end
        return true
    end
end

--- Configuration table for the nginx sender.
-- @field dsn DSN string
-- @field verify_ssl Whether or not the SSL certificate is checked (boolean,
--  defaults to false)
-- @field configure_socket Callback used to configure the created socket (e.g.
--  adjusting the timeout). Called with the sender object and socket as arguments.
--  Must return `true` or `nil, error_message`.
-- @field queue_limit Maximum number of message in the asynchronous sending queue
--  (default: 50)
-- @table sender_conf

--- Create a new sender object for the given DSN
-- @param conf Configuration table, see @{sender_conf}
-- @return A sender object
function _M.new(conf)
    local obj, err = parse_dsn(conf.dsn)
    if not obj then
        return nil, err
    end

    obj.target = conf.target or obj.host
    obj.verify_ssl = conf.verify_ssl
    obj.configure_socket = conf.configure_socket
    obj.queue_limit = conf.queue_limit or 50
    obj.send_queue = {}
    obj.task_running = false

    return setmetatable(obj, mt)
end

--- Returns the value of the `server_name` variable if possible.
-- Otherwise (wrong phase), this will return "undefined".
--
-- It is intended to be used as a `get_server_name` override on the main raven
-- instance.
--
-- @usage
-- local raven_ngx = require("raven.senders.ngx")
-- local rvn = raven.new(...)
-- rvn.get_server_name = raven_ngx.get_server_name
function _M.get_server_name()
    local phase = ngx.get_phase()
    -- the ngx.var.* API is not available in all contexts
    if phase == "set" or
        phase == "rewrite" or
        phase == "access" or
        phase == "content" or
        phase == "header_filter" or
        phase == "body_filter" or
        phase == "log"
    then
        return ngx.var.server_name
    end
    return "undefined"
end

return _M
