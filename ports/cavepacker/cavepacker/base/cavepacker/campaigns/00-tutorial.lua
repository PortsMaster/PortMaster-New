-- create a new campaign
local c = Campaign.new("tutorial")
-- set an ingame icon for this campaign
c:setSetting("icon", "icon-campaign")
-- set the on screen message when this campaign is activated
c:setSetting("text", "Tutorial")
-- set the achievement id that you unlock once you finished this campaign
c:setSetting("achievement", "achievement_finished_tutorials")
-- now add all maps
c:addMaps("tutorial*")
c:unlock()
