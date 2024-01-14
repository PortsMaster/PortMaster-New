/**
 * Position on the map
 */
class cPosition {
    x: number;
    y: number;
}

/**
 * A Sprite
 */
class sSprite {
    x: number;
    y: number;
}

/**
 * A Structure
 */
class sStructure {

    /**
     * TileIDs to be placed for structure
     */
    Struct: object;

    /**
     * Types of structure which can be placed
     */
    Types: object;
}

/**
 * A Campaign
 */
interface cCampaign {
    name: string;
    author: string;

    getMissions(): Array<cMission>;
    SetCustomCampaign(): void;
}

/**
 * A map
 */
interface cMap {
    seed: number;

    /**
     * Save to disk
     */
    save(): void;

    /**
     * Create a new map
     * 
     * @param pWidth
     * @param pHeight 
     * @param pTileType 
     * @param pTileSub 
     */
    Create(pWidth:number, pHeight:number, pTileType:number, pTileSub:number): void;

    /**
     * Create a 2D diamond square array
     */
    DiamondSquare(): Array<Array<number>>;

    /**
     * Create a 2D simplex island array 
     * 
     * @param pOctaves 
     * @param pRoughness 
     * @param pScale 
     * @param pSeed
     * @param pRadialEnabled 
     * @param pEdgeFade 
     */
    SimplexIslands(pOctaves, pRoughness, pScale, pSeed, pRadialEnabled, pEdgeFade): Array<Array<number>>;

    /**
     * Create a 2D simplex noise array
     * 
     * @param pOctaves 
     * @param pFrequency 
     * @param pLacunarity 
     * @param pPersistence 
     */
    SimplexNoise(pOctaves, pFrequency, pLacunarity, pPersistence): Array<Array<number>>;

    /**
     * Get the current tile type
     */
    getTileType(): number;

    /**
     * Get the current tile sub
     */
    getTileSub(): number;

    /**
     * Get map width in tiles
     */
    getWidth(): number;

    /**
     * Get map height in tiles
     */
    getHeight(): number;

    /**
     * Get the total map area in tiles
     */
    getArea(): number;

    /**
     * Get map width in pixels
     */
    getWidthPixels(): number;

    /**
     * Get max height in pixels
     */
    getHeightPixels(): number;

    /**
     * Get the total map area in pixels
     */
    getAreaPixels(): number;

    /**
     * Get the number of sprites matching this type
     * 
     * @param pSpriteType 
     */
    getSpriteTypeCount(pSpriteType): number;

    /**
     * Get all sprites matching this type
     * 
     * @param pSpriteType 
     */
    getSpritesByType(pSpriteType): Array<sSprite>;

    /**
     * Get a random X/Y if the tiles within the radius contain the provided tile id
     * @param pTiles 
     * @param pRadius 
     */
    getRandomXYByTileID( pTiles:Array<number>, pRadius:number ) : cPosition;

    /**
     * Get a random X/Y if the tiles within the radius have the provided features
     * @param pFeatures 
     * @param pRadius 
     * @param pIgnoreSprites 
     */
    getRandomXYByFeatures( pFeatures:Array<number>, pRadius:number, pIgnoreSprites:boolean ) : cPosition;

    /**
     * Get a random X/Y if the tiles within the radius have the provided feature
     * 
     * @param pType 
     * @param pRadius 
     */
    getRandomXYByTerrainType( pType:number, pRadius:number ) : cPosition;

    /**
     * Add a sprite to the map
     * 
     * @param pSpriteID
     * @param pSpriteX 
     * @param pSpriteY 
     */
    SpriteAdd(pSpriteID:number, pSpriteX:number, pSpriteY:number ) : void;

    /**
     * Get the tile ID at X/Y
     * 
     * @param pTileX 
     * @param pTileY 
     */
    TileGet(pTileX:number, pTileY:number) : void;

    /**
     * Set the tile at X/Y
     * 
     * @param pTileX 
     * @param pTileY 
     * @param pTileID 
     */
    TileSet(pTileX:number, pTileY:number, pTileID:number) : void;

    /**
     * Get a random int between min/max
     * 
     * @param pMin 
     * @param pMax 
     */
    getRandomInt(pMin:number, pMax:number) : number;

    /**
     * Get a random float between the min/max
     * 
     * @param pMin 
     * @param pMax 
     */
    getRandomFloat(pMin:number, pMax:number) : number;

    /**
     * Calculate the distance between two positions
     * 
     * @param pPos1 
     * @param pPos2 
     */
    getDistanceBetweenPositions(pPos1:cPosition, pPos2:cPosition) : number;

    /**
     * Calculate a path between two positions for the provided sprite type
     * 
     * @param pSpriteType Type of sprite
     * @param pPos1 Starting position
     * @param pPos2 Finishing position
     */
    calculatePathBetweenPositions(pSpriteType:number, pPos1:cPosition, pPos2:cPosition) : Array<cPosition>;
}

/**
 * A Phase
 */
interface cPhase {
    /**
     * Map filename
     */
    map: string;

    /**
     * Phase name
     */
    name: string;

    /**
     * Add an objective to this phase
     * 
     * @param pObjectiveID 
     */
    ObjectiveAdd(pObjectiveID): void;

    /**
     * Remove an objective from this phase
     * @param pObjectiveID 
     */
    ObjectiveRemove(pObjectiveID): void;

    /**
     * Clear all objectives
     */
    ObjectivesClear(): void;

    /**
     * Set the sprite aggression level
     * @param pMin
     * @param pMax 
     */
    SetAggression(pMin: number, pMax: number): void;

    /**
     * Set the min sprite aggression
     * 
     * @param pMin 
     */
    SetMinAggression(pMin): void;

    /**
     * Set the max sprite aggression
     * @param pMax 
     */
    setMaxAggression(pMax): void;
}

/**
 * A Mission
 */
interface cMission {
    /**
     * Mission name
     */
    name: string;

    NumberOfPhases(): number;
    PhaseGet(): cPhase;
}

/**
 * The Scripting Engine Object
 */
interface cScriptingEngine {

    /**
     * Execute a script with the provided name
     * 
     * @param pFilename 
     */
    scriptCall(pFilename): void;

    /**
     * Get the current campaign
     */
    getCampaign(): cCampaign;

    /**
     * Get the current Map
     */
    getMap(): cMap;

    /**
     * Get the current Phase
     */
    getPhase(): cPhase;

    /**
     * Get the current Mission
     */
    getMission() : cMission;

    /**
     * Print a string to the screen
     * 
     * @param pText 
     * @param pX 
     * @param pY 
     * @param pLarge 
     * @param pUnderline 
     */
    guiPrintString(pText:string, pX:number, pY:number, pLarge:boolean, pUnderline:boolean) : void;

    /**
     * Create a new mission
     */
    missionCreate() : cMission;
    
    /**
     * Create a new phase
     */
    phaseCreate() : cPhase;

    /**
     * Save the current map
     */
    mapSave() : void;
}

/**
 * Scripting Engine
 */
declare var Engine: cScriptingEngine;
