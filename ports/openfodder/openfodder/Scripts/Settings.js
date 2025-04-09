var Settings = {

    /**
     * @var {number}
     */
    Width: 0,

    /**
     * @var {number}
     */
    Height: 0,

    /**
     * @var {number}
     */
    TerrainType: Terrain.Types.Jungle,

    /**
     * @var {number}
     */
    TerrainTypeSub: 0,

    /**
     * @var {object}
     */
    Aggression: {
        Min: 4,
        Max: 8
    },

    /**
     * Minimum distance between same type structures if not defined
     */
    BuildingsDistanceMinimum: 100,

    /**
     * Number and type of civilian buildings to be created
     */
    BuildingsCivilianCount: {
        hut: {
            civilian: 1,
            civilian_spear: 1,
            civilian_rescue: 0
        }
    },

    /**
     * Nunmber and type of enemy buildings to be created
     */
    BuildingsEnemyCount: {
        barracks: {
            soldier: 1,
            soldier_reinforced: 0
        },
        bunker: {
            soldier: 0,
        },
        hut: {
            soldier: 0,
        }
    },

    /**
     * Minimum distances for objects
     */
    ObjectMinimumDistance: {

        barracks: {

            /**
             * @var {number} soldier Minimum distance between each enemy barracks
             */
            soldier: 100
        },

        hut: {
            /**
             * @var {number} civilian Minimum distance between each home
             */
            civilian: 100,

            /**
             * @var {number} civilian_rescue Minimum distance between each home
             */
            civilian_rescue: 150,
        },

        civilian: {
            /**
             * @var {number} to_rescue Minimum distance between a civilian and a civilian_rescue hut
             */
            rescue: 150
        },

        hostage: {

            /**
             * @var {number} tent: Minimum distance between a hostage and the rescue tent
             */
            tent: 150
        }

    },

    /**
     * @var {Array<number>} Objectives
     */
    Objectives: [],

    /**
     *
     */
    TerrainAlgorithms: ["islands", "simplex", "diamondsquare"],

    /**
     * @var {string}
     */
    TerrainAlgorithm: "islands",

    /**
     * @var {object}
     */
    TerrainSettings: {},

    /**
     * @var {number} seed The initial seed
     */
    Seed: 0,

    /**
     * Randomise a settings with a specific seed
     *
     * @param {number} pSeed
     */
    FromSeed: function(pSeed) {
        Engine.getMap().seed = pSeed;

        this.Reset();
    },

    /**
     * Reset settings using current seed
     */
    Reset: function() {

        this.Seed = Engine.getMap().seed;

        print("Starting Seed: " + this.Seed);
    },

    /**
     * Randomize all settings
     */
    Random: function() {
        this.Width = Map.getRandomInt(40, 150);
        this.Height = Map.getRandomInt(40, 150);

        this.Aggression.Min = Map.getRandomInt(2, 4);
        this.Aggression.Max = Map.getRandomInt(this.Aggression.Min, 8);

        this.TerrainAlgorithm = this.TerrainAlgorithms[Map.getRandomInt(0, 2)];
        this.TerrainType = Map.getRandomInt(Terrain.Types.Jungle, Terrain.Types.Interior);

        this.TerrainType = Terrain.Types.Jungle;

        // Randomise items based on map properties
        this.RandomUpdate();
    },

    /**
     * Randomise items based on map parameters (should be called after changing map width/height)
     */
    RandomUpdate: function() {
        this.RandomObjectives();
        this.RandomNoise();
        this.RandomBuildings();
    },

    /**
     * Total number of tiles the map will have
     */
    getCalculatedArea: function() {
        return Settings.Width * Settings.Height;
    },

    /**
     * Setup the number of buildings placed based on the area
     */
    RandomBuildings: function() {

        print("Total map area: " + this.getCalculatedArea());

        this.BuildingsEnemyCount.barracks.soldier = Math.floor(this.getCalculatedArea() / 1600);
        this.BuildingsEnemyCount.barracks.soldier_reinforced = 0;
        this.BuildingsEnemyCount.bunker.soldier = 0;
        this.BuildingsEnemyCount.hut.soldier = 0;

        this.BuildingsCivilianCount.hut.civilian = Math.floor(this.getCalculatedArea() / 1600);
        this.BuildingsCivilianCount.hut.civilian_spear = Math.floor(this.getCalculatedArea() / 3200);
        this.BuildingsCivilianCount.hut.civilian_rescue = 0;
    },

    /**
     * Set random objectives
     */
    RandomObjectives: function() {
        this.Objectives = [];

        // TODO: This could be alot better
        if(Map.getRandomInt(0, 1) == 1)
            this.addObjective(Objectives.KillAllEnemy);
        else
            this.addObjective(Objectives.DestroyEnemyBuildings);

        if(Map.getRandomInt(0, 1) == 1)
            this.addObjective(Objectives.DestroyEnemyBuildings);

            // Either Rescue or get civilian home
        if(Map.getRandomInt(0, 1) == 1) {
            this.addObjective(Objectives.RescueHostages);
        } else {
            if(Map.getRandomInt(0, 1) == 1)
                this.addObjective(Objectives.GetCivilianHome);
        }
    },

    /**
     * Set the phase objectives
     *
     * @param {Array<object>} pObjectives
     */
    setObjectives: function(pObjectives) {
        this.Objectives = [];

        for(var x = 0; x < pObjectives.length; ++x) {
            this.addObjective(pObjectives[x]);
        }
    },

    /**
     * Add an objective
     *
     * @param {object} pObjective
     */
    addObjective: function(pObjective) {
        this.Objectives.push(pObjective.ID);
    },

    /**
     * Do we have this objective
     *
     * @param {object} pObjective
     */
    hasObjective: function(pObjective) {
        return this.Objectives.indexOf(pObjective.ID) != -1;
    },

    /**
     * Create random terrain island settings
     */
    RandomTerrainIsland: function() {

        this.TerrainSettings = {
            lev_limits: [0.20, 0.23, 0.55, 0.65, 1.00],
            //lev_limits: [0.17, 0.25, 0.35, 0.45, 1.00],   //Old values

            Octaves: 4,
            Roughness: Map.getRandomFloat(0.01, 0.3),
            Scale: Map.getRandomFloat(0.02, 0.04),
            Seed: Map.getRandomInt(0, 255),
            EdgeFade: Map.getRandomFloat(0.00, 0.2),
            RadialEnabled: Map.getRandomInt(0,1) == 0 ? false : true
        };
    },

    /**
     * Create random terrain simplex noise settings
     */
    RandomTerrainSimplex: function() {

        this.TerrainSettings = {
            lev_limits: [0.20, 0.23, 0.55, 0.65, 1.00],

            Octaves: 4,
            Scale: Map.getRandomFloat(0.02, 0.04),
            Lacunarity:  Map.getRandomFloat(0.01, 0.5),
            Persistance: Map.getRandomFloat(0.01, 1.)
        };
    },

    /**
     * Create random terrain diamond square settings
     */
    RandomDiamondSquare: function() {

        this.TerrainSettings = {
            lev_limits: [0.20, 0.23, 0.55, 0.65, 1.00]

        }
    },

    /**
     * Create noise settings based on set algorithm
     */
    RandomNoise: function() {

        switch(this.TerrainAlgorithm) {
            case "islands":
                return this.RandomTerrainIsland()

            case "simplex":
                return this.RandomTerrainSimplex();

            case "diamondsquare":
                return this.RandomDiamondSquare();

            default:
                break;
        }

    },

    /**
     * Get noise for the terrain algorithm
     */
    GetNoise: function() {

        switch(this.TerrainAlgorithm) {
            case "islands":
                return this.GetIslandNoise();

            case "simplex":
                return this.GetSimplexNoise();

            case "diamondsquare":
                return this.GetDiamondSquare();

            default:
                break;
        }

    },

    /**
     * Generate Simplex Island
     */
    GetIslandNoise: function() {

        print('>> SimplexIslands parameters:');
        print('>>   pOctaves = ' + this.TerrainSettings.Octaves);
        print('>>   pRoughness = ' + this.TerrainSettings.Roughness.toFixed(2));
        print('>>   pScale = ' + this.TerrainSettings.Scale.toFixed(2));
        print('>>   pSeed = ' + this.TerrainSettings.Seed);
        print('>>   pRadialEnabled = ' + this.TerrainSettings.RadialEnabled);
        print('>>   pEdgeFade = ' + this.TerrainSettings.EdgeFade.toFixed(2));

        return Map.SimplexIslands(this.TerrainSettings.Octaves,
                                    this.TerrainSettings.Roughness,
                                    this.TerrainSettings.Scale,
                                    this.TerrainSettings.Seed,
                                    this.TerrainSettings.RadialEnabled,
                                    this.TerrainSettings.EdgeFade);

    },

    /**
     *Generate Simplex Noise
     */
    GetSimplexNoise: function() {

        return Map.SimplexNoise(this.TerrainSettings.Octaves, this.TerrainSettings.Scale, this.TerrainSettings.Lacunarity, this.TerrainSettings.Persistance);
    },

    /**
     * Generate Diamond Square heightmap
     */
    GetDiamondSquare: function() {
        return Map.DiamondSquare();
    },

    /**
     * Number of players
     */
    GetPlayerCount: function() {
        return Map.getRandomInt(1,8);
    },

    /**
     * Return the background item count
     */
    GetBackgroundObjectCount: function() {

        return {
            Palms: 10,
            Bushes1: 10,
            Blooms: 5
        };
    },

    /**
     * Calculate the number of hostages to create
     */
    GetHostageCount: function() {
        // TODO: Algorithm to decide number of hostage group
        return Math.floor(Math.min(Map.getArea() / 900, 1));
    },

    /**
     * Number of hostages per placement
     */
    GetHostageGroupSize: function() {

        return Map.getRandomInt(1,3);
    },

    /**
     * Number of enemies which should be placed
     */
    GetEnemyCount: function() {

        return Math.floor(Math.min(Map.getArea() / 900, 1));;

    },

    /**
     * Number of enemy buildings to be placed
     */
    GetEnemyBuildingCount: function() {

        return this.BuildingsEnemyCount;
    },

    /**
     * Get the civilian buildings to be placed
     */
    GetCivilianBuildingCount: function() {

        return this.BuildingsCivilianCount;
    },

    /**
     * Minimum number of grenades required for this mission
     */
    GetMinimumGrenades: function() {
        return 1 + (Session.TotalStructures() / 4);
    },

    GetMinimumRockets: function() {
        return 1 + (Session.TotalStructures() / 4);
    },

    /**
     * Get the minimum distance between two same type structures
     *
     * @param {string} pObjectName
     * @param {string} pTargetName
     */
    GetMinimumDistance: function(pObjectName, pTargetName) {
        var Obj = this.ObjectMinimumDistance[pObjectName.toLowerCase()];
        if( Obj === undefined )
            return this.BuildingsDistanceMinimum;

        var Target = Obj[pTargetName.toLowerCase()];
        if( Target === undefined)
            return this.BuildingsDistanceMinimum;

        return Target;
    }
};
