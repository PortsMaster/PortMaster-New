
Scenario.Random = {

    Start: function(pMissionNumber, pPhaseNumber) {

        Human.RandomXY(8);
        Background.Random( Settings.GetBackgroundObjectCount() );
    
        // Randomize kill all enemy?
        if(Settings.hasObjective(Objectives.KillAllEnemy))
            Objectives.KillAllEnemy.Random(Settings.GetEnemyCount());
    
        // Randomsize Destroy enemy buildings
        if(Settings.hasObjective(Objectives.DestroyEnemyBuildings))
            Objectives.DestroyEnemyBuildings.Random(Settings.GetEnemyBuildingCount());

        // Random Rescue Hostages
        if(Settings.hasObjective(Objectives.RescueHostages)) {
            for(var x = 0; x < Settings.GetHostageCount(); ++x) {
                Objectives.RescueHostages.Random(Settings.GetHostageGroupSize());
            }
        }
    
        // Random Get Civilian home
        if(Settings.hasObjective(Objectives.GetCivilianHome)) {
            Objectives.GetCivilianHome.Random();
        }

        Structures.PlaceBuildings(Settings.GetCivilianBuildingCount());

        Weapons.RandomGrenades(Settings.GetMinimumGrenades());
        Weapons.RandomRockets(Settings.GetMinimumRockets() / 2);
    },

    Settings: function(pMissionNumber, pPhaseNumber) {
        Settings.Random();
    }
};

Scenario.RandomSmall = {

    Start: function(pMissionNumber, pPhaseNumber) {

        Scenario.Random.Start(pMissionNumber, pPhaseNumber);
    },

    Settings: function(pMissionNumber, pPhaseNumber) {
       //Settings.FromSeed(-28133);
       Settings.Random();
       Settings.Width = 40;
       Settings.Height = 40;
       Settings.TerrainType = Terrain.Types.Jungle;

       Settings.RandomUpdate();
       Settings.setObjectives( [Objectives.KillAllEnemy, Objectives.DestroyEnemyBuildings] );
    }
}

