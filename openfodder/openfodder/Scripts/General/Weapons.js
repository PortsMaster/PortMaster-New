
var Weapons = {

    
    /**
     * 
     * @param {number}  pCount      
     * @param {boolean} pWalkable   
     */
    RandomGrenades: function(pCount, pWalkable) {
        if(pWalkable === undefined)
            pWalkable = false;

        for(var count = 0; count < pCount; ++count ) {
            if(pWalkable)
                Position = Positioning.RandomWalkable(SpriteTypes.Player, Session.HumanPosition);
            else
                Position = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), 1, true);
                
            Map.SpriteAdd( SpriteTypes.GrenadeBox, Position.x, Position.y );
        }
    },

    /**
     * 
     * @param {number} pCount 
     * @param {boolean} pWalkable 
     */
    RandomRockets: function(pCount, pWalkable) {
        if(pWalkable === undefined)
            pWalkable = false;

        for(var count = 0; count < pCount; ++count ) {
            if(pWalkable)
                Position = Positioning.RandomWalkable(SpriteTypes.Player, Session.HumanPosition);
            else
                Position = Map.getRandomXYByFeatures(Terrain.Features.FlatGround(), 1, true);
                
            Map.SpriteAdd( SpriteTypes.RocketBox, Position.x, Position.y );
        }
    }
}
