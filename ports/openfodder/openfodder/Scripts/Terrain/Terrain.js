
/**
 * @var {object} {object} Terrain related functions
 */
var Terrain = {
	
	/**
	 * @var {object} {number} Types of available 
	 */
	Types: {
		Jungle: 0,
		Desert: 1,
		Ice: 2,
		Moors: 3,
		Interior: 4,
		AmigaFormat: 5
	},

	/**
	 * @var {object} {number} Terrain Features
	 */
	Features: {
		Land: 		0,
		Rocky:	 	1,
		Rocky2: 	2,
		BounceOff: 	3,
		QuickSand: 	4,
		WaterEdge: 	5,
		Water: 		6,
		Snow: 		7,
		QuickSandEdge: 8,
		Drop: 	9,
		Drop2: 	0x0A,
		Sink: 	0x0B,
		C: 		0x0C,
		D: 		0x0D,
		Jump: 	0x0E,

		FlatGround: function() { return [Terrain.Features.Land , Terrain.Features.Snow]; }
	},

	Jungle: {
		Tiles: {
			Water: 326,
			QuickSand: 167,
			Land: 123,
			Tree: 82
		},
		Mainland: [0, 20, 40, 18, 19],
		Borderland: [123, 124, 68, 240, 365]
	},

	Desert: {
		Tiles: {
			Water: 180,
			Land: 0,
			Tree: 220
		},
		Mainland: [0, 20, 40, 18, 19],
		Borderland: [123, 124, 68, 240, 365]
	},
	
	Ice: {
		Tiles: {
			Water: 100,
			Land: 0,
			Tree: 170
		},
		Mainland: [0, 20, 40, 18, 19],
		Borderland: [123, 124, 68, 240, 365]
	},

	Moors: {
		
		Tiles: {
			Water: 193,
			Land: 0,
			Tree: 2
		},
		Mainland: [0, 20, 40, 18, 19],
		Borderland: [123, 124, 68, 240, 365]
	},
	
	Interior: {
		Tiles: {
			Water: 242,
			Land: 4,
			Tree: 275
		},
		Mainland: [0, 20, 40, 18, 19],
		Borderland: [123, 124, 68, 240, 365]
	},
	
	AmigaFormat: {
		Tiles: {
			Water: 100,
			Land: 0,
			Tree: 240
		},
		Mainland: [0, 20, 40, 18, 19],
		Borderland: [123, 124, 68, 240, 365]
	},
	
	/**
	 * Get basic titles for the current Map Tile Type
	 */
	GetCurrent: function() {
		switch(Map.getTileType()) {
			
			case this.Types.Jungle:
				return Terrain.Jungle;
			case this.Types.Desert:
				return Terrain.Desert;
			case this.Types.Ice:
				return Terrain.Ice;
			case this.Types.Moors:
				return Terrain.Moors;
			case this.Types.Interior:
				return Terrain.Interior;
			case this.Types.AmigaFormat:
				return Terrain.AmigaFormat;
				
			default:
				return Terrain.Jungle;
		}
	},

	/**
	 * Get the basic tile ids for the current map tileType
	 * 
	 * @return object
	 */
	GetTiles: function() {

		return this.GetCurrent().Tiles;
	},
	
	/**
	 * Create a random map
	 */
	RandomSmooth: function() {

		if(Map.getTileType() == this.Types.Jungle) {
			noises = Settings.GetNoise();

			var st = new CSmoothTerrain();
			st.run('cf1', 'jungle', 'level', Settings.Width, Settings.Height, noises, Settings.TerrainSettings.lev_limits);

			for (var y = 0; y < Settings.Height; y++) {
				for (var x = 0; x < Settings.Width; x++) {

					Map.TileSet( x, y, st.getMapTile(x, y) );
				}
			}

			return;
		}

		this.Random();
	},

	/**
	 * Create random, with basic tiles
	 */
	Random: function() {
		Tiles = this.GetTiles();
		noises = Settings.GetNoise();

		for( x = 0; x < Settings.Width; ++x ) {
			for( y = 0; y < Settings.Height; ++y) {

				noise =  noises[x][y];
				TileID = 0;

				if (noise <= 0.21) {
					TileID = Tiles.Water;
				}
				else if (noise < 0.6) {
					TileID = Tiles.Land;
				}
				else if (noise > 0.6) {
					TileID = Tiles.Tree;
				}

				Map.TileSet( x, y, TileID );
			}
		}
	}
};
