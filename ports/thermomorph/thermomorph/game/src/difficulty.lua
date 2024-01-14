function SetDifficulty(hour)
  log.debug("Setting difficulty to " .. hour)
  if hour == 1 then
    TRANSITION_TIME_RANGE = vector(4, 6)
    NUM_MONSTERS = 1
    ATTACKING_TIME = 3
    INTRO_SOUND = 'assets/sound/hour-1-call.mp3'
    HIDDEN_MESSAGE = 'assets/sound/morse-1.wav'
    HEATING_ENABLED = false
    FLAME_FUEL = 15
  elseif hour == 2 then
    TRANSITION_TIME_RANGE = vector(2, 4)
    ATTACKING_TIME = 3
    NUM_MONSTERS = 1
    INTRO_SOUND = 'assets/sound/hour-2-call.mp3'
    HIDDEN_MESSAGE = 'assets/sound/morse-2.wav'
    HEATING_ENABLED = true
    FLAME_FUEL = 15
  elseif hour == 3 then
    TRANSITION_TIME_RANGE = vector(2, 4)
    ATTACKING_TIME = 3
    NUM_MONSTERS = 2
    INTRO_SOUND = 'assets/sound/hour-3-call.mp3'
    HIDDEN_MESSAGE = 'assets/sound/morse-3.wav'
    HEATING_ENABLED = true
    FLAME_FUEL = 20
  else
    error("Unknown hour.")
  end
end
