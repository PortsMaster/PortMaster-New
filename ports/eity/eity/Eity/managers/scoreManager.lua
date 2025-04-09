scoreManager = {}

local note

function scoreManager.ResetCombo()
  scoreManager.combo = 0
end

function scoreManager.AddHealth(value)  
  gameManager.health = gameManager.health + value
  if gameManager.health > 100 then
    gameManager.health = 100
  end
end

function scoreManager.AddCombo()
  scoreManager.combo = scoreManager.combo + 1
  
end

function scoreManager.Restart()
  scoreManager.score = 0
  scoreManager.combo = 0
  scoreManager.maxCombo = 0
  scoreManager.misses = 0
  scoreManager.hits = 0
  scoreManager.destroyednotes = 0
  scoreManager.destroyedArrows = 0
  
  scoreManager.totalBlueArrows = 0
  scoreManager.totalBlueSliders = 0
  scoreManager.totalYellowArrows = 0
  scoreManager.totalYellowSliders = 0
  
  scoreManager.collectedBlueArrows = 0
  scoreManager.collectedBlueSliders = 0
  scoreManager.collectedYellowArrows = 0
  scoreManager.collectedYellowSliders = 0
  scoreManager.collectedRedArrows = 0
  scoreManager.collectedRedSliders = 0
end

function scoreManager.CalculateTotalNotes()
  scoreManager.totalBlueArrows = 0
  scoreManager.totalBlueSliders = 0
  scoreManager.totalYellowArrows = 0
  scoreManager.totalYellowSliders = 0
  note = 1
  for i, v in ipairs(mapNotes) do
    if #mapNotes >= note then
      if mapNotes[note][1] == 1 and mapNotes[note][4] == 0 then scoreManager.totalBlueArrows = scoreManager.totalBlueArrows + 1
      elseif mapNotes[note][1] == 1 and mapNotes[note][4] ~= 0 then scoreManager.totalBlueSliders = scoreManager.totalBlueSliders + 1
      elseif mapNotes[note][1] == 2 and mapNotes[note][4] == 0 then scoreManager.totalYellowArrows = scoreManager.totalYellowArrows + 1
      elseif mapNotes[note][1] == 2 and mapNotes[note][4] ~= 0 then scoreManager.totalYellowSliders = scoreManager.totalYellowSliders + 1
      end
      note = note + 1
    end
  end
end

function scoreManager.AddScore(type)
  if (type == "perfect") then
      scoreManager.AddCombo()
      scoreManager.hits = scoreManager.hits + 1
      scoreManager.AddHealth(5)
      scoreManager.score = scoreManager.score + 300 * scoreManager.combo * scoreManager.modMultiplier
  elseif (type == "sliderStart") then
      scoreManager.AddHealth(2)
      scoreManager.score = scoreManager.score + 100 * scoreManager.combo * scoreManager.modMultiplier
  elseif (type == "sliderEnd") then
      scoreManager.AddCombo()
      scoreManager.hits = scoreManager.hits + 1
      scoreManager.AddHealth(2)
      scoreManager.score = scoreManager.score + 100 * scoreManager.combo * scoreManager.modMultiplier
  elseif (type == "miss") then
      if scoreManager.combo > scoreManager.maxCombo then scoreManager.maxCombo = scoreManager.combo end
      scoreManager.ResetCombo()
      scoreManager.AddHealth(-20)
      scoreManager.misses = scoreManager.misses + 1
  elseif (type == "bad") then
      if scoreManager.combo > scoreManager.maxCombo then scoreManager.maxCombo = scoreManager.combo end
      scoreManager.ResetCombo()
      scoreManager.AddHealth(-25)
      scoreManager.misses = scoreManager.misses + 1
      scoreManager.score = scoreManager.score - 100
      if (scoreManager.score < 0) then
        scoreManager.score = 0
      end
  end
end

function scoreManager:update(dt)
  
  scoreManager.modMultiplier = 1.00
  if modManager.isHalfSpeed then
    scoreManager.modMultiplier = scoreManager.modMultiplier - 0.50
  end
  if modManager.isDoubleSpeed then
    scoreManager.modMultiplier = scoreManager.modMultiplier + 0.50
  end
  if modManager.isHidden then
    scoreManager.modMultiplier = scoreManager.modMultiplier + 0.25
  end
  if modManager.isFlashlight then
    scoreManager.modMultiplier = scoreManager.modMultiplier + 0.25
  end
  if modManager.isNoFail then
    scoreManager.modMultiplier = scoreManager.modMultiplier - 0.25
  end
  if modManager.isAuto then
    scoreManager.modMultiplier = 0
  end
end

function scoreManager.setHighScore()
  saveManager.highscores.mapScore[mapList.getSelectedMapIndex()] = scoreManager.score
  saveManager.highscores.mapGrade[mapList.getSelectedMapIndex()] = scoreManager.getGrade()
  
  saveManager:saveHighscore()
end

function scoreManager:draw()
  love.graphics.setFont(squareButtonsmallFont)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(scoreManager.combo .. "x", 5, gh - 50, gw, "left")
  love.graphics.printf(string.format("%08d", scoreManager.score), 0, 0, gw, "right")
  love.graphics.setFont(buttonSmallFont)
  love.graphics.printf(string.format("%0.2f", scoreManager.getAccuracy()) .. "%", 0, 50, gw, "right")
end

function scoreManager.getAccuracy()
  if scoreManager.destroyednotes == 0 or (scoreManager.destroyednotes - scoreManager.misses) / scoreManager.destroyednotes * 100 == 100 then
    return 100
  else
    return (scoreManager.destroyednotes - scoreManager.misses) / scoreManager.destroyednotes * 100
  end
end

function scoreManager.getGrade()
  if scoreManager.getAccuracy() == 100 then
    return "SS"
  elseif scoreManager.getAccuracy() >= 98 then
    return "S"
  elseif scoreManager.getAccuracy() >= 95 then
    return "A"
  elseif scoreManager.getAccuracy() >= 90 then
    return "B"
  elseif scoreManager.getAccuracy() >= 85 then
    return "C"
  elseif scoreManager.getAccuracy() >= 0 then
    return "D"
  else
    return ""
  end
end

function scoreManager.getGradeColor(grade)
  if grade == "SS" then
    return {255 / 255, 215 / 255, 55 / 255, 1}
  elseif grade == "S" then
    return {255 / 255, 215 / 255, 55 / 255, 1}
  elseif grade == "A" then
    return {153 / 255, 199 / 255, 59 / 255, 1}
  elseif grade == "B" then
    return {51 / 255, 152 / 255, 220 / 255, 1}
  elseif grade == "C" then
    return {116 / 255, 94 / 255, 198 / 255, 1}
  else
    return {242 / 255, 75 / 255, 60 / 255, 1}
  end
end

return scoreManager
