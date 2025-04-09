-- vim: st=4 sts=4 sw=4 et:
--- Network backend using [LuaSocket](http://w3.impa.br/~diego/software/luasocket/home.html).
-- This module should be used when the LuaSocket library is available. Note
-- that the HTTPS support depends on the [LuaSec](https://github.com/brunoos/luasec)
-- library. This libary is not required for plain HTTP.
--
-- @module raven.senders.luasocket
-- @copyright 2014-2017 CloudFlare, Inc.
-- @license BSD 3-clause (see LICENSE file)

local util = require 'raven.util'
local http = require 'socket.http'
local ltn12 = require 'ltn12'

-- try to load luassl (not mandatory, so do not hard fail if the module is
-- not there
local _, https = pcall(require, 'ssl.https')

local assert = assert
local pairs = pairs
local setmetatable = setmetatable
local table_concat = table.concat
local source_string = ltn12.source.string
local table_sink = ltn12.sink.table
local parse_dsn = util.parse_dsn
local generate_auth_header = util.generate_auth_header
local _VERSION = util._VERSION
local _M = {}

local mt = {}
mt.__index = mt

function mt:send(json_str)
    local resp_buffer = {}
    local opts = {
        method = "POST",
        url = self.server,
        headers = {
            ['Content-Type'] = 'applicaion/json',
            ['User-Agent'] = "raven-lua-socket/" .. _VERSION,
            ['X-Sentry-Auth'] = generate_auth_header(self),
            ["Content-Length"] = tostring(#json_str),
        },
        source = source_string(json_str),
        sink = table_sink(resp_buffer),
    }

    -- set master opts (if any)
    if self.opts then
        for h, v in pairs(self.opts) do
            opts[h] = v
        end
    end

    local ok, code = self.factory(opts)
    if not ok then
        return nil, code
    end
    if code ~= 200 then
        return nil, table_concat(resp_buffer)
    end
    return true
end

--- Configuration table for the nginx sender.
-- @field dsn DSN string
-- @field verify_ssl Whether or not the SSL certificate is checked (boolean,
--  defaults to false)
-- @field cafile Path to a CA bundle (see the `cafile` parameter in the
--  [newcontext](https://github.com/brunoos/luasec/wiki/LuaSec-0.6#ssl_newcontext)
--  docs)
-- @table sender_conf

--- Create a new sender object for the given DSN
-- @param conf Configuration table, see @{sender_conf}
-- @return A sender object
function _M.new(conf)
    local obj, err = parse_dsn(conf.dsn)
    if not obj then
        return nil, err
    end

    if obj.protocol == 'https' then
        assert(https, 'LuaSec is required to use HTTPS transport')
        obj.factory = https.request
        obj.opts = {
            verify = conf.verify_ssl and 'peer' or 'none',
            cafile = conf.verify_ssl and conf.cafile or nil,
            protocol = 'tlsv1_2',
        }
    else
        obj.factory = http.request
    end

    return setmetatable(obj, mt)
end

return _M

