local Talkies = require("talkies")
local say = Talkies.say

Talkies.say = function(title, messages, config)
    if title == "Cybion" or title == "Cebion" then
        title = "Ronax"
    end
    return say(title, messages, config)
end
