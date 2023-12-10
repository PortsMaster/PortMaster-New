
/**
 * @param {number} pCount Number of Enemy troops to place
 */
Objectives.KillAllEnemy.CreateEnemyTroop = function(pCount) {
	print("Placing enemy soldiers");

	for(var count = 0; count < pCount; ++count) {
		position = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), 1, false);

		// TODO: Check distance between all soldiers?
		
		if(position.x == -1 || position.y == -1) {
			print("Failed to place enemy soldier");
			continue;
		}

		Map.SpriteAdd( SpriteTypes.Enemy, position.x, position.y );
	}
}

/**
 * 
 */
Objectives.KillAllEnemy.Random = function(pCount) {

	this.CreateEnemyTroop(pCount);

};
