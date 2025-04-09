player = {}

player.lineWidth = 2

function player:resetPosition()
  player.direction = "up"
end

function player:update(dt)
  if player.lineWidth > 2 then
    player.lineWidth = player.lineWidth - 18 * dt
  else
    player.lineWidth = 2
  end
end 

function player:blink(dt)
  player.lineWidth = 10
end 

function player:draw()  
  love.graphics.setColor(1, 1, 1, 1) 
  love.graphics.setLineWidth(player.lineWidth)
  if player.direction == "up" then
    love.graphics.polygon('fill', gw / 2, gh / 2 - 34,
                          gw / 2 + 40, gh / 2 + 5,
                          gw / 2 + 20, gh / 2 + 25,
                          gw / 2, gh / 2 + 5,
                          gw / 2 - 20, gh / 2 + 25,
                          gw / 2 - 40, gh / 2 + 5)
    love.graphics.polygon('line', gw / 2, gh / 2 - 34,
                          gw / 2 + 40, gh / 2 + 5,
                          gw / 2 + 20, gh / 2 + 25,
                          gw / 2, gh / 2 + 5,
                          gw / 2 - 20, gh / 2 + 25,
                          gw / 2 - 40, gh / 2 + 5)
  elseif player.direction == "down" then
    love.graphics.polygon('fill', gw / 2, gh / 2 - 34 * -1,
                          gw / 2 + 40, gh / 2 + 5 * -1,
                          gw / 2 + 20, gh / 2 + 25 * -1,
                          gw / 2, gh / 2 + 5 * -1,
                          gw / 2 - 20, gh / 2 + 25 * -1,
                          gw / 2 - 40, gh / 2 + 5 * -1)
    love.graphics.polygon('line', gw / 2, gh / 2 - 34 * -1,
                          gw / 2 + 40, gh / 2 + 5 * -1,
                          gw / 2 + 20, gh / 2 + 25 * -1,
                          gw / 2, gh / 2 + 5 * -1,
                          gw / 2 - 20, gh / 2 + 25 * -1,
                          gw / 2 - 40, gh / 2 + 5 * -1)
  elseif player.direction == "left" then
    love.graphics.polygon('fill', gw / 2 - 34, gh / 2,
                          gw / 2 + 5, gh / 2 + 40,
                          gw / 2 + 25, gh / 2 + 20,
                          gw / 2 + 5, gh / 2,
                          gw / 2 + 25, gh / 2 - 20,
                          gw / 2 + 5, gh / 2 - 40)
    love.graphics.polygon('line', gw / 2 - 34, gh / 2,
                          gw / 2 + 5, gh / 2 + 40,
                          gw / 2 + 25, gh / 2 + 20,
                          gw / 2 + 5, gh / 2,
                          gw / 2 + 25, gh / 2 - 20,
                          gw / 2 + 5, gh / 2 - 40)
  elseif player.direction == "right" then
    love.graphics.polygon('fill', gw / 2 - 34 * -1, gh / 2,
                          gw / 2 + 5 * -1, gh / 2 + 40,
                          gw / 2 + 25 * -1, gh / 2 + 20,
                          gw / 2 + 5 * -1, gh / 2,
                          gw / 2 + 25 * -1, gh / 2 - 20,
                          gw / 2 + 5 * -1, gh / 2 - 40)
    love.graphics.polygon('line', gw / 2 - 34 * -1, gh / 2,
                          gw / 2 + 5 * -1, gh / 2 + 40,
                          gw / 2 + 25 * -1, gh / 2 + 20,
                          gw / 2 + 5 * -1, gh / 2,
                          gw / 2 + 25 * -1, gh / 2 - 20,
                          gw / 2 + 5 * -1, gh / 2 - 40)
  end
end

function player:keypressed(key)
  if not modManager.isAuto and not gameManager.pause and not gameManager.isFailed then
    if key == "w" or key == "up" then
      player.direction = "up"
    end
    if key == "s" or key == "down" then
      player.direction = "down"
    end
    if key == "a" or key == "left" then
      player.direction = "left"
    end
    if key == "d" or key == "right" then
      player.direction = "right"
    end
  end
end

return player
