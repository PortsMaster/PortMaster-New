-- create a new campaign
local c = Campaign.new("taxi")
-- set an ingame icon for this campaign
--c:setSetting("icon", "wind-campaign")
-- set the on screen message when this campaign is activated
c:setSetting("text", "Taxi")
-- now add all maps
c:addMaps("taxi-01")
c:addMaps("taxi-02")
c:addMaps("taxi-03")
c:addMaps("taxi-04")
c:addMaps("taxi-05")
c:addMaps("taxi-06")
