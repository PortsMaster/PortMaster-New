map = { }
 
function map:getBackground()
  return "maps/Template/bg.jpg"
end

function map:getTitle()
  return "Template"
end

function map:getDifficult()
  return "Template"
end
 
function map:getPorter()
  return "Template"
end

function map:getSong()
  return "maps/Yumeiro Parade/song.mp3"
end
 
function map:getLength()  
  return 100
end

function map:getNotes()        
  -- (0 = none, 1 = normal, 2 = reverse, 3 = bad), (448 = up, 64 = down, 192 = left, 320 = right), speed, slider length, milliseconds to spawn
  return {
    {1, 320, 400, 600, 1111402},
  }
end

return map
