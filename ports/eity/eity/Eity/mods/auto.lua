auto = {}

function auto.ApplyMod(mapNotes)
  for i, v in ipairs(mapNotes) do    
    if #mapNotes >= scoreManager.destroyedArrows + 1 and mapNotes[scoreManager.destroyedArrows+1][1] == 1 then
      if math.ceil(mapNotes[scoreManager.destroyedArrows+1][2] * 4 / 512) == 1 then player.direction = "right"
      elseif math.ceil(mapNotes[scoreManager.destroyedArrows+1][2] * 4 / 512) == 2 then player.direction = "up"
      elseif math.ceil(mapNotes[scoreManager.destroyedArrows+1][2] * 4 / 512) == 3 then player.direction = "left"
      elseif math.ceil(mapNotes[scoreManager.destroyedArrows+1][2] * 4 / 512) == 4 then player.direction = "down" end 
           
    elseif (#mapNotes >= scoreManager.destroyedArrows + 1 and mapNotes[scoreManager.destroyedArrows+1][1] == 2) or
           (#mapNotes >= scoreManager.destroyedArrows + 1 and mapNotes[scoreManager.destroyedArrows+1][1] == 3) then
      if math.ceil(mapNotes[scoreManager.destroyedArrows+1][2] * 4 / 512) == 1 then player.direction = "left"
      elseif math.ceil(mapNotes[scoreManager.destroyedArrows+1][2] * 4 / 512) == 2 then player.direction = "down"
      elseif math.ceil(mapNotes[scoreManager.destroyedArrows+1][2] * 4 / 512) == 3 then player.direction = "right"
      elseif math.ceil(mapNotes[scoreManager.destroyedArrows+1][2] * 4 / 512) == 4 then player.direction = "up" end
    end
  end
end

return auto
