local discordRPC = require "lib.discordRPC"

---@class Discord
local Discord = {}

Discord.isInitialized = false
Discord.clientID = "1098761843956273304"

local __options = {
	details = "Starting",
	state = nil,
	largeImageKey = "icon",
	largeImageText = "FNF LÖVE",
	smallImageKey = nil,
	startTimestamp = nil,
	endTimestamp = nil
}

function discordRPC.ready(userId, username, discriminator, avatar)
	print(string.format("Discord: ready (%s, %s, %s, %s)", userId, username,
		discriminator, avatar))

	discordRPC.updatePresence(__options)
end

function discordRPC.disconnected(errorCode, message)
	print(string.format("Discord: disconnected (%d: %s)", errorCode, message))
end

function discordRPC.errored(errorCode, message)
	print(string.format("Discord: error (%d: %s)", errorCode, message))
end

function Discord.init()
	discordRPC.initialize(Discord.clientID, true)

	print("Discord Client initialized")
	Discord.isInitialized = true
end

function Discord.shutdown() discordRPC.shutdown() end

function Discord.changePresence(options)
	__options = options
	__options.largeImageKey = options.largeImageKey or "icon"
	__options.largeImageText = options.largeImageText or "FNF LÖVE"

	discordRPC.updatePresence(__options)
end

function Discord.update() discordRPC.runCallbacks() end

return Discord
