---@class Conductor:Classic
local Conductor = Classic:extend("Conductor")

-- ITS NOT CROCHET
-- ITS CROTCHET!!!!
-- DONT LET FNF BRAINROTS YOU
-- TODO: make conductor on normal second instead of ms

function Conductor.calculateCrotchet(bpm) return (60 / bpm) * 1000 end

function Conductor.sortByTime(a, b) return a.time < b.time end

function Conductor.sortBySection(a, b) return a.section < b.section end

function Conductor.getDummyBPMChange(bpm)
	if type(bpm) == "table" then bpm = bpm.bpm end
	return {
		time = 0,
		step = 0,
		bpm = bpm,
		stepCrotchet = Conductor.calculateCrotchet(bpm) / 4,
		id = 0 -- is calculated in mapBPMChangeFromSong(), sortBPMChanges()
	}
end

function Conductor.getDummySectionChange(beats)
	if type(beats) == "table" then beats = beats.beats end
	return {
		section = 0,
		beats = beats,
		id = 0 -- is calculated in getSectionChangesFromSong()
	}
end

function Conductor.newBPMChanges(bpm, list)
	list = list or {}; table.clear(list)
	list[0] = Conductor.getDummyBPMChange(bpm)
	return list
end

function Conductor.newSectionChanges(beats, list)
	list = list or {}; table.clear(list)
	list[0] = Conductor.getDummySectionChange(beats)
	return list
end

-- function Conductor.getSectionChangesFromSong(song, sectionChanges)
-- 	local beats, total = song.beats or 4, 0
-- 	local prev = beats
-- 	sectionChanges = Conductor.newSectionChanges(beats, sectionChanges)

-- 	for i, v in ipairs(song.notes) do
-- 		if v.sectionBeats ~= nil then
-- 			beats = v.sectionBeats
-- 		else
-- 			beats = 4
-- 		end
-- 		if prev ~= beats then
-- 			prev, total = beats, total + 1
-- 			table.insert(sectionChanges, {
-- 				section = i,
-- 				beats = beats,
-- 				id = total
-- 			})
-- 		end
-- 	end

-- 	return sectionChanges
-- end

function Conductor.sortBPMChanges(bpmChanges)
	table.sort(bpmChanges, Conductor.sortByTime)
	for i = 1, #bpmChanges do bpmChanges[i].id = i end
end

function Conductor.getBPMChangeFromIndex(bpmChanges, index)
	index = math.min(index or 0, #bpmChanges)

	local lastChange = bpmChanges[index]
	if lastChange == nil then
		return bpmChanges[0]
	elseif lastChange.id == index then
		return lastChange
	end

	Conductor.sortBPMChanges(bpmChanges); lastChange = bpmChanges[index]
	return lastChange or bpmChanges[0]
end

function Conductor.sortSectionChanges(sectionChanges)
	table.sort(sectionChanges, Conductor.sortBySection)
	for i = 1, #sectionChanges do sectionChanges[i].id = i end
end

function Conductor.getSectionChangeFromIndex(sectionChanges, index)
	index = math.min(index or 0, #sectionChanges)

	local lastChange = sectionChanges[index]
	if lastChange == nil then
		return sectionChanges[0]
	elseif lastChange.id == index then
		return lastChange
	end

	Conductor.sortSectionChanges(sectionChanges); lastChange = sectionChanges[index]
	return lastChange or sectionChanges[0]
end

function Conductor.getBPMChangeFromTime(bpmChanges, time, from)
	local size = #bpmChanges
	if size == 0 or time < bpmChanges[1].time then
		return bpmChanges[0]
	elseif time >= bpmChanges[size].time then
		return bpmChanges[size]
	end

	local lastChange = Conductor.getBPMChangeFromIndex(bpmChanges, from)
	local reverse = lastChange.time > time
	from = lastChange.id

	local i, v = from < 1 and (reverse and size or 1) or from + (reverse and -1 or 1)
	while reverse and i > 0 or i <= size do
		v = bpmChanges[i]
		if v.id ~= i then
			Conductor.sortBPMChanges(bpmChanges)
			return Conductor.getBPMChangeFromTime(bpmChanges, time, i)
		end
		if reverse then if v.time <= time then break end elseif v.time > time then break end
		lastChange, i = v, reverse and i - 1 or i + 1
	end
	return lastChange
end

function Conductor.getBPMChangeFromStep(bpmChanges, step, from)
	local size = #bpmChanges
	if size == 0 or step < bpmChanges[1].step then
		return bpmChanges[0]
	elseif step >= bpmChanges[size].step then
		return bpmChanges[size]
	end

	local lastChange = Conductor.getBPMChangeFromIndex(bpmChanges, from)
	local reverse = lastChange.step > step
	from = lastChange.id

	local i, v = from < 1 and (reverse and size or 1) or from + (reverse and -1 or 1)
	while reverse and i > 0 or i <= size do
		v = bpmChanges[i]
		if v.id ~= i then
			Conductor.sortBPMChanges(bpmChanges)
			return Conductor.getBPMChangeFromStep(bpmChanges, step, i)
		end
		if reverse then if v.step <= step then break end elseif v.step > step then break end
		lastChange, i = v, reverse and i - 1 or i + 1
	end
	return lastChange
end

function Conductor.getSectionChange(sectionChanges, section, from)
	local size = #sectionChanges
	if size == 0 or section < sectionChanges[1].section then
		return sectionChanges[0]
	elseif section >= sectionChanges[size].section then
		return sectionChanges[size]
	end

	local lastChange = Conductor.getSectionChangeFromIndex(sectionChanges, from)
	local reverse = lastChange.section > section
	from = lastChange.id

	local i, v = from < 1 and (reverse and size or 1) or from + (reverse and -1 or 1)
	while reverse and i > 0 or i <= size do
		v = sectionChanges[i]
		if v.id ~= i then
			Conductor.sortSectionChanges(sectionChanges)
			return Conductor.getSectionChange(sectionChanges, section, i)
		end
		if reverse then if v.section <= section then break end elseif v.section > section then break end
		lastChange, i = v, reverse and i - 1 or i + 1
	end
	return lastChange
end

function Conductor.stepToTimeFromBPMChange(bpmChange, step, offset)
	return bpmChange.time + (step - bpmChange.step - offset) * bpmChange.stepCrotchet
end

function Conductor.stepToTime(bpmChanges, step, offset, from)
	return Conductor.stepToTimeFromBPMChange(Conductor.getBPMChangeFromStep(bpmChanges, step, from), step, offset)
end

function Conductor.beatToTimeFromBPMChange(bpmChange, beat, offset)
	return Conductor.stepToTimeFromBPMChange(bpmChange, beat * 4, offset * 4)
end

function Conductor.beatToTime(bpmChanges, beat, offset, from)
	return Conductor.stepToTime(bpmChanges, beat * 4, offset * 4, from)
end

function Conductor.getStepFromBPMChange(bpmChange, time, offset)
	return bpmChange.step + (time - bpmChange.time - offset) / bpmChange.stepCrotchet
end

function Conductor.getStep(bpmChanges, time, offset, from)
	return Conductor.getStepFromBPMChange(Conductor.getBPMChangeFromTime(bpmChanges, time, from), time, offset)
end

function Conductor.getBeatFromBPMChange(bpmChange, time, offset)
	return Conductor.getStepFromBPMChange(bpmChange, time, offset, from) / 4
end

function Conductor.getBeat(bpmChanges, time, offset, from)
	return Conductor.getStep(bpmChanges, time, offset, from) / 4
end

function Conductor:new(bpm)
	self:setBPM(bpm or 120)

	self.time = 0
	self.offset = 0

	self.currentStepFloat, self.currentStep = 0, 0
	self.currentBeatFloat, self.currentBeat = 0, 0
	self.currentSectionFloat, self.currentSection = 0, 0

	self.lastStepFloat, self.lastStep = 0, 0
	self.lastBeatFloat, self.lastBeat = 0, 0
	self.lastSectionFloat, self.lastSection = 0, 0

	self.stepsToDo, self.stepsOnSection = 0, 0
	self.passedSections, self.currentSectionChange = {}, nil
	self.currentBPMChange = nil
end

function Conductor:setBPM(bpm, bpmChanges, sectionChanges)
	self.bpm = bpm
	self.bpmChanges = bpmChanges or Conductor.newBPMChanges(bpm, self.bpmChanges)
	self.sectionChanges = sectionChanges or Conductor.newSectionChanges(4, self.sectionChanges)

	self.beats = self.sectionChanges[0] and self.sectionChanges[0].beats or 4
	self.dummyBPMChange = self:getDummyBPMChange()
	self.dummySectionChange = self:getDummySectionChange()

	self.crotchet = Conductor.calculateCrotchet(bpm)
	self.stepCrotchet = self.crotchet / 4

	return self
end

function Conductor:setSong(song)
	self:setBPM(song.bpm,
		song.bpmChanges
	-- Conductor.getSectionChangesFromSong(song, self.sectionChanges)
	)

	return self
end

function Conductor:update()
	self.lastStepFloat, self.lastStep = self.currentStepFloat, self.currentStep
	self.lastBeatFloat, self.lastBeat = self.currentBeatFloat, self.currentBeat
	self.lastSectionFloat, self.lastSection = self.currentSectionFloat, self.currentSection

	local time, bpmChange = self.time - self.offset, self.currentBPMChange
	bpmChange = Conductor.getBPMChangeFromTime(self.bpmChanges, time,
		bpmChange == nil and 0 or bpmChange.id) or self.dummyBPMChange

	self.currentBPMChange = bpmChange
	self.currentStepFloat = Conductor.getStepFromBPMChange(bpmChange, time, 0)
	self.currentStep = math.floor(self.currentStepFloat)

	self.currentBeatFloat = self.currentStepFloat / 4
	self.currentBeat = math.floor(self.currentBeatFloat)

	if self.lastStep ~= self.currentStep then
		self:__step()
		if self.currentStep > self.lastStep then
			self:updateSection()
		else
			self:rollbackSection()
		end
	end
end

-- need a fucking rewrite lmao
function Conductor:updateSection(dontHit)
	local sectionChange, passedSections = self.currentSectionChange, self.passedSections
	if self.stepsToDo <= 0 then
		sectionChange, self.currentSection = self.dummySectionChange, 0
		self.stepsOnSection = sectionChange.beats * 4
		self.stepsToDo = self.stepsOnSection
	end

	while self.currentStep >= self.stepsToDo do
		table.insert(passedSections, self.stepsToDo)

		self.currentSection = #passedSections
		self.currentSectionFloat = self.currentSection
		sectionChange = Conductor.getSectionChange(self.sectionChanges, self.currentSection + 1,
			sectionChange == nil and 0 or sectionChange.id) or self.dummySectionChange

		self.stepsOnSection = sectionChange.beats * 4
		self.stepsToDo = self.stepsToDo + self.stepsOnSection
		if not dontHit then
			self.currentSectionChange = sectionChange
			if self.onSection then self.onSection(self.currentSection) end
		end
	end

	self.currentSectionChange = sectionChange
	self.currentSectionFloat = self.currentSection +
		(self.currentStepFloat - (passedSections[self.currentSection - 1] or -self.stepsOnSection))
		/ self.stepsOnSection
end

function Conductor:rollbackSection()
	if self.currentStep <= 0 then
		self.stepsToDo = 0
		self:updateSection()
		if self.onSection and self.currentBeat < 1 and self.currentSection ~= self.lastSection then
			self.onSection(self.currentSection)
		end
		return
	end

	local newSection = #self.passedSections
	while newSection > 1 and (self.passedSections[self.currentSection - 1] and
			self.currentStep < self.passedSections[self.currentSection - 1]) do
		stepsToDo = table.remove(self.passedSections)
		newSection = newSection - 1
	end

	if self.onSection and self.currentSection > self.lastSection then
		self.onSection(self.currentSection)
	end
end

function Conductor:__step()
	--[[print(
		self.currentStep, self.currentBPMChange.id, #self.bpmChanges,
		(self.bpmChanges[self.currentBPMChange.id + 1] or self.currentBPMChange).step
	)]]

	if self.onStep then self.onStep(self.currentStep) end
	if self.onBeat and self.lastBeat ~= self.currentBeat then
		self.onBeat(self.currentBeat)
	end
end

return Conductor
