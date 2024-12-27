local Events = {
	Cancellable = require "funkin.backend.scripting.events.cancellable",
	NoteHit = require "funkin.backend.scripting.events.notehit",
	Miss = require "funkin.backend.scripting.events.miss",
	PopUpScore = require "funkin.backend.scripting.events.popupscore",
	CameraMove = require "funkin.backend.scripting.events.cameramove",
	GameOver = require "funkin.backend.scripting.events.gameover",
	CountdownCreation = require "funkin.backend.scripting.events.countdowncreation"
}

return Events
