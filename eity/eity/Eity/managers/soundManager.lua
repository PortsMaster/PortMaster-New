soundManager = {}



function soundManager:SetMainVolume(volume)
  saveManager.settings.mainVolume = volume
  love.audio.setVolume(volume)
end

function soundManager:SetMusicVolume(volume)  
  saveManager.settings.musicVolume = volume
  soundManager.mainmenusrc:setVolume(volume)
end

function soundManager:SetEffectsVolume(volume)
  saveManager.settings.effectVolume = volume
  effectsVolume = volume
  
  soundManager.buttonOversrc:setVolume(volume)
  soundManager.buttonHitsrc:setVolume(volume)

  soundManager.hitsrc:setVolume(volume)
  soundManager.hitSlidersrc:setVolume(volume)
  soundManager.misssrc:setVolume(volume)
end


function soundManager:load()
  soundManager.mainmenusrc = love.audio.newSource("assets/verse_one_bgmusic.mp3", "static")
  
  soundManager.buttonOversrc = love.audio.newSource("assets/ButtonOver.wav", "static")
  soundManager.buttonHitsrc = love.audio.newSource("assets/ButtonHit.wav", "static")
  
  soundManager.hitsrc = love.audio.newSource("assets/hit.wav", "static")
  soundManager.hitSlidersrc = love.audio.newSource("assets/slider.wav", "static")
  soundManager.misssrc = love.audio.newSource("assets/miss.wav", "static")
  
  soundManager:SetMainVolume(saveManager.settings.mainVolume)
  soundManager:SetMusicVolume(saveManager.settings.musicVolume)  
  soundManager:SetEffectsVolume(saveManager.settings.effectVolume)
  
end

function soundManager.playSoundEffect(source)
	local clone = source:clone()
	clone:play()
end

function soundManager:Restart()
  mapSong:stop()
  mapSong:play()
end

return soundManager
