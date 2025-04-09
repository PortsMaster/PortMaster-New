/**
 * OpenFodder
 * 
 * Helicopters
 */

/**
 * Functions for placing helicopters
 */
var Helicopters = {
	
	Human: {

		HaveAny: function() {
			if(this.HaveHoming() || this.HaveGrenade() || this.HaveMissile())
				return true;
			return false;
		},

		/**
		 * Does a human homing missile helicopter exist
		 */
		HaveHoming: function() {
			return Map.getSpriteTypeCount(SpriteTypes.Helicopter_Homing_Human) > 0;
		},

		/**
		 * Does a human grenade helicopter exist
		 */
		HaveGrenade: function() {
			return Map.getSpriteTypeCount(SpriteTypes.Helicopter_Grenade_Human) > 0;
		},

		/**
		 * Does a human missile helicopter exist
		 */
		HaveMissile: function() {
			return Map.getSpriteTypeCount(SpriteTypes.Helicopter_Missile_Human) > 0;
		},

		/**
		 * Get a random human helicopter type
		 */
		GetRandomType: function() {
			Type = SpriteTypes.Helicopter_Grenade_Human;

			switch(Map.getRandomInt(0, 2)) {
				case 0:
					Type = SpriteTypes.Helicopter_Grenade_Human;
					break;
				case 1:
					Type = SpriteTypes.Helicopter_Missile_Human;
					break;
				case 2:
					Type = SpriteTypes.Helicopter_Homing_Human;
					break;
				default:
					print("No helicopter");
			}
			return Type;
		},

		/**
		 *  Add a homing missile helicopter at a random X/Y
		 *   in a path which is accessible on foot to the player
		 */
		RandomHoming: function() {

			// Find a location which is walkable from the human starting position
			Position = Positioning.RandomWalkable(SpriteTypes.Player, Session.HumanPosition);
			Map.SpriteAdd( SpriteTypes.Helicopter_Homing_Human, Position.x, Position.y );

			return Position;
		},
			
		/**
		 * Add a random human helicopter, if no position is provided, 
		 *  a walkable path between the human player will be ensured
		 * 
		 * @param {number} pType
		 * @param {cPosition} pPosition Position where to place a random type of helicopter
		 */
		Random: function(pType, pPosition) {

			if(pType === -1) 
				pType = this.GetRandomType();

			if(pPosition === undefined) {
				pPosition = Positioning.RandomWalkable(SpriteTypes.Player, Session.HumanPosition);
				print("Placing random helicopter: x: " + pPosition.x + " y: " + pPosition.y);
			}
			
			Map.SpriteAdd( pType, pPosition.x, pPosition.y );
		}
	}
	

};
