/**
 * OpenFodder
 * 
 * Rescue Hostages
 */

/**
 * Create a hostage rescue tent
 * 
 * @return {cPosition} Position of tent
 */
Objectives.RescueHostages.CreateTent = function() {

	TentSprites = Map.getSpritesByType(SpriteTypes.Hostage_Rescue_Tent);
	if(TentSprites.length == 0) {
		Attempts = 0;

		print("Placing rescue tent");
		// TODO: Loop all known groups
		do {
			Position = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), 1, false);
			++Attempts;
		} while( Map.getDistanceBetweenPositions(Session.HostageGroupPositions[0], Position) < Settings.GetMinimumDistance("hostage", "tent") && Attempts < 10);

		if(Attempts == 10) 
			print("Failed finding location for rescue tent, placing anyway");

		Session.RescueTentPosition = Position;
		Map.SpriteAdd( SpriteTypes.Hostage_Rescue_Tent, Position.x, Position.y );
	} else {
		Session.RescueTentPosition = TentSprites[0].getPosition();
	}

	return Session.RescueTentPosition;
};

/**
 * Create a group of hostages
 *
 * @param {number} pHostageCount Number of hostages to be placed
 * @param {boolean} pHasEnemyGuard Place an enemy soldier with each hostage
 *
 * @return cPosition
 */
Objectives.RescueHostages.CreateHostages = function(pHostageCount, pHasEnemyGuard) {
	print("Placing hostages");

	if(pHostageCount == 0)
		++pHostageCount;

	if(pHasEnemyGuard == undefined)
	pHasEnemyGuard = true;

	// Place a 'groups' of hostages
	HostagePosition = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), 2, true);
	Session.HostageGroupPositions.push(HostagePosition);

	// Place an amount of hostages near this group
	for(var count = 0; count < pHostageCount; ++count) {
		
		position = new cPosition();
		position.x = HostagePosition.x + (16 * count);
		position.y = HostagePosition.y;

		Map.SpriteAdd( SpriteTypes.Hostage, position.x, position.y );
		if(pHasEnemyGuard)
			Map.SpriteAdd( SpriteTypes.Enemy, position.x + 8, position.y );
	}	

	return HostagePosition;
}

/**
 * Add a random hostage, rescue tent and helicopter (if needed) to the map
 * 
 * @param {number} pHostageCount How many hostages to place
 */
Objectives.RescueHostages.Random = function(pHostageCount) {

	this.CreateHostages(pHostageCount, true);
	this.CreateTent();
};
