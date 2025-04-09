local save = {}

local serpent = require "external.serpent"

log.debug("Save directory:", love.filesystem.getSaveDirectory())

local info = love.filesystem.getInfo('savegame.lua', 'file')
if info == nil then
  save.data = {
    hour = nil,
    completed = false,
  }
else
  local contents, _ = love.filesystem.read('savegame.lua')
  local ok, res = serpent.load(contents)
  if not ok then error(res) end
  save.data = res

  log.debug("Data successfully loaded...")
end


function save.save()
  log.debug("Saving data...")
  local success, message = love.filesystem.write('savegame.lua', serpent.dump(save.data))
  if not success then
    log.error(message)
  end
end

return save
