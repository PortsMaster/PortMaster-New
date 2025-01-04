local Highscore = {
	scores = {
		songs = {},
		weeks = {}
	}
}

function Highscore.saveScore(song, score, diff)
	local formatSong = paths.formatToSongPath(song) .. '-' .. diff:lower()

	if Highscore.scores.songs[formatSong] then
		if Highscore.scores.songs[formatSong] < score then
			Highscore.scores.songs[formatSong] = score
		end
	else
		Highscore.scores.songs[formatSong] = score
	end
	game.save.data.scores = Highscore.scores
end

function Highscore.saveWeekScore(week, score, diff)
	local formatWeek = week .. '-' .. diff:lower()

	if Highscore.scores.weeks[formatWeek] then
		if Highscore.scores.weeks[formatWeek] < score then
			Highscore.scores.weeks[formatWeek] = score
		end
	else
		Highscore.scores.weeks[formatWeek] = score
	end
	game.save.data.scores = Highscore.scores
end

function Highscore.getScore(song, diff)
	local formatSong = paths.formatToSongPath(song) .. '-' .. diff:lower()

	if Highscore.scores.songs[formatSong] == nil then
		Highscore.scores.songs[formatSong] = 0
	end

	return Highscore.scores.songs[formatSong]
end

function Highscore.getWeekScore(week, diff)
	local formatWeek = week .. '-' .. diff:lower()

	if Highscore.scores.weeks[formatWeek] == nil then
		Highscore.scores.weeks[formatWeek] = 0
	end

	return Highscore.scores.weeks[formatWeek]
end

function Highscore.load()
	if game.save.data.scores then
		Highscore.scores = game.save.data.scores
	end
end

return Highscore
