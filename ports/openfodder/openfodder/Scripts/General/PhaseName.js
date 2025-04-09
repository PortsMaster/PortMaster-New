var PhaseName = {

	Jungle: {
	},

	Desert: {
	},

	Ice: {
	},

	Underground: {
	},

	Moors: {
	},
	
	/**
	 * Genereate a random phase name
	 * 
	 * @return {string}
	 */
	Generate: function() {

		switch(Settings.TerrainType) {

			case Terrain.Types.Jungle:
				return this.Jungle.Random();
			case Terrain.Types.Desert:
				return this.Desert.Random();
			case Terrain.Types.Ice:
				return this.Ice.Random();
			case Terrain.Types.Moors:
				return this.Moors.Random();
			case Terrain.Types.Interior:
				return this.Underground.Random();
			case Terrain.Types.AmigaFormat:
				return this.Ice.Random();
			default:
				return this.Jungle.Random();
		}
	}
}
