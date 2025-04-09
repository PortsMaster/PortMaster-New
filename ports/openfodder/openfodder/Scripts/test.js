
Scenario.Testing = {

    Start: function(pMissionNumber, pPhaseNumber) {

		Scenario.Random.Start(pMissionNumber, pPhaseNumber);
    },

    Settings: function(pMissionNumber, pPhaseNumber) {
       //Settings.FromSeed(3);
	   Settings.Random();
	   return;
       Settings.Width = 40;
       Settings.Height = 40;
       Settings.TerrainType = Terrain.Types.Jungle;

       Settings.RandomUpdate();
       Settings.setObjectives( [Objectives.KillAllEnemy, Objectives.DestroyEnemyBuildings] );
    }
}


OpenFodder.start();
//OpenFodder.createPhases(1, Scenario.Random);
//createSmallMap();

OpenFodder.createPhases(1, Scenario.Testing);
//OpenFodder.createPhases(1, Scenario.Random.Start, Scenario.RandomSmall.Settings);


//OpenFodder.createMissions(2, [1, 2], createMapContent);
//createSmallMap();

// Some Fun
/*
RandomLast = null;

for(count = 0; count < 5; ++count) {
	Random = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), 1, false);

	if(RandomLast != null)
		Strange.PlaceSpritesOnPath(SpriteTypes.GrenadeBox,Random, RandomLast);

	Strange.PlaceSpritesOnPath(SpriteTypes.GrenadeBox, Random, Session.HumanPosition);
	RandomLast = Random;
}*/

/*
for(count = 0; count < Session.HostageGroupPositions.length; ++count) {

	//Strange.PlaceSpritesOnPath(SpriteTypes.Enemy, Session.HostageGroupPositions[count], Session.HumanPosition);
	Strange.PlaceSpritesOnPath(SpriteTypes.GrenadeBox, Session.HostageGroupPositions[count], Session.HumanPosition);

	//Strange.PlaceSpritesOnPath(SpriteTypes.Enemy, Session.HostageGroupPositions[count], Session.RescueTentPosition);
	Strange.PlaceSpritesOnPath(SpriteTypes.GrenadeBox, Session.HostageGroupPositions[count], Session.RescueTentPosition);
}
Map.SpriteAdd(SpriteTypes.Helicopter_Missile_Human,  Session.HumanPosition.x,  Session.HumanPosition.y);

if(Session.RescueHelicopter !== null)
	Strange.PlaceSpritesOnPath(SpriteTypes.GrenadeBox, Session.RescueHelicopter, Session.HumanPosition);

*/