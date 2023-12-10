local keen = {}

local http = require "socket.http"
local ltn12 = require 'ltn12'
local json = require 'external.json'

local WRITE_KEY = "394457B515D080993779145C4CBB6A7ED44EBDE88996A51BB5AA10E8797DDDD4D097E63285617F0FF4ED987213EEFED1542519D5D592954E33697D5929703BBF624EF41498ECA161F9024D6AECFEC88E436F45768724CE5BE2CE1616CA088B5C"
local PROJECT_ID = "5afa7c1ac9e77c000163976f"

function keen.log(collection, data)
  local resp_buffer = {}
  local json_str = json.encode(data)

  local ok, status, rh, rsl = http.request{
    url = 'https://api.keen.io/3.0/projects/' .. PROJECT_ID .. '/events/' .. collection,
    method = 'POST',
    headers = {
      ['Authorization'] = WRITE_KEY,
      ['Content-Type'] = 'application/json',
      ["Content-Length"] = tostring(#json_str)
    },
    source = ltn12.source.string(json_str),
    sink = ltn12.sink.table(resp_buffer),
  }

  if ok == nil then
    log.error(error)
  elseif status ~= 201 then
    log.error(rsl)
  end
end

return keen
