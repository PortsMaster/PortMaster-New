

/**
 * Create a civilian
 *
 * @return cPosition
 */
Objectives.GetCivilianHome.CreateCivilian = function() {
	print("Placing civilian");

	// Place a 'groups' of hostages
	var CivilianPosition = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), 2, true);
	Session.CivilianPositions.push(CivilianPosition);

	Map.SpriteAdd( SpriteTypes.Civilian_Spear, position.x, position.y );

	return CivilianPosition;
}

/**
 * Create the home for a civilian to return to
 *
 * @return cPosition
 */
Objectives.GetCivilianHome.CreateHome = function() {

	found = false;

	do {
		found = true;

		position = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), 3, false);
		for( count = 0; count < Session.CivilianPositions.count; ++count) {

			if( Map.getDistanceBetweenPositions( Session.CivilianPositions[count], position) < Settings.GetMinimumDistance("civilian", "rescue") ) {
				found = false;
				break;
			}

			var path = Map.calculatePathBetweenPositions( SpriteTypes.Civilian, position, Session.HumanPosition );
			if(!path.length) {
				found = false;
				break;
			}
		}

	} while( found == false );

	Structures.PlaceHut( position, "Civilian_Rescue" );
}

Objectives.GetCivilianHome.Random = function(pCount) {

	for( var count = 0; count < pCount; ++count)
		this.CreateCivilian();

	this.CreateHome();
};
