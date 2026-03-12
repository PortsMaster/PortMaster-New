# mcl_bells

Village bells for Mineclonia, originally imported from mcl5, heavily modified by cora.

## License of media files

* sounds/bell_stroke.ogg - cc0 http://creativecommons.org/publicdomain/zero/1.0/
	* created by edsward
	* modified by sorcerykid
	* obtained from https://freesound.org/people/edsward/sounds/341866/

* textures/mcl_bells_bell.png - cc4-by-sa https://creativecommons.org/licenses/by-sa/4.0/
	* from pixelperfection by XSSheep and NovaWostra ( https://www.planetminecraft.com/texture-pack/pixel-perfection-chorus-edit/ )
	
* textures/mcl_bells_bell_*.png - cc0 http://creativecommons.org/publicdomain/zero/1.0/
	* created by cora

* models/mcl_bells_bell.bbmodel - cc4-by-sa https://creativecommons.org/licenses/by-sa/4.0/
	* created by Codiac

## Exporting glTF Files

1. Load bbmodel in Blockbench
1. Go to the OUTLINER area (default lower right side of screen)
1. Ensure the "TOGGLE MORE OPTIONS" icon is on (F4)
1. For all glTF exports you need to ensure
	1. Encoding is ASCII
	1. Model Export Scale is 1.6
	1. Embed Textures in unchecked
	1. Export Groups as Armature is unchecked
	1. Export Animations is checked
1. For ground model
	1. Ensure all of the Export check boxes are checked
	1. Menu->File->Export->Export glTF Model
	1. Set filename to mcl_bells_bell_ground.gltf
1. For wall model
	1. Uncheck the Export check boxes for the "front" and "back" meshes in the frame section
	1. Menu->File->Export->Export glTF Model
	1. Set filename to mcl_bells_bell_wall.gltf
1. For ceiling model
	1. Uncheck the Export check box for the frame section
	1. Menu->File->Export->Export glTF Model
	1. Set filename to mcl_bells_bell_ceiling.gltf
