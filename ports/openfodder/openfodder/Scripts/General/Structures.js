var Structures = {
    Jungle: {
        Hut: {},
        Barracks: {},
        Bunker: {}
    },
    Desert: {
        Hut: {},
        Barracks: {},
        Bunker: {}
    },
    Ice: {
        Hut: {},
        Barracks: {},
        Bunker: {}
    },
    Moors: {
        Hut: {},
        Barracks: {},
        Bunker: {}
    },
    Interior: {
        Hut: {},
        Barracks: {},
        Bunker: {}
    },
    AmigaFormat: {
        Hut: {},
        Barracks: {},
        Bunker: {}
    },

    /**
     * 
     */
	GetCurrent: function() {
		switch(Map.getTileType()) {

			case Terrain.Types.Jungle:
				return Structures.Jungle;
			case Terrain.Types.Desert:
				return Structures.Desert;
			case Terrain.Types.Ice:
				return Structures.Ice;
			case Terrain.Types.Moors:
				return Structures.Moors;
			case Terrain.Types.Interior:
				return Structures.Interior;
			case Terrain.Types.AmigaFormat:
				return Structures.AmigaFormat;
				
			default:
				return Structures.Jungle;
		}
    },

    GetStructInfo: function(pStructType) {
        Struct = this.GetCurrent();

        switch(pStructType.toLowerCase()) {
            case "barracks":
                return Struct.Barracks;
            case "hut":
                return Struct.Hut;
            case "bunker":
                return Struct.Bunker;
            default:
                print("Invalid structure: " + pStructType);
                break;
        }
    },

    /**
     * 
     * @param {string} pStructType
     */
    GetStructPositions(pStructType) {

        switch(pStructType.toLowerCase()) {
            case "barracks":
                return Session.BarracksPositions;

            case "huts":
                return Session.HutPositions;

            case "bunker":
                return Session.BunkerPositions;

            default:
                return [];
        }
    },

    /**
     * Place a structure
     *
     * @param {cPosition} pPosition
     * @param {sStructure} pStructure
     * @param {string} pStructSet
     * @param {string} pSpriteSet
     */
    Place: function(pPosition, pStructure, pStructSet, pSpriteSet) {
        TileX = Math.floor(pPosition.x / 16);
        TileY = Math.floor(pPosition.y / 16);

        if(pStructure === undefined || pStructure.Struct === undefined || pStructure.Types === undefined)
            return;

        Struct = pStructure.Struct[pStructSet];
        Sprites = pStructure.Types[pSpriteSet.toLowerCase()];

        if(Sprites === undefined && pSpriteSet !== "") {
            print("Structure does not have sprite-set: " + pSpriteSet);
            return;
        }

        // Set the terrain tiles
        for( var count = 0; count < Struct.length; ++count ) {
            Map.TileSet(TileX + Struct[count][0], TileY + Struct[count][1], Struct[count][2]);
        }

        // Now add the sprites
        for( var count = 0; count < Sprites.length; ++count ) {
            Map.SpriteAdd(Sprites[count][2], (TileX * 16) + Sprites[count][0], (TileY * 16) + Sprites[count][1]);
        }
    },

    /**
     * Place a civilian hut
     * 
     * @param {cPosition} pPosition
     * @param {string} pHutType
     */
    PlaceHut: function(pPosition, pHutType) {
        Struct = this.GetCurrent();
        this.Place(pPosition, Struct.Hut, 0, pHutType);
        Session.HutPositions.push(pPosition);
    },

    /**
     * Place a barracks
     *
     * @param {cPosition} pPosition
     * @param {string} pSpriteSet
     */
    PlaceBarracks: function(pPosition, pSpriteSet) {
        Struct = this.GetCurrent();
        this.Place(pPosition, Struct.Barracks, 0, pSpriteSet);
        Session.BarracksPositions.push(pPosition);
    },

    /**
     * Place a bunker
     *
     * @param {cPosition} pPosition
     * @param {string} pSpriteSet
     */
    PlaceBunker: function(pPosition, pSpriteSet) {
        Struct = this.GetCurrent();
        this.Place(pPosition, Struct.Bunker, 0, pSpriteSet);
        Session.BunkerPositions.push(pPosition);
    },

    /**
     *
     * Place a number of 'pStructType' at random locations, at a minimum of 'pMinDistance' from each other
     *
     * @param {string} pStructType
     * @param {string} pSpriteType
     * @param {number} pCount
     * @param {number} pMinDistance If undefined, value will be obtained from Settings.MinimumDistances
     */
    PlaceRandom: function(pStructType, pSpriteType, pCount, pMinDistance) {
        if(pMinDistance === undefined)
            var pMinDistance = Settings.GetMinimumDistance(pStructType, pSpriteType);

        var StructInfo = this.GetStructInfo(pStructType);

        for(var x = 0; x < pCount; ++x) {

            // Get the positions of the existing similar type structures
            existingPositions = this.GetStructPositions(pStructType);

            var position = new cPosition(-1, -1);

            if(StructInfo.StructFindTile.length) {
                var type = Map.getRandomInt(0, StructInfo.StructFindTile.length - 1);
                position = Positioning.PositionOnTilesAwayFrom(StructInfo.StructFindTile[type], 3, existingPositions, pMinDistance );
            }

            if(position.x == -1 || position.y == -1) {
                print("Fallback position find to flatground");
                position = Positioning.PositionAwayFrom(Terrain.Features.FlatGround(), 4, existingPositions, pMinDistance );
            }

            if(position.x != -1 && position.y != -1) {
                existingPositions.push(position);

                this.Place(position, StructInfo, 0, pSpriteType);
            }
        }
    },

    /**
     *
     * @param {object} pBuildings
     */
    PlaceBuildings: function(pBuildings) {

        for (var building in pBuildings) {
            for(var sprite in pBuildings[building]) {

                Structures.PlaceRandom(building, sprite, pBuildings[building][sprite]);
            };
        };

    },

};
