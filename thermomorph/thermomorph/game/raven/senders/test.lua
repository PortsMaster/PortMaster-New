-- vim: st=4 sts=4 sw=4 et:
-- Test sender for running the test suite without spawning an actual server.
--
-- @module raven.senders.test
-- @copyright 2014-2017 CloudFlare, Inc.
-- @license BSD 3-clause (see LICENSE file)
local cjson = require 'cjson'


local function new()
    return {
        events = {},
        send = function(self, json_str)
            table.insert(self.events, cjson.decode(json_str))
            return true
        end,
    }
end

return {
    new = new,
}
