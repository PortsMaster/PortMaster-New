-- create a new campaign
local c = Campaign.new("wind")
-- set an ingame icon for this campaign
--c:setSetting("icon", "wind-campaign")
-- set the on screen message when this campaign is activated
c:setSetting("text", "Wind")
-- now add all maps
c:addMaps("wind-01")
c:addMaps("wind-02")
c:addMaps("wind-03")
c:addMaps("wind-04")
