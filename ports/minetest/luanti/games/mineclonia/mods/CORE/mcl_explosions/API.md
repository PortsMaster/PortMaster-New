# mcl_explosions
This mod provide helper functions to create explosions.

## mcl_explosions.explode(pos, strength, info, puncher)
* pos: position, initial position of the explosion
* strenght: number, radius of the explosion
* info: table, explosion informations:
    * drop_chance: number, if specified becomes the drop chance of all nodes in the explosion (default: 1.0 / strength)
    * max_blast_resistance: int, if specified the explosion will treat all non-indestructible nodes as having a blast resistance of no more than this value
    * sound: bool, if true, the explosion will play a sound (default: true)
    * particles: bool, if true, the explosion will create particles (default: true)
    * fire: bool, if true, 1/3 nodes become fire (default: false)
    * griefing: bool, if true, the explosion will destroy nodes (default: true)
    * grief_protected: bool, if true, the explosion will also destroy nodes which have been protected (default: false)
* puncher: (optional) entity, will be used as source for damage done by the explosion