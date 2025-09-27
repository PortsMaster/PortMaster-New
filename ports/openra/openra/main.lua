function setupWindow()
    love.window.setTitle("OpenRA Game Launcher")
    love.window.setFullscreen(true, "desktop")
    love.window.setMode(0, 0)
    width, height = love.graphics.getDimensions()
    max_per_row = 3
end

function loadMods()
  modsDir = love.filesystem.getDirectoryItems("game/mods")
  mods = {}
  count = 0
  for k, name in pairs(modsDir) do
    if not string.match(name, "content") and not string.match(name, "common") and not string.match(name, "all") then
      print("Found mod: " .. name)
      table.insert(mods, name)
      count = count + 1
    end
  end

  if count == 0 then
    print("No games found, exiting")
    love.event.quit()
  end
end

function moveUp()
  if selected - max_per_row > 0 then
    selected = selected - max_per_row
  end
end

function moveDown()
  if selected + max_per_row <= count then
    selected = selected + max_per_row
  end
end

function moveRight()
  if selected % max_per_row > 0 and selected < count then
    selected = selected + 1
  end
end

function moveLeft()
  if (selected - 1) % max_per_row > 0 and selected > 1 then
    selected = selected - 1
  end
end

function handleSelection()
  file = io.open("selected_game", "w")
  file:write(mods[selected])
  file:close()
  isStarting = true
end

function love.keypressed(key, scancode, isrepeat)
  if key == "up" then
    moveUp()
  end

  if key == "down" then
    moveDown()
  end

  if key == "left" then
    moveLeft()
  end

  if key == "right" then
    moveRight()
  end

  if key == "return" then
    handleSelection()
  end

  if key == "escape" then
    love.event.quit()
  end
end

function love.gamepadpressed(joystick, button)
  if button == "dpup" then
    moveUp()
  end

  if button == "dpdown" then
    moveDown()
  end

  if button == "dpleft" then
    moveLeft()
  end

  if button == "dpright" then
    moveRight()
  end

  if button == "a" then
    handleSelection()
  end

  if button == "b" then
    handleSelection()
  end
end

function love.load()
  setupWindow()
  loadMods()
  isStarting = false
  selected = 1
end

function love.draw()
  if isStarting then
    love.graphics.print("Launching...", width / 2 - 115, height / 4, 0, 3, 3)
    love.event.quit()
  else
    row = 0
    for k, mod in pairs(mods) do
      x = (width / (max_per_row + 1)) * (1 + (k - 1) % max_per_row) - 48
      y = row * 135 + height / 2 - 48

      love.graphics.print("Select game", width / 2 - 115, height / 4, 0, 3, 3)

      icon = love.graphics.newImage("game/mods/" .. mod .. "/icon-3x.png")
      love.graphics.draw(icon, x, y)

      if selected == k then
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", x + 48, y + 48, 64)
      end

      if k % max_per_row == 0 then
        row = row + 1
      end
    end
  end
end
