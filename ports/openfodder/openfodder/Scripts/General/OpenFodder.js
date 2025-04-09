var OpenFodder = {

    /**
     * Reset the session, and create a map and prepare the terrain
     */
    createMap: function() {
        Session.Reset();

        Map.Create( Settings.Width, Settings.Height, Settings.TerrainType, Settings.TerrainTypeSub);
        Terrain.RandomSmooth();
    },

    /**
     * Prepare a phase
     *  Set Aggression
     *  Create the map
     *  Call the content creation function
     *  Validate the map/objectives are completable
     *
     * @param {number} pMissionNumber
     * @param {number} pPhaseNumber
     * @param {Object|Function} pScenario
     */
    createPhase: function(pMissionNumber, pPhaseNumber, pScenario) {
        var Phase = this.getNextPhase();
        Phase.map = mapname + "p" + pPhaseNumber;
        Phase.SetAggression(Settings.Aggression.Min, Settings.Aggression.Max);

        Phase.ObjectivesClear();
		for( var x = 0; x < Settings.Objectives.length; ++x) {
			Phase.ObjectiveAdd(Settings.Objectives[x]);
        }

        this.createMap();

        // If a callable function was passed, call it
        if( pScenario && {}.toString.call(pScenario) === '[object Function]') {
            pScenario(pMissionNumber, pPhaseNumber);
        } else {

            // Otherwise its a scenario object
            pScenario.Start(pMissionNumber, pPhaseNumber);
        }

        Validation.ValidateMap();
    },

    /**
     * Create a number of phases in the current mission
     *
     * @param {number} PhaseNumber         Number of phases in the current mission
     * @param {Object|Function} pScenario  Called during creation of the map
     * @param {function} pPrepareSettings  Called during initialisation of the phase
     *
     */
    createPhases: function(pTotalPhases, pScenario, pPrepareSettings) {
        var Campaign = Engine.getCampaign();
        OpenFodder.printSmall("Creating Phases", 0, 55);
        var MissionNumber = Campaign.getMissions().length;
        mapname = "m" + MissionNumber;

        for(var PhaseNumber = 0; PhaseNumber < pTotalPhases; ++PhaseNumber) {

            // If we received scenario object, call its settings function
            if( pScenario && {}.toString.call(pScenario) === '[object Object]' && pPrepareSettings === undefined) {
                pScenario.Settings(MissionNumber, PhaseNumber);
            } else {

                // Otherwise, check pPrepareSettings
                if(pPrepareSettings === undefined)
                    Scenario.Settings(MissionNumber, PhaseNumber);
                else
                    pPrepareSettings(MissionNumber, PhaseNumber);
            }

            this.createPhase(MissionNumber, PhaseNumber, pScenario);
        }
    },

    /**
     * Create a number of missions
     *
     * @param {number} pMissions
     * @param {Array<number>} pPhases Number of phases per mission to create
     * @param {function} pCreateContent Callback to create the content of the map
     * @param {function} pPrepareSettings Callback to configure the settings of the map
     *
     */
    createMissions: function(pMissions, pPhases, pCreateContent, pPrepareSettings) {
        OpenFodder.printSmall("Creating " + pMissions + " Missions", 0, 25);

        for(var count = 0; count < pMissions; ++count) {
            var Mission = OpenFodder.getNextMission();

            Settings.TerrainType = Map.getRandomInt(0, 4);
            createPhases(pPhases[count], pCreateContent, pPrepareSettings);
        }
    },

    /**
     * Create the next mission
     *
     * @return {cMission}
     */
    getNextMission: function() {
        Mission = Engine.getMission();
        if(Mission.name != "") {
            print("Creating new mission");
            Mission = Engine.missionCreate();
        }
        Mission.name = PhaseName.Generate();
        return Mission;
    },
    
    /**
     * Create the next phase
     * 
     * @return {cPhase}
     */
    getNextPhase: function() {
        Phase = Engine.getPhase();
        if(Phase.name != "") {
            print("Creating new phase");
            Phase = Engine.phaseCreate();
        }

        Phase.name = PhaseName.Generate();
        return Phase;
    },

    /**
     * Print a string using the large font
     * 
     * @param {string} pText 
     * @param {number} pX X location to draw (0 will centre)
     * @param {number} pY Y location to draw
     * @param {boolean} pUnderline Print with an underline
     */
    printLarge: function(pText, pX, pY, pUnderline) {
        if(pUnderline === undefined)
            pUnderline = false;
        Engine.guiPrintString(pText, pX, pY, true, pUnderline);
    },
    
    /**
     * Print a string using the small font
     * 
     * @param {string} pText 
     * @param {number} pX X location to draw (0 will centre)
     * @param {number} pY Y location to draw
     */
    printSmall: function(pText, pX, pY) {
        Engine.guiPrintString(pText, pX, pY, false, false);
    },

    /**
     * Start me up
     *
     * @param {number} pSeed Undefined for random
     */
    start: function(pSeed) {
        this.printLarge("PLEASE WAIT", 0, 15);

        // Global Map object
        Map = Engine.getMap();

        // Global Mission
        Mission = this.getNextMission();

        // Prepare settings
        if(pSeed === undefined)
            Settings.Reset();
        else
            Settings.FromSeed(pSeed);
    }
};
