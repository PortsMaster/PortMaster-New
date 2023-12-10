require 'mods/halfSpeed'
require 'mods/doubleSpeed'
require 'mods/hidden'
require 'mods/flashlight'
require 'mods/auto'

modManager = {}

function modManager:load()
  modManager.isHalfSpeed = false
  modManager.isDoubleSpeed = false
  modManager.isHidden = false
  modManager.isFlashlight = false
  modManager.isNoFail = false
  modManager.isAuto = false
    
  modManager.speed = 1.00
end

function modManager.SetSpeed(speed)
  modManager.speed = speed
end

function modManager.getSpeed()
  return modManager.speed
end

return modManager
