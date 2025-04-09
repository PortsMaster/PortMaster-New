-- vim: st=4 sts=4 sw=4 et:
--- Sender object specification.
-- A Lua has a disparate ecosystem of networking libraries, this makes difficult
-- doing a one-size-fits-all library. Lua-Raven does as much logic as possible
-- in a generic way, relying on a *sender* object to send the actual payload to
-- the Sentry server.
--
-- This module only contains documentation, it does not implement an actual
-- sender.
--
-- @module raven.senders.reference
-- @copyright 2014-2017 CloudFlare, Inc.
-- @license BSD 3-clause (see LICENSE file)

--- A sender object can be a table or a userdata.
-- I must contain all the logic to locate the server and send the data to it.
-- Notably, the core Raven object has no idea of the URL of the server, the
-- sender object must be able to build it by itself.
--
-- You can use the @{raven.util.parse_dsn} function to process DSN strings.
--
-- @type Sender

--- The `send` method is called whenever a message must be sent to the Sentry
-- server. The authentication header can be generated with
-- @{raven.util.generate_auth_header}.
--
-- @param json_str Request payload as a serialized string (it must be sent
--   verbatim, the sender should **not** try to alter it in any way)
-- @return[1] `true` when the payload has been sent successfully
-- @return[2] `nil` in case of error
-- @return[2] error message (will be logged)
-- @function Sender:send

return
