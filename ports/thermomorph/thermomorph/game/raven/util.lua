-- vim: st=4 sts=4 sw=4 et:
--- Utility functions module.
-- This is mostly used for internal stuff and should not be relevant for end
-- users (except some function that can be overridden).
--
-- @module raven.util
-- @copyright 2014-2017 CloudFlare, Inc.
-- @license BSD 3-clause (see LICENSE file)

local string_format = string.format
local string_find = string.find
local string_sub = string.sub
local string_match = string.match
local math_random = math.random
local os_date = os.date

local _M = {}

local _VERSION = "0.5.0"
_M._VERSION = _VERSION

--- Used to log errors during reporting.
-- The default implementation is quite dumb: it will simply use `print` to
-- display the error message. Users are encouraged to override this
-- implementation to something smarter.
-- @param ... Message to log (will be concatenated)
function _M.errlog(...)
    print("[ERROR]", ...)
end

--- Returns a string suitable to be used as `event_id`.
-- @return a new random `event_id` string.
function _M.generate_event_id()
    -- Some version of Lua can only generate random integers up to 2^31, so we are limited to 7
    -- hex-digits per call
    return string_format("%07x%07x%07x%07x%04x",
        math_random(0, 0xfffffff),
        math_random(0, 0xfffffff),
        math_random(0, 0xfffffff),
        math_random(0, 0xfffffff),
        math_random(0, 0xffff))
end

--- Returns the current date/time in ISO8601 format with no timezone indicator
-- but in UTC.
function _M.iso8601()

    -- The ! forces os_date to return UTC. Don't change this to use
    -- os.date/os.time to format the date/time because timezone
    -- problems occur

    local t = os_date("!*t")
    return string_format("%04d-%02d-%02dT%02d:%02d:%02d",
        t["year"], t["month"], t["day"], t["hour"], t["min"], t["sec"])
end

local iso8601 = _M.iso8601

-- parse_host_port: parse long host ("127.0.0.1:2222")
-- to host ("127.0.0.1") and port (2222)
local function parse_host_port(protocol, host)
    local i = string_find(host, ":")
    if not i then
        return host, protocol == 'https' and 443 or 80
    end

    local port_str = string_sub(host, i + 1)
    local port = tonumber(port_str)
    if not port then
        return nil, nil, "illegal port: " .. port_str
    end

    return string_sub(host, 1, i - 1), port
end

--- Parsed DSN table containing its different fields.
-- @field protocol  Connection protocol (`http`, `https`, ...)
-- @field public_key
-- @field secret_key
-- @field host  Hostname (without the port part)
-- @field port  Port to connect to as a number (always filled, default
--  depend on protocol)
-- @field path
-- @field project_id
-- @field request_uri URI path for storing messages
-- @field server  Full URL to the `/store/` Sentry endpoint
-- @table parsed_dsn

--- Parses a DSN and returns a table with parsed elements.
-- @param dsn DSN to parse (string)
-- @param[opt] obj Table to populate (create a new one if not provided)
-- @return[1] populated table, see @{parsed_dsn}
-- @return[2] nil
-- @return[2] error message
function _M.parse_dsn(dsn, obj)
    if not obj then
        obj = {}
    end

    assert(type(obj) == "table")

    -- '{PROTOCOL}://{PUBLIC_KEY}:{SECRET_KEY}@{HOST}/{PATH}{PROJECT_ID}'
    obj.protocol, obj.public_key, obj.secret_key, obj.long_host,
    obj.path, obj.project_id =
        string_match(dsn, "^([^:]+)://([^:]+):([^@]+)@([^/]+)(.*/)(.+)$")

    if obj.protocol and obj.public_key and obj.secret_key and obj.long_host
        and obj.project_id then

        local host, port, err = parse_host_port(obj.protocol, obj.long_host)

        if not host then
            return nil, err
        end

        obj.host = host
        obj.port = port

        obj.request_uri = string_format("%sapi/%s/store/", obj.path, obj.project_id)
        obj.server = string_format("%s://%s:%d%s", obj.protocol, obj.host, obj.port,
            obj.request_uri)

        return obj
    end

    return nil, "failed to parse DSN string"
end

--- Generate a Sentry compliant `X-Sentry-Auth` header value.
-- @param dsn_object A @{parsed_dsn} table
-- @return A Sentry authentication string
function _M.generate_auth_header(dsn_object)
    return string_format(
        "Sentry sentry_version=6, sentry_client=%s, sentry_timestamp=%s, sentry_key=%s, sentry_secret=%s",
        "raven-lua/" .. _VERSION,
        iso8601(),
        dsn_object.public_key,
        dsn_object.secret_key)
end

return _M
