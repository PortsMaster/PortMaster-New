# mcl_boats
This mod add an API for drivable boats.

mcl_boats.register_boat(name,item_overrides,object_properties,entity_overrides)
	name - name (usually the type of wood) of the boat type, if the name contains the string "chest" it will be assumed to be a chest boat and an mcl_entity_inv will be attached to it.
	item_overrides - fields in this table if supplied will be applied to the boat's craftitem
	object_properties - fields in this table if supplied will be applied to the spawned boat object as object properties
	entity_overrides - fields in this table if supplied will be applied to the luaentity of the spawned boat object

# Credits
## Mesh
Boat mesh (`models/mcl_boats_boat.b3d`) created by 22i.
Source: https://github.com/22i/minecraft-voxel-blender-models

License of boat model:
GNU GPLv3 <https://www.gnu.org/licenses/gpl-3.0.html>

## Textures
See the main MineClone 2 README.md file to learn more.

## Code
Code based on Minetest Game, licensed under the MIT License (MIT).

Authors include:
* PilzAdam (2012-2016)
* Various Minetest / Minetest Game developers and contributors (2012-2016)
* maikerumine (2017)
* Wuzzy (2017)
* Fleckenstein (2020-2021)
* cora (2023)
