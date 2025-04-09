
/**
 * Functions for calculating positions on a map
 */
var Positioning = {
    
    /**
     * Find a position on the map which 'SpriteType' can walk to from its location
     * If MaxAttempts is reached, the position of pSpritePosition is returned, + 1 tile
     * 
     * @param {*} pSpriteType     Type of the sprite
     * @param {*} pSpritePosition Position of the sprite
     * @param {*} pMaxAttempts    Maximum number of attempts to find a random X/Y (default 20)
     * 
     * @return cPosition
     */
    RandomWalkable: function(pSpriteType, pSpritePosition, pMaxAttempts) {
        Attempts = 0;
        Distance = [];

        if(pMaxAttempts === undefined)
            pMaxAttempts = 20;

        // Find a position which can be accessed by moving
        do {
            Position = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), 1, false);
            Distance = Map.calculatePathBetweenPositions(pSpriteType, Position, pSpritePosition);
            ++Attempts;
        } while(Distance.length < 2 && Attempts < pMaxAttempts);

        if(Attempts >= pMaxAttempts) {
            Position = pSpritePosition;
            Position.x += 16;
            print("Failed to find a walkable position");
        }

        return Position;
    },

    /**
     * Find a position on the map which has 'pTerrainFeatures' in 'Radius' atleast 'pDistance' away from all positions in 'pPositions'
     *
     * @param {Array<number>} pTerrainFeatures
     * @param {number} pRadius
     * @param {cPosition} pPositions
     * @param {number} pDistance
     * @param {number} pMaxAttempts 
     *
     * @return cPosition
     */
    PositionAwayFrom: function(pTerrainFeatures, pRadius, pPositions, pDistance, pMaxAttempts) {
        found = false;
        Attempts = 0;
        Distance = [];

        // Default parameters
        if(pMaxAttempts === undefined)
            pMaxAttempts = 20;
        if(pDistance === undefined)
            pDistance = 10;

        // Find a position
        do {
            Position = Map.getRandomXYByFeatures(pTerrainFeatures, pRadius, false);
            found = true;

            // Ensure its away from the current placements
            for(var count = 0; count < pPositions.length; ++count) {
                Distance = Map.getDistanceBetweenPositions(Position, pPositions[count]);
                if(Distance < pDistance)
                    found = false;    
            }
            ++Attempts;
        } while(found == false && Attempts < pMaxAttempts);

        if(Attempts >= pMaxAttempts) {
            Position = new cPosition(-1, -1);
            print("Failed to find a position");
        }

        return Position;
    },

    /**
     * Find a position on the map which has 'pTileIDs' in 'Radius' atleast 'pDistance' away from all positions in 'pPositions'
     *
     * @param {Array<number>} pTileIDs
     * @param {number} pRadius
     * @param {cPosition} pPositions
     * @param {number} pDistance
     * @param {number} pMaxAttempts 
     *
     * @return cPosition
     */
    PositionOnTilesAwayFrom: function(pTileIDs, pRadius, pPositions, pDistance, pMaxAttempts) {
        found = false;
        Attempts = 0;
        Distance = [];

        // Default parameters
        if(pMaxAttempts === undefined)
            pMaxAttempts = 20;
        if(pDistance === undefined)
            pDistance = 10;

        // Find a position
        do {
            Position = Map.getRandomXYByTileID(pTileIDs, pRadius);
            found = true;

            // Ensure its away from the current placements
            for(var count = 0; count < pPositions.length; ++count) {
                Distance = Map.getDistanceBetweenPositions(Position, pPositions[count]);
                if(Distance < pDistance)
                    found = false;    
            }
            ++Attempts;
        } while(found == false && Attempts < pMaxAttempts);

        if(Attempts >= pMaxAttempts) {
            Position = new cPosition(-1, -1);
            print("Failed to find a position");
        }

        return Position;
    }
}