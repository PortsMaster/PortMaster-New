local Talkies = require("talkies")
local originalSay = Talkies.say

Talkies.say = function(title, messages, config)
    if title == "Cybion" then
        title = "Ronax"
    end
    return originalSay(title, messages, config)
end
