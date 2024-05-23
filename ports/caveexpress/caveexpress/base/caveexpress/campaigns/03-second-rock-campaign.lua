-- create a new campaign
local c = Campaign.new("secondrock")
-- set an ingame icon for this campaign
c:setSetting("icon", "icon-campaign-rock")
-- set the on screen message when this campaign is activated
c:setSetting("text", "SecondRock")
-- now add all maps
c:addMaps("second-rock-01")
c:addMaps("second-rock-02")
c:addMaps("second-rock-03")
c:addMaps("second-rock-04")
c:addMaps("second-rock-05")
c:addMaps("second-rock-06")
