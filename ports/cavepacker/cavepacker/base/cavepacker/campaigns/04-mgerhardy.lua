-- create a new campaign
local c = Campaign.new("mgerhardy")
-- set an ingame icon for this campaign
c:setSetting("icon", "mgerhardy-campaign")
-- set the on screen message when this campaign is activated
c:setSetting("text", "mgerhardy")
-- set the achievement id that you unlock once you finished this campaign
c:setSetting("achievement", "achievement_finsihed_the_mgerhardy_campaign")
-- now add all maps
c:addMaps("mgerhardy*")
c:unlock()
