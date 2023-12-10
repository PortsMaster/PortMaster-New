shelter = require "maps/Shelter/map"
freedomDive = require "maps/FREEDOM DiVE/map"
yumeiroParade = require "maps/Yumeiro Parade/map"
highscore = require "maps/Highscore/map"
prayerBlue = require "maps/Prayer Blue/map"
paradigmShift = require "maps/Paradigm Shift/map"
pressure = require "maps/The Pressure/map"
stellaRium = require "maps/Stella-rium/map"
virtualParadise = require "maps/Virtual Paradise/map"
coldGreenEyes = require "maps/Cold Green Eyes/map"
--elama = require "maps/Elaman koulu/map"
--template = require "maps/Template/map"

mapManager = { }
 
listOfMaps = {}
 
function mapManager.getListOfMaps()
 return listOfMaps
end

function mapManager.getLengthOfIndex(index)
  return listOfMaps[index].getLength()
end

function mapManager.getDifficultOfIndex(index)
  return listOfMaps[index].getDifficult()
end

function mapManager.getTitleOfIndex(index)
  return listOfMaps[index].getTitle()
end

function mapManager.getPorterOfIndex(index)
  return listOfMaps[index].getPorter()
end

function mapManager.getBackgroundOfIndex(index)
  return listOfMaps[index].getBackground()
end

function mapManager.getSongOfIndex(index)
  return listOfMaps[index].getSong()
end

function mapManager.getNotesOfIndex(index)
  return listOfMaps[index].getNotes()
end

 
function mapManager:load()      
  -- (0 = none, 1 = normal, 2 = slider, 3 = bad), 448 = up, 64 = down, 192 = left, 320 = right, milliseconds to spawn
  -- Slider length
  table.insert(listOfMaps, shelter)
  table.insert(listOfMaps, prayerBlue)
  table.insert(listOfMaps, virtualParadise)
  table.insert(listOfMaps, coldGreenEyes)
  table.insert(listOfMaps, paradigmShift)  
  table.insert(listOfMaps, stellaRium)  
  table.insert(listOfMaps, pressure)
  table.insert(listOfMaps, freedomDive)
  table.insert(listOfMaps, highscore)
  table.insert(listOfMaps, yumeiroParade)  
  
  
  --table.insert(listOfMaps, elama)  
  --table.insert(listOfMaps, template)
  for i, v in ipairs(mapManager.getListOfMaps()) do
    for i, v in ipairs(v) do
      if (v[i][1] == 3) then
        v[i][5] = v[i][5] + 100
      end
    end
  end
end

return mapManager
