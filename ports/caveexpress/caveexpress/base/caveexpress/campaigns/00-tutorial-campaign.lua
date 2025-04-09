-- create a new campaign
local c = Campaign.new("tutorial")
-- set an ingame icon for this campaign
--c:setSetting("icon", "tutorial-campaign")
-- set the on screen message when this campaign is activated
c:setSetting("text", "Introduction")
c:setSetting("achievement", "achievement_finish_the_tutorial")
-- now add all maps
c:addMaps("introducing-01-package")
c:addMaps("introducing-02-game")
c:addMaps("introducing-03-tree")
c:addMaps("introducing-04-geyser")
c:addMaps("introducing-05-flying")
c:addMaps("introducing-06-attack")
c:addMaps("introducing-07-findyourway")
c:addMaps("introducing-08-npcdeliver")
c:addMaps("introducing-09-npcrescue")
--c:addMaps("introducing-10-placestone")
c:unlock()
