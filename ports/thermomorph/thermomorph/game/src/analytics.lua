local keen = require 'src.keen'
local raven = require "raven"

local analytics = {}

-- Generate a unique user ID.
local userid = nil
if love.filesystem.getInfo("userid", "file") then
  log.debug("Reading user id.")
  userid, _ = love.filesystem.read("userid")
else
  log.debug("Generating user id.")
  userid = lume.uuid()
  love.filesystem.write("userid", userid)
end
log.debug(string.format("User id: '%s'", userid))

-- Generate a uniuqe session id
local sessionid = lume.uuid()

if love.filesystem.isFused() then
  log.debug("Game is fused. Registering Sentry error handler...")

  local rvn = raven.new {
      sender = require("raven.senders.luasocket").new {
          dsn = "http://a6442cde909b47bb9c056b3220d1f06b:a939a42e7f1e4115b4cda2af2d24c1f0@sentry.io/1206707",
      },
      tags = {
        platform = love.system.getOS(),
        version = VERSION,
      },
      user = {
        id = userid
      }
  }

  function love.errhand(error_message)
    log.error(error_message)

    local exception = {{
      ["type"] = "Fatal Error",
      ["value"] = error_message,
    }}
    local id, err = rvn:captureException(exception, {trace_level = 3})
    if not id then log.error(err) end

    local dialog_message = [[
%s

This error has been reported. ]]
    local title = "Thermomorph Has Crashed"
    local full_error = debug.traceback(error_message or "")
    local message = string.format(dialog_message, full_error)

    local pressedbutton = love.window.showMessageBox(title, message)
  end
else
  log.debug("Game is not fused. Keeping default error handler...")
end

function analytics.logGameResult(data)
  if not love.filesystem.isFused() then return end

  data.user = userid
  data.session = sessionid
  data.platform = love.system.getOS()
  data.version = VERSION
  keen.log('gameresults', data)
end

if love.filesystem.isFused() then
  keen.log('sessions', {
    user = userid,
    session = sessionid,
    platform = love.system.getOS(),
    version = VERSION,
  })
end

return analytics
