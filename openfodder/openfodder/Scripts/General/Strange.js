
/**
 * OpenFodder
 * 
 * Strange functionality
 */

 var Strange = {

    /**
     * Place a sprite at every step on a path between two objects
     * 
     * @param {int} pSpriteType 
     * @param {cPosition} pFrom 
     * @param {cPosition} pTo 
     */
	PlaceSpritesOnPath: function(pSpriteType, pFrom, pTo) {
        
        Path = Map.calculatePathBetweenPositions(SpriteTypes.Player, pFrom, pTo);
        for(var count = 0; count < Path.length; ++count) {
            Map.SpriteAdd( pSpriteType, Path[count].x, Path[count].y);
        }
    },

    /**
     * Place a sprite based on an array of strings 
     * 
     * @param {number} pSpriteType 
     * @param {Array<string>} pPlacementMap 
     * @param {number} pZoomFactor 
     * @param {number} pX
     * @param {number} pY
     */
    PlaceSpritesOnCharMap: function( pSpriteType, pPlacementMap, pZoomFactor, pX, pY ) {
        pX *= 16;
        pY *= 16;
        
        // Set text
        var of_text = new Array(pPlacementMap.length * pZoomFactor);
        for (var y = 0; y <= pPlacementMap.length - 1; y++) {
            for (var i = 0; i <= pZoomFactor - 1; i++) {
                of_text[pZoomFactor * y + i] = pPlacementMap[y];
            }
        }

        for (var y = 0; y <= of_text.length - 1; y++) {
            var s = '';
            for (var x = 0; x <= of_text[0].length - 1; x++) {
                c = of_text[y].charAt(x);
                if ((x + 1) % 8 != 0) { 
                    for (var j = 0; j <= pZoomFactor - 1; j++) {
                        s = s + c; 
                    }
                } else {
                    s = s + c;
                }    
            }
            of_text[y] = s;  
        }

        // Add oppen fodder generade boxes
        for (var y = 0; y <= of_text.length - 1; y++) {
            for (var x = 0; x <= of_text[0].length - 1; x++) {
                if (of_text[y].charAt(x) == '#') {
                    Map.SpriteAdd( pSpriteType, pX + x * 8, pY + y * 8 );
                }
            }
        }
    }
};

