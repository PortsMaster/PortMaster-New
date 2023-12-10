Structures.Jungle.Barracks = {
    StructFindTile: [
        Terrain.Jungle.Mainland.concat(Terrain.Jungle.Borderland),
    ],

    Struct: [
        [
            [ 2, 0, 228 ],
            [ 3, 0, 127 ],
            [ 4, 0, 229 ],

            [ 1, 1, 225 ],
            [ 2, 1, 333 ],
            [ 3, 1, 334 ],
            [ 4, 1, 123 ],
            [ 5, 1, 229 ],

            [ 0, 2, 228 ],
            [ 1, 2, 352 ],
            [ 2, 2, 353 ],
            [ 3, 2, 354 ],
            [ 4, 2, 123 ],
            [ 5, 2, 49 ],

            [ 0, 3, 165 ],
            [ 1, 3, 372 ],
            [ 2, 3, 373 ],
            [ 3, 3, 374 ],
            [ 4, 3, 375 ],
            [ 5, 3, 210 ],

            [ 0, 4, 209 ],
            [ 1, 4, 392 ],
            [ 2, 4, 393 ],
            [ 3, 4, 394 ],
            [ 4, 4, 68 ],

            [ 1, 5, 209 ],
            [ 2, 5, 47 ],
            [ 3, 5, 210 ]
        ]
    ],

    
    Types: {
        "soldier": [
            [ 28, 34, SpriteTypes.BuildingRoof ],
            [ 24, 65, SpriteTypes.BuildingDoor ]
        ]
    }

};

Structures.Desert.Barracks = {
    StructFindTile: [
        Terrain.Desert.Mainland,
    ],

    Struct: [
        [
            [0, 0, 196],
            [1, 0, 197],
            [2, 0, 198],

            [0, 1, 216],
            [1, 1, 217],
            [2, 1, 218],
            
            [0, 2, 236],
            [1, 2, 237],
            [2, 2, 238]
        ]
    ],

    
    Types: {
        "soldier": [
            [ 12, -15, SpriteTypes.BuildingRoof ],
            [ 7, 16, SpriteTypes.BuildingDoor ]
        ]
    }

};

Structures.Ice.Barracks = {
    StructFindTile: [
        Terrain.Ice.Mainland,
    ],
    Struct: [
        [
            [1, 0, 245],
            [2, 0, 246],
            [3, 0, 247],

            [0, 1, 264],
            [1, 1, 265],
            [2, 1, 266],
            [3, 1, 267],

            [0, 2, 284],
            [1, 2, 285],
            [2, 2, 286],
            [3, 2, 287]
        ]
    ],

    
    Types: {
        "soldier": [
            [ 23, 12, SpriteTypes.BuildingRoof ],
            [ 19, 42, SpriteTypes.BuildingDoor ]
        ]
    }

};


Structures.Moors.Barracks = {
    StructFindTile: [
        Terrain.Moors.Mainland,
    ],
    Struct: [
        [
            [1, 0, 335],
            [2, 0, 336],

            [0, 1, 354],
            [1, 1, 355],
            [2, 1, 356],

            [0, 2, 374],
            [1, 2, 375],
            [2, 2, 376],
            
            [0, 3, 394],
            [1, 3, 395],
            [2, 3, 396]
        ]
    ],

    
    Types: {
        "soldier": [
            [ 15, 1, SpriteTypes.BuildingRoof ],
            [ 7, 33, SpriteTypes.BuildingDoor ]
        ]
    }

};

Structures.Interior.Barracks = {
    StructFindTile: [
        Terrain.Interior.Mainland,
    ],

    Struct: [
        [
            [0, 0, 246],
            [0, 1, 266]
        ]
    ],

    
    Types: {
        "soldier": [
            [ 3, 5, SpriteTypes.BuildingDoor ]
        ]
    }

};
