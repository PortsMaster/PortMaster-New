Slider = {}

listOfSliders = {}

function createSlider(type, direction, speed, length)
  slider = {}
  slider.type = type -- normal, reverse, bad --
  slider.direction = direction -- 1 = left, 2 = down, 3 = right, 4 = up  --
  if (direction == 1) then
    slider.tempPosition = gw / 2 + gh / 2
  elseif (direction == 2) then
    slider.tempPosition = 0
  elseif (direction == 3) then
    slider.tempPosition = gw / 2 - gh / 2
  elseif (direction == 4) then
    slider.tempPosition = gh
  end
  slider.shouldPlayhitSound = true
  slider.speed = speed
  slider.rotation = 0
  slider.maxlength = length
  slider.length = length
  slider.scoreLength = length
  if modManager.isFlashlight then
    slider.alpha = 0
  else
    slider.alpha = 1
  end

  table.insert(listOfSliders, slider)
end

function Slider:update(dt)
  for i, v in ipairs(listOfSliders) do

    if (v.direction == 4) then
    v.tempPosition = v.tempPosition - v.speed * dt
    if v.tempPosition < gh * 0.82 and v.type == 2 then
      if(v.rotation < math.pi) then
          v.rotation = v.rotation + v.speed * 0.05 * dt
      else
        v.rotation = math.pi
      end
    end
      if(v.tempPosition < gh * 0.615) then
        v.tempPosition = gh * 0.615
          if(v.length > 0) then
            v.length = v.length - v.speed * dt
            if((v.type == 1 and player.direction == "down") or (v.type == 3 and player.direction == "down") or (v.type == 2 and player.direction == "up")) then
              v.scoreLength = v.scoreLength - v.speed * dt
              player:blink(dt)
              if saveManager.settings.isEnabledTicksound == true then
                soundManager.hitSlidersrc:play()
              else
                if (v.shouldPlayhitSound) then
                  soundManager.playSoundEffect(soundManager.hitsrc)
                  v.shouldPlayhitSound = false
                end
              end
            end
          else
            table.remove(listOfSliders, i)
            scoreManager.destroyednotes = scoreManager.destroyednotes + 2
            scoreManager.destroyedArrows = scoreManager.destroyedArrows + 1
            if((v.scoreLength <= 0 and v.type == 1) or (v.scoreLength <= 0 and v.type == 2)) then
              scoreManager.AddScore("sliderStart")
            elseif((v.scoreLength >= 0 and v.type == 1) or (v.scoreLength >= 0 and v.type == 2)) then
              scoreManager.AddScore("miss")
            elseif ((v.scoreLength < v.maxlength and v.type == 3)) then
              scoreManager.collectedRedSliders = scoreManager.collectedRedSliders + 1
              soundManager.playSoundEffect(soundManager.misssrc)
              scoreManager.AddScore("bad")
            end

            if (v.type == 1) then
              if (player.direction == "down") then
                scoreManager.collectedBlueSliders = scoreManager.collectedBlueSliders + 1
                soundManager.playSoundEffect(soundManager.hitsrc)
                scoreManager.AddScore("sliderEnd")
              else
                soundManager.playSoundEffect(soundManager.misssrc)
                scoreManager.AddScore("miss")
              end
            elseif (v.type == 2) then
              scoreManager.collectedYellowSliders = scoreManager.collectedYellowSliders + 1
              if (player.direction == "up") then
                soundManager.playSoundEffect(soundManager.hitsrc)
                scoreManager.AddScore("sliderEnd")
              else
                soundManager.playSoundEffect(soundManager.misssrc)
                scoreManager.AddScore("miss")
              end
            end
          end
        end

    elseif (v.direction == 2) then
    v.tempPosition = v.tempPosition + v.speed * dt
    if(v.tempPosition > gh * 0.18) and v.type == 2 then
      if(v.rotation < math.pi) then
          v.rotation = v.rotation + v.speed * 0.05 * dt
      else
        v.rotation = math.pi
      end
    end
    if(v.tempPosition > gh * 0.385) then
      v.tempPosition = gh * 0.385
        if(v.length > 0) then
          v.length = v.length - v.speed * dt
        if((v.type == 1 and player.direction == "up") or (v.type == 3 and player.direction == "up") or (v.type == 2 and player.direction == "down")) then
          v.scoreLength = v.scoreLength - v.speed * dt
          player:blink(dt)
          if saveManager.settings.isEnabledTicksound == true then
            soundManager.hitSlidersrc:play()
          else
            if (v.shouldPlayhitSound) then
              soundManager.playSoundEffect(soundManager.hitsrc)
              v.shouldPlayhitSound = false
            end
          end
        end
        else
          table.remove(listOfSliders, i)
          scoreManager.destroyednotes = scoreManager.destroyednotes + 2
          scoreManager.destroyedArrows = scoreManager.destroyedArrows + 1
          if((v.scoreLength <= 0 and v.type == 1) or (v.scoreLength <= 0 and v.type == 2)) then
            scoreManager.AddScore("sliderStart")
          elseif((v.scoreLength >= 0 and v.type == 1) or (v.scoreLength >= 0 and v.type == 2)) then
            scoreManager.AddScore("miss")
          elseif ((v.scoreLength < v.maxlength and v.type == 3)) then
            scoreManager.collectedRedSliders = scoreManager.collectedRedSliders + 1
            soundManager.playSoundEffect(soundManager.misssrc)
            scoreManager.AddScore("bad")
          end

          if (v.type == 1) then
            if (player.direction == "up") then
              scoreManager.collectedBlueSliders = scoreManager.collectedBlueSliders + 1
              soundManager.playSoundEffect(soundManager.hitsrc)
              scoreManager.AddScore("sliderEnd")
            else
              soundManager.playSoundEffect(soundManager.misssrc)
              scoreManager.AddScore("miss")
            end
          elseif (v.type == 2) then
            if (player.direction == "down") then
              scoreManager.collectedYellowSliders = scoreManager.collectedYellowSliders + 1
              soundManager.playSoundEffect(soundManager.hitsrc)
              scoreManager.AddScore("sliderEnd")
            else
              soundManager.playSoundEffect(soundManager.misssrc)
              scoreManager.AddScore("miss")
            end
          end
        end
      end

    elseif (v.direction == 1) then
    v.tempPosition = v.tempPosition - v.speed * dt
    if(v.tempPosition < gw * 0.68) and v.type == 2 then
      if(v.rotation < math.pi) then
          v.rotation = v.rotation + v.speed * 0.05 * dt
      else
        v.rotation = math.pi
      end
    end
    if(v.tempPosition < gw * 0.575) then
      v.tempPosition = gw * 0.575
        if(v.length > 0) then
          v.length = v.length - v.speed * dt
          if((v.type == 1 and player.direction == "right") or (v.type == 3 and player.direction == "right") or (v.type == 2 and player.direction == "left")) then
            v.scoreLength = v.scoreLength - v.speed * dt
            player:blink(dt)
            if saveManager.settings.isEnabledTicksound == true then
              soundManager.hitSlidersrc:play()
            else
              if (v.shouldPlayhitSound) then
                soundManager.playSoundEffect(soundManager.hitsrc)
                v.shouldPlayhitSound = false
              end
            end
          end
        else
          table.remove(listOfSliders, i)
          scoreManager.destroyednotes = scoreManager.destroyednotes + 2
          scoreManager.destroyedArrows = scoreManager.destroyedArrows + 1
          if((v.scoreLength <= 0 and v.type == 1) or (v.scoreLength <= 0 and v.type == 2)) then
            scoreManager.AddScore("sliderStart")
          elseif((v.scoreLength >= 0 and v.type == 1) or (v.scoreLength >= 0 and v.type == 2)) then
            scoreManager.AddScore("miss")
          elseif ((v.scoreLength < v.maxlength and v.type == 3)) then
            scoreManager.collectedRedSliders = scoreManager.collectedRedSliders + 1
            soundManager.playSoundEffect(soundManager.misssrc)
            scoreManager.AddScore("bad")
          end

          if (v.type == 1) then
            if (player.direction == "right") then
              scoreManager.collectedBlueSliders = scoreManager.collectedBlueSliders + 1
              soundManager.playSoundEffect(soundManager.hitsrc)
              scoreManager.AddScore("sliderEnd")
            else
              soundManager.playSoundEffect(soundManager.misssrc)
              scoreManager.AddScore("miss")
            end
          elseif (v.type == 2) then
            if (player.direction == "left") then
              scoreManager.collectedYellowSliders = scoreManager.collectedYellowSliders + 1
              soundManager.playSoundEffect(soundManager.hitsrc)
              scoreManager.AddScore("sliderEnd")
            else
              soundManager.playSoundEffect(soundManager.misssrc)
              scoreManager.AddScore("miss")
            end
          end
        end
      end

  elseif (v.direction == 3) then
  v.tempPosition = v.tempPosition + v.speed * dt
  if(v.tempPosition > gw * 0.32) and v.type == 2 then
    if(v.rotation < math.pi) then
        v.rotation = v.rotation + v.speed * 0.05 * dt
    else
      v.rotation = math.pi
    end
  end
  if(v.tempPosition > gw * 0.425) then
    v.tempPosition = gw * 0.425 
      if(v.length > 0) then
        v.length = v.length - v.speed * dt
        if((v.type == 1 and player.direction == "left") or (v.type == 3 and player.direction == "left") or (v.type == 2 and player.direction == "right")) then
          v.scoreLength = v.scoreLength - v.speed * dt
          player:blink(dt)
          if saveManager.settings.isEnabledTicksound == true then
            soundManager.hitSlidersrc:play()
          else
            if (v.shouldPlayhitSound) then
              soundManager.playSoundEffect(soundManager.hitsrc)
              v.shouldPlayhitSound = false
            end
          end
        end
      else
        table.remove(listOfSliders, i)
        scoreManager.destroyednotes = scoreManager.destroyednotes + 2
        scoreManager.destroyedArrows = scoreManager.destroyedArrows + 1
        if((v.scoreLength <= 0 and v.type == 1) or (v.scoreLength <= 0 and v.type == 2)) then
          scoreManager.AddScore("sliderStart")
        elseif((v.scoreLength >= 0 and v.type == 1) or (v.scoreLength >= 0 and v.type == 2)) then
          scoreManager.AddScore("miss")
        elseif ((v.scoreLength < v.maxlength and v.type == 3)) then
          scoreManager.collectedRedSliders = scoreManager.collectedRedSliders + 1
          soundManager.playSoundEffect(soundManager.misssrc)
          scoreManager.AddScore("bad")
        end

        if (v.type == 1) then
          if (player.direction == "left") then
            scoreManager.collectedBlueSliders = scoreManager.collectedBlueSliders + 1
            soundManager.playSoundEffect(soundManager.hitsrc)
            scoreManager.AddScore("sliderEnd")
          else
            soundManager.playSoundEffect(soundManager.misssrc)
            scoreManager.AddScore("miss")
          end
        elseif (v.type == 2) then
          if (player.direction == "right") then
            scoreManager.collectedYellowSliders = scoreManager.collectedYellowSliders + 1
            soundManager.playSoundEffect(soundManager.hitsrc)
            scoreManager.AddScore("sliderEnd")
          else
            soundManager.playSoundEffect(soundManager.misssrc)
            scoreManager.AddScore("miss")
          end
        end
      end
    end
  end
end

function Slider:draw()
  for i, v in ipairs(listOfSliders) do
  if (v.direction == 4) then
    love.graphics.push()
    love.graphics.translate(gw / 2, gh / 2)
    love.graphics.rotate(v.rotation)
    love.graphics.translate(gw / 2 * -1, gh / 2 * -1)

    love.graphics.setColor(0.25, 0.25, 0.25, v.alpha)
    love.graphics.rectangle('fill', gw / 2 - 40, 35 + v.tempPosition, 80, v.length)

    if (v.type == 1) then
      love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, v.alpha)

    elseif (v.type == 2) then
        love.graphics.setColor(219 / 255, 130 / 255, 52 / 255, v.alpha)

    elseif (v.type == 3) then
        love.graphics.setColor(219 / 255, 52 / 255, 52 / 255, v.alpha)
    end
    love.graphics.polygon('fill', gw / 2, -4 + v.tempPosition,
                          gw / 2 + 40, 35 + v.tempPosition,
                          gw / 2 + 20, 55 + v.tempPosition,
                          gw / 2, 35 + v.tempPosition,
                          gw / 2 - 20, 55 + v.tempPosition,
                          gw / 2 - 40, 35 + v.tempPosition)

    love.graphics.polygon('fill', gw / 2, -4 + v.tempPosition + v.length,
                          gw / 2 + 40, 35 + v.tempPosition + v.length,
                          gw / 2 + 20, 55 + v.tempPosition + v.length,
                          gw / 2, 35 + v.tempPosition + v.length,
                          gw / 2 - 20, 55 + v.tempPosition + v.length,
                          gw / 2 - 40, 35 + v.tempPosition + v.length)


    love.graphics.setLineWidth(5)
    love.graphics.setColor(1, 1, 1, v.alpha)

    love.graphics.line(gw / 2, -4 + v.tempPosition,
                          gw / 2 + 40, 35 + v.tempPosition,
                          gw / 2 + 40, 35 + v.tempPosition + v.length,
                          gw / 2 + 20, 55 + v.tempPosition + v.length,
                          gw / 2, 35 + v.tempPosition + v.length,
                          gw / 2 - 20, 55 + v.tempPosition + v.length,
                          gw / 2 - 40, 35 + v.tempPosition + v.length,
                          gw / 2 - 40, 35 + v.tempPosition,
                          gw / 2, -4 + v.tempPosition)
      love.graphics.pop()
      
      elseif (v.direction == 2) then
        love.graphics.push()
        love.graphics.translate(gw / 2, gh / 2)
        love.graphics.rotate(v.rotation)
        love.graphics.translate(gw / 2 * -1, gh / 2 * -1)

        love.graphics.setColor(0.25, 0.25, 0.25, v.alpha)
        love.graphics.rectangle('fill', gw / 2 - 40, -35 + v.tempPosition - v.length, 80, v.length)

        if (v.type == 1) then
          love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, v.alpha)

        elseif (v.type == 2) then
            love.graphics.setColor(219 / 255, 130 / 255, 52 / 255, v.alpha)

        elseif (v.type == 3) then
            love.graphics.setColor(219 / 255, 52 / 255, 52 / 255, v.alpha)
        end
        love.graphics.polygon('fill', gw / 2, 4 + v.tempPosition,
                              gw / 2 + 40, -35 + v.tempPosition,
                              gw / 2 + 20, -55 + v.tempPosition,
                              gw / 2, -35 + v.tempPosition,
                              gw / 2 - 20, -55 + v.tempPosition,
                              gw / 2 - 40, -35 + v.tempPosition)

        love.graphics.polygon('fill', gw / 2, 4 + v.tempPosition - v.length,
                              gw / 2 + 40, -35 + v.tempPosition - v.length,
                              gw / 2 + 20, -55 + v.tempPosition - v.length,
                              gw / 2, -35 + v.tempPosition - v.length,
                              gw / 2 - 20, -55 + v.tempPosition - v.length,
                              gw / 2 - 40, -35 + v.tempPosition - v.length)


      love.graphics.setLineWidth(5)
      love.graphics.setColor(1, 1, 1, v.alpha)

      love.graphics.line(gw / 2, 4 + v.tempPosition,
                            gw / 2 + 40, -35 + v.tempPosition,
                            gw / 2 + 40, -35 + v.tempPosition - v.length,
                            gw / 2 + 20, -55 + v.tempPosition - v.length,
                            gw / 2, -35 + v.tempPosition - v.length,
                            gw / 2 - 20, -55 + v.tempPosition - v.length,
                            gw / 2 - 40, -35 + v.tempPosition - v.length,
                            gw / 2 - 40, -35 + v.tempPosition,
                            gw / 2, 4 + v.tempPosition)

      love.graphics.pop()
      elseif (v.direction == 1) then
        love.graphics.push()
        love.graphics.translate(gw / 2, gh / 2)
        love.graphics.rotate(v.rotation)
        love.graphics.translate(gw / 2 * -1, gh / 2 * -1)

        love.graphics.setColor(0.25, 0.25, 0.25, v.alpha)
        love.graphics.rectangle('fill', 13 + v.tempPosition, gh / 2 - 40, v.length, 80)

        if (v.type == 1) then
          love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, v.alpha)

        elseif (v.type == 2) then
            love.graphics.setColor(219 / 255, 130 / 255, 52 / 255, v.alpha)

        elseif (v.type == 3) then
            love.graphics.setColor(219 / 255, 52 / 255, 52 / 255, v.alpha)
        end

        love.graphics.polygon('fill', -26 + v.tempPosition , gh / 2,
                              13 + v.tempPosition, gh / 2 + 40,
                              33 + v.tempPosition, gh / 2 + 20,
                              13 + v.tempPosition, gh / 2,
                              33 + v.tempPosition, gh / 2 - 20,
                              13 + v.tempPosition, gh / 2 - 40)

        love.graphics.polygon('fill', -26 + v.tempPosition + v.length, gh / 2,
                              13 + v.tempPosition + v.length, gh / 2 + 40,
                              33 + v.tempPosition + v.length, gh / 2 + 20,
                              13 + v.tempPosition + v.length, gh / 2,
                              33 + v.tempPosition + v.length, gh / 2 - 20,
                              13 + v.tempPosition + v.length, gh / 2 - 40)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(1, 1, 1, v.alpha)

        love.graphics.line(-26 + v.tempPosition , gh / 2,
                              13 + v.tempPosition, gh / 2 + 40,
                              13 + v.tempPosition + v.length, gh / 2 + 40,
                              33 + v.tempPosition + v.length, gh / 2 + 20,
                              13 + v.tempPosition + v.length, gh / 2,
                              33 + v.tempPosition + v.length, gh / 2 - 20,
                              13 + v.tempPosition + v.length, gh / 2 - 40,
                              13 + v.tempPosition, gh / 2 - 40,
                              -26 + v.tempPosition, gh / 2)
        love.graphics.pop()

        elseif (v.direction == 3) then
        love.graphics.push()
        love.graphics.translate(gw / 2, gh / 2)
        love.graphics.rotate(v.rotation)
        love.graphics.translate(gw / 2 * -1, gh / 2 * -1)

        love.graphics.setColor(0.25, 0.25, 0.25, v.alpha)
        love.graphics.rectangle('fill', (13 - v.tempPosition + v.length) * -1, gh / 2 - 40, v.length, 80)

        if (v.type == 1) then
          love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, v.alpha)

        elseif (v.type == 2) then
            love.graphics.setColor(219 / 255, 130 / 255, 52 / 255, v.alpha)

        elseif (v.type == 3) then
            love.graphics.setColor(219 / 255, 52 / 255, 52 / 255, v.alpha)
        end


        love.graphics.polygon('fill', 26 + v.tempPosition, gh / 2,
                              -13 + v.tempPosition, gh / 2 + 40,
                              -33 + v.tempPosition, gh / 2 + 20,
                              -13 + v.tempPosition, gh / 2,
                              -33 + v.tempPosition, gh / 2 - 20,
                              -13 + v.tempPosition, gh / 2 - 40)

        love.graphics.polygon('fill', 26 + v.tempPosition - v.length, gh / 2,
                              -13 + v.tempPosition - v.length, gh / 2 + 40,
                              -33 + v.tempPosition - v.length, gh / 2 + 20,
                              -13 + v.tempPosition - v.length, gh / 2,
                              -33 + v.tempPosition - v.length, gh / 2 - 20,
                              -13 + v.tempPosition - v.length, gh / 2 - 40)

      love.graphics.setLineWidth(5)
      love.graphics.setColor(1, 1, 1, v.alpha)

      love.graphics.line(26 + v.tempPosition, gh / 2,
                            -13 + v.tempPosition, gh / 2 + 40,
                            -13 + v.tempPosition - v.length, gh / 2 + 40,
                            -33 + v.tempPosition - v.length, gh / 2 + 20,
                            -13 + v.tempPosition - v.length, gh / 2,
                            -33 + v.tempPosition - v.length, gh / 2 - 20,
                            -13 + v.tempPosition - v.length, gh / 2 - 40,
                            -13 + v.tempPosition, gh / 2 - 40,
                            26 + v.tempPosition, gh / 2)
        love.graphics.pop()
      end
    end
  end
end

return Slider
