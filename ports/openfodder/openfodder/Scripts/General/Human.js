
var Human = {

	/**
	 * Randomize the human starting  position
	 * 
	 * @param {number} pCount 
	 */
	RandomXY: function(pCount) {
		print("Placing human players");

		var radius = 3;

		do {
			Session.HumanPosition = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), radius, false);
		// TODO: Check for enemy within X range
			--radius;
			if(radius == 0) {
				print("Failed to find place for humans");
				break;
			}

		} while(Session.HumanPosition.x == -1 || Session.HumanPosition.y == -1);

		var Position = new cPosition();
		Position.x = Session.HumanPosition.x;
		Position.y = Session.HumanPosition.y;

		for(var count = 0; count < pCount; ++count) {

			Map.SpriteAdd( SpriteTypes.Player, Position.x, Position.y );

			if(count / 1)
				Position.x += 16;
			else
				Position.y += 16;
		}
	}
};
