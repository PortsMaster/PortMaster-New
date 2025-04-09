-- wave.lua v0.1

-- Copyright (c) 2016 Ulysse Ramage
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local wave, waveObject = {
  overwrite = false,
  
  energyRatio = 1.2, --energy peak detection threshold
  trainSize = 108, --train size for convolution, blocks of 1024 (430 = 10s)
  
  minLength = 2048 --minimum length, in samples, to parse audio
  
}, {}
setmetatable(wave, wave)

--[[ Private ]]--

local tr2 = 1.0594630943592952645

local playInstance, stopInstance, isPlaying

local function removeStopped(sources)
	local remove = {}
	for s in pairs(sources) do
		remove[s] = true
	end
	for s in pairs(remove) do
		sources[s] = nil
	end
end

local function lerp(a, b, k) --smooth transitions
  if a == b then
    return a
  else
    if math.abs(a-b) < 0.005 then return b else return a * (1-k) + b * k end
  end
end

--[[ Public - Wave ]]--

function wave:newSource(path, type)
  local _object = {
		_paused   = false,
		path      = path,
		type      = type,
		instances = {},
		looping   = false,
		pitch     = 1,
		volume    = 1
	}
  
  setmetatable(_object, { __index = waveObject })
  
  if _object.type == "static" then
    _object:parse()
  end

  return _object
end

--[[ Public - Source ]]--

function waveObject:play(pitched)
  
  removeStopped(self.instances)
	if self._paused then self:stop() end
  
  self._paused = false
  
	local instance = love.audio.newSource(self.data or self.path, self.type or "stream")

	-- overwrite instance:stop() and instance:play()
	if not (playInstance and stopInstance) then
		playInstance = getmetatable(instance).play  

		stopInstance = getmetatable(instance).stop
    
    isPlaying = getmetatable(instance).isPlaying
    
    if wave.overwrite then
      getmetatable(instance).play = error
      getmetatable(instance).stop = function(this)
        stopInstance(this)
        self.instances[this] = nil
      end
      getmetatable(instance).isPlaying = error
    end
	end

	instance:setLooping(self.looping)
	instance:setPitch(self.pitch + (pitched and (math.random()-.5)*.1 or 0) )
	instance:setVolume(self.volume)

	self.instances[instance] = instance
	playInstance(instance)
	
  if self:isMusic() or self:isParsed() then
    self.instance = instance
    if self:isMusic() then --start listening to beat
      
      self.duration = self.duration or self.instance:getDuration()
      self.previousFrame = love.timer.getTime() * 1000
      self.lastTime = 0
      self.time = 0
      self.beat = 0
      self.beatTime = 0
      
    end
    return self
  else
    return self
  end
  
end

function waveObject:stop()
	for s in pairs(self.instances) do
		s:stop()
	end
	self._paused = false
	self.instances = {}
  return self
end

function waveObject:pause()
	if self._paused then return end
	for s in pairs(self.instances) do
		s:pause()
	end
	self._paused = true
  return self
end

function waveObject:resume()
	if not self._paused then return end
	for s in pairs(self.instances) do
		s:resume()
	end
	self._paused = false
  return self
end

function waveObject:seek(position, unit)
  for s in pairs(self.instances) do
    s:seek(position, unit)
  end
  self.time = position * 1000
  self.lastTime = position * 1000
  self.previousFrame = love.timer.getTime() * 1000
  self.beatTime = self:calculateBeat()
  self.beat = math.floor(self.beatTime)
  return self
end

--// Configure music

function waveObject:parse()
  assert(not self.data, "Audio is already parsed.")
  self.data = love.sound.newSoundData(self.path)
  self.length = self.data:getSampleCount()
  self.duration = self.data:getDuration()
  return self
end

--

function waveObject:setBPM(bpm)
  self.bpm = bpm
  self.bps = 60 / bpm
  self.detector = nil
  return self
end

function waveObject:setOffset(offset)
  self.offset = offset
  return self
end

function waveObject:onBeat(f)
  self.onBeat = f
  return self
end

function waveObject:getBeat()
  return self.beat
end

function waveObject:getBeatTime()
  return self.beatTime - self.beat
end

function waveObject:calculateBeat()
  return (self.bpm / 60) * ((self.time + (self.offset or 0)) % (self.duration * 1000)) / 1000
end

--

function waveObject:fadeIn(target)
  if self:getTargetVolume() ~= 0 and not self:isPaused() then return self end
  if self:isPlaying() and self:isPaused() then --playing but paused
    self:resume()
  elseif not self:isPlaying() then --not playing
    self:play()
  end
  self:setTargetVolume(target or 1)
  self.isFadingOut = nil
  return self
end

function waveObject:fadeOut(speed)
  self.isFadingOut = speed or true
  self:setTargetVolume(0)
  return self
end

--

function waveObject:setIntensity(intensity)
  self.intensity = intensity
  self.energy = 0
  return self
end

function waveObject:getEnergy()
  if not self:isParsed() then return 0 end
  return self.energy
end

--// Get/set properties
for _, property in ipairs{'looping', 'pitch', 'volume'} do
	local name = property:sub(1,1):upper() .. property:sub(2)
  
	waveObject['get' .. name] = function(self)
		return self[property]
	end

	waveObject['set' .. name] = function(self, val, force)
    if force then waveObject['setTarget' .. name](self, val) end
		self[property] = val
		for s in pairs(self.instances) do
			s['set' .. name](s, val)
		end
    return self
	end
end

for _, property in ipairs{'pitch', 'volume'} do
	local name = 'Target' .. property:sub(1,1):upper() .. property:sub(2)
	waveObject['get' .. name] = function(self)
		return self['target' .. property]
	end

	waveObject['set' .. name] = function(self, val)
		self['target' .. property] = val
    return self
	end
end

function waveObject:tone(offset)
  
  local pitch = self:getTargetPitch() or self:getPitch()
  
  pitch = pitch * (tr2 ^ offset)
  
  return pitch
  
end

function waveObject:octave(offset) return self:tone(offset * 12) end

--// Beat detection

function waveObject:detectBPM()
  assert(self:isParsed(), "Parse audio before enabling beat detection.")
  
  local length = self.length
  local size = math.floor(length/1024)
  
  self.detector = {
    
    length = length,
    e1024 = {}, --size
    e44100 = {}, --size
    energyPeak = {}, --size + 21
    
    size = size
  }
  
  for i=0, size + 21 do
    self.detector.energyPeak[i] = 0
  end
  
  self:setBPM( self:calculateBPM() ) --heavy stuff
  
  return self
end

function waveObject:calculateEnergy(offset, size, limiter)
  
  local _energy = 0
  for i = offset, offset + size do
    _energy = _energy + (self.data:getSample(i) ^ 2)/ (limiter or size);
  end
  
  return _energy
end

function waveObject:normalizeSignal(signal, size, maxValue)
  local max = 0
  
  for i = 0, size do
    if (math.abs(signal[i]) > max) then
      max = math.abs(signal[i])
    end
  end

  --adjust signal
  local ratio = maxValue / max

  for i = 0, size do
    signal[i] = signal[i] * ratio
  end

  return signal
end

function waveObject:findMax(signal, position, size)
  local half = size * .5
  local max = 0
  local maxPosition = position

  for i = position-half, position+half do

    if signal[i] > max then
      max = signal[i]
      maxPosition = i
    end

  end

  return maxPosition
end

function waveObject:calculateBPM()

  local _d = self.detector
  
  local _size = _d.size --length/1024

  --calculate instant energy

  for i = 0, _size + 42 do
    _d.e1024[i] = self:calculateEnergy(1024 * i, 4096) --4096 makes it smoother
  end

  --calculate average energy for 1 sec

  _d.e44100[0] = 0

  --average of the first 43 first e1024 gives the average e44100

  local sum = 0

  for i = 0, 43 do
    sum = sum + _d.e1024[i];
  end

  _d.e44100[0] = sum / 43;

  --fill others
  
  for i = 1, _size do
    sum = sum - _d.e1024[i - 1] + _d.e1024[i + 42] --because 42 is the only answer
    _d.e44100[i] = sum / 43;
  end

  --calculate ratio

  for i = 21, _size do

    -- -21 centers e1024 on e44100's second

    if (_d.e1024[i] > wave.energyRatio * _d.e44100[i-21]) then
      
      _d.energyPeak[i] = 1
      
    end

  end

  --calculate BPM

  --calculate time between every energy peak

  local T = {}

  local iPrevious = 0

  for i = 1, _size do

    if (_d.energyPeak[i] == 1) and (_d.energyPeak[i-1] == 0) then

      local di = i - iPrevious

      if (di > 5) then --interferences

        table.insert(T, di)

        iPrevious = i

      end
    end
  end

  --let the statistics begin

  local maxOccT, avgOccT = 0, 0

  --count the frequency of each interval

  local occT = {}; --86 = max 2 blocks of 43 gap (=2s)

  for i = 0, 86 do
    occT[i] = 0
  end

  for i = 1, #T do
    if(T[i] <= 86) then
      occT[T[i]] = occT[T[i]] + 1
    end
  end
  

  local occMax = 0

  for i = 1, 86 do

    if occT[i] > occMax then

      occMaxT = i

      occMax = occT[i]

    end
  end

  --average of max + max neighbour for more precision

  local neighbour = occMaxT - 1

  if (occT[occMaxT + 1] > occT[neighbour]) then
    neighbour = occMaxT + 1
  end

  local div = occT[occMaxT] + occT[neighbour]

  if div == 0 then
    avgOccT = 0
  else
    avgOccT = (occMaxT * occT[occMaxT] + neighbour * occT[neighbour]) / div
  end



  --last step

  local bpm = 60 / (avgOccT * (1024/44100))
  
  while bpm < 90 or bpm > 180 do --clamp at a reasonable bpm
    if bpm < 90 then
      bpm = bpm * 2
    else
      bpm = bpm * .5
    end
  end
  
  return math.floor(bpm + .5)
end

--// Update

function waveObject:update(dt)
  if not self:isPaused() then
    if self:isMusic() then self:updateBeat(dt) end
    if self:isParsed() then self:updateEnergy(dt) end
  end
  
  self:updateProperties(dt)
  
  return self
end

function waveObject:updateBeat(dt)
  local _instance = self.instances[self.instance]
  if not _instance then return self end
  
  local _offset = love.timer.getTime() * 1000
  
  local _elapsedBeats = 0
  
  self.time = self.time + _offset - self.previousFrame
  
  self.previousFrame = _offset
  local _position = _instance:tell("seconds") * 1000
  if _position < self.lastTime then --music looped
    self.time = _position
    self.lastTime = _position
    _elapsedBeats = _elapsedBeats + 1
    self.beat = 0
  elseif _position ~= self.lastTime then --updates music time, but with easing
    self.time = (self.time + (_position))/2
    self.lastTime = _position
  end
  
  self.beatTime = self:calculateBeat()
  
  local _beat = math.floor(self.beatTime)
  _elapsedBeats = _elapsedBeats + _beat - self.beat
  self.beat = _beat
  
  if self.onBeat then
    for i = 1, _elapsedBeats do
      self.onBeat()
    end
  end
  
  return self
end

function waveObject:updateEnergy(dt)
  local _instance = self.instances[self.instance]
  if not _instance then return self end
  
  local _sample = _instance:tell( "samples" )
  local size = 1024
  if _sample > size then
    
    local _energy = self:calculateEnergy(_sample, size, self.intensity)
    self.energy = lerp(self.energy, _energy, 10*dt)
     
  end
  return self
end

function waveObject:updateProperties(dt)
  
  if self:getTargetPitch() then
    self:setPitch(lerp(self:getPitch(), self:getTargetPitch(), 2*dt))
  end
  
  if self:getTargetVolume() then
    self:setVolume(
      lerp(
        self:getVolume(),
        self:getTargetVolume(),
        ((self.isFadingOut and self.isFadingOut ~= true) and self.isFadingOut or 2)*dt)
    )
  end

  if self.isFadingOut and self:getVolume() == self:getTargetVolume() then
    self.isFadingOut = nil
    self:pause()
  end
  
end

--// Checks

function waveObject:isMusic() return self.bpm and true or false end
function waveObject:isParsed() return (self.data and self.duration > 10) and true or false end

function waveObject:isPaused() return self._paused end

function waveObject:isPlaying() 
  local _playing = false
  for s in pairs(self.instances) do
		if s then _playing = true end --if there's at least one instance
	end
  return _playing
end

--[[ Aliases ]]--

waveObject.isLooping = waveObject.getLooping

function waveObject:fade(inout, target) if inout == "in" then return self:fadeIn(target) else return self:fadeOut() end end

--[[ End ]]--

return wave
