
/**
 * Create random map objectives
 */
function createRandom() {
	Session.Reset();

	Human.RandomXY(3);

	Objectives.KillAllEnemy.Random(10);

	Objectives.DestroyEnemyBuildings.Random(2);

	Objectives.RescueHostages.Random(1);
	Objectives.RescueHostages.Random(1);
	Objectives.RescueHostages.Random(1);
	Objectives.RescueHostages.Random(1);

	Objectives.AddRequired(Objectives.KillAllEnemy);
	Objectives.AddRequired(Objectives.DestroyEnemyBuildings);
	Objectives.AddRequired(Objectives.RescueHostages);

	Weapons.RandomGrenades(Session.RequiredMinimumGrenades());
	Weapons.RandomRockets(Session.RequiredMinimumRockets() / 2);

	Validation.ValidateMap();
}

/**
 * Create a number of phases in the current mission
 * 
 * @param {number} pCount 
 * @param {number} pTileType 
 */
function createPhases(pCount, pTileType) {

	var Campaign = Engine.getCampaign();
	
	mapname = "m" + Campaign.getMissions().length;

	for(var count = 0; count < pCount; ++count) {

		Map.Create( Map.getRandomInt(40, 150), Map.getRandomInt(40, 150), pTileType, 0);

		var Phase = OpenFodder.getNextPhase();

		Phase.map = mapname + "p" + count;
		Phase.SetAggression(4, 8);

		//Terrain.Randomize();

        var _map_char = [
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................################################................',
            '................################################................',
            '................################################................',
            '................################################................',
            '................################################................',
            '................########++++++++++++++++########................',
            '................########++++++++++++++++########................',
            '........################++++++++++++++++################........',
            '........################++++++++++++++++################........',
            '........################++++TTTTTTTT++++################........',
            '........################++++TTTTTTTT++++################........',
            '........################++++TTTTTTTT++++################........',
            '........################++++TTTTTTTT++++################........',
            '........################++++TTTTTTTT++++################........',
            '........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
            '........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
            '........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
            '........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
            '........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
            '........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
            '........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
            '........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
            '........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
            '........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
            '........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
            '........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
            '........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
            '........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
            '........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
            '........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
            '........################++++TTTTTTTT++++################........',
            '........################++++TTTTTTTT++++################........',
            '........################++++TTTTTTTT++++################........',
            '........################++++TTTTTTTT++++################........',
            '........################++++TTTTTTTT++++################........',
            '........################++++++++++++++++################........',
            '........################++++++++++++++++################........',
            '........################++++++++++++++++################........',
            '........################++++++++++++++++################........',
            '................################################................',
            '................################################................',
            '................################################................',
            '................################################................',
            '................################################................',
            '................################################................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
            '................................................................',
        ];
            
        var st = new CSmoothTerrain();
        var map_char = st.convertMapChar(_map_char);
        var w = _map_char[0].length;
        var h = _map_char.length;
        var lev_limits = [0, 0, 0, 0, 0];
        var map = st.run('cf1', 'jungle', 'char', w, h, map_char, lev_limits);

		Map.Create(w, h, Terrain.Types.Jungle, 0);
		
		for (var y = 0; y < Map.getHeight() ; y++) {
			for (var x = 0; x < Map.getWidth(); x++) {
				Map.TileSet( x, y, st.getMapTile(x, y) );	  
			}
		}

		createRandom();
	}
}

/**
 * Create a number of missions
 * 
 * @param {number} pMissions 
 * @param {Array<number>} pPhases Number of phases per mission to create
 */
function createMissions(pMissions, pPhases) {

	for(var count = 0; count < pMissions; ++count) {
		var Mission = OpenFodder.getNextMission();
		Terrain.Types.Jungle

		createPhases(pPhases[count], Map.getRandomInt(0, 4));
	}
}

// Reset the map session
Session.Reset();

var Map = Engine.getMap();
//createMissions(2, [1, 2]);

var Mission = OpenFodder.getNextMission();
createPhases(1, Terrain.Types.Jungle );

/////////////////