# Mineclone Skins

This mod allows advanced skin customization.
Use the /skin command to open the skin configuration screen.

To include custom skins in Mineclonia, please download [mcl_custom_skins](https://codeberg.org/mineclonia/mcl_custom_skins)

## License
Code under MIT license
Author: MrRar

See image_credits.txt for image licensing.

## API

### `mcl_skins.register_item(item)`
Register a skin item. `item` is a table with item properties listed below.

### Item properties

`type`
Set the item type. Valid values are: "base", "footwear", "eye", "mouth", "bottom", "top", "hair", "headwear"

`texture`
Set to the image file that will be used. If this property is omitted "blank.png" is used.

`mask`
Set the color mask texture. Coloring is only applied to non transparent areas of the texture.
Coloring only works for "base", "bottom, "top", and "hair".

`preview_rotation`
A table containing properties x and y. x and y represent the x and y rotation of the item preview.

`alex`
If set to true the item will be default for female character.

`steve`
If set to true the item will be default for male character.

`rank`
This property is used to change the application order of the skin item when applied to a player.
The default ranks for each item type are:

base: 10

footwear: 20

eye: 30

mouth: 40

bottom: 50

top: 60

hair: 70

headwear: 80

Lower ranks are applied to the player first and can thus be covered by higher rank items.


### `mcl_skins.show_formspec(player)`
Show the skin configuration screen.
`player` is a player ObjectRef.

### `mcl_skins.get_skin_list()`
This function is used by mods that want a list of skins to register nodes that use the player skin as a texture.
Returns an array of tables containing information about each skin.
Each table contains the following properties:

`id`: A string representing the node ID. A node can be registered using this node ID.

`texture`: A texture string that can be used in the node defintion.

`slim_arms`: A boolean value. If true, this texture is used with the "female" player mesh. Otherwise the regular mesh is to be used.

### `mcl_skins.get_node_id_by_player(player)`
`player` is a player ObjectRef.
Returns a string node ID based on players current skin for use by mods that want to register nodes that use the player skin.

### `mcl_skins.save(player)`
Save player skin. `player` is a player ObjectRef.

### `mcl_skins.update_player_skin(player)`
Update a player based on skin data in mcl_skins.players.
`player` is a player ObjectRef.

### `mcl_skins.base_color`
A table of ColorSpec integers that the player can select to color the base item.
These colors are separate from `mcl_skins.color` because some mods register two nodes per base color so the amount of base colors needs to be limited.

### `mcl_skins.color`
A table of ColorSpec integers that the player can select to color colorable skin items.

### `mcl_skins.player_skins`
A table mapped by player ObjectRef containing tables holding the player's selected skin items and colors.
Only stores skin information for logged in users.

### `mcl_skins.compile_skin(skin)`
`skin` is a table with skin item properties.
Returns an image string.

### `mcl_skins.register_simple_skin(skin)`
`skin` is a table with the following properties:

`texture`
The texture of the skin.

`slim_arms`
A boolean value. If set to true, the slim armed player mesh will be used with this skin.
