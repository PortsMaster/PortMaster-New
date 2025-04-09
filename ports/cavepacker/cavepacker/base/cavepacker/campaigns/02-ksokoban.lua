-- create a new campaign
local c = Campaign.new("ksokoban")
-- set an ingame icon for this campaign
c:setSetting("icon", "ksokoban-campaign")
-- set the on screen message when this campaign is activated
c:setSetting("text", "KSokoban")
-- set the achievement id that you unlock once you finished this campaign
c:setSetting("achievement", "achievement_finished_the_grigorusha_campaign")
-- now add all maps
c:addMaps("microban*")
c:addMaps("sasquatch*")
c:unlock()
